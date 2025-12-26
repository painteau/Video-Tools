@echo off
:: Wrapper to launch optimized PowerShell converter
:: This provides significantly better performance through parallel processing and GPU acceleration

where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: PowerShell not found. This script requires PowerShell.
    echo Please run the original Convert.cmd instead.
    pause
    exit /b
)

echo Starting Optimized Video Converter...
echo.
echo This version includes:
echo  - Parallel processing (4-8x faster batch conversions)
echo  - GPU hardware acceleration (NVENC/QSV/AMF)
echo  - Optimized FFMPEG parameters
echo  - Smart bitrate calculation
echo  - Progress tracking
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Convert-Optimized.ps1"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Optimized converter failed. You may want to use Convert.cmd instead.
    pause
)
