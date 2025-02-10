# 🎥 Video-Tools

## 📌 Overview
**Video-Tools** is a collection of scripts and utilities designed for various video processing tasks, including conversion, extraction, recovery, and streaming. The project provides simple, command-line-based tools to streamline video workflows.

---

## 📂 Project Structure

- **Convert/** – Scripts for converting and merging video files.
- **Extract/** – Tools for extracting content from video files.
- **FFMPEG/** – Setup and configuration for **FFMPEG**.
- **Recover/** – Tools for recovering corrupted video files.
- **Stream/** – Scripts and settings for video streaming.

---

## 🚀 Getting Started

### 📥 Prerequisites
Ensure that **FFMPEG** is installed on your system. Some scripts might require administrator privileges.

### 📌 Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/video-tools.git
   cd video-tools
   ```
2. Install dependencies (if needed):
   ```bash
   ./FFMPEG/"[With Admin rights] FFMPEG Setup.exe"
   ```

---

## 🛠 Usage

### 🎬 Video Conversion
Inside the **Convert/** folder, different scripts handle various formats. Some key scripts include:
```bash
Convert/ALL-2/Convert.cmd   # Convert all videos to your choice of encoding
Convert/Drag&Drop/iConvert-FLV-2-MP4.cmd    # Convert FLV to MP4 using drag & drop
```

### 🎞️ Video Extraction
Extract content from videos using:
```bash
Extract/Extractor.cmd
```

### 🛠 Video Recovery
To recover corrupted MP4 files:
```bash
Recover/recover_mp4.cmd   # Run recovery script
```

### 📡 Streaming Setup
To start a video stream:
```bash
Stream/Stream.cmd
```
Configuration settings can be adjusted in:
```bash
Stream/stream.config
```

---

## 🔧 Troubleshooting
- Ensure that **FFMPEG** is correctly installed.
- Run scripts as **Administrator** if required.
- Some scripts rely on specific codecs; install missing dependencies if prompted.

---

## 📜 License
This project is licensed under the **MIT License**.

---

## 💡 Contributing
1. Fork the repository.
2. Create a new branch (`feature-xyz`).
3. Commit your changes.
4. Open a Pull Request.

---

## 📬 Contact
For issues or improvements, open an issue on GitHub.

