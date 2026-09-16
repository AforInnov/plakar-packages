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
