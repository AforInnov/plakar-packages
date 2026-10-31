# plakar-packages

Builds plakar integration plugins as `.ptar` files, so hosts install them from a GitHub release
instead of the Plakar plugin server. `plakar pkg add <name>` needs a Plakar account;
`plakar pkg build <name>` does not.

A `.ptar` is built for one OS/arch and one plakar API version. These builds are linux/amd64 only.

## Release a build

Tag `v<plakar-version>-<n>`, for example `v1.1.6-1`. The workflow reads the plakar version from
the tag, installs that plakar, builds every plugin in `plugins.txt`, and attaches the `.ptar`
files plus `SHA256SUMS` to the release.

```sh
gh release create v1.1.6-1 --generate-notes
```

This creates the tag on GitHub and starts the build. If a build fails, delete the release and
the tag, then use the next `-<n>`.

## Install on a host

```sh
plakar pkg add -allow-unsigned ./s3_v1.1.6_linux_amd64.ptar
plakar pkg show
```

`-allow-unsigned` because these builds are not signed by Plakar.

## Add a plugin

One integration name per line in `plugins.txt`, then a new tag.

## Backup image

Each release also pushes `ghcr.io/aforinnov/plakar-backup:<tag without v>`, for example
`1.1.6-2`: Debian with plakar, these plugins, sqlite3 and `image/backup.sh`. A change to the
image needs a new tag, like a plugin change.

The container takes a snapshot once at start, then every day at `BACKUP_TIME` (UTC, default
`01:30`), and deletes the snapshots older than `PLAKAR_KEEP` (default `90d`). Before each
snapshot it empties `/staging` and runs `BACKUP_PREPARE`, the app-specific shell command that
fills it. The store is encrypted with `PLAKAR_PASSPHRASE`.

| Variable | Value |
| --- | --- |
| `STORE` | `s3://s3.eu-central-1.amazonaws.com/<bucket>/<app>/<env>/plakar` |
| `BACKUP_S3_ACCESS_KEY`, `BACKUP_S3_SECRET_KEY` | the app's writer in `platform-backups` |
| `PLAKAR_PASSPHRASE` | the passphrase in SSM; snapshots are unreadable without it |
| `BACKUP_PREPARE` | for example `sqlite3 /data/db.sqlite3 "VACUUM INTO '/staging/db.sqlite3'"` |
| `CRONITOR_API_KEY`, `CRONITOR_MONITOR` | optional; the telemetry key and the monitor to ping |
