#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname $0)
: ${WORKSPACE=$(pwd)}
: ${KEYSTORE_PASSWORD:="blog"}
: ${SIGNING_CERTIFICATE:=signing.crt}
: ${SIGNING_KEY:=signing.key}
: ${KEYSTORE_KEY_ALIAS:="androidblog"}
: ${BUILD_NUMBER:=$GO_PIPELINE_COUNTER}
: ${BUILD_NUMBER:=1}

echo ">> create a symlink to the zipalign tool in the SDK tools directory. This is because the maven plugin looks for it there."
ln -fs $ANDROID_HOME/build-tools/20.0.0/zipalign $ANDROID_HOME/tools/zipalign

echo ">> create certificate file from environment variable."
echo $SIGNING_CERTIFICATE | tr "\t" "\n" > server.crt

echo ">> create signing key from environment variable."
echo $SIGNING_KEY | tr "\t" "\n" > server.key

echo ">> create a p12 keystore file from the certificate and key file above."
openssl pkcs12 -export \
    -in server.crt \
    -inkey server.key \
    -out keystore.p12 \
    -name $KEYSTORE_KEY_ALIAS \
    -passout pass:$KEYSTORE_PASSWORD

echo ">> convert p12 keystore file to format expected by android maven plugin."
echo 'y' | keytool -importkeystore \
    -srckeystore keystore.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass $KEYSTORE_PASSWORD \
    -destkeystore $WORKSPACE/blog.keystore \
    -deststorepass $KEYSTORE_PASSWORD


echo ">> package and sigin"
mvn clean package -e -DskipTests=true -f app/pom.xml -Prelease -U \
    -Dandroid.sdk.path=$ANDROID_HOME \
    -Dkeystore.file=$WORKSPACE/blog.keystore \
    -Dkey.password=$KEYSTORE_PASSWORD \
    -Dkeystore.password=$KEYSTORE_PASSWORD \
    -Dkey.alias=$KEYSTORE_KEY_ALIAS \
    -Dandroid.manifestMerger.versionCode=$BUILD_NUMBER
