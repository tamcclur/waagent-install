#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

if ! type "pip" > /dev/null; then
  echo "pip not installed, please install python-pip"
fi

if ! type "git" > /dev/null; then
  echo "giit not installed, please install git"
fi

pip list | grep setuptools > /dev/null 2>&1
if [ $? -eq 1 ]; then
  echo "Python setuptools not found, please install setuptools"
  echo "pip install setuptools"
fi

echo "Downloading waagent from github."
git clone https://github.com/Azure/WALinuxAgent.git /tmp/WALinuxAgent

echo "Installing waagent"
python /tmp/WALinuxAgent/setup.py install --force
sleep 0.5

echo "Installation done, restarting waagent."
if ! type "systemctl"; then
  service walinuxagent restart
  sleep 0.5
else
  systemctl daemon-reload && systemctl restart waagent
  sleep 0.5
  exit 0
fi
  
# Check if running
waagent --version
if [ $? -eq 1 ]; then
  echo "waagent is not running, something bad happened."
fi
