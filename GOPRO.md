# GoPro With `mmt`

This machine uses [`mmt`](https://github.com/konradit/mmt), the newer replacement for the deprecated `gopro-linux` script.

`mmt` is installed declaratively through Home Manager from [home/todor/modules/media.nix](/home/todor/mycfg/home/todor/modules/media.nix:1).

## Installed Command

After the Home Manager switch, the command is available as:

```bash
mmt
```

Current installed path:

```bash
/home/todor/.nix-profile/bin/mmt
```

## Install It

For this repo, `mmt` is installed by Home Manager, not manually with `curl`.

1. Keep the package declaration in [home/todor/modules/media.nix](/home/todor/mycfg/home/todor/modules/media.nix:1).
2. Apply the config:

```bash
home-manager switch --flake ~/mycfg#todor
```

3. Verify:

```bash
command -v mmt
mmt --help
```

This package definition builds `mmt` from the upstream `v2.0` source release and wraps runtime tools needed for camera/media workflows.

## What `mmt` Does

`mmt` is a media management tool for:

- GoPro
- Insta360
- DJI
- Android phones

For GoPro use, the main commands are:

- `mmt list`
- `mmt import`
- `mmt update`

## Typical GoPro Workflow

1. Insert the GoPro SD card.
2. Find the mount point:

```bash
mmt list
```

Example output on this machine included:

```bash
/run/media/todor/3666-3534
```

3. Import the footage into a project folder:

```bash
mmt import \
  --input /run/media/todor/3666-3534 \
  --output ~/Videos \
  --camera gopro \
  --name "Weekend Ride"
```

## Import Command

Basic form:

```bash
mmt import --input <sd-card-path> --output <destination> --camera gopro --name "<project name>"
```

Useful flags from upstream:

- `--input`: SD card mount path, or GoPro Connect IP for supported models
- `--output`: destination directory
- `--name`: project name used for organizing imported content
- `--camera gopro`: tells `mmt` to use GoPro import logic
- `--buffersize`: copy buffer size
- `--date`: date format, default is `dd-mm-yyyy`
- `--range`: import only a date range like `12-03-2021,15-03-2021`
- `--connection`: GoPro connection type, typically `sd_card`
- `--skip_aux`: skip `.THM` and `.LRV`
- `--sort_by`: organize by `camera`, `days`, or both

Example with more useful GoPro flags:

```bash
mmt import \
  --input /run/media/todor/3666-3534 \
  --output ~/Videos/GoPro \
  --camera gopro \
  --name "Alps Trip" \
  --connection sd_card \
  --skip_aux \
  --sort_by camera,days
```

## Common Commands

List connected/importable devices:

```bash
mmt list
```

Show help:

```bash
mmt --help
mmt import --help
```

Import GoPro footage:

```bash
mmt import --input /path/to/card --output ~/Videos --camera gopro --name "Session"
```

Update GoPro firmware from an SD card:

```bash
mmt update --input /path/to/card --camera gopro
```

## Suggested Folder Setup

A simple destination layout is:

```bash
~/Videos/GoPro
```

Then import into that root with a distinct `--name` per shoot:

```bash
mmt import \
  --input /run/media/todor/3666-3534 \
  --output ~/Videos/GoPro \
  --camera gopro \
  --name "Snowboard March 2026"
```

## Notes

- `mmt` replaces the older `gopro-linux` script.
- This setup is declarative. If you want to change the installed version or runtime dependencies, do it in [home/todor/modules/media.nix](/home/todor/mycfg/home/todor/modules/media.nix:1) and re-run `home-manager switch`.
- `mmt list` may show extra mount points on NixOS in restricted environments. Use the real SD card mount path for imports.
