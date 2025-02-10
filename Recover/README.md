# 🔄 Recover - Unfinalized Video & Audio Stream Recovery

## 📌 Overview
**Recover** is a powerful utility designed to **recover video and audio streams** from **unfinalized MP4/MOV/3GP files** that are missing or have an empty header. This is useful in cases where a recording was interrupted due to camcorder damage or power failure.

### 🎥 Supported Video Formats
- **AVC/H.264**
- **HEVC/H.265**

### 🎵 Supported Audio Formats
- **AAC**
- **ADPCM (Intel)**
- **MP3**
- **PCM (LE, BE, float)**
- **RAW**

---

## 🚀 Usage

### 🔍 Step 1: Analyze a Good File
To generate a **header file** from a similar, working video:
```sh
recover_mp4.exe good.mp4 --analyze
```
This will create `video.hdr` and `audio.hdr` files in the current directory and display **FFmpeg instructions** for reconstruction.

### 🛠 Step 2: Recover Streams from a Corrupted File
```sh
recover_mp4.exe bad.mp4 recovered.h264 recovered.aac
```
Ensure that `video.hdr` and `audio.hdr` exist in the current directory. You may need to add specific recovery options (see Step 1 output for guidance).

### 🔄 Step 3: Recreate the MP4/MOV File
#### 🔹 Standard MP4 Recovery
```sh
ffmpeg.exe -r 30 -i recovered.h264 -i recovered.aac -bsf:a aac_adtstoasc -c:v copy -c:a copy recovered.mp4
```
#### 🎵 PCM Audio (MOV Format)
```sh
ffmpeg.exe -r 30 -i recovered.h264 -i recovered.wav -c:v copy -c:a copy recovered.mov
```
#### 🎤 ADPCM Audio (MOV Format)
```sh
ffmpeg.exe -r 30 -i recovered.h264 -i recovered.wav -c:v copy -c:a adpcm_ima_wav recovered.mov
```
**Note:** Replace `30` with the correct FPS value. If your video uses **29.97 FPS**, specify `30000/1001` instead.

---

## ⚙️ Advanced Options

### 🎯 Basic Options
```sh
recover_mp4 in_good_similar.mp4 --analyze
recover_mp4 in_corrupted.mp4 {out_video.h264 | out_video.hevc | --novideo} {out_audio.aac | out_audio.wav | out_audio.mp3 | out_audio.raw | --noaudio} [options]
```
- `--start` → Read from a specific position (ignoring `mdat` atom)
- `--end` → Define an end position (`0` for EOF)
- `--avcidrmax` → Ignore **AVC IDR NAL units** above a specified size (bytes)
- `--avcxmax` → Ignore **AVC non-IDR NAL units** above a specified size (bytes)
- `--aacmin` → Minimum allowed AAC frame size, used to filter out corrupted or incomplete AAC frames, ensuring a cleaner audio recovery.

### 🏆 Camcorder-Specific Recovery Modes
- `--gopro4` → GoPro Hero 4 detection (default for MP4)
- `--ambarella` → Ambarella-based cameras
- `--qt` → QuickTime format (default for MOV files)
- `--eos` → Canon EOS cameras
- `--eos2` → Canon EOS extended format
- `--vmix` → vMix templates
- `--blackmagic` → BlackMagic templates
- `--g7` → Panasonic DMC-G7
- `--a7sm2` → Sony A7S Mark II
- `--drim` → Samsung NX1000 (DRIMeIII)
- `--drim5` → Samsung NX1/NX500 (DRIMeV HEVC/H.265)
- `--hevc` → Generic HEVC/H.265 recovery
- `--ext` → Generic recovery mode (for any camcorder/smartphone)

---

## ❗ Troubleshooting
- Ensure `video.hdr` and `audio.hdr` exist before attempting recovery.
- Use the correct **frame rate (FPS)** when remuxing with FFmpeg.
- If issues persist, try different camcorder-specific modes (`--gopro4`, `--eos`, etc.).

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

