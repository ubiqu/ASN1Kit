// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ASN1Kit",
    products: [
        .library(name: "ASN1Kit", targets: ["ASN1Kit"]),
    ],
    targets: [
        .target(name: "ASN1Kit", dependencies: []),
        .testTarget(name: "ASN1KitTests", dependencies: ["ASN1Kit"]),
    ]
)
