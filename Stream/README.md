# 📡 Stream - Automated Video Streaming

## 📌 Overview
**Stream** is a lightweight tool that enables automated video streaming using a predefined playlist. Simply configure your streaming parameters and add videos to the designated folder to begin streaming.

This tool is part of the **Video-Tools** repository:  
📦 [GitHub Repository](https://github.com/painteau/Video-Tools)

---

## 🚀 Usage

### 1️⃣ Configure Streaming Settings
Edit the `stream.config` file to set your streaming parameters.

### 2️⃣ Add Videos
Place all the videos you want to stream in the `videos/` folder.

### 3️⃣ Start Streaming
Run the script:
```sh
Stream.cmd
```
The tool will read the configuration file and stream the videos in order.

---

## 🔧 Configuration
The `stream.config` file contains all the necessary parameters for the streaming session. Below is a breakdown of each setting:

- **resolution**: Set the output video resolution (e.g., `1920x1080`).
- **bitrate**: Define the video bitrate in kbps (e.g., `6000`).
- **buffersize**: Specify the buffer size for the stream (e.g., `600`).
- **serveur**: Define the RTMP server URL for streaming (e.g., `rtmp://live.restream.io/live/re_1_`).
- **bitaudio**: Set the audio bitrate in kbps (e.g., `128`).

Ensure these values match the requirements of your streaming platform before running the script.

---

## ❗ Troubleshooting
- Ensure `stream.config` is correctly configured.
- Check that the `videos/` folder contains valid video files.
- Verify that the streaming platform supports the configured parameters.

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

