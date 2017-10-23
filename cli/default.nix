{ stdenv
, fetchFromGitHub
, fetchurl
, libunwind
, openssl
, icu
, libuuid
, zlib
, curl
, patchelf
, mktemp
}:

let
  sdk203 = fetchurl {
    url = "https://dotnetcli.azureedge.net/dotnet/Sdk/2.0.3-servicing-007037/dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz";
    sha256 = "0kqk1f0vfdfyb9mp7d4y83airkxyixmxb7lrx0h0hym2a9661ch8";
  };
  rpath = "${stdenv.cc.cc.lib}/lib64:${libunwind}/lib:${libuuid.out}/lib:${icu}/lib:${openssl.out}/lib:${zlib}/lib:${curl.out}/lib";
in
  stdenv.mkDerivation rec {
    name = "cli-${version}";
    version = "2.0.2";

    src = fetchFromGitHub {
      owner  = "dotnet";
      repo   = "cli";
      rev    = "v${version}";
      sha256 = "0m7lqyrpqxd8s9g6cxnashnzjyraclybpcjlzanrhcrj1xv3rbyr";
    };

    patchPhase = ''
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
    '';

    configurePhase = ''
      patchShebangs .
    '';

    buildPhase = ''
      runHook preBuild
      cp -v ${sdk203} ./dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz
      mkdir -p .dotnet_stage0/x64/
      tar -xf ./dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz -C .dotnet_stage0/x64/
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" .dotnet_stage0/x64/dotnet
      patchelf --set-rpath "${rpath}" .dotnet_stage0/x64/dotnet
      find -type f -name "*.so" -exec patchelf --set-rpath "${rpath}" {} \;
      echo -n "dotnet-sdk version: "
      .dotnet_stage0/x64/dotnet --version
      ./build.sh /t:Compile
      runHook postBuild
    '';

    meta = with stdenv.lib; {
      homepage = http://dotnet.github.io/core/;
      description = ".NET is a general purpose development platform";
      platforms = [ "x86_64-linux" ];
      maintainers = with maintainers; [ kuznero ];
      license = licenses.mit;
    };
  }
