#!/bin/bash
# Stages the libraries Pillow is built with, as sources SwiftPM compiles for
# whichever platform is being built: Swift/vendor/{jpeg,freetype,webp}. They are
# committed, so run this only to update a library.
#
# JPEG through libjpeg-turbo (without its SIMD code), PNG through zlib, fonts
# through FreeType, and WebP. TIFF, JPEG 2000, colour management and complex
# text layout are left out; Pillow reports them as unavailable.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/.build/vendor-sources"
OUT="$ROOT/Swift/vendor"

fetch() {  # repository, tag, directory
    [ -d "$SRC/$3" ] || git clone -q --depth 1 --branch "$2" "https://github.com/$1.git" "$SRC/$3"
}
mkdir -p "$SRC"
fetch libjpeg-turbo/libjpeg-turbo 3.1.4.1 libjpeg-turbo
fetch freetype/freetype VER-2-15-0 freetype
fetch webmproject/libwebp v1.6.0 libwebp

rm -rf "$OUT"
mkdir -p "$OUT"

# libjpeg-turbo: the headers CMake would generate, for 64-bit Apple platforms.
JPEG="$OUT/jpeg"
mkdir -p "$JPEG/include"
cp -R "$SRC/libjpeg-turbo/src" "$JPEG/src"
cp "$SRC/libjpeg-turbo/LICENSE.md" "$SRC/libjpeg-turbo/README.ijg" "$JPEG/"
sed -e 's/@JPEG_LIB_VERSION@/62/' -e 's/@VERSION@/3.1.4.1/' \
    -e 's/@LIBJPEG_TURBO_VERSION_NUMBER@/3001004/' \
    -e 's/#cmakedefine C_ARITH_CODING_SUPPORTED 1/#define C_ARITH_CODING_SUPPORTED 1/' \
    -e 's/#cmakedefine D_ARITH_CODING_SUPPORTED 1/#define D_ARITH_CODING_SUPPORTED 1/' \
    -e 's|#cmakedefine \(.*\)|/* #undef \1 */|' \
    "$JPEG/src/jconfig.h.in" > "$JPEG/src/jconfig.h"
sed -e 's/@BUILD@/swiftpy/' -e 's/@HIDDEN@/__attribute__((visibility("hidden")))/' \
    -e 's/@INLINE@/__inline__ __attribute__((always_inline))/' -e 's/@THREAD_LOCAL@/__thread/' \
    -e 's/@CMAKE_PROJECT_NAME@/libjpeg-turbo/' -e 's/@VERSION@/3.1.4.1/' -e 's/@SIZE_T@/8/' \
    -e 's/#cmakedefine HAVE_BUILTIN_CTZL/#define HAVE_BUILTIN_CTZL/' \
    -e 's/#cmakedefine C_ARITH_CODING_SUPPORTED 1/#define C_ARITH_CODING_SUPPORTED 1/' \
    -e 's/#cmakedefine D_ARITH_CODING_SUPPORTED 1/#define D_ARITH_CODING_SUPPORTED 1/' \
    -e 's|#cmakedefine \(.*\)|/* #undef \1 */|' \
    "$JPEG/src/jconfigint.h.in" > "$JPEG/src/jconfigint.h"
sed -e 's/@COPYRIGHT_YEAR@/1991-2026/' "$JPEG/src/jversion.h.in" > "$JPEG/src/jversion.h"
cp "$JPEG/src/"{jpeglib.h,jmorecfg.h,jerror.h,jconfig.h} "$JPEG/include/"
# jpeglib.h needs FILE and size_t declared first, so it is no module alone.
printf '#include <stddef.h>\n#include <stdio.h>\n#include "jpeglib.h"\n' > "$JPEG/include/Cjpeg.h"
printf 'module Cjpeg {\n    header "Cjpeg.h"\n    export *\n}\n' > "$JPEG/include/module.modulemap"

# FreeType with its default modules and options: its own zlib copy, no PNG.
mkdir -p "$OUT/freetype"
cp -R "$SRC/freetype/src" "$SRC/freetype/include" "$OUT/freetype/"
cp "$SRC/freetype/LICENSE.TXT" "$OUT/freetype/"
# Only ft2build.h: the rest is included through its macros, internal headers too.
printf 'module Cfreetype {\n    header "ft2build.h"\n    export *\n}\n' > "$OUT/freetype/include/module.modulemap"

# libwebp; dependents include <webp/...>, its own sources "src/...".
mkdir -p "$OUT/webp/include"
cp -R "$SRC/libwebp/src" "$SRC/libwebp/sharpyuv" "$OUT/webp/"
cp -R "$SRC/libwebp/src/webp" "$OUT/webp/include/"
cp "$SRC/libwebp/COPYING" "$SRC/libwebp/PATENTS" "$OUT/webp/"

echo "staged $(du -sh "$OUT" | cut -f1) of sources"
