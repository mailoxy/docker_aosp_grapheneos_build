#!/bin/bash

set -e

AOSP_RELEASE_URL=https://dl.google.com/dl/android/aosp/

mkdir -p $WORKDIR && cd $WORKDIR

wget -c $AOSP_RELEASE_URL/$FACTORY_IMAGE

git config --global user.name "Your Name"
git config --global user.email "you@example.org"

repo init -u $MANIFEST -b $RELEASE
repo sync -j6 --force-sync

rm -rf out
make clobber

if [[ ! -e $WORKDIR/keys/$DEVICE/avb_pkmd.bin ]]; then
  mkdir -p $WORKDIR/keys/$DEVICE && cd $WORKDIR/keys/$DEVICE
  echo | ../../development/tools/make_key releasekey '/C=Co/ST=State/L=City/O=Org/OU=Org/CN=Org/emailAddress=org@example.org' || true
  echo | ../../development/tools/make_key platform '/C=Co/ST=State/L=City/O=Org/OU=Org/CN=Org/emailAddress=org@example.org' || true
  echo | ../../development/tools/make_key shared '/C=Co/ST=State/L=City/O=Org/OU=Org/CN=Org/emailAddress=org@example.org' || true
  echo | ../../development/tools/make_key media '/C=Co/ST=State/L=City/O=Org/OU=Org/CN=Org/emailAddress=org@example.org' || true
  openssl genrsa -out avb.pem 2048
  ../../external/avb/avbtool extract_public_key --key avb.pem --output avb_pkmd.bin
fi


if [[ -e $WORKDIR/kernel/google/crosshatch/build.sh ]] && [[ $DEVICE =~ ^(blueline|crosshatch)$ ]]; then
  cd  $WORKDIR/kernel/google/crosshatch
  git submodule update --init --recursive
  ./build.sh $DEVICE
fi

if [[ -e $WORKDIR/kernel/google/wahoo/build.sh ]] && [[ $DEVICE =~ ^(walleye|taimen)$ ]]; then
  cd  $WORKDIR/kernel/google/wahoo
  git submodule update --init --recursive
  ./build.sh $DEVICE
fi


cd $WORKDIR

pushd system/core && git checkout rootdir/etc/hosts && wget https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -O rootdir/etc/hosts && popd

pushd packages/apps/Updater && git checkout res/values/config.xml && popd
cat << EOF > packages/apps/Updater/res/values/config.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="url" translatable="false">$UPDATE_URL/</string>
    <string name="url_legacy" translatable="false">$UPDATE_URL_LEGACY/</string>
</resources>
EOF

mkdir -p vendor/google_devices

sudo rm -rf vendor/google_devices/*
vendor/android-prepare-vendor/execute-all.sh --debugfs -d $DEVICE -b $BUILD -i $FACTORY_IMAGE -o vendor/android-prepare-vendor
mv vendor/android-prepare-vendor/$DEVICE/$(echo $BUILD | awk '{print tolower($0)}')/vendor/google_devices/* vendor/google_devices
source script/envsetup.sh
choosecombo release aosp_$DEVICE user
make -j $(nproc) target-files-package brillo_update_payload
script/release.sh $DEVICE

