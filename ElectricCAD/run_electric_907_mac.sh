#!/bin/bash

cd "$(dirname "$0")" || exit 1

# Prefer ARM Java 8 for non-3D (stable on Apple Silicon)
JAVA8_ARM=$(/usr/libexec/java_home -v 1.8 -a arm64 2>/dev/null || true)

# If ARM Java 8 isn't found, fall back to any Java 8
if [ -z "$JAVA8_ARM" ]; then
  JAVA8_ARM=$(/usr/libexec/java_home -v 1.8 2>/dev/null || true)
fi

if [ -z "$JAVA8_ARM" ]; then
  echo "ERROR: Java 8 not found. Run: /usr/libexec/java_home -V"
  exit 1
fi

echo "Using Java 8 at: $JAVA8_ARM"
"$JAVA8_ARM/bin/java" -version
echo

# macOS/Linux classpath separator is ":" (NOT ";")
exec "$JAVA8_ARM/bin/java" \
  -Xmx2g \
  -cp "electricBinary-9.07.jar:vecmath.jar:j3dcore.jar:j3dutils.jar:jogamp-fat.jar" \
  com.sun.electric.Launcher

