import PackageDescription

let package = Package(
    name: "Yajl",
    targets: [
        Target(name: "YajlConfig", dependencies: []),
        Target(name: "Yajl", dependencies: ["YajlConfig"])
    ],
    dependencies: [
        .Package(url: "../CYajl", "0.1.2")
    ],
    exclude: ["Tools", "Makefile"]
)
