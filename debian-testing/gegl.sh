#!/bin/bash
#Created by Sam Gleske
#Ubuntu 16.04.4 LTS
#Linux 4.13.0-41-generic x86_64
#GNU bash, version 4.3.48(1)-release (x86_64-pc-linux-gnu)

set -xeo pipefail

PRODUCT=gegl
REPOSITORY=https://gitlab.gnome.org/GNOME/"${PRODUCT}"
initial_workspace="$PWD"

# dependencies
if [ -z "${SKIP_MAKE_BUILD:-}" ]; then
    pushd "$PREFIX"
    tar -xzf /data/babl-internal.tar.gz
    popd
fi

#clone if not already
if [ ! -d "${PRODUCT}" ]; then
    GIT_ARGS=()
    if [ -d /export/"${PRODUCT}".git ]; then
        GIT_ARGS=(--reference /export/"${PRODUCT}".git)
    fi
    git clone "${GIT_ARGS[@]}" "${REPOSITORY}"
fi
cd "${PRODUCT}"/
if [ -n "${GEGL_BRANCH}" -a -z "${SKIP_MAKE_BUILD:-}" -a -z "${JOB_NAME:-}" ]; then
    git checkout "${GEGL_BRANCH}"
fi
#build and install (runs by default)
if [ -z "${SKIP_MAKE_BUILD:-}" ]; then
    ./autogen.sh
    ./configure --prefix="$PREFIX"
    make "-j$(nproc)" install
fi
#run tests (runs by default)
[ -n "${SKIP_MAKE_CHECK:-}" ] || make "-j$(nproc)" check
#run distcheck (disabled by default)
[ -z "${INCLUDE_DISTCHECK:-}" ] || make distcheck

# package binaries for use in GIMP build
pushd "$PREFIX"
tar -czvf ~1/"${PRODUCT}"-internal.tar.gz lib/*"${PRODUCT}"* lib/pkgconfig/"${PRODUCT}"* include/"${PRODUCT}"* bin share
popd
cp -f "${PRODUCT}"-internal.tar.gz /data/

cd "${initial_workspace}"
