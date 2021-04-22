// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ASN1Kit",
    products: [
        .library(name: "ASN1Kit", targets: ["ASN1Kit"]),
    ],
    targets: [
        .binaryTarget(
            name: "ASN1Kit",
            path: "xcframework/ASN1Kit.xcframework")
    ]
)
