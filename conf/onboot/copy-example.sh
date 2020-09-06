#!/bin/bash

if [ ! -d /home/jovyan/example ]; then
  mkdir -p /home/jovyan/example
  chown jovyan /home/jovyan/example
  cp -p /tmp/resource/*.ipynb /home/jovyan/example/
fi
