# 📽️ Extractor - Video Segment & Frame Extractor

## 📌 Overview
**Extractor** is a simple command-line tool for extracting video segments or single frames using **FFmpeg**. It allows users to specify start times, durations, and output filenames interactively.

This tool is part of the **Video-Tools** repository, available at:
📦 [GitHub Repository](https://github.com/painteau/Video-Tools)

---

## 📂 Location in Repository
This tool is located inside the **Extract/** folder in the repository structure.

---

## 🚀 Features
- ✅ Extract a **video segment** with a defined start time and duration.
- ✅ Extract a **single frame** at a precise timestamp.
- ✅ Interactive user input for file selection and extraction parameters.
- ✅ **Automatic FFmpeg verification** to ensure installation before running.
- ✅ **Error handling** for missing files or invalid input.

---

## 🛠️ Requirements
- **FFmpeg** must be installed and added to the system PATH.

To check if FFmpeg is installed, run:
```sh
ffmpeg -version
```
If it's not installed, download it from [FFmpeg Official Website](https://ffmpeg.org/download.html).

---

## 🔧 Installation
1. Clone this repository:
   ```sh
   git clone https://github.com/painteau/Video-Tools.git
   cd Video-Tools/Extract
   ```
2. Ensure `FFmpeg` is installed and accessible.

---

## ▶️ Usage
Run the script:
```sh
Extractor.cmd
```
Follow the on-screen prompts to:
1. Select a video file.
2. Enter the **start time** (HH:MM:SS.mmm format).
3. Enter the **duration** of the video segment (if applicable).
4. Choose to extract a **frame or a full segment**.
5. Provide an **output filename**.

---

## 📝 Example Commands
### 🎬 Extract a Video Segment
```sh
Enter the input video file: sample.mp4
Enter the start time: 00:01:30.500
Enter the duration: 00:00:10.000
Enter the output file name: clip.mp4
```

### 📸 Extract a Single Frame
```sh
Enter the input video file: sample.mp4
Enter the start time: 00:01:30.500
Extract a single frame? (y/n) [default: n]: y
Enter the output file name: frame.png
```

---

## ❗ Troubleshooting
### FFmpeg Not Found
If FFmpeg is missing, ensure it is installed and available in the system PATH:
- On **Windows**: Add the FFmpeg binary folder to your environment variables.
- On **Mac/Linux**: Install via package manager:
  ```sh
  sudo apt install ffmpeg   # Debian-based systems
  brew install ffmpeg       # macOS (Homebrew)
  ```

### Invalid Input Format
Ensure that:
- The **time format** is `HH:MM:SS.mmm` (milliseconds are optional but recommended).
- The **video file exists** in the specified path.

---

## 📜 License
This project is licensed under the **MIT License**.

---

## 💡 Contributing
1. Fork this repository.
2. Create a new branch (`feature-xyz`).
3. Commit your changes.
4. Open a Pull Request.

---

## 📬 Contact
For issues or suggestions, open an issue on GitHub.

