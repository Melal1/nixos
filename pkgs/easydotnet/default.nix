{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  dotnet-sdk_10,
}:

let
  version = "3.4.25";
in
stdenv.mkDerivation {
  pname = "easydotnet";
  inherit version;

  # NuGet flat-container URL: stable, no redirect, fetchurl-friendly.
  src = fetchurl {
    url = "https://api.nuget.org/v3-flatcontainer/easydotnet/${version}/easydotnet.${version}.nupkg";
    sha256 = "sha256-RburiBDwtkNcTmzce2HHY1HJWdoOFx9x692PBd2VD9Y=";
  };

  # A .nupkg is a zip; native ELFs inside (netcoredbg, libdbgshim.so) need patching.
  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
  ];

  # Provides libstdc++ etc. for the bundled native binaries, and the dotnet
  # runtime used to launch the managed entry point via a wrapper.
  buildInputs = [
    dotnet-sdk_10
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    unzip -q $src -d nupkg
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/easydotnet
    cp -r nupkg/tools $out/lib/easydotnet/tools

    # The nupkg ships native payloads for every RID (musl-x64, arm/arm64, osx,
    # win). autoPatchelfHook would try to patch all of them and fail on the
    # musl/foreign-arch ones. Trim everything we can't run on x86_64-glibc so
    # only linux-x64 payloads remain; the tool picks its RID at runtime and
    # will find linux-x64 just fine.
    for d in tools/netcoredbg tools/dncdbg tools/sharpdbg/runtimes; do
      if [ -d $out/lib/easydotnet/$d ]; then
        find $out/lib/easydotnet/$d -mindepth 1 -maxdepth 1 -type d \
          ! -name 'linux-x64' -exec rm -rf {} +
      fi
    done

    # nupkg stores every file 0444; autoPatchelfHook rewrites RPATHs but does
    # not restore exec bits on bundled native ELF launchers. chmod them so the
    # tool can spawn netcoredbg / the AppWrapper / Aspire apphosts.
    find $out/lib/easydotnet/tools -type f \
      \( -name 'netcoredbg' \
         -o -name 'EasyDotnet.AppWrapper' \
         -o -name 'EasyDotnet.Aspire' \
      \) \
      -exec chmod +x {} +

    # Resolve the managed entry DLL (EasyDotnet.IDE.dll declared in DotnetToolSettings.xml).
    entryDll=$(find $out/lib/easydotnet/tools -name 'EasyDotnet.IDE.dll' -print -quit)
    if [ -z "$entryDll" ]; then
      echo "easydotnet: could not locate EasyDotnet.IDE.dll under tools/" >&2
      exit 1
    fi

    mkdir -p $out/bin
    makeWrapper ${dotnet-sdk_10}/bin/dotnet $out/bin/dotnet-easydotnet \
      --add-flags "$entryDll"

    # Convenience alias matching the bare tool name.
    ln -s dotnet-easydotnet $out/bin/easydotnet

    runHook postInstall
  '';

  meta = with lib; {
    description = "Easy Dotnet Server — JSON-RPC server powering easy-dotnet.nvim";
    homepage = "https://github.com/GustavEikaas/easy-dotnet";
    mainProgram = "dotnet-easydotnet";
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [
      binaryNativeCode
      fromSource
    ];
    license = licenses.mit;
  };
}
