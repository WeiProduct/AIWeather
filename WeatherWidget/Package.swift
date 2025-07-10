// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "WeatherWidget",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "WeatherWidget",
            targets: ["WeatherWidget"]),
    ],
    targets: [
        .target(
            name: "WeatherWidget",
            dependencies: []),
    ]
)
