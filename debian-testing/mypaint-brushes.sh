set -xeo pipefail

initial_workspace="$PWD"

# dependencies
pushd "$PREFIX"
for x in /data/{babl,gegl,libmypaint}-internal.tar.gz; do
    tar -xzf "${x}"
done
popd

# build
PRODUCT=mypaint-brushes
git clone --reference /export/"${PRODUCT}".git https://github.com/Jehan/mypaint-brushes.git
cd "${PRODUCT}"/
git fetch /export/"${PRODUCT}".git '+refs/tags/v1.3.0:refs/tags/v1.3.0'
git checkout 'v1.3.0'
./autogen.sh
./configure --prefix="$PREFIX"
make "-j$(nproc)" install

# package binaries for use in GIMP build
pushd "$PREFIX"
tar -czvf ~1/"${PRODUCT}"-internal.tar.gz share/pkgconfig/"${PRODUCT}"* share/mypaint-data
popd
cp -f "${PRODUCT}"-internal.tar.gz /data/

cd "${initial_workspace}"