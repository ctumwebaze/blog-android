#!/usr/bin/env bash

[[ ! -d $ANDROID_HOME/platforms/android-21 ]] && \
(echo 'y' | $ANDROID_HOME/tools/android --silent update sdk --no-ui --force --all --filter android-21)

mvn install:install-file \
  -Dfile=$ANDROID_HOME/platforms/android-21/android.jar \
  -DgroupId=com.google.android \
  -DartifactId=android \
  -Dversion=5.0.1 \
  -Dpackaging=jar