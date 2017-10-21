#!/usr/bin/env bash

curl -LOk https://github.com/dotnet/cli/archive/v2.0.2.zip && \
  mv -v v2.0.2.zip cli-2.0.2.zip && \
  unzip cli-2.0.2.zip

curl -LOk https://dotnetcli.azureedge.net/dotnet/Sdk/2.0.3-servicing-007037/dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz && \
  mv -v ./dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz cli-2.0.2/
