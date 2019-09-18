#!/bin/bash -xe

# This is primarily for go-agent, if/when it requires lavacli to inject
# test-jobs into a Lava test infrastructure.

# Update this version as needed...
LAVACLI_URL=https://files.pythonhosted.org/packages/b1/e4/958e3c2b027e0ff6efbc2f135d893baa848755e486d284bcaf88ac574417/lavacli-0.9.6.tar.gz
LAVACLI_DIR=$(basename "$LAVACLI_URL" | sed 's/.tar.gz//')

wget -c "$LAVACLI_URL"
tar xf "$(basename "$LAVACLI_URL")"
cd "$LAVACLI_DIR"

# This step requires python 3 of course, and the setuptools package... and
# possibly some other python deps
sudo python3 setup.py install

echo Testing lavacli:
echo
lavacli --version
