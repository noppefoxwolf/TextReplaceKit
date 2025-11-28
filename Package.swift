// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TextReplaceKit",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "TextReplaceKit",
            targets: [
                "TextReplaceKit",
                "ShortcodeReplace",
            ]
        )
    ],
    targets: [
        .target(
            name: "TextReplaceKit",
            dependencies: [
                "ShortcodeReplace",
                "PaddingInsert",
                "AttachmentReplace",
            ]
        ),
        .target(
            name: "ShortcodeReplace",
            dependencies: [
                "Extensions"
            ]
        ),
        .target(
            name: "AttachmentReplace",
            dependencies: [
                "Extensions"
            ]
        ),
        .target(
            name: "PaddingInsert",
            dependencies: [
                "Extensions"
            ]
        ),
        .target(
            name: "Extensions"
        ),
        .testTarget(
            name: "TextReplaceKitTests",
            dependencies: [
                "TextReplaceKit",
                "Extensions"
            ]
        ),
    ]
)
