FROM jupyter/scipy-notebook

USER root

# Jenkins
RUN apt-get update && apt-get install -yq supervisor gnupg curl \
    && sh -c 'wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -' \
    && sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
       /etc/apt/sources.list.d/jenkins.list' \
    && apt-get update && apt-get install -yq openjdk-8-jdk jenkins \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Scripts
COPY . /tmp/resource

RUN mkdir -p /usr/local/bin/before-notebook.d && \
    cp /tmp/resource/conf/onboot/* /usr/local/bin/before-notebook.d/ && \
    chmod +x /usr/local/bin/before-notebook.d/*
RUN cp -fr /tmp/resource/conf/supervisor /opt/
RUN mv /opt/conda/bin/jupyterhub-singleuser /opt/conda/bin/_jupyterhub-singleuser && \
    mv /opt/conda/bin/jupyter-notebook /opt/conda/bin/_jupyter-notebook && \
    cp /tmp/resource/conf/bin/* /opt/conda/bin/ && \
    chmod +x /opt/conda/bin/jupyterhub-singleuser /opt/conda/bin/jupyter-notebook

USER $NB_USER
