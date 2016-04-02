#!/usr/bin/env bash

echo $PUBLISHER_PRIVATE_KEY | sed 's/\\n/\'$'\n/g' > publisher.key
echo $PUBLISHER_CERTIFICATE | sed 's/\\n/\'$'\n/g' > publisher.crt

PUBLISHER_KEYSTORE="$WORKSPACE/publisher.p12"
openssl pkcs12 -export -inkey publisher.key -in publisher.crt -name privatekey -passout pass:notasecret -out $PUBLISHER_KEYSTORE

echo ">> publishing to playstore"

mvn android:publish-apk android:publish-listing -f app/pom.xml -Ppublisher -e \
  -Dandroid.sdk.path=$ANDROID_HOME \
  -Dandroid.publisher.upload.images=true \
  -Dandroid.publisher.google.email=$PUBLISHER_EMAIL \
  -Dandroid.publisher.google.p12=$PUBLISHER_KEYSTORE
