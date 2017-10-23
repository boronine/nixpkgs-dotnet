{ stdenv
, fetchFromGitHub
, fetchurl
# , which
# , cmake
# , clang
# , llvmPackages
, libunwind
# , gettext
, openssl
# , python2
, icu
# , lttng-ust
# , liburcu
, libuuid
# , libkrb5
, patchelf
# , debug ? false
}:

let
  # available SDKs: https://github.com/dotnet/core/blob/master/release-notes/download-archive.md
  # sdk107 = fetchurl {
  #   url = "https://download.microsoft.com/download/B/0/D/B0D6D983-3188-4008-A852-94BCED5355E6/dotnet-ubuntu.16.04-x64.1.0.7.tar.gz";
  #   sha256 = "0n3nfpwmws4fkpgrh17hh9f7yjbb31qlffp9y8m94s3x672wa4jb";
  # };
  sdk203 = fetchurl {
    url = "https://dotnetcli.azureedge.net/dotnet/Sdk/2.0.3-servicing-007037/dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz";
    sha256 = "0kqk1f0vfdfyb9mp7d4y83airkxyixmxb7lrx0h0hym2a9661ch8";
  };
  rpath = "${stdenv.cc.cc.lib}/lib64:${libunwind}/lib:${libuuid.out}/lib:${icu}/lib:${openssl.out}/lib";
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

    # buildInputs = [
    #   which
    #   cmake
    #   clang
    #   llvmPackages.llvm
    #   llvmPackages.lldb
    #   libunwind
    #   gettext
    #   openssl
    #   python2
    #   icu
    #   lttng-ust
    #   liburcu
    #   libuuid
    #   libkrb5
    # ];

    configurePhase = ''
      patchShebangs .
    '';

    # BuildArch = if stdenv.is64bit then "x64" else "x86";
    # BuildType = if debug then "Debug" else "Release";

    # hardeningDisable = [
    #   "strictoverflow"
    #   "format"
    # ];

    # ./build.sh
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
      .dotnet_stage0/x64/dotnet restore /p:GeneratePropsFile=true --disable-parallel
      runHook postBuild
    '';

    # installPhase = ''
    #   runHook preInstall
    #   mkdir -p $out/share/dotnet $out/bin
    #   cp -r bin/Product/Linux.$BuildArch.$BuildType/* $out/share/dotnet
    #   for cmd in coreconsole corerun createdump crossgen ilasm ildasm mcs superpmi; do
    #     ln -s $out/share/dotnet/$cmd $out/bin/$cmd
    #   done
    #   runHook postInstall
    # '';

    meta = with stdenv.lib; {
      homepage = http://dotnet.github.io/core/;
      description = ".NET is a general purpose development platform";
      platforms = [ "x86_64-linux" ];
      maintainers = with maintainers; [ kuznero ];
      license = licenses.mit;
    };
  }
