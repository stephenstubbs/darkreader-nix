# darkreader-nix

[Dark Reader](https://darkreader.org) packaged for Nix as an **unpacked
Chromium Manifest V3 extension directory**, ready for
`--load-extension=<dir>` (the form Chromium/CloakBrowser use to side-load an
unpacked extension).

Dark Reader is MIT-licensed and publishes a prebuilt Chrome MV3 zip
(`darkreader-chrome-mv3.zip`) as a GitHub release asset, with `manifest.json`
at the archive root. There is nothing to build — this repo just fetches the
pinned zip and unpacks it into `$out`, so the store path *is* the unpacked
extension directory.

## Updates

A scheduled GitHub Actions workflow checks the Dark Reader GitHub releases
daily, bumps `package.nix` via `nix-update`, verifies the package builds, and
commits to `main`. Downstream consumers get new releases with a plain
`nix flake update` — no manual version bookkeeping.

## Usage

```nix
{
  inputs.darkreader = {
    url = "github:stephenstubbs/darkreader-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then reference `darkreader.packages.${system}.default` (or apply
`overlays.default`, exposing `pkgs.darkreader`). The package output is the
unpacked extension directory, so use it directly as a `--load-extension`
target:

```bash
chromium \
  --load-extension=${darkreader} \
  --disable-extensions-except=${darkreader} \
  https://example.com
```

### With CloakBrowser / agent-browser

agent-browser's own `--extension` plumbing does not reliably register the
extension with the CloakBrowser engine, but passing `--load-extension`
directly to the CloakBrowser Chromium binary works. Wrap `cloakbrowser-chrome`
so it always appends the flags, then point
`AGENT_BROWSER_EXECUTABLE_PATH` at the wrapper.

## Licensing

This repository contains packaging expressions only. The Dark Reader artifact
is fetched from its official GitHub release at build time and remains subject
to its own MIT license.
