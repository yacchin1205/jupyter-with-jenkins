FROM jupyter/scipy-notebook

USER root

# Jenkins, Tinyproxy and Supervisor
RUN apt-get update && apt-get install -yq supervisor tinyproxy gnupg curl \
    && sh -c 'wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -' \
    && sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
       /etc/apt/sources.list.d/jenkins.list' \
    && apt-get update && apt-get install -yq openjdk-8-jdk jenkins \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Server Proxy
RUN pip install jupyter-server-proxy && \
    jupyter serverextension enable --sys-prefix jupyter_server_proxy

COPY . /tmp/resource

# Scripts for Jenkins/Supervisor
RUN mkdir -p /usr/local/bin/before-notebook.d && \
    cp /tmp/resource/conf/onboot/* /usr/local/bin/before-notebook.d/ && \
    chmod +x /usr/local/bin/before-notebook.d/* && \
    cp -fr /tmp/resource/conf/supervisor /opt/

# Boot scripts to perform /usr/local/bin/before-notebook.d/* on JupyterHub
RUN mv /opt/conda/bin/jupyterhub-singleuser /opt/conda/bin/_jupyterhub-singleuser && \
    mv /opt/conda/bin/jupyter-notebook /opt/conda/bin/_jupyter-notebook && \
    cp /tmp/resource/conf/bin/* /opt/conda/bin/ && \
    chmod +x /opt/conda/bin/jupyterhub-singleuser /opt/conda/bin/jupyter-notebook

# Configuration for Server Proxy
RUN cat /tmp/resource/conf/jupyter_notebook_config.py >> $CONDA_DIR/etc/jupyter/jupyter_notebook_config.py

USER $NB_USER
