#!/usr/bin/env bash
set -e

ARCH=${1:-"amd64"}
VERSION="1.2.0"
BUNDLE_DIR="build/linux/x64/release/bundle"

if [ "$ARCH" = "arm64" ]; then
  BUNDLE_DIR="build/linux/arm64/release/bundle"
fi

OUTPUT_DIR="build/linux/packages"
mkdir -p "$OUTPUT_DIR"

PKG_NAME="zefir_${VERSION}_${ARCH}"
PKG_DIR="build/linux/deb_pkg/${PKG_NAME}"

echo "==> Packaging Zefir for Linux ($ARCH)..."

rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/opt/zefir"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/pixmaps"

# Copie des binaires et dépendances
cp -r "$BUNDLE_DIR"/* "$PKG_DIR/opt/zefir/"

# Lanceur dans /usr/bin
cat > "$PKG_DIR/usr/bin/zefir" << 'EOF'
#!/usr/bin/env bash
exec /opt/zefir/zefir "$@"
EOF
chmod +x "$PKG_DIR/usr/bin/zefir"

# Fichier .desktop
cp linux/zefir.desktop "$PKG_DIR/usr/share/applications/"

# Icône
if [ -f "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" ]; then
  cp "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" "$PKG_DIR/usr/share/pixmaps/zefir.png"
fi

# Fichier de contrôle Debian
cat > "$PKG_DIR/DEBIAN/control" << EOF
Package: zefir
Version: ${VERSION}
Section: video
Priority: optional
Architecture: ${ARCH}
Maintainer: Metoushael <contact@metoushael.com>
Depends: libc6, libgtk-3-0, liblzma5
Description: Zefir - Compression vidéo locale haute performance
 Traitement vidéo 100% hors-ligne, fluide et confidentiel avec profil expressif.
EOF

# Construction du paquet .deb
dpkg-deb --build "$PKG_DIR" "$OUTPUT_DIR/${PKG_NAME}.deb"

# Création de l'archive tar.gz portable
tar -czf "$OUTPUT_DIR/Zefir-Linux-${ARCH}-v${VERSION}.tar.gz" -C "$BUNDLE_DIR" .

echo "==> Linux packages created successfully in $OUTPUT_DIR :"
ls -lh "$OUTPUT_DIR"
