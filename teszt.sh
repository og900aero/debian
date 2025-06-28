#!/bin/bash

# log all commands
exec > >(tee -a "output.log") 2>&1

set +x

# Install Oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

set -x
