# Dark Reader, packaged as an unpacked Chromium MV3 extension directory for
# --load-extension. Fetches the prebuilt darkreader-chrome-mv3.zip release
# asset (manifest.json at root) and unpacks it into $out.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "darkreader-chrome-mv3";
  version = "4.9.128";

  src = fetchurl {
    url = "https://github.com/darkreader/darkreader/releases/download/v${finalAttrs.version}/darkreader-chrome-mv3.zip";
    hash = "sha256-Jz1u3Muq9/LtJIK6AcjUtXTurKgzVeGGF8qli0EihxE=";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    mkdir -p source
    unzip -q "$src" -d source
    runHook postUnpack
  '';

  sourceRoot = "source";

  # Suppress the darkreader.org "goodluck" welcome tab that the service worker
  # opens on install (fires every launch since agent-browser uses a fresh
  # --user-data-dir each time).
  postPatch = ''
    substituteInPlace background/index.js \
      --replace-fail "chrome.tabs.create({url: getHelpURL()})" "void 0"
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    test -f "$out/manifest.json"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex" "^v?([0-9.]+)$" ];
  };

  meta = {
    description = "Dark Reader — dark mode for every website, packaged as an unpacked Chromium MV3 extension directory for --load-extension";
    homepage = "https://darkreader.org";
    downloadPage = "https://github.com/darkreader/darkreader/releases";
    changelog = "https://github.com/darkreader/darkreader/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
  };
})
