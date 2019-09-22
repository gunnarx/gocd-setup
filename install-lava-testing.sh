#!/bin/bash -xe

# This is primarily for go-agent, if/when it requires lavacli to inject
# test-jobs into a Lava test infrastructure.

# Update this version as needed...
# This step requires python 3 of course, and the setuptools package... and
# possibly some other python deps
LAVACLI_URL=https://files.pythonhosted.org/packages/82/b3/2de414b62995b1e2084cdd0f3d978c3a4df8dc46e436fa23f9a820c5990b/lavacli-0.9.8.tar.gz
LAVACLI_FILE="$(basename "$LAVACLI_URL")"
LAVACLI_DIR="$(echo "$LAVACLI_FILE" | sed 's/.tar.gz//')"

curl -O -J -L "$LAVACLI_URL"
tar xf "$LAVACLI_FILE"

sudo apt-get install -y python3-setuptools python3-pip
sudo pip3 install --upgrade pip
sudo pip3 install pyzmq PyYaml jinja2 setuptools

cd "$LAVACLI_DIR"
sudo python3 setup.py install

echo Testing lavacli:
echo
lavacli --version
