#!/usr/bin/env bash

curl -LOk https://github.com/dotnet/coreclr/archive/v2.0.0.zip  && \
  mv -v v2.0.0.zip coreclr-2.0.0.zip && \
  unzip coreclr-2.0.0.zip
