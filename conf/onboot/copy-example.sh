#!/bin/bash

if [ ! -d ${HOME}/example ]; then
  mkdir -p ${HOME}/example
  cp /tmp/resource/*.ipynb ${HOME}/example/
  cp /tmp/resource/*.md ${HOME}/example/
  cp -fr /tmp/resource/images ${HOME}/example/
  chown ${NB_USER} -R ${HOME}/example
fi
