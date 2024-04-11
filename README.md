# docker-bitcoind-librerelay

A simple Docker image for the LibreRelay fork of bitcoind by @petertodd.

## What is LibreRelay?

LibreRelay is a fork of Bitcoin Core maintained by @petertodd that enables three things:

1. Removes the OP_Return limits.
2. Connects to an additional four Libre Relay nodes, to ensure transactions propagate.
3. Implements pure replace-by-fee-rate (RBFR) and full-rbf, to solve Rule #3 transaction pinning.

For more info on LibreRelay, see the following three resources:

- [Peter Todd on X](https://twitter.com/peterktodd/status/1750019647586320440)
- [Bitcoin mailing list explanation](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022308.html)
- [LibreRelay fork repo](https://github.com/petertodd/bitcoin)

## Credit

- LibreRelay is created and maintained by @petertodd: https://github.com/petertodd/bitcoin/tree/libre-relay-v27.0rc1
- The Docker image is a frankenstein compilation of 4 images:
  - Base image and scripts: https://github.com/kylemanna/docker-bitcoind
  - Improved image and Github Actions: https://github.com/sethforprivacy/docker-bitcoind
  - Pieces pulled for bitcoind build process:https://github.com/lncm/docker-bitcoind
  - Pieces pulled for bitcoind build process: https://github.com/jamesob/docker-bitcoind/tree/master
