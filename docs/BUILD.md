# Building & Releasing v2ray-mli

This document describes how to build, code-sign, and publish the
**v2ray-mli** fork for macOS on both Apple Silicon (`arm64`) and Intel
(`amd64`). It is the canonical reference for the release workflow used to
produce the GitHub release assets.

## Prerequisites

- **Go ≥ 1.16** (tested with Go 1.26). Native `darwin/arm64` requires Go 1.16+.
- macOS with the **Xcode command line tools** (`codesign`, `xcrun`).
- A **Developer ID Application** certificate in your login keychain, for
  signing. List available identities with:

  ```bash
  security find-identity -v -p codesigning
  ```

- [`gh`](https://cli.github.com/) authenticated against the target repo, for
  creating releases (`gh auth status`).

## Version scheme

The fork version lives in [`core.go`](../core.go):

```go
version  = "4.31.1-mli"
build    = "mli"
codename = "v2ray-mli, a native Apple Silicon fork of V2Ray."
```

The `build` field is overridden per-architecture at link time (see below), so
the running binary reports e.g. `mli-arm64`. Git tags use the `mli-vX.Y.Z`
prefix to stay clearly distinct from upstream `vX.Y.Z` tags.

## Building a native binary

```bash
# Apple Silicon
GOOS=darwin GOARCH=arm64 go build \
  -ldflags "-s -w -X v2ray.com/core.build=mli-arm64" \
  -o v2ray ./main/
GOOS=darwin GOARCH=arm64 go build \
  -ldflags "-s -w -X v2ray.com/core.build=mli-arm64" \
  -o v2ctl ./infra/control/main/

# Intel
GOOS=darwin GOARCH=amd64 go build \
  -ldflags "-s -w -X v2ray.com/core.build=mli-amd64" \
  -o v2ray ./main/
```

Verify the architecture and that it runs without panicking:

```bash
file v2ray            # => Mach-O 64-bit executable arm64
./v2ray -version      # => V2Ray 4.31.1-mli (...) mli-arm64 (go1.26.2 darwin/arm64)
```

> Apple Silicon binaries **must** carry at least an ad-hoc signature to run at
> all. Go's linker ad-hoc-signs `arm64` output by default; the release step
> below replaces that with a Developer ID signature.

## Code signing

Sign each binary with the Developer ID Application identity, enabling the
hardened runtime and a secure timestamp:

```bash
codesign --force --timestamp --options runtime \
  --sign "Developer ID Application: <Your Name> (<TEAMID>)" \
  v2ray v2ctl

# Verify
codesign --verify --strict --verbose=2 v2ray
codesign --display --verbose=2 v2ray
```

### Notarization (optional, not done by default)

Signing lets the binary run locally without `killed: 9` / "damaged" errors.
For distribution to third parties without a Gatekeeper prompt, the artifacts
must also be **notarized**, which requires Apple ID credentials:

```bash
xcrun notarytool submit v2ray-mli-macos-arm64.zip \
  --apple-id <apple-id> --team-id <TEAMID> --password <app-specific-password> \
  --wait
```

The default release of this fork is signed but **not** notarized.

## Packaging a release

Each macOS release archive bundles the signed binaries with the geo data files
and a sample config:

```
v2ray-mli-macos-<arch>.zip
├── v2ray                     # signed
├── v2ctl                     # signed (arm64 build)
├── geoip.dat
├── geosite.dat
└── config.json               # sample, from release/config/
```

The geo data and sample configs live in [`release/config/`](../release/config/).

## One-shot release script

A reproducible build/sign/package/publish script is kept at
[`release/macos-release.sh`](../release/macos-release.sh). It builds both
architectures, signs them, produces the zips plus `SHA256SUMS`, creates the
`mli-vX.Y.Z` tag, and publishes a GitHub release. Configure the signing
identity via the `SIGN_IDENTITY` environment variable:

```bash
SIGN_IDENTITY="Developer ID Application: <Your Name> (<TEAMID>)" \
  release/macos-release.sh 4.31.1
```

See [`CHANGELOG.md`](../CHANGELOG.md) for the per-release history.
