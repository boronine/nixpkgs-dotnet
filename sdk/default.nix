{ stdenv
, libunwind
, openssl
, icu
, libuuid
, zlib
, curl
, patchelf
}:

let
  rpath = "${stdenv.cc.cc.lib}/lib64:${libunwind}/lib:${libuuid.out}/lib:${icu}/lib:${openssl.out}/lib:${zlib}/lib:${curl.out}/lib";
in
  stdenv.mkDerivation rec {
    name = "dotnet-sdk-${version}";
    version = "2.0.3";
    src = fetchTarball "https://dotnetcli.azureedge.net/dotnet/Sdk/2.0.3-servicing-007037/dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz";

    buildPhase = ''
      runHook preBuild
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" ./dotnet
      patchelf --set-rpath "${rpath}" ./dotnet
      find -type f -name "*.so" -exec patchelf --set-rpath "${rpath}" {} \;
      echo -n "dotnet-sdk version: "
      ./dotnet --version
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp -r ./ $out
      ln -s $out/dotnet $out/bin/dotnet
      runHook postInstall
    '';

    meta = with stdenv.lib; {
      homepage = http://dotnet.github.io/core/;
      description = ".NET is a general purpose development platform";
      platforms = [ "x86_64-linux" ];
      maintainers = with maintainers; [ kuznero ];
      license = licenses.mit;
    };
  }
