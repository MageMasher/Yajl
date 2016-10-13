import PackageDescription

let package = Package(
    name: "Yajl",
    targets: [
        Target(name: "YajlConfig", dependencies: []),
        Target(name: "Yajl", dependencies: ["YajlConfig"])
    ],
    dependencies: [
        .Package(url: "https://github.com/baberthal/CYajl.git", "0.1.2")
    ],
    exclude: ["Tools", "Makefile", "README.md"]
)
