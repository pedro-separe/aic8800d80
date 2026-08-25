#!/bin/sh
set -eu

PACKAGE="aic8800d80-recovery-dkms"
DKMS_NAME="aic8800d80-recovery"
DKMS_VERSION="1.0.0"
DEB_VERSION="1.0.0-2"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="${1:-$PROJECT_DIR/dist}"
STAGE_ROOT="$(mktemp -d /tmp/aic8800d80-deb.XXXXXX)"
PACKAGE_ROOT="$STAGE_ROOT/root"

cleanup() {
    rm -rf -- "$STAGE_ROOT"
}
trap cleanup EXIT INT TERM

mkdir -p \
    "$OUTPUT_DIR" \
    "$PACKAGE_ROOT/DEBIAN" \
    "$PACKAGE_ROOT/usr/src/$DKMS_NAME-$DKMS_VERSION" \
    "$PACKAGE_ROOT/lib/firmware" \
    "$PACKAGE_ROOT/usr/bin" \
    "$PACKAGE_ROOT/usr/lib/udev/rules.d" \
    "$PACKAGE_ROOT/etc/usb_modeswitch.d" \
    "$PACKAGE_ROOT/usr/share/doc/$PACKAGE"

cp -a "$PROJECT_DIR/drivers" "$PACKAGE_ROOT/usr/src/$DKMS_NAME-$DKMS_VERSION/"
cp -a "$PROJECT_DIR/dkms.conf" "$PACKAGE_ROOT/usr/src/$DKMS_NAME-$DKMS_VERSION/"
cp -a "$PROJECT_DIR/fw/." "$PACKAGE_ROOT/lib/firmware/"
cp -a "$PROJECT_DIR/aic.rules" \
    "$PACKAGE_ROOT/usr/lib/udev/rules.d/60-aic8800d80.rules"
cp -a "$PROJECT_DIR/usb_modeswitch/1111_1111" \
    "$PACKAGE_ROOT/etc/usb_modeswitch.d/1111:1111"
cp -a "$PROJECT_DIR/tools/aic8800d80-check" \
    "$PACKAGE_ROOT/usr/bin/aic8800d80-check"
cp -a "$SCRIPT_DIR/debian/control" "$PACKAGE_ROOT/DEBIAN/control"
cp -a "$SCRIPT_DIR/debian/copyright" "$PACKAGE_ROOT/usr/share/doc/$PACKAGE/copyright"

for maintainer_script in preinst postinst prerm postrm; do
    cp -a "$SCRIPT_DIR/debian/$maintainer_script" \
        "$PACKAGE_ROOT/DEBIAN/$maintainer_script"
    chmod 0755 "$PACKAGE_ROOT/DEBIAN/$maintainer_script"
done

find "$PACKAGE_ROOT/usr/src/$DKMS_NAME-$DKMS_VERSION" \
    -type f \
    \( -name '*.o' -o -name '*.ko' -o -name '*.cmd' -o \
       -name '*.mod' -o -name '*.mod.c' -o -name 'Module.symvers' -o \
       -name 'modules.order' \) \
    -delete

find "$PACKAGE_ROOT" -type d -exec chmod 0755 {} +
find "$PACKAGE_ROOT" -type f -exec chmod 0644 {} +
chmod 0755 "$PACKAGE_ROOT/usr/bin/aic8800d80-check"
chmod 0755 \
    "$PACKAGE_ROOT/DEBIAN/preinst" \
    "$PACKAGE_ROOT/DEBIAN/postinst" \
    "$PACKAGE_ROOT/DEBIAN/prerm" \
    "$PACKAGE_ROOT/DEBIAN/postrm"

installed_size="$(du -sk "$PACKAGE_ROOT" | awk '{print $1}')"
printf 'Installed-Size: %s\n' "$installed_size" >> "$PACKAGE_ROOT/DEBIAN/control"

(
    cd "$PACKAGE_ROOT"
    find . -type f ! -path './DEBIAN/*' -print0 |
        sort -z |
        xargs -0 md5sum > DEBIAN/md5sums
)

output="$OUTPUT_DIR/${PACKAGE}_${DEB_VERSION}_all.deb"
dpkg-deb --root-owner-group --build "$PACKAGE_ROOT" "$output"

echo "$output"
