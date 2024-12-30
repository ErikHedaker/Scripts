$date = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')
$name = "wow_addon_backup_$date"
$output = ".\Output\WowAddonBackups\$name"
7z a $output 'C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns' 'C:\Program Files (x86)\World of Warcraft\_retail_\WTF'