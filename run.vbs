Dim WshShell, CurrentDir, choice, debugMode
Set WshShell = CreateObject("WScript.Shell")
CurrentDir = WshShell.CurrentDirectory

' 1. 主控制台弹窗
choice = MsgBox("确定：激活拦截系统； 取消：强杀清理后台。", 1 + 32, "控制台")

If choice = 1 Then
    ' ==================== 启动流程 ====================
    ' 2. 额外询问是否开启调试可见窗口
    debugMode = MsgBox("是否开启【调试回显模式】？" & vbCrLf & "【是】: 弹出窗口看实时日志" & vbCrLf & "【否】: 彻底隐藏运行（实战用）", 3 + 64, "模式选择")
    
    Dim runVisibility
    If debugMode = 6 Then ' 用户点了【是】
        runVisibility = 1 ' 1 代表显示 CMD 窗口
    ElseIf debugMode = 7 Then ' 用户点了【否】
        runVisibility = 0 ' 0 代表彻底隐藏窗口
    Else
        Wscript.Quit ' 点击了取消则退出
    End If

    ' 执行 PowerShell 脚本
    WshShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -File """ & CurrentDir & "\anti_screen.ps1""", runVisibility, False
    WshShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -File """ & CurrentDir & "\anti_cam_stream.ps1""", runVisibility, False
    
    WshShell.Popup "系统已成功拉起！", 2, "激活成功", 64
Else
    ' ==================== 快速退出清理流程 ====================
    WshShell.Run "taskkill /f /t /im ffmpeg.exe", 0, True
    WshShell.Run "powershell -Command ""Stop-Process -Name powershell -Force -ErrorAction SilentlyContinue""", 0, True
    WshShell.Popup "后台拦截已全部退出，恢复默认监控！", 2, "清理完毕", 48
End If

Set WshShell = Nothing