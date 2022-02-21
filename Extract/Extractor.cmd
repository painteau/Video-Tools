ffmpeg -ss 00:51:36.0 -i AAA.mp4 -t 00:03:07.0 -vcodec copy -acodec copy OUTPUT_FILE.mp4

:: USAGE 
:: ffmpeg --ss START_TIME_HH:MIN:SEC.FRAME -i INPUT_FILE.mp4 -t DURATION_TIME_HH:MIN:SEC.FRAME -vcodec copy -acodec copy OUTPUT_FILE.mp4