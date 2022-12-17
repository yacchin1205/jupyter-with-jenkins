FROM niicloudoperation/notebook:latest

USER root

# Jenkins, Tinyproxy and Supervisor
RUN apt-get update && apt-get install -yq supervisor tinyproxy gnupg curl ca-certificates \
    && sh -c 'wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
       /usr/share/keyrings/jenkins-keyring.asc > /dev/null' \
    && sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ > \
       /etc/apt/sources.list.d/jenkins.list' \
    && apt-get update && apt-get install -yq openjdk-8-jdk jenkins \
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

# ChromeDriver
RUN cd /usr/local/sbin/ && \
    export CHROME_MAJOR_VERSION=$(dpkg -s google-chrome-stable | grep Version | sed -r 's/Version: ([0-9]+)\.[0-9\.]+-[0-9]*/\1/') && \
    export CHROMEDRIVER_VERSION=$(curl https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION}) && \
    wget https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    chmod +x chromedriver && \
    rm chromedriver_linux64.zip

RUN pip --no-cache-dir install selenium

# AWSCLI
RUN conda install --quiet --yes awscli passlib && conda clean --all -f -y

COPY . /tmp/resource

# Scripts for Jenkins/Supervisor
RUN mkdir -p /usr/local/bin/before-notebook.d && \
    cp /tmp/resource/conf/onboot/* /usr/local/bin/before-notebook.d/ && \
    chmod +x /usr/local/bin/before-notebook.d/* && \
    cp -fr /tmp/resource/conf/supervisor /opt/

# Boot scripts to perform /usr/local/bin/before-notebook.d/* on JupyterHub
RUN mkdir -p /opt/jupyter-with-jenkins/original/bin/ && \
    mv /opt/conda/bin/jupyterhub-singleuser /opt/jupyter-with-jenkins/original/bin/jupyterhub-singleuser && \
    mv /opt/conda/bin/jupyter-notebook /opt/jupyter-with-jenkins/original/bin/jupyter-notebook && \
    cp /tmp/resource/conf/bin/* /opt/conda/bin/ && \
    chmod +x /opt/conda/bin/jupyterhub-singleuser /opt/conda/bin/jupyter-notebook

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
