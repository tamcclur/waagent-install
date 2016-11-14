#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

if ! type "pip" > /dev/null; then
  echo "pip not installed, please install python-pip"
fi

pip list | grep setuptools > /dev/null 2>&1
if [ $? -eq 1 ]; then
  echo "Python setuptools not found, please install setuptools"
  echo "pip install setuptools"
fi

mkdir -p /tmp/WALinuxAgent

# Installing latest release from the github API
echo "Downloading waagent from github."
wget -O /tmp/WALinuxAgent.tar.gz `curl -s https://api.github.com/repos/Azure/WALinuxAgent/releases | grep tarball_url | head -n 1 | cut -d '"' -f 4`
tar xzf /tmp/WALinuxAgent.tar.gz -C /tmp/WALinuxAgent
echo "Installing waagent"
python /tmp/WALinuxAgent/`ls /tmp/WALinuxAgent`/setup.py install --force
sleep 0.5

echo "Installation done, restarting waagent."
if ! type "systemctl"; then
  service walinuxagent restart
  sleep 0.5
else
  systemctl daemon-reload && systemctl restart waagent
  sleep 0.5
fi

# Cleanup
rm -rf /tmp/WALinuxAgent /tmp/WALinuxAgent.tar.gz

# Check if running
waagent --version
if [ $? -eq 1 ]; then
  echo "waagent is not running, something bad happened."
fi
