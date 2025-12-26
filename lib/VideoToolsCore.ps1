# Video Tools Core Library - Optimized Functions
# PowerShell module for parallel processing and GPU detection

# Parse INI configuration file
function Read-Config {
    param([string]$ConfigPath = "config.ini")

    $config = @{}
    $section = ""

    if (Test-Path $ConfigPath) {
        Get-Content $ConfigPath | ForEach-Object {
            $line = $_.Trim()
            if ($line -match '^\[(.+)\]$') {
                $section = $matches[1]
                $config[$section] = @{}
            }
            elseif ($line -match '^([^=;]+)=(.+)$' -and $section) {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                $config[$section][$key] = $value
            }
        }
    }
    return $config
}

# Detect GPU hardware acceleration capabilities
function Get-HardwareAcceleration {
    param([string]$Preference = "auto")

    if ($Preference -eq "none") {
        return @{Type="none"; Encoder=""; Decoder=""}
    }

    # Check NVIDIA GPU (NVENC)
    if ($Preference -eq "auto" -or $Preference -eq "nvenc") {
        $nvidia = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*NVIDIA*" }
        if ($nvidia) {
            # Verify NVENC support via ffmpeg
            $nvencTest = & ffmpeg -hide_banner -encoders 2>&1 | Select-String "h264_nvenc"
            if ($nvencTest) {
                Write-Host "[GPU] NVIDIA GPU detected - Using NVENC acceleration" -ForegroundColor Green
                return @{
                    Type="nvenc"
                    H264Encoder="h264_nvenc"
                    H265Encoder="hevc_nvenc"
                    Decoder="-hwaccel cuda"
                    ExtraParams="-preset p4 -tune hq -rc vbr"
                }
            }
        }
    }

    # Check Intel GPU (QuickSync)
    if ($Preference -eq "auto" -or $Preference -eq "qsv") {
        $intel = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*Intel*" }
        if ($intel) {
            $qsvTest = & ffmpeg -hide_banner -encoders 2>&1 | Select-String "h264_qsv"
            if ($qsvTest) {
                Write-Host "[GPU] Intel GPU detected - Using QuickSync acceleration" -ForegroundColor Green
                return @{
                    Type="qsv"
                    H264Encoder="h264_qsv"
                    H265Encoder="hevc_qsv"
                    Decoder="-hwaccel qsv"
                    ExtraParams="-preset medium"
                }
            }
        }
    }

    # Check AMD GPU (AMF)
    if ($Preference -eq "auto" -or $Preference -eq "amf") {
        $amd = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*AMD*" -or $_.Name -like "*Radeon*" }
        if ($amd) {
            $amfTest = & ffmpeg -hide_banner -encoders 2>&1 | Select-String "h264_amf"
            if ($amfTest) {
                Write-Host "[GPU] AMD GPU detected - Using AMF acceleration" -ForegroundColor Green
                return @{
                    Type="amf"
                    H264Encoder="h264_amf"
                    H265Encoder="hevc_amf"
                    Decoder="-hwaccel d3d11va"
                    ExtraParams="-quality quality"
                }
            }
        }
    }

    Write-Host "[GPU] No hardware acceleration detected - Using CPU encoding" -ForegroundColor Yellow
    return @{Type="none"; H264Encoder="libx264"; H265Encoder="libx265"; Decoder=""; ExtraParams=""}
}

# Calculate optimal bitrate based on resolution
function Get-OptimalBitrate {
    param(
        [int]$Width,
        [int]$Height,
        [int]$FPS = 30,
        [float]$BitratePerPixel = 0.07,
        [float]$MotionFactor = 1.0
    )

    $bitrate = [math]::Round($Width * $Height * $FPS * $MotionFactor * $BitratePerPixel / 1000)
    return $bitrate
}

# Get video information using ffprobe
function Get-VideoInfo {
    param([string]$FilePath)

    try {
        $probeOutput = & ffprobe -v quiet -print_format json -show_format -show_streams "$FilePath" 2>&1 | ConvertFrom-Json

        $videoStream = $probeOutput.streams | Where-Object { $_.codec_type -eq "video" } | Select-Object -First 1
        $audioStreams = $probeOutput.streams | Where-Object { $_.codec_type -eq "audio" }
        $subtitleStreams = $probeOutput.streams | Where-Object { $_.codec_type -eq "subtitle" }

        return @{
            Valid = $true
            Width = [int]$videoStream.width
            Height = [int]$videoStream.height
            FPS = [math]::Round([decimal]($videoStream.r_frame_rate -split '/')[0] / [decimal]($videoStream.r_frame_rate -split '/')[1], 2)
            Duration = [float]$probeOutput.format.duration
            VideoCodec = $videoStream.codec_name
            AudioCodec = $audioStreams[0].codec_name
            AudioStreamCount = $audioStreams.Count
            SubtitleStreamCount = $subtitleStreams.Count
            Size = [long]$probeOutput.format.size
        }
    }
    catch {
        return @{Valid = $false; Error = $_.Exception.Message}
    }
}

