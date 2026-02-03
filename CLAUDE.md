# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rustypaste is a minimal, self-hosted file upload/pastebin service written in Rust. It's a single-binary application using Actix-web that stores files on the filesystem (no database). Key features include file upload, URL shortening, one-shot links, file expiration, and optional authentication.

## Common Commands

```bash
# Build
cargo build --release

# Run tests (must be single-threaded due to file I/O)
cargo test -- --test-threads 1

# Run a single test
cargo test test_name -- --test-threads 1

# Linting
cargo clippy --tests -- -D warnings

# Formatting
cargo fmt
cargo fmt -- --check

# Integration tests
./fixtures/test-fixtures.sh

# Run the server
cargo run
# Or with custom config:
CONFIG=/path/to/config.toml cargo run
```

## Feature Flags

- `rustls` (default): Use rustls for TLS
- `openssl`: Use system OpenSSL (~20% smaller binary)
- `shuttle`: Deploy on Shuttle platform

Build with specific features: `cargo build --release --no-default-features --features openssl`

## Code Architecture

### Source Files (`src/`)

| File | Purpose |
|------|---------|
| `main.rs` | Entry point: initializes server, config watcher, cleanup thread |
| `server.rs` | HTTP route handlers (upload, download, delete, list endpoints) |
| `config.rs` | Configuration structures and TOML/YAML parsing |
| `paste.rs` | PasteType enum and file upload/download logic |
| `auth.rs` | Token-based authentication via Authorization header |
| `file.rs` | File struct with SHA256 checksum for duplicate detection |
| `util.rs` | Path operations, expiration logic, checksums |
| `random.rs` | Random filename generation (petname or alphanumeric) |
| `mime.rs` | MIME type detection with regex overrides |
| `middleware.rs` | Content-Length limiter middleware |
| `header.rs` | Custom header parsing (expire, filename) |

### Key Concepts

- **PasteType**: `File`, `RemoteFile`, `Oneshot`, `Url`, `OneshotUrl` - stored in different subdirectories
- **File expiration**: Implemented via timestamp file extensions (e.g., `file.txt.1234567890`)
- **Random names**: Configurable petname (`capital-mosquito.txt`) or alphanumeric (`yB84D2Dv.txt`)
- **Duplicate detection**: Uses SHA256 checksums, configurable via `duplicate_files` setting
- **Hot-reload**: Config file changes are automatically detected via hotwatch

### Directory Structure for Uploads

```
upload/
├── regular-file.txt
├── oneshot/           # One-shot files (deleted after first view)
├── url/               # URL shortener entries
└── oneshot_url/       # One-shot URL redirects
```

## Configuration

Main config file: `config.toml` (see file for all options)

Environment variables:
- `CONFIG`: Path to config file
- `AUTH_TOKEN` / `AUTH_TOKENS_FILE`: Authentication tokens
- `DELETE_TOKEN` / `DELETE_TOKENS_FILE`: Deletion tokens
- `RUST_LOG`: Logging level (debug, info, warn, error)

## Code Quality

The codebase enforces:
- `#![warn(missing_docs, clippy::unwrap_used)]` - documentation required, avoid unwrap()
- All clippy warnings treated as errors in CI
