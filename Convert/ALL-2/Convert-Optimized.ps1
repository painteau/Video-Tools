# Optimized Batch Video Converter with Parallel Processing & GPU Acceleration
# PowerShell version with significant performance improvements

param(
    [string]$ConfigPath = "..\..\config.ini",
    [string]$InputDir = "ORIGINAL",
    [string]$OutputDir = "OUTPUT"
)

# Import core library
$libPath = Join-Path $PSScriptRoot "..\..\lib\VideoToolsCore.ps1"
. $libPath

# Check if FFmpeg is installed
try {
    $null = & ffmpeg -version 2>&1
} catch {
    Write-Host "ERROR: FFmpeg not found. Please install it and ensure it's in PATH." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Load configuration
$config = Read-Config -ConfigPath (Join-Path $PSScriptRoot $ConfigPath)

# Detect GPU capabilities
$gpuAccel = Get-HardwareAcceleration -Preference $config.General.HardwareAccel

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Display menu
Clear-Host
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   OPTIMIZED VIDEO CONVERTER (Parallel + GPU)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Hardware Acceleration: " -NoNewline
Write-Host $gpuAccel.Type.ToUpper() -ForegroundColor Green
Write-Host ""
Write-Host "Select conversion type:" -ForegroundColor Yellow
Write-Host "[1]  MP4 H.264 (fast, compatible)"
Write-Host "[2]  MP4 H.265 (smaller size, slower)"
Write-Host "[3]  WebM VP8 (web-friendly)"
Write-Host "[4]  WebM VP9 (best for web, 2-pass)"
Write-Host "[5]  AV1 (best compression, very slow)"
Write-Host "[6]  ProRes (editing, large files)"
Write-Host "[7]  DNxHD/DNxHR (editing)"
Write-Host "[8]  HAP (real-time playback)"
Write-Host "[9]  Normalize audio only"
Write-Host "[10] Stream copy (no re-encode)"
Write-Host ""

$choice = Read-Host "Enter your choice (1-10)"

# Resolution selection for re-encoding
$resolutions = @{
    "1" = @{Name="8K UHD"; Size="7680x4320"; Width=7680; Height=4320}
    "2" = @{Name="4K UHD"; Size="3840x2160"; Width=3840; Height=2160}
    "3" = @{Name="1440p QHD"; Size="2560x1440"; Width=2560; Height=1440}
    "4" = @{Name="1080p FHD"; Size="1920x1080"; Width=1920; Height=1080}
    "5" = @{Name="720p HD"; Size="1280x720"; Width=1280; Height=720}
    "6" = @{Name="480p SD"; Size="854x480"; Width=854; Height=480}
    "7" = @{Name="360p"; Size="640x360"; Width=640; Height=360}
    "8" = @{Name="240p"; Size="320x240"; Width=320; Height=240}
}

$resolution = $null
if ($choice -in 1..8) {
    Write-Host "`nAvailable resolutions:" -ForegroundColor Yellow
    foreach ($key in $resolutions.Keys | Sort-Object) {
        Write-Host "[$key] $($resolutions[$key].Name) - $($resolutions[$key].Size)"
    }

    $resChoice = Read-Host "Enter resolution choice (1-8)"
    if ($resolutions.ContainsKey($resChoice)) {
        $resolution = $resolutions[$resChoice]
    } else {
        Write-Host "Invalid resolution choice, exiting..." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Get input files
$inputFiles = Get-ChildItem -Path $InputDir -File | Where-Object { $_.Extension -match '\.(mp4|mkv|avi|mov|flv|webm|mts|m2ts)$' }

if ($inputFiles.Count -eq 0) {
    Write-Host "`nNo video files found in $InputDir" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "`nFound $($inputFiles.Count) video files to process" -ForegroundColor Green

# Calculate bitrate if enabled
$bitrate = $null
if ($resolution -and $config.BitrateCalculation.Enable -eq "true") {
    $fps = [int]$config.BitrateCalculation.DefaultFPS
    $bpp = [float]$config.BitrateCalculation.BitratePerPixel
    $motion = [float]$config.BitrateCalculation.MotionFactor
    $bitrate = Get-OptimalBitrate -Width $resolution.Width -Height $resolution.Height -FPS $fps -BitratePerPixel $bpp -MotionFactor $motion
    Write-Host "Auto-calculated bitrate: ${bitrate}k" -ForegroundColor Cyan
}

# Define encoding scriptblock for parallel processing
$encodeScript = {
    param($InputFile, $Choice, $Resolution, $Bitrate, $GpuAccel, $Config, $OutputDir)

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile.Name)
    $outputExt = "mp4"
    $ffmpegCmd = @("ffmpeg", "-y")

    # Add hardware decoder if available
    if ($GpuAccel.Decoder) {
        $ffmpegCmd += $GpuAccel.Decoder -split ' '
    }

    $ffmpegCmd += @("-i", $InputFile.FullName)

    switch ($Choice) {
        "1" { # H.264
            $encoder = if ($GpuAccel.Type -ne "none") { $GpuAccel.H264Encoder } else { "libx264" }
            $preset = $Config.H264.Preset
            $crf = $Config.H264.CRF
            $threads = $Config.H264.Threads

            $ffmpegCmd += @("-c:v", $encoder)

            if ($encoder -eq "libx264") {
                $ffmpegCmd += @("-preset", $preset, "-crf", $crf)
            } elseif ($GpuAccel.ExtraParams) {
                $ffmpegCmd += $GpuAccel.ExtraParams -split ' '
                if ($Bitrate) { $ffmpegCmd += @("-b:v", "${Bitrate}k") }
            }

            $ffmpegCmd += @("-threads", $threads)
            if ($Resolution) { $ffmpegCmd += @("-s", $Resolution.Size) }
            $ffmpegCmd += @("-c:a", "aac", "-b:a", "192k")
            $ffmpegCmd += $Config.H264.AdditionalParams -split ' '
            $outputExt = "mp4"
        }

        "2" { # H.265
            $encoder = if ($GpuAccel.Type -ne "none") { $GpuAccel.H265Encoder } else { "libx265" }
            $preset = $Config.H265.Preset
            $crf = $Config.H265.CRF

            $ffmpegCmd += @("-c:v", $encoder)

            if ($encoder -eq "libx265") {
                $ffmpegCmd += @("-preset", $preset, "-crf", $crf)
            } elseif ($GpuAccel.ExtraParams) {
                $ffmpegCmd += $GpuAccel.ExtraParams -split ' '
                if ($Bitrate) { $ffmpegCmd += @("-b:v", "${Bitrate}k") }
            }

            if ($Resolution) { $ffmpegCmd += @("-s", $Resolution.Size) }
            $ffmpegCmd += @("-c:a", "aac", "-b:a", "192k")
            $ffmpegCmd += $Config.H265.AdditionalParams -split ' '
            $outputExt = "mp4"
        }

        "3" { # VP8
            $bitrateCalc = if ($Bitrate) { [math]::Round($Bitrate * 0.8) } else { 1000 }
            $ffmpegCmd += @("-c:v", "libvpx", "-b:v", "${bitrateCalc}k", "-quality", "good")
            if ($Resolution) { $ffmpegCmd += @("-s", $Resolution.Size) }
            $ffmpegCmd += @("-c:a", "libvorbis", "-b:a", "128k")
            $outputExt = "webm"
        }

        "4" { # VP9 with two-pass
            $bitrateCalc = if ($Bitrate) { [math]::Round($Bitrate * 0.6) } else { 1000 }
            $outputPath = Join-Path $OutputDir "$fileName.$outputExt"

            # Two-pass encoding
            $pass1Cmd = @("ffmpeg", "-y", "-i", $InputFile.FullName, "-c:v", "libvpx-vp9", "-b:v", "${bitrateCalc}k")
            $pass1Cmd += @("-quality", "good", "-cpu-used", "4", "-row-mt", "1", "-tile-columns", "2")
            if ($Resolution) { $pass1Cmd += @("-s", $Resolution.Size) }
            $pass1Cmd += @("-pass", "1", "-an", "-f", "null", "NUL")

            & $pass1Cmd[0] $pass1Cmd[1..($pass1Cmd.Length-1)]

            $ffmpegCmd += @("-c:v", "libvpx-vp9", "-b:v", "${bitrateCalc}k", "-quality", "good")
            $ffmpegCmd += @("-cpu-used", "4", "-row-mt", "1", "-tile-columns", "2", "-pass", "2")
            if ($Resolution) { $ffmpegCmd += @("-s", $Resolution.Size) }
            $ffmpegCmd += @("-c:a", "libopus", "-b:a", "128k")
            $outputExt = "webm"
        }

        "5" { # AV1
            $ffmpegCmd += @("-c:v", "libaom-av1", "-crf", "30", "-cpu-used", "6")
            $ffmpegCmd += @("-row-mt", "1", "-tiles", "2x2", "-threads", "0")
            if ($Resolution) { $ffmpegCmd += @("-s", $Resolution.Size) }
            $ffmpegCmd += @("-c:a", "libopus", "-b:a", "128k")
            $outputExt = "webm"
        }

        "6" { # ProRes
            $ffmpegCmd += @("-c:v", "prores_ks", "-profile:v", "3")
            if ($Resolution) { $ffmpegCmd += @("-s", $Resolution.Size) }
            $ffmpegCmd += @("-c:a", "pcm_s16le")
            $outputExt = "mov"
        }

        "7" { # DNxHD
            $ffmpegCmd += @("-c:v", "dnxhd", "-b:v", "115M")
            if ($Resolution) { $ffmpegCmd += @("-s", $Resolution.Size) }
            $ffmpegCmd += @("-c:a", "pcm_s16le")
            $outputExt = "mov"
        }

        "8" { # HAP
            $ffmpegCmd += @("-c:v", "hap", "-format", "hap_alpha", "-chunks", "1")
            if ($Resolution) { $ffmpegCmd += @("-s", $Resolution.Size) }
            $outputExt = "mov"
        }

        "9" { # Audio normalize
            $ffmpegCmd += @("-af", "loudnorm", "-c:v", "copy")
            $outputExt = "wav"
        }

        "10" { # Stream copy
            $ffmpegCmd += @("-c:v", "copy", "-c:a", "aac")
            $outputExt = "mp4"
        }
    }

    $outputPath = Join-Path $OutputDir "$fileName.$outputExt"
    $ffmpegCmd += $outputPath

    # Execute ffmpeg
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Processing: $($InputFile.Name)" -ForegroundColor Yellow
    & $ffmpegCmd[0] $ffmpegCmd[1..($ffmpegCmd.Length-1)] 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Complete: $fileName.$outputExt" -ForegroundColor Green
    } else {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Failed: $($InputFile.Name)" -ForegroundColor Red
    }
}

# Get max parallel jobs
$maxJobs = [int]$config.General.MaxParallelJobs
if ($maxJobs -le 0) {
    $maxJobs = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
    if ($maxJobs -gt 2) { $maxJobs-- }
}

Write-Host "`nStarting parallel encoding with $maxJobs concurrent jobs..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Process files in parallel
$results = Start-ParallelEncoding -Files $inputFiles -ProcessScript $encodeScript -MaxParallelJobs $maxJobs -ArgumentList @($choice, $resolution, $bitrate, $gpuAccel, $config, $OutputDir)

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   CONVERSION COMPLETE!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Total files: $($results.Total)"
Write-Host "Successful: $($results.Success)" -ForegroundColor Green
Write-Host "Failed: $($results.Failed)" -ForegroundColor $(if ($results.Failed -gt 0) { "Red" } else { "Green" })
Write-Host "Duration: $($results.Duration.ToString('hh\:mm\:ss'))"
Write-Host ""

Read-Host "Press Enter to exit"
