# class MySettings : Playnite.SDK.ISettings {
#     [MyPlugin] $plugin
#     [string] $option1 = ""
#     [bool] $option2 = $false
#
#     # Playnite serializes settings object to a JSON object and saves it as text file.
#     # If you want to exclude some property from being saved then use `JsonIgnore` ignore attribute.
#     # TODO: does hidden work like JsonIgnore?
#     [bool] hidden $optionThatWontBeSaved  = $false
#
#     # Parameterless constructor must exist if you want to use LoadPluginSettings method.
#     MySettings() {
#     }
#
#     MySettings([MyPlugin] $plugin)
#     {
#         # Injecting your plugin instance is required for Save/Load method because Playnite saves data to a location based on what plugin requested the operation.
#         $this.plugin = $plugin
#
#         # Load saved settings.
#         $savedSettings = $plugin.LoadPluginSettings()
#
#         # LoadPluginSettings returns null if not saved data is available.
#         if ($savedSettings)
#         {
#             $this.option1 = $savedSettings.option1
#             $this.option2 = $savedSettings.option2
#         }
#     }
#
#     [void] BeginEdit() {
#         # Code executed when settings view is opened and user starts editing values.
#     }
#
#     [void] CancelEdit() {
#         # Code executed when user decides to cancel any changes made since BeginEdit was called.
#         # This method should revert any changes made to Option1 and Option2.
#     }
#
#     [void] EndEdit() {
#         # Code executed when user decides to confirm changes made since BeginEdit was called.
#         # This method should save settings made to Option1 and Option2.
#         $this.plugin.SavePluginSettings($this)
#     }
#
#     # It's impossible to use [ref] in a method definition in PowerShell
#     [bool] VerifySettings([Collections.Generic.List`1[[string]]&] $errors) {
#         # Code execute when user decides to confirm changes made since BeginEdit was called.
#         # Executed before EndEdit is called and EndEdit is not called if false is returned.
#         # List of errors is presented to user if verification fails.
#         # TODO: returning [ref] values from class methods isn't possible in PowerShell
#         errors = @()
#         return true
#     }
# }

class MyPlugin : Playnite.SDK.Plugins.Plugin {
    [Playnite.SDK.ILogger]$logger = [Playnite.SDK.LogManager]::GetLogger("MyPlugin")
    [Playnite.SDK.IPlayniteAPI]$PlayniteApi
    # [MySettings]$settings

    # You can't correctly do getters/setters in PowerShell, but you can override get_Id directly
    [Guid]get_Id() {
       return "00000000-0000-0000-0000-000000000001"
    }

    MyPlugin([Playnite.SDK.IPlayniteAPI]$api) : base($api) {
        $this.logger.Info("MyPlugin constructing")
        $this.PlayniteApi = $api
        # $this.settings = [MySettings]::new($this)
    }

    [void]OnGameSelected([Playnite.SDK.Events.GameSelectionEventArgs]$gameSelectionEventArgs) {
        $this.logger.Info("OnGameSelected $($gameSelectionEventArgs.OldValue) -> $($gameSelectionEventArgs.NewValue)")

    }

    [Playnite.SDK.ISettings]GetSettings([bool]$firstRunSettings)
    {
        # It's not possible to contstruct an ISettings object in PowerShell
        return $null
    }

    [Windows.Controls.UserControl]GetSettingsView([bool]$firstRunSettings)
    {
        # This should be doable with XAML
        return $null
    }
}

function GenericPlugin($playniteApi) {
    return [MyPlugin]::new($playniteApi)
}
