#!/usr/bin/env bash
cd "$(dirname "$0")/repos/kcov"

cmake -G Xcode \
  -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl \
  -DOPENSSL_LIBRARIES=/usr/local/opt/openssl/lib \
  .
xcodebuild -target kcov -configuration Release
