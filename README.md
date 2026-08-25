# AIC8800D80 Recovery DKMS

Recovery-focused Linux driver and Debian package for USB Wi-Fi adapters based
on the AIC8800D80 family. This project focuses on the kernel compatibility gap
across Linux 6.x and 7.x and on a predictable, reversible installation.

This repository is derived from
[RicknotDev/aic8800d80](https://github.com/RicknotDev/aic8800d80), itself a
community fork of
[shenmintao/aic8800d80](https://github.com/shenmintao/aic8800d80). The driver
and this recovery work are distributed under GPL-2.0; see [`LICENSE`](LICENSE)
and [`packaging/debian/copyright`](packaging/debian/copyright).

## Current status

The recovery package is functional, but still considered a release candidate.

| System | Kernel | DKMS build | Hardware | Wi-Fi |
|---|---|---:|---:|---:|
| Linux Mint 22.3 XFCE | 6.14.0-37-generic | pass | pass | pass |
| Linux Mint 22.3 XFCE | 7.0.0-30-generic | pass | pass | 5 GHz pass |

On `7.0.0-30-generic`, the package was tested through installation, reboot,
automatic USB mode switching, firmware loading, 5 GHz authentication, IPv4 and
IPv6 address assignment, internet traffic, physical removal, reinsertion and
automatic reconnection. The detailed evidence is recorded in
[`docs/SAFE-TEST-PROTOCOL.md`](docs/SAFE-TEST-PROTOCOL.md).

These results apply only to the listed systems and kernels. Other kernels in
the 6.x-7.x range still need explicit testing; a successful compilation alone
is not presented as proof that the hardware works.

## What the package provides

- DKMS source for `aic_load_fw` and `aic8800_fdrv`;
- firmware for the AIC8800 variants carried by the upstream project;
- udev and usb_modeswitch configuration for automatic device-mode switching;
- `aic8800d80-check`, a read-only preflight diagnostic;
- package lifecycle scripts for tracked installation and removal.

Installing the package builds the modules for the running kernel but does not
load or unload them. This lets the adapter remain disconnected until the
operator completes the preflight checks.

## Build the Debian package

On a Debian, Ubuntu or Linux Mint system:

```sh
./packaging/build-deb.sh
```

The resulting file is written to `dist/`:

```text
aic8800d80-recovery-dkms_1.0.0-2_all.deb
```

## Safe installation

Keep the AIC adapter disconnected and retain another working network connection
during installation.

```sh
sudo apt install ./dist/aic8800d80-recovery-dkms_1.0.0-2_all.deb
aic8800d80-check
sudo reboot
```

After rebooting, run `aic8800d80-check` again before connecting the adapter.
Follow the complete staged procedure in
[`docs/SAFE-TEST-PROTOCOL.md`](docs/SAFE-TEST-PROTOCOL.md).

The package deliberately refuses to overwrite a detected manual AIC firmware,
udev or DKMS installation. Remove or archive a conflicting installation only
after identifying exactly where it came from.

## Uninstall

Disconnect the adapter, then remove the tracked package and reboot:

```sh
sudo apt remove --purge aic8800d80-recovery-dkms
sudo reboot
```

## Internal installer memory

Some adapters initially expose a small mass-storage device containing a Windows
installer. This package only uses the normal mode-switch sequence; it does not
write to that internal storage. Any future investigation of the storage must
begin with read-only identification and imaging. Flash writes are outside the
scope of the current release.

## Known limitations

- Secure Boot environments may require enrollment of the DKMS signing key.
- Bluetooth enumeration passed on the kernel 7.0 test system, but pairing and
  sustained Bluetooth traffic have not yet been validated.
- Long-duration Wi-Fi stability and additional kernel versions remain to be
  tested.
- The package currently targets Debian-family systems; the driver source may be
  usable elsewhere, but this recovery installer does not claim multi-distro
  packaging support.

## Contributing test results

Report the distribution, exact `uname -r`, adapter USB IDs, package version and
the highest completed validation level:

1. `SOURCE_AUDITED`
2. `COMPILES`
3. `DKMS_INSTALLS`
4. `MODULES_LOAD`
5. `DEVICE_DETECTED`
6. `WIFI_CONNECTS`
7. `STABLE`

Do not label a kernel `STABLE` based only on a build or a single connection.
