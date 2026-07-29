import Foundation

public final class CloudBuildServiceCore {
    public init() {}

    public func buildWorkflowYAML(projectName: String) -> String {
        return """
name: Build

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Swift
        uses: fwal/setup-swift@v2
        with:
          swift-version: '5.8'
      - name: Build
        run: swift build --disable-sandbox
      - name: Run tests
        run: swift test --disable-sandbox
"""
    }
