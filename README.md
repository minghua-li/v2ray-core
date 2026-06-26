# v2ray-mli — native Apple Silicon fork

> **This is a fork of the archived [`v2ray/v2ray-core`](https://github.com/v2ray/v2ray-core).**
> It builds and runs **natively on Apple Silicon (M-series) macOS**, avoiding the
> Rosetta 2 "not optimized for your Mac" warning shown by upstream's amd64-only
> binaries. The only feature removed is the QUIC transport, which is
> incompatible with modern Go toolchains (it pins `qtls` to Go 1.15). All other
> transports and proxy protocols are unchanged.
>
> - **Releases:** native `darwin/arm64` + `darwin/amd64`, Developer ID signed.
> - **What changed & why:** [`CHANGELOG.md`](CHANGELOG.md)
> - **How to build / sign / release:** [`docs/BUILD.md`](docs/BUILD.md)
> - Version scheme: `X.Y.Z-mli`, tags `mli-vX.Y.Z`.

***

# Move To https://github.com/v2fly/v2ray-core

***

# Project V

[![GitHub Test Badge][1]][2] [![codecov.io][3]][4] [![GoDoc][5]][6] [![codebeat][7]][8] [![Downloads][9]][10] [![Downloads][11]][12]

[1]: https://github.com/v2fly/v2ray-core/workflows/Test/badge.svg "GitHub Test Badge"
[2]: https://github.com/v2fly/v2ray-core/actions "GitHub Actions Page"
[3]: https://codecov.io/gh/v2fly/v2ray-core/branch/master/graph/badge.svg?branch=master "Coverage Badge"
[4]: https://codecov.io/gh/v2fly/v2ray-core?branch=master "Codecov Status"
[5]: https://godoc.org/v2ray.com/core?status.svg "GoDoc Badge"
[6]: https://godoc.org/v2ray.com/core "GoDoc"
[7]: https://goreportcard.com/badge/github.com/v2fly/v2ray-core "Goreportcard Badge"
[8]: https://goreportcard.com/report/github.com/v2fly/v2ray-core "Goreportcard Result"
[9]: https://img.shields.io/github/downloads/v2ray/v2ray-core/total.svg "v2ray/v2ray-core downloads count"
[10]: https://github.com/v2ray/v2ray-core/releases "v2ray/v2ray-core release page"
[11]: https://img.shields.io/github/downloads/v2fly/v2ray-core/total.svg "v2fly/v2ray-core downloads count"
[12]: https://github.com/v2fly/v2ray-core/releases "v2fly/v2ray-core release page"

Project V is a set of network tools that help you to build your own computer network. It secures your network connections and thus protects your privacy. See [our website](https://www.v2fly.org/) for more information.

## License

[The MIT License (MIT)](https://raw.githubusercontent.com/v2fly/v2ray-core/master/LICENSE)

## Credits

This repo relies on the following third-party projects:

- In production:
  - [gorilla/websocket](https://github.com/gorilla/websocket)
  - [gRPC](https://google.golang.org/grpc)
- For testing only:
  - [miekg/dns](https://github.com/miekg/dns)
  - [h12w/socks](https://github.com/h12w/socks)
