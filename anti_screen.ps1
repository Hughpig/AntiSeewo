# =====================================================================
# 希沃屏幕墙欺骗系统 (带深度日志调试版)
# =====================================================================
$TargetDir = "C:\ProgramData\seewo\screenCapture\temp"
$FakeImage = Join-Path $PSScriptRoot "Seewo_Fake_Screen.jpg"
$LogFile   = Join-Path $PSScriptRoot "debug_screen.log"

function Write-DebugLog($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logLine = "[$timestamp] $msg"
    Write-Host $logLine -ForegroundColor Cyan
    Add-Content -Path $LogFile -Value $logLine -ErrorAction SilentlyContinue
}

Write-DebugLog "==== 屏幕拦截系统启动调试 ===="
if (-not (Test-Path $FakeImage)) {
    Write-DebugLog "[错误] 未在 C:\ 发现伪造图片 Seewo_Fake_Screen.jpg！"
    exit
}

if (-not (Test-Path $TargetDir)) {
    Write-DebugLog "[提示] 目标缓存目录不存在，正在等待希沃唤醒或手动创建..."
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = $TargetDir
$Watcher.Filter = "*.jpg"
$Watcher.EnableRaisingEvents = $true

$Action = {
    $FullPath = $Event.SourceEventArgs.FullPath
    $FileName = $Event.SourceEventArgs.Name
    
    # 捕获到希沃正在尝试写入
    IEX "Write-DebugLog '[雷达] 检测到希沃生成屏幕快照: $FileName'"
    
    $maxTries = 5
    $retryDelay = 2 
    $success = $false
    
    for ($i = 0; $i -lt $maxTries; $i++) {
        try {
            Copy-Item -Path $FakeImage -Destination $FullPath -Force -ErrorAction Stop
            $success = $true
            break
        } catch {
            Start-Sleep -Milliseconds $retryDelay
        }
    }
    
    if ($success) {
        IEX "Write-DebugLog '[成功] 瞬间掉包覆盖成功！老师端已看假图。'"
    } else {
        IEX "Write-DebugLog '[警告] 强锁覆盖失败，可能遭遇严重的硬件读写冲突。'"
    }
}

Register-ObjectEvent $Watcher "Created" -Action $Action | Out-Null
Register-ObjectEvent $Watcher "Changed" -Action $Action | Out-Null

Write-DebugLog "[*] 监控雷达已上线，正在死守缓存路径..."
while ($true) { Start-Sleep 5 }