# Process files in parallel
function Start-ParallelEncoding {
    param(
        [array]$Files,
        [scriptblock]$ProcessScript,
        [int]$MaxParallelJobs = 0,
        [string]$LogDir = "logs"
    )

    # Auto-detect CPU cores if not specified
    if ($MaxParallelJobs -le 0) {
        $MaxParallelJobs = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
        # Reserve 1 core for system
        if ($MaxParallelJobs -gt 2) { $MaxParallelJobs-- }
    }

    Write-Host "`n[PARALLEL] Processing $($Files.Count) files with $MaxParallelJobs parallel jobs" -ForegroundColor Cyan

    # Create log directory
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }

    $jobs = @()
    $completed = 0
    $failed = 0
    $startTime = Get-Date

    foreach ($file in $Files) {
        # Wait if we've hit the max parallel jobs
        while ((Get-Job -State Running).Count -ge $MaxParallelJobs) {
            Start-Sleep -Milliseconds 500

            # Check for completed jobs
            $finishedJobs = Get-Job -State Completed
            foreach ($job in $finishedJobs) {
                $result = Receive-Job -Job $job
                $completed++

                $percent = [math]::Round(($completed / $Files.Count) * 100, 1)
                $elapsed = (Get-Date) - $startTime
                $eta = if ($completed -gt 0) {
                    $totalTime = $elapsed.TotalSeconds * ($Files.Count / $completed)
                    [TimeSpan]::FromSeconds($totalTime - $elapsed.TotalSeconds)
                } else {
                    [TimeSpan]::Zero
                }

                Write-Host "[$completed/$($Files.Count)] $percent% | Elapsed: $($elapsed.ToString('hh\:mm\:ss')) | ETA: $($eta.ToString('hh\:mm\:ss'))" -ForegroundColor Green

                Remove-Job -Job $job
            }

            # Check for failed jobs
            $failedJobs = Get-Job -State Failed
            foreach ($job in $failedJobs) {
                $failed++
                Write-Host "[ERROR] Job failed: $($job.Name)" -ForegroundColor Red
                Remove-Job -Job $job
            }
        }

        # Start new job
        $job = Start-Job -Name (Split-Path $file -Leaf) -ScriptBlock $ProcessScript -ArgumentList $file
        $jobs += $job
    }

    # Wait for remaining jobs
    Write-Host "`n[PARALLEL] Waiting for remaining jobs to complete..." -ForegroundColor Cyan
    Wait-Job -Job $jobs | Out-Null

    # Collect final results
    foreach ($job in $jobs) {
        if ($job.State -eq "Completed") {
            Receive-Job -Job $job | Out-Null
            $completed++
        } else {
            $failed++
        }
        Remove-Job -Job $job
    }

    $totalTime = (Get-Date) - $startTime
    Write-Host "`n[COMPLETE] Total: $($Files.Count) | Success: $completed | Failed: $failed | Time: $($totalTime.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

    return @{Total=$Files.Count; Success=$completed; Failed=$failed; Duration=$totalTime}
}

# Create log entry
function Write-Log {
    param(
        [string]$Message,
        [string]$LogFile = "logs/encoding.log",
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"

    # Ensure log directory exists
    $logDir = Split-Path $LogFile -Parent
    if ($logDir -and -not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    Add-Content -Path $LogFile -Value $logEntry

    switch ($Level) {
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
        default { Write-Host $logEntry }
    }
}

# Validate file before processing
function Test-VideoFile {
    param(
        [string]$FilePath,
        [string]$OutputPath,
        [bool]$SkipIfExists = $true
    )

    # Check if input exists
    if (-not (Test-Path $FilePath)) {
        Write-Log "Input file not found: $FilePath" -Level "ERROR"
        return $false
    }

    # Check if output already exists
    if ($SkipIfExists -and (Test-Path $OutputPath)) {
        $inputTime = (Get-Item $FilePath).LastWriteTime
        $outputTime = (Get-Item $OutputPath).LastWriteTime

        if ($outputTime -gt $inputTime) {
            Write-Log "Skipping - already processed: $(Split-Path $FilePath -Leaf)" -Level "WARNING"
            return $false
        }
    }

    # Validate video file
    $info = Get-VideoInfo -FilePath $FilePath
    if (-not $info.Valid) {
        Write-Log "Invalid video file: $FilePath - $($info.Error)" -Level "ERROR"
        return $false
    }

    return $true
}

Export-ModuleMember -Function *
