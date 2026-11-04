// swift-tools-version: 6.4
import Foundation
import PackageDescription

// Pillow as a Swift package: PIL's C modules built in, the Python package as
// bytecode in a zip. Adds about 7.2 MB to an iOS app: 6.5 of code, FreeType the
// most, and 0.7 of Python. Compiled against CPython's staged headers, so it follows
// whichever cpython checkout it builds with.
let packageDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let cpythonOverride = ProcessInfo.processInfo.environment["SWIFTPY_CPYTHON_PATH"]
let cpythonPath = URL(fileURLWithPath: cpythonOverride ?? "../cpython", relativeTo: packageDirectory)
    .standardizedFileURL.path

let pythonHeaders: [CSetting] = [
    (".cpython-dist", Platform.macOS), (".cpython-dist-iphoneos", .iOS), (".cpython-dist-xros", .visionOS),
].map { dist, platform in
    .unsafeFlags([
        "-I\(cpythonPath)/Swift/\(dist)/include/python",
        "-I\(cpythonPath)/Swift/\(dist)/include/python/internal",
    ], .when(platforms: [platform]))
}

let package = Package(
    name: "Pillow",
    platforms: [.macOS("15.4"), .iOS("18.4"), .visionOS("2.4")],
    products: [
        .library(name: "PIL", targets: ["PIL"]),
    ],
    dependencies: [
        cpythonOverride.map { .package(path: $0) }
            ?? .package(url: "https://github.com/libswiftpy/cpython.git", exact: "3.15.2-swiftpy.2"),
    ],
    targets: [
        // JPEG, FreeType and WebP, from Swift/stage-vendor.sh, which only an update needs.
        .target(
            name: "Cjpeg",
            path: "Swift/vendor/jpeg",
            sources: [
                "src/jcapimin.c", "src/wrapper/jcapistd-8.c", "src/wrapper/jcapistd-12.c",
                "src/wrapper/jcapistd-16.c", "src/wrapper/jccoefct-8.c",
                "src/wrapper/jccoefct-12.c", "src/wrapper/jccolor-8.c", "src/wrapper/jccolor-12.c",
                "src/wrapper/jccolor-16.c", "src/wrapper/jcdctmgr-8.c",
                "src/wrapper/jcdctmgr-12.c", "src/wrapper/jcdiffct-8.c",
                "src/wrapper/jcdiffct-12.c", "src/wrapper/jcdiffct-16.c", "src/jchuff.c",
                "src/jcicc.c", "src/jcinit.c", "src/jclhuff.c", "src/wrapper/jclossls-8.c",
                "src/wrapper/jclossls-12.c", "src/wrapper/jclossls-16.c",
                "src/wrapper/jcmainct-8.c", "src/wrapper/jcmainct-12.c",
                "src/wrapper/jcmainct-16.c", "src/jcmarker.c", "src/jcmaster.c", "src/jcomapi.c",
                "src/jcparam.c", "src/jcphuff.c", "src/wrapper/jcprepct-8.c",
                "src/wrapper/jcprepct-12.c", "src/wrapper/jcprepct-16.c",
                "src/wrapper/jcsample-8.c", "src/wrapper/jcsample-12.c",
                "src/wrapper/jcsample-16.c", "src/jctrans.c", "src/jdapimin.c",
                "src/wrapper/jdapistd-8.c", "src/wrapper/jdapistd-12.c",
                "src/wrapper/jdapistd-16.c", "src/jdatadst.c", "src/jdatasrc.c",
                "src/wrapper/jdcoefct-8.c", "src/wrapper/jdcoefct-12.c", "src/wrapper/jdcolor-8.c",
                "src/wrapper/jdcolor-12.c", "src/wrapper/jdcolor-16.c", "src/wrapper/jddctmgr-8.c",
                "src/wrapper/jddctmgr-12.c", "src/wrapper/jddiffct-8.c",
                "src/wrapper/jddiffct-12.c", "src/wrapper/jddiffct-16.c", "src/jdhuff.c",
                "src/jdicc.c", "src/jdinput.c", "src/jdlhuff.c", "src/wrapper/jdlossls-8.c",
                "src/wrapper/jdlossls-12.c", "src/wrapper/jdlossls-16.c",
                "src/wrapper/jdmainct-8.c", "src/wrapper/jdmainct-12.c",
                "src/wrapper/jdmainct-16.c", "src/jdmarker.c", "src/jdmaster.c",
                "src/wrapper/jdmerge-8.c", "src/wrapper/jdmerge-12.c", "src/jdphuff.c",
                "src/wrapper/jdpostct-8.c", "src/wrapper/jdpostct-12.c",
                "src/wrapper/jdpostct-16.c", "src/wrapper/jdsample-8.c",
                "src/wrapper/jdsample-12.c", "src/wrapper/jdsample-16.c", "src/jdtrans.c",
                "src/jerror.c", "src/jfdctflt.c", "src/wrapper/jfdctfst-8.c",
                "src/wrapper/jfdctfst-12.c", "src/wrapper/jfdctint-8.c",
                "src/wrapper/jfdctint-12.c", "src/wrapper/jidctflt-8.c",
                "src/wrapper/jidctflt-12.c", "src/wrapper/jidctfst-8.c",
                "src/wrapper/jidctfst-12.c", "src/wrapper/jidctint-8.c",
                "src/wrapper/jidctint-12.c", "src/wrapper/jidctred-8.c",
                "src/wrapper/jidctred-12.c", "src/jmemmgr.c", "src/jmemnobs.c", "src/jpeg_nbits.c",
                "src/wrapper/jquant1-8.c", "src/wrapper/jquant1-12.c", "src/wrapper/jquant2-8.c",
                "src/wrapper/jquant2-12.c", "src/wrapper/jutils-8.c", "src/wrapper/jutils-12.c",
                "src/wrapper/jutils-16.c", "src/jaricom.c", "src/jcarith.c", "src/jdarith.c",
            ],
            publicHeadersPath: "include"
        ),
        .target(
            name: "Cfreetype",
            path: "Swift/vendor/freetype",
            sources: [
                "src/autofit/autofit.c", "src/base/ftbase.c", "src/base/ftbbox.c",
                "src/base/ftbdf.c", "src/base/ftbitmap.c", "src/base/ftcid.c",
                "src/base/ftfstype.c", "src/base/ftgasp.c", "src/base/ftglyph.c",
                "src/base/ftgxval.c", "src/base/ftinit.c", "src/base/ftmm.c", "src/base/ftotval.c",
                "src/base/ftpatent.c", "src/base/ftpfr.c", "src/base/ftstroke.c",
                "src/base/ftsynth.c", "src/base/fttype1.c", "src/base/ftwinfnt.c", "src/bdf/bdf.c",
                "src/bzip2/ftbzip2.c", "src/cache/ftcache.c", "src/cff/cff.c",
                "src/cid/type1cid.c", "src/gzip/ftgzip.c", "src/hvf/hvf.c", "src/lzw/ftlzw.c",
                "src/pcf/pcf.c", "src/pfr/pfr.c", "src/psaux/psaux.c", "src/pshinter/pshinter.c",
                "src/psnames/psnames.c", "src/raster/raster.c", "src/sdf/sdf.c", "src/sfnt/sfnt.c",
                "src/smooth/smooth.c", "src/svg/svg.c", "src/truetype/truetype.c",
                "src/type1/type1.c", "src/type42/type42.c", "src/winfonts/winfnt.c",
                "src/base/ftsystem.c", "src/base/ftdebug.c",
            ],
            publicHeadersPath: "include",
            cSettings: [.define("FT2_BUILD_LIBRARY")]
        ),
        .target(
            name: "Cwebp",
            path: "Swift/vendor/webp",
            sources: ["src/dec", "src/dsp", "src/enc", "src/utils", "src/demux", "src/mux", "sharpyuv"],
            publicHeadersPath: "include",
            cSettings: [.headerSearchPath(".")]
        ),
        // PNG goes through zlib.
        .target(
            name: "CPIL",
            dependencies: ["Cjpeg", "Cfreetype", "Cwebp"],
            path: ".",
            sources: [
                "src/_imaging.c", "src/decode.c", "src/encode.c", "src/map.c", "src/display.c",
                "src/outline.c", "src/path.c", "src/libImaging", "src/_imagingft.c", "src/_webp.c",
                "src/_imagingmath.c", "src/_imagingmorph.c", "Swift/Sources/CPIL/shim.c",
            ],
            publicHeadersPath: "Swift/Sources/CPIL",
            cSettings: pythonHeaders + [
                .define("HAVE_LIBJPEG"), .define("HAVE_LIBZ"), .define("PILLOW_VERSION", to: "\"13.0.0\""),
            ],
            linkerSettings: [.linkedLibrary("z")]
        ),
        .target(
            name: "PIL",
            dependencies: [.product(name: "PythonModules", package: "cpython"), "CPIL"],
            path: "Swift/Sources/PIL",
            exclude: ["modules.txt"],
            plugins: [.plugin(name: "StageStdlib", package: "cpython")]
        ),
        .testTarget(
            name: "PILTests",
            dependencies: ["PIL", .product(name: "Python", package: "cpython")],
            path: "Swift/Tests/PILTests"
        ),
    ]
)
