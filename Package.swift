// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TargetJournal",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "TargetJournalCore",
            targets: ["TargetJournalCore"]
        ),
    ],
    targets: [
        .target(
            name: "TargetJournalCore",
            path: "TargetJournal",
            exclude: ["App/Assets.xcassets", "App/TargetJournalApp.swift"]
        ),
        .testTarget(
            name: "TargetJournalTests",
            dependencies: ["TargetJournalCore"],
            path: "TargetJournalTests"
        )
    ]
)
