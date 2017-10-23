# Nix sandbox for .NET Core CLR package

## Build

```bash
nix-build shell.nix
```

## Troubleshooting

```bash
./prep.sh
nix-shell
cd coreclr-2.0.0
patchShebangs .
substituteInPlace scripts/obtain/dotnet-install.sh \
  --replace '[ -z "$($LDCONFIG_COMMAND' '# [ -z "$($LDCONFIG_COMMAND'
substituteInPlace scripts/obtain/dotnet-install.sh \
  --replace 'local hasMinimum=false' 'local hasMinimum=true'
substituteInPlace scripts/obtain/dotnet-install.sh \
  --replace 'zip_path=$(mktemp $temporary_file_template)' "zip_path=$(pwd)/dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz"
substituteInPlace scripts/obtain/dotnet-install.sh \
  --replace 'download "$download_link" $zip_path' '# download "$download_link" $zip_path'
substituteInPlace scripts/obtain/dotnet-install.sh \
  --replace 'extract_dotnet_package $zip_path $install_root' '# extract_dotnet_package $zip_path $install_root'
mkdir -p .dotnet_stage0/x64/
tar -xf ./dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz -C .dotnet_stage0/x64/
patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" .dotnet_stage0/x64/dotnet
```

Now, configure `RPATH`. But first let's figure out what is the value of required
`RPATH`:

```bash
nix-repl '<nixpkgs>'
> "${stdenv.cc.cc.lib}/lib64:${libunwind}/lib:${libuuid.out}/lib:${icu}/lib:${openssl.out}/lib:${zlib}/lib"
```

This will output expanded paths, just copy it and use instead of `[RPATH]`
below (don't forget to exit `nix-repl` before proceeding):

```bash
patchelf --set-rpath "[RPATH]" .dotnet_stage0/x64/dotnet
find -type f -name "*.so" -exec patchelf --set-rpath "[RPATH]" {} \;
echo -n "dotnet-sdk version: "
.dotnet_stage0/x64/dotnet --version
./build.sh
```
