<p align="center">
  <img src="https://github.com/user-attachments/assets/3d63fb0d-d961-47ea-bcdd-81394bdc70f4" width="160" alt="AeroBrowser Logo">
</p>

<h1 align="center">AeroBrowser</h1>
<p align="center">
  A modern, privacy-friendly web browser for macOS — designed with performance and elegance in mind.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.1-blueviolet?style=flat-square" />
  <img src="https://img.shields.io/github/license/aerobrowser/aerobrowser?style=flat-square" />
  <img src="https://img.shields.io/badge/macOS-14+-lightgrey?style=flat-square" />
</p>

---

## ✨ Features

- 🚫 Built-in **Ad Blocker**
- 📚 **Bookmarks & Library** support
- 🔍 **Search & Visit History**
- 🌐 Customizable **Search Engine Providers**
- 🧹 Auto-delete history after specific periods
- 🔄 **Auto-updater** (Sparkle-integrated — see note below)
- 🧠 Smart address bar with enhanced search logic
- 🛡️ Browser fingerprint resistance
- 🎨 Sleek, gradient-based UI
- 🧪 Experimental toggles in Settings

---

## 📸 Screenshots

<img src="https://github.com/user-attachments/assets/b96d92d1-5e28-44ae-873f-93f4337bf26f" width="400">
<img src="https://github.com/user-attachments/assets/5e71dca1-a3d6-4978-82db-e8cff5594d7d" width="400">

---

## 📦 Installation

AeroBrowser is distributed as a `.pkg` installer.

### ➡️ [Download AeroBrowser.pkg](https://github.com/aerobrowser/aerobrowser/releases/latest)

- This is the recommended method for **new users** or **manual installation**.
- Simply open the `.pkg` file and follow the installer steps.

> ⚠️ **Do not open or touch the `.zip` update file.**  
> It is used by **Sparkle auto-updater** internally and may not behave correctly if run manually.  
> Sparkle update launching is currently **bugged** and will be fixed in v1.0.2.

---

## 🛠️ Build Instructions

```bash
git clone https://github.com/aerobrowser/aerobrowser.git
cd aerobrowser
open AeroBrowser.xcodeproj
