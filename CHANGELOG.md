# Changelog

All notable changes to this fork (**v2ray-mli**) are documented here.

This fork tracks the upstream archived [`v2ray/v2ray-core`](https://github.com/v2ray/v2ray-core)
codebase and adds the changes required to build and run natively on modern
Apple Silicon (M-series) macOS. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
uses an `mli-` prefixed version scheme to distinguish releases from upstream.

## [4.31.1-mli] — 2026-06-25

First fork release. Produces native `darwin/arm64` (Apple Silicon) and
`darwin/amd64` (Intel) binaries, code-signed with a Developer ID.

### Why this fork exists

The upstream project is archived and its macOS releases were only ever built
for `darwin/amd64`. On Apple Silicon those binaries run under Rosetta 2, which
makes macOS show the *"this application is not optimized for your Mac / future
versions of macOS will not support it"* warning.

Building the upstream source natively for `darwin/arm64` is not enough on its
own: the QUIC transport depends on `quic-go v0.18.1`, which pulls in
`marten-seemann/qtls-go1-15`. That package uses `unsafe` to mirror the internal
`crypto/tls` struct layout of **Go 1.15** and panics at package-init time on any
newer toolchain:

```
panic: qtls.ConnectionState doesn't match
github.com/marten-seemann/qtls-go1-15.init.0()
```

Go 1.15 has no native `darwin/arm64` support (that arrived in Go 1.16), so
"use the Go version the code wants" and "produce a native arm64 binary" are
mutually exclusive. This fork resolves the conflict by removing the
incompatible QUIC transport.

### Removed

- **QUIC transport** (`transport/internet/quic`) and its `quic-go` / `qtls`
  dependency chain. This is the only feature removed. All other transports —
  TCP, mKCP, WebSocket, HTTP/2, Domain Socket, TLS, XTLS — are unchanged, as
  are all proxy protocols (VMess, VLESS, Shadowsocks, Trojan, SOCKS, HTTP,
  Dokodemo-door, Freedom, Blackhole).
  - Dropped the blank import in `main/distro/all/all.go`.
  - Removed `QUICConfig` parsing from `infra/conf/transport_internet.go` and
    `infra/conf/transport.go`.
  - Removed QUIC test cases from `infra/conf/transport_test.go` and
    `testing/scenarios/transport_test.go`.
  - `go mod tidy` dropped `github.com/lucas-clemente/quic-go`,
    `github.com/marten-seemann/qtls-go1-15` and related transitive modules.

### Changed

- Version is now `4.31.1-mli` (`core.go`), with a fork codename. Release tags
  use the `mli-vX.Y.Z` prefix.

### Build / Release

- Native `darwin/arm64` and `darwin/amd64` binaries.
- Both architectures are code-signed with a Developer ID (hardened runtime,
  secure timestamp). See [`docs/BUILD.md`](docs/BUILD.md) for the full build,
  sign, and release procedure.

### Known limitations

- No QUIC transport (see above).
- Release binaries are **signed but not notarized**. They run fine when built
  or downloaded locally; a third party downloading them from the internet may
  still see a Gatekeeper prompt until they are notarized.

[4.31.1-mli]: https://github.com/minghua-li/v2ray-core/releases/tag/mli-v4.31.1
