#!/bin/bash

if [ ! -d /home/jovyan/example ]; then
  mkdir -p /home/jovyan/example
  chown jovyan /home/jovyan/example
  cp -p /tmp/resource/*.ipynb /home/jovyan/example/
  cp -p /tmp/resource/*.md /home/jovyan/example/
  cp -pfr /tmp/resource/images /home/jovyan/example/
fi
