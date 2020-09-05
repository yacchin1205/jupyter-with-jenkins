#!/bin/bash

set -xe

export JENKINS_SERVICE_PREFIX=${JUPYTERHUB_SERVICE_PREFIX:-/}

supervisord -c /opt/supervisor/supervisor.conf

export SUPERVISOR_INITIALIZED=1
