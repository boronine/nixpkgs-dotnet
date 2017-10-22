#!/usr/bin/env bash

curl -LOk https://github.com/dotnet/cli/archive/v2.0.2.zip && \
  mv -v v2.0.2.zip cli-2.0.2.zip && \
  unzip cli-2.0.2.zip

# curl -LOk https://download.microsoft.com/download/B/0/D/B0D6D983-3188-4008-A852-94BCED5355E6/dotnet-ubuntu.16.04-x64.1.0.7.tar.gz && \
#   mv -v ./dotnet-ubuntu.16.04-x64.1.0.7.tar.gz cli-2.0.2/

curl -LOk https://dotnetcli.azureedge.net/dotnet/Sdk/2.0.3-servicing-007037/dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz && \
  mv -v ./dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz cli-2.0.2/
