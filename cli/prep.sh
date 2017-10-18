#!/usr/bin/env bash

curl -LOk https://github.com/dotnet/cli/archive/v2.0.2.zip && \
  mv -v v2.0.2.zip cli-2.0.2.zip && \
  unzip cli-2.0.2.zip
