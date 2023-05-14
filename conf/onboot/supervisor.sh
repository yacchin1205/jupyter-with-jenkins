#!/bin/bash

set -xe

export JENKINS_SERVICE_PREFIX=${JUPYTERHUB_SERVICE_PREFIX:-/}

if [ "$EUID" -eq 0 ]; then
    cp -f /opt/supervisor/jenkins-root.conf /opt/supervisor/conf.d/jenkins.conf
fi
supervisord -c /opt/supervisor/supervisor.conf

export SUPERVISOR_INITIALIZED=1
