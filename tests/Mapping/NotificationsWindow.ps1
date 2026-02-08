using module PSNativeAutomation

class NotificationsWindow : Window
{
    [ListBox]$ListNotifications

    NotificationsWindow() : base({Get-UIWindow -ProcessName "ETPlayer.DesktopApp" -AutomationId "WindowNotifications"}, "NotificationsWindow")
    {
        $this.ListNotifications   = [ListBox]::New($this.GetChildReference({Get-UIListBox -AutomationId "ListNotifications" -First}), "ListNotifications")
    }
}

return [NotificationsWindow]::New()