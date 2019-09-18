#!/bin/bash -xe

# This is primarily for go-agent, if/when it requires lavacli to inject
# test-jobs into a Lava test infrastructure.

# Update this version as needed...
LAVACLI_URL=https://files.pythonhosted.org/packages/b1/e4/958e3c2b027e0ff6efbc2f135d893baa848755e486d284bcaf88ac574417/lavacli-0.9.6.tar.gz
LAVACLI_DIR=$(basename "$LAVACLI_URL" | sed 's/.tar.gz//')

# This step requires python 3 of course, and the setuptools package... and
# possibly some other python deps
LAVACLI_FILE="$(basename "$LAVACLI_URL")"
LAVACLI_DIR="$(echo "$LAVACLI_FILE" | sed 's/.tar.gz//')"

curl -O -J -L "$LAVACLI_URL"
tar xf "$LAVACLI_FILE"

sudo apt-get install -y python3-setuptools
sudo pip3 install --upgrade pip
sudo pip install pyzmq PyYaml jinja2 setuptools

cd "$LAVACLI_DIR"
sudo python3 setup.py install

echo Testing lavacli:
echo
lavacli --version
