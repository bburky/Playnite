class MySettings : Playnite.SDK.PowerShellSettings {
    [string] $Option1 = "Default value"
    [bool] $Option2 = $false

    # Playnite serializes settings object to a JSON object and saves it as text file.
    # If you want to exclude some property from being saved then use `JsonIgnore` ignore attribute.
    [Newtonsoft.Json.JsonIgnore()][MyPlugin] $plugin

    # Parameterless constructor must exist if you want to use LoadPluginSettings method.
    MySettings() {
    }

    MySettings([MyPlugin] $plugin)
    {
        # Injecting your plugin instance is required for Save/Load method because Playnite saves data to a location based on what plugin requested the operation.
        $this.plugin = $plugin 

        # Load saved settings.
        $savedSettings = [MyPlugin].GetMethod("LoadPluginSettings").MakeGenericMethod([MySettings]).Invoke($plugin, $null)
        # I tried to get something like this to work, but apparently PS doesn't do generic methods very well?
        #   $savedSettings = [MySettings]::$plugin.LoadPluginSettings()

        # LoadPluginSettings returns null if not saved data is available.
        if ($savedSettings)
        {
            $this.Option1 = $savedSettings.Option1
            $this.Option2 = $savedSettings.Option2
        }
    }

    [void] BeginEdit() {
        $this.plugin.logger.Info("MyPlugin BeginEdit")
        # Code executed when settings view is opened and user starts editing values.
    }

    [void] CancelEdit() {
        $this.plugin.logger.Info("MyPlugin CancelEdit")
        # Code executed when user decides to cancel any changes made since BeginEdit was called.
        # This method should revert any changes made to Option1 and Option2.
    }

    [void] EndEdit() {
        # Code executed when user decides to confirm changes made since BeginEdit was called.
        # This method should save settings made to Option1 and Option2.
        $this.plugin.logger.Info("MyPlugin EndEdit")
        $this.plugin.SavePluginSettings($this)
    }

    # Alternate VerifySettings from PowerShellSettings
    [Collections.Generic.List[string]] VerifySettings(){
        # Return a nonempty list to indicate true
        return $null
    }
}

class MyPlugin : Playnite.SDK.Plugins.Plugin {
    [Playnite.SDK.ILogger]$logger = [Playnite.SDK.LogManager]::GetLogger("MyPlugin")
    [Playnite.SDK.IPlayniteAPI]$PlayniteApi
    [MySettings]$settings

    # You can't correctly do getters/setters in PowerShell, but you can override get_Id directly
    [Guid]get_Id() {
       return "00000000-0000-0000-0000-000000000001"
    }

    MyPlugin([Playnite.SDK.IPlayniteAPI]$api) : base($api) {
        $this.logger.Info("MyPlugin constructing")
        $this.PlayniteApi = $api
        $this.settings = [MySettings]::new($this)
    }

    [void]OnGameSelected([Playnite.SDK.Events.GameSelectionEventArgs]$gameSelectionEventArgs) {
        $this.logger.Info("OnGameSelected $($gameSelectionEventArgs.OldValue) -> $($gameSelectionEventArgs.NewValue)")

    }

    [Playnite.SDK.ISettings]GetSettings([bool]$firstRunSettings)
    {
        return $this.settings
    }

    [Windows.Controls.UserControl]GetSettingsView([bool]$firstRunSettings)
    {
        [xml]$xaml = @"
<UserControl
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <StackPanel>
        <TextBlock Text="Description for Option1:"/>
        <TextBox Text="{Binding Option1}"/>
        <TextBlock Text="Description for Option2:"/>
        <CheckBox IsChecked="{Binding Option2}"/>
    </StackPanel>
</UserControl>
"@
        $reader = [System.Xml.XmlNodeReader]::new($xaml)
        $control = [Windows.Markup.XamlReader]::Load($reader)
        return $control
    }
}

function GenericPlugin($playniteApi) {
    return [MyPlugin]::new($playniteApi)
}
