#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")" || exit 1

find_java8() {
  if command -v java >/dev/null 2>&1; then
    if java -version 2>&1 | grep -q '"1\.8'; then
      command -v java
      return 0
    fi
  fi

  if [ -d /usr/lib/jvm ]; then
    shopt -s nullglob
    local j
    for j in /usr/lib/jvm/java-8-openjdk-*/jre/bin/java \
             /usr/lib/jvm/java-8-openjdk-*/bin/java \
             /usr/lib/jvm/jdk1.8*/bin/java; do
      if [ -x "$j" ]; then
        echo "$j"
        shopt -u nullglob
        return 0
      fi
    done
    shopt -u nullglob
  fi

  return 1
}

REQUIRED_PKGS=(libgl1 libglu1-mesa libxrender1 libxtst6 libxi6 libxext6 libxrandr2 libxfixes3)
MISSING_PKGS=()
for pkg in "${REQUIRED_PKGS[@]}"; do
  dpkg -s "$pkg" >/dev/null 2>&1 || MISSING_PKGS+=("$pkg")
done

JAVA_BIN="$(find_java8 || true)"
INSTALL_PKGS=("${MISSING_PKGS[@]}")
if [ -z "$JAVA_BIN" ]; then
  INSTALL_PKGS+=(openjdk-8-jre)
fi

if [ "${#INSTALL_PKGS[@]}" -ne 0 ]; then
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: apt-get not found. Install packages manually: ${INSTALL_PKGS[*]}"
    exit 1
  fi
  echo "Installing packages: ${INSTALL_PKGS[*]}"
  sudo apt-get update
  sudo apt-get install -y "${INSTALL_PKGS[@]}"
fi

JAVA_BIN="$(find_java8 || true)"
if [ -z "$JAVA_BIN" ]; then
  echo "ERROR: Java 8 not found. Install openjdk-8-jre and rerun."
  exit 1
fi

echo "Using Java 8 at: $JAVA_BIN"
"$JAVA_BIN" -version
echo

exec "$JAVA_BIN" \
  -Xmx2g \
  -cp "electricBinary-9.07.jar:vecmath.jar:j3dcore.jar:j3dutils.jar:jogamp-fat.jar" \
  com.sun.electric.Launcher
