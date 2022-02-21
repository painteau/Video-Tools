# FFMPEG Tools

This utility can recover video and audio streams from unfinalized MP4/MOV/3GP files without (or empty) header.
You may got the unfinalized file in case of damaging camcorder during recording or such.

Supported video formats: AVC/H.264, HEVC/H.265

Supported audio formats: AAC, ADPCM (Intel), MP3, PCM (LE, BE, float), RAW

Usage:
recover_mp4 in_good_similar.mp4 --analyze
recover_mp4 in_corrupted.mp4 {out_video.h264 | out_video.hevc | --novideo}
[out_audio.aac | out_audio.wav | out_audio.mp3 | out_audio.raw | --noaudio] [options]
Options:
--start read from position (ignore mdat atom)
--end end position (ignore mdat atom). Specify 0 for EOF
--avcidrmax ignore AVC NAL units (IDR) with the size above than bytes
--avcxmax ignore AVC NAL units (non IDR) with the size above than bytes
--aacmin

--gopro4 use Ambarella templates and detect GoPro4 specific data. Default for MP4 files.
--ambarella use Ambarella templates (ignore GoPro4 specific data).
--qt use QuickTime templates. Default for MOV files.
--eos use Canon EOS templates
--eos2 use Canon EOS extended templates
--vmix use vMix templates
--blackmagic use BlackMagic templates
--g7 use Panasonic DMC-G7
--a7sm2 use SONY A7S Mark II templates
--drim use DRIMeIII templates (Samsung NX1000 camcorder)
--drim5 use DRIMeV HEVC/H.265 templates (Samsung NX1/NX500 camcorder)
--hevc use generic HEVC/H.265 templates
--ext use generic templates for any other camcorder or smartphone

Step 1: Use any good previous file with the same resolution and bitrate to generate the header files, for example

>recover_mp4.exe good.mp4 --analyze

It will create files 'video.hdr' and 'audio.hdr' in the current directory and print instructions (ffmpeg options, etc.).

Step 2: Recover streams from the corrupted file, for example

>recover_mp4.exe bad.mp4 recovered.h264 recovered.aac

Note: Files 'video.hdr' and 'audio.hdr' must be exist.
Probably you need to add a specific option (look at instructions from step 1).

Step 3: Use any other utility (Yamb or ffmpeg for example)
to recreate the MP4/MOV file from the streams (recovered.h264 and recovered.aac).

>ffmpeg.exe -r 30 -i recovered.h264 -i recovered.aac -bsf:a aac_adtstoasc -c:v copy -c:a copy recovered.mp4

Note MP4 does not support PCM sound, you must create MOV in this case:

>ffmpeg.exe -r 30 -i recovered.h264 -i recovered.wav -c:v copy -c:a copy recovered.mov

In case of ADPCM audio:

>ffmpeg -r 30 -i recovered.h264 -i recovered.wav -c:v copy -c:a adpcm_ima_wav recovered.mov

Note: 30 is FPS in these examples. Specify your correct value.
In case of 29.97 I suggest to specify 30000/1001 instead.