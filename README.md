# SwiftStore 🚀

> **The All-In-One iOS & iPadOS Creation Studio and Sideloading Hub**

**SwiftStore** is a PC-free tool designed for iPad and iOS users. It bridges Apple’s **Swift Playgrounds** with GitHub Actions cloud compilation, allowing you to build, sign, and install your own custom applications—directly on your device, completely free, and without needing a Mac, Xcode, or a paid Apple Developer account.

Built with complete compatibility for **SideStore** core features, SwiftStore also serves as a full-featured sideloading manager and drop-in replacement for traditional iOS app installers.

---

## 🛠️ How It Works (The Pipeline)

```text
[ Swift Playgrounds (.swiftpm) ]
               │
               ▼
   [ SwiftStore iPad Hub ] ────► Authenticate (GitHub OAuth + Apple ID)
               │
               ▼
     [ GitHub Actions ] ────────► Cloud macOS Runner (`xcodebuild`)
               │
               ▼
   [ Direct .IPA Output ]
               │
               ▼
[ Local On-Device Signing ] ───► App Installed on Home Screen!
```

1. **Develop:** Write code or design your game directly in Swift Playgrounds on iPad.
2. **Export:** Pass your exported `.swiftpm` package directly into SwiftStore.
3. **Cloud Build:** SwiftStore creates a private GitHub repository on your account and triggers a pre-configured GitHub Actions workflow.
4. **Compile:** A macOS virtual machine in the cloud compiles your Swift project into a signed or unsigned `.ipa` package.
5. **Install:** SwiftStore retrieves the output `.ipa`, signs it on-device using your Apple ID via local loopback networking, and installs it straight to your home screen.

---

## ✨ Core Features

* 📱 **100% On-Device Creation:** Go from raw `.swiftpm` code to a running app on your home screen without touching a computer.
* 🔄 **Built-in Sideloading Engine:** Full SideStore compatibility—manage on-device resigning, background refreshing, and local 7-day certificate management.
* 📦 **External Repository Support:** Native support for standard AltStore/SideStore JSON source formats (`sources.json`) to browse community apps or install `.ipa` files from direct URLs.
* ☁️ **Zero-Cost Infrastructure:** Leverages free GitHub private repos and GitHub Actions minutes to handle heavy compilation without draining local iPad resources.
* 🎯 **Decentralized App Sharing:** Share your projects via standard GitHub repositories or source links without central server dependencies.

---

## 🚀 Getting Started

### Prerequisites
* An iPad running **iPadOS 16.0** or later.
* A free **GitHub Account** (for cloud build workflows).
* A free **Apple ID** (used strictly for local on-device app provisioning).

### Installation via SwiftInstaller

To install SwiftStore for the first time without a computer, use **SwiftInstaller**—our lightweight, single-purpose bootstrap tool:

1. Download the latest **SwiftInstaller** release.
2. Follow the on-screen setup wizard to configure the initial local loopback pairing.
3. SwiftInstaller will install **SwiftStore** onto your device.
4. **Once installed, you can immediately delete SwiftInstaller!** SwiftStore manages all ongoing signing, refreshing, and builds internally.

---

## ⚙️ Cloud Quotas & Usage Guidelines

Because SwiftStore relies on GitHub Actions' free tier:
* **Build Frequency:** Free GitHub accounts receive 2,000 Action minutes per month. Since macOS runners use a 10x multiplier, you can typically run **15 to 20 full app builds per month** for free.
* **Build Duration:** Cloud compilation typically takes between 2 to 5 minutes depending on project complexity and GitHub runner availability.

---

## 🔒 Security & Privacy

* **Local Signing:** Your Apple ID credentials are used strictly for authenticating with Apple's staging APIs via local device loopback (`127.0.0.1`) and are never sent to external third-party servers.
* **Private Repositories:** All code uploaded to GitHub is pushed exclusively to private repositories under your personal GitHub account.

---

## 📜 Open Source & Licensing

SwiftStore is a fork/derivative of [SideStore](https://github.com/SideStore/SideStore) and is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

* **Upstream Attribution:** Contains code, submodules, and logic derived from SideStore and AltStore under AGPL-3.0.
* **Copyleft:** Any modifications or extensions to this repository must remain open-source under the same AGPL-3.0 terms.

---

<p align="center">
  Built with ❤️ for the iPad developer & sideloading community.
</p>
