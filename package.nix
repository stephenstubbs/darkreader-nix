# Dark Reader browser extension, packaged as an *unpacked* Manifest V3
# directory suitable for Chromium `--load-extension=<dir>` (the form
# agent-browser / CloakBrowser use via `--extension` / AGENT_BROWSER_EXTENSIONS).
#
# Dark Reader is MIT-licensed and ships a prebuilt Chrome MV3 zip as a GitHub
# release asset (darkreader-chrome-mv3.zip) with manifest.json at its root, so
# there is nothing to build — we just fetch the pinned zip and unpack it into
# $out. `nix-update` tracks new GitHub releases; downstream flakes pick bumps
# up with a plain `nix flake update`.
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

  # The asset is a zip with manifest.json at the top level; unpack it as the
  # unpacked extension directory.
  unpackPhase = ''
    runHook preUnpack
    mkdir -p source
    unzip -q "$src" -d source
    runHook postUnpack
  '';

  sourceRoot = "source";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    # Sanity check: an unpacked Chromium extension must have manifest.json at
    # the directory root or `--load-extension` will silently ignore it.
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
