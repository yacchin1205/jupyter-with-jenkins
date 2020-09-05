#!/bin/bash

set -xe

supervisord -c /opt/supervisor/supervisor.conf

export SUPERVISOR_INITIALIZED=1
