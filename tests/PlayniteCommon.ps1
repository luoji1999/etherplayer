$global:PlayniteVariables = @{
    DefaultAppDir = Join-Path $env:LOCALAPPDATA "ETPlayer"
    StartMenuDir = Join-Path $env:APPDATA "\Microsoft\Windows\Start Menu\Programs\ETPlayer\"
    DesktopIconPath = Join-Path $env:ProgramData "Desktop\ETPlayer.lnk"
    UninstallRegKey32 = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ETPlayer_is1"
    UninstallRegKey64 = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ETPlayer_is1"
    UiProcessName = "ETPlayer.DesktopApp"
    UiExecutableName = "ETPlayer.DesktopApp.exe"
    DefaultUiExecutablePath = Join-Path $env:LOCALAPPDATA "ETPlayer\ETPlayer.DesktopApp.exe"
    DefaultUinstallerExecutablePath = Join-Path $env:LOCALAPPDATA "ETPlayer\unins000.exe"
    AppMutex = "ETPlayerInstaceMutex"
}

function global:Stop-PlayniteProcesses()
{
    if (Get-Process -Name $PlayniteVariables.UiProcessName -EA 0)
    {
        Stop-Process -Name $PlayniteVariables.UiProcessName -Force
        WaitFor { (Get-Process -Name $PlayniteVariables.UiProcessName -EA 0) -eq $null }
    }
}
