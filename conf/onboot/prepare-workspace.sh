#!/bin/bash

if [ ! -d ${HOME}/jenkins-workspace ]; then
  ln -s ${HOME}/.jenkins/workspace ${HOME}/jenkins-workspace
fi
