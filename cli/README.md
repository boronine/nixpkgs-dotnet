# Nix sandbox for .NET Core CLR package

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
> "${stdenv.cc.cc.lib}/lib64:${libunwind}/lib:${libuuid.out}/lib:${icu}/lib:${openssl.out}/lib"
```

This will output expanded paths, just copy it and use instead of `[RPATH]`
below (don't forget to exit `nix-repl` before proceeding):

/nix/store/y5ac95kk3nb52si8zcyznjrfb45720hk-gcc-6.4.0-lib/lib64:/nix/store/0p1vqwbbifw15ax18sppq908087ci64m-libunwind-1.2.1/lib:/nix/store/91103425ih24fkgsk7sga6pwmbayk2r1-util-linux-2.30/lib:/nix/store/m0gq3gxdnvirpsry48zvvqpcxyjz4w8k-icu4c-58.2/lib:/nix/store/ybajdccj1h5xssna16h6vv3qqda6m7l4-openssl-1.0.2l/lib

```bash
patchelf --set-rpath "[RPATH]" .dotnet_stage0/x64/dotnet
find -type f -name "*.so" -exec patchelf --set-rpath "[RPATH]" {} \;
echo -n "dotnet-sdk version: "
.dotnet_stage0/x64/dotnet --version
./build.sh
```
