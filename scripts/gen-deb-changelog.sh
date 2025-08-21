#!/usr/bin/env bash

set -x

# Examples:
# 
# ${pkgSource}_${pkgVersion}-${pkgRevision}~${pkgDistro}.${pkgDistroId}~${pkgDistroSuite}.deb
# lat_1.6.2-1~debian.13~trixie_loong64.deb
# lat_1.6.2-1~debian.14~forky_loong64.deb

. /etc/os-release

version="$(git describe --tags --first-parent --abbrev=7 --long --always | sed -e "s/^v//g")"

pkgDistro=$ID
pkgDistroId=$VERSION_ID
pkgDistroSuite=$VERSION_CODENAME

pkgSource="$(awk -F ': ' '$1 == "Source" { print $2; exit }' debian/control)"
pkgMaintainer="$(awk -F ': ' '$1 == "Maintainer" { print $2; exit }' debian/control)"
pkgDate="$(date --rfc-2822)"
pkgVersion="${version%%-*}"
pkgRevision=1

cat > "debian/changelog" <<-EOF
$pkgSource (${pkgVersion}-${pkgRevision}~${pkgDistro}.${pkgDistroId}~${pkgDistroSuite}) $pkgDistroSuite; urgency=low
  * Version: $version
 -- $pkgMaintainer  $pkgDate
EOF
