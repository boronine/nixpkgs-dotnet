{ stdenv
, fetchFromGitHub
, fetchurl
# , which
# , cmake
# , clang
# , llvmPackages
, libunwind
# , gettext
# , openssl
# , python2
# , icu
# , lttng-ust
# , liburcu
# , libuuid
# , libkrb5
# , debug ? false
}:

let
  sdk = fetchurl {
    url = "https://dotnetcli.azureedge.net/dotnet/Sdk/2.0.3-servicing-007037/dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz";
    sha256 = "0kqk1f0vfdfyb9mp7d4y83airkxyixmxb7lrx0h0hym2a9661ch8";
  };
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
      # override to avoid cmake running
      patchShebangs .
    '';

    # BuildArch = if stdenv.is64bit then "x64" else "x86";
    # BuildType = if debug then "Debug" else "Release";

    # hardeningDisable = [
    #   "strictoverflow"
    #   "format"
    # ];

    # 'cp "${fetchurl {...}}" src/foobar.tar.gz'
    # https://dotnetcli.azureedge.net/dotnet/Sdk/2.0.3-servicing-007037/dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz

    buildPhase = ''
      runHook preBuild
      cp -v ${sdk} dotnet-sdk-2.0.3-servicing-007037-linux-x64.tar.gz
      ls -lah
      ./build.sh --dry-run
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
