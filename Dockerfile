FROM niicloudoperation/notebook:latest

USER root

# Jenkins, Tinyproxy and Supervisor
RUN apt-get update && apt-get install -yq supervisor tinyproxy gnupg curl ca-certificates \
    && sh -c 'wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
       /usr/share/keyrings/jenkins-keyring.asc > /dev/null' \
    && sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ > \
       /etc/apt/sources.list.d/jenkins.list' \
    && apt-get update && apt-get install -yq openjdk-11-jdk jenkins \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Server Proxy and papermill
RUN pip --no-cache-dir install jupyter-server-proxy papermill && \
    jupyter serverextension enable --sys-prefix jupyter_server_proxy

# Selenium
# Xvfb + Chrome
RUN sh -c 'wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' \
    && sh -c 'echo deb http://dl.google.com/linux/chrome/deb/ stable main >> \
       /etc/apt/sources.list.d/google.list' \
    && apt-get update && apt-get install -y xvfb google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

COPY . /tmp/resource

# ChromeDriver
RUN cd /usr/local/sbin/ && \
    dpkg -s google-chrome-stable | grep Version && \
    export CHROME_MAJOR_VERSION=$(dpkg -s google-chrome-stable | grep Version | sed -r 's/Version: ([0-9]+\.[0-9\.]+)-[0-9]*/\1/') && \
    echo CHROME_MAJOR_VERSION=${CHROME_MAJOR_VERSION} && \
    wget -O /tmp/resource/chromedriver-linux64.zip $(python3 /tmp/resource/util/resolve-chromedriver-url.py --chrome-version ${CHROME_MAJOR_VERSION} --platform linux64) && \
    unzip /tmp/resource/chromedriver-linux64.zip && \
    chmod +x chromedriver-linux64/chromedriver && \
    ln -s /usr/local/sbin/chromedriver-linux64/chromedriver /usr/local/sbin/chromedriver && \
    rm /tmp/resource/chromedriver-linux64.zip

RUN pip --no-cache-dir install selenium

# AWSCLI
RUN mamba install --quiet --yes awscli passlib && mamba clean --all -f -y

# Scripts for Jenkins/Supervisor
RUN mkdir -p /usr/local/bin/before-notebook.d && \
    cp /tmp/resource/conf/onboot/* /usr/local/bin/before-notebook.d/ && \
    chmod +x /usr/local/bin/before-notebook.d/* && \
    cp -fr /tmp/resource/conf/supervisor /opt/

# Boot scripts to perform /usr/local/bin/before-notebook.d/* on JupyterHub
RUN mkdir -p /opt/jupyter-with-jenkins/original/bin/ && \
    mkdir -p /opt/jupyter-with-jenkins/bin/ && \
    mv /opt/conda/bin/jupyterhub-singleuser /opt/jupyter-with-jenkins/original/bin/jupyterhub-singleuser && \
    mv /opt/conda/bin/jupyter-notebook /opt/jupyter-with-jenkins/original/bin/jupyter-notebook && \
    mv /opt/conda/bin/jupyter-lab /opt/jupyter-with-jenkins/original/bin/jupyter-lab && \
    cp /tmp/resource/conf/bin/jupyter* /opt/conda/bin/ && \
    cp /tmp/resource/conf/bin/*.sh /opt/jupyter-with-jenkins/bin/ && \
    chmod +x /opt/conda/bin/jupyterhub-singleuser /opt/conda/bin/jupyter-notebook /opt/conda/bin/jupyter-lab \
        /opt/jupyter-with-jenkins/bin/*

# Configuration for Server Proxy
RUN cat /tmp/resource/conf/jupyter_notebook_config.py >> $CONDA_DIR/etc/jupyter/jupyter_notebook_config.py
RUN chown $NB_USER /tmp/resource/*.ipynb

USER $NB_USER

# Replace contents
RUN rm /home/$NB_USER/*.ipynb /home/$NB_USER/*.md && \
    rm -fr /home/$NB_USER/images /home/$NB_USER/resources && \
    cp /tmp/resource/*.md /home/$NB_USER/ && \
    cp /tmp/resource/*.ipynb /home/$NB_USER/ && \
    cp -fr /tmp/resource/images /home/$NB_USER/
