// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "TikerService",
    products: [
        .library(name: "TikerService", targets: ["App"]),
    ],
    dependencies: [
      // 💧 A server-side Swift web framework.
      .package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),
      
      // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
      .package(url: "https://github.com/vapor/websocket.git", from: "1.1.2"),
      .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2"),
      .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.1")
  ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "WebSocket", "Leaf", "Jobs"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

