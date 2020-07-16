#!/bin/bash
set -e
if [[ ! -r /usr/share/java/leveldb-api.jar ]] || [[ ! -r /usr/share/java/leveldb.jar ]]; then
    sudo apt-get install libleveldb-java libleveldb-api-java
fi
wget https://github.com/ltonetwork/docker-public-node/raw/master/lto-public-all.jar
mkdir -p worker
cd worker/
jar -xvf ../lto-public-all.jar
cp -v META-INF/MANIFEST.MF .
rm -rvf `find . -name *leveldb*`
cp /usr/share/java/leveldb-api.jar .
cp /usr/share/java/leveldb.jar .
jar -xvf leveldb-api.jar
jar -xvf leveldb.jar
rm -vf *.jar
cp -vf MANIFEST.MF META-INF/
jar -cvfm ../lto-public-all-arm.jar META-INF/MANIFEST.MF *
cd ..
rm -rvf worker/
echo "Finished successfully!"
