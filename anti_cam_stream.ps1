# =====================================================================
# 希沃摄像头推流欺骗系统 (带深度日志调试版)
# =====================================================================
$FFmpegPath = "C:\Program Files (x86)\Seewo\EasiRecorder\ffmpeg.exe"
$FakeImage = Join-Path $PSScriptRoot "Seewo_Fake_Cam.jpg"
$LogFile   = Join-Path $PSScriptRoot "debug_camera.log"

function Write-DebugLog($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logLine = "[$timestamp] $msg"
    Write-Host $logLine -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $logLine -ErrorAction SilentlyContinue
}

$RtspUser   = "seewo"
$RtspPass   = "vHy8Es66"
$LocalPort  = "1163" 
$RtspTarget = "rtsp://$RtspUser`:$RtspPass`@127.0.0.1:$LocalPort/live/camera_stream"

Write-DebugLog "==== 摄像头推流系统启动调试 ===="
if (-not (Test-Path $FakeImage)) {
    Write-DebugLog "[错误] 未在 C:\ 发现伪造图片 Seewo_Fake_Cam.jpg！"
    exit
}

# 构造 FFmpeg 启动参数，将错误流重定向到我们的日志分析器
$Args = "-loop 1 -r 1 -i `"$FakeImage`" -vcodec libx264 -pix_fmt yuv420p -preset ultrafast -tune stillimage -f rtsp -rtsp_transport tcp `"$RtspTarget`""

while ($true) {
    Write-DebugLog "[推流] 正在尝试与本地希沃 ZLMediaKit (127.0.0.1:$LocalPort) 建立 RTSP 握手..."
    
    # 启动 FFmpeg 并在后台保持连接
    $proc = Start-Process -FilePath $FFmpegPath -ArgumentList $Args -NoNewWindow -PassThru -ErrorAction SilentlyContinue
    if ($proc) {
        Write-DebugLog "[就绪] 虚拟摄像头通道推流中。老师若点开看班，将秒开假图画面。"
        $proc.WaitForExit()
        Write-DebugLog "[断开] 检测到 FFmpeg 推流断开（可能是希沃主服务重启或闲置断开），准备重连..."
    }
    Start-Sleep -Seconds 3
}