#adding this line to test dev branch lol

Write-Host 'Welcome to SafeSSID' -ForegroundColor DarkBlue
Write-Host 'This tool identifies saved hidden networks and networks with no password, typically after visitng guest wifi' -ForegroundColor Green
Write-Host 'You can then use this tool to remove any old or suspicious saved networks to protect yourself from Hidden SSID Probe attacks' -ForegroundColor Green
Write-Host 'Please wait... obtaining saved Wi-Fi networks' -ForegroundColor Green

$allNetworks = $(netsh.exe wlan show profiles)

if($allNetworks -match "There is no wireless interface on the system.")
{
    Write-Host "Your system has no wireless profiles. Goodbye"
    exit
}


$SSIDList = ($allNetworks | Select-string "\w*All User Profile.*: (.*)").Matches | ForEach-Object {$_.Groups[1].Value}
$SSIDCount = $SSIDList.count
$SSIDHidden = @()
$SSIDOpen = @()

Write-Host "Detected SSIDs: $SSIDCount" -ForegroundColor DarkGreen
foreach ($SSID in $SSIDList)
{
    $SSIDDetect = netsh wlan show profile name=$SSID
    if($SSIDDetect | Select-String -Pattern "Connect even if this network is not broadcasting")
    {
        $SSIDHidden += $SSID
        continue
    }
    if($SSIDDetect | Select-String -Pattern "Authentication         : Open")
    {
        $SSIDOpen += $SSID
    }
}
Write-Host "======================="
Write-Host "Hidden Networks:"

$count = 1
foreach ($name in $SSIDHidden)
{
    Write-Host "$count : $name" -ForegroundColor Cyan
    $count = $count + 1
}

while($true)
{
    Write-Host "=======================`n"
    if($SSIDHidden.count -eq 0)
    {
        Write-Host "No Hidden SSIDs on the system" -ForegroundColor Red
        break
    }
    Write-Host "Type in the number of which network profile you want to delete. Enter 0 when finished."
    $userin = Read-Host
    if($userin -eq 0)
    {
        break
    }
    elseif ($userin -lt $SSIDHidden.count) {
        Write-Host "Invalid Entry"
        continue
    }
    else {
        netsh wlan delete profile name=$($SSIDHidden[$userin - 1])
    }
    
}

Write-Host "=======================`n"
Write-Host "Displaying Open Networks..."
Start-Sleep -Seconds 3
$count = 1
foreach ($name in $SSIDOpen)
{
    Write-Host "$count : $name" -ForegroundColor Cyan
    $count = $count + 1
}
while($true)
{
    Write-Host "`=======================`n"
    if($SSIDOpen.count -eq 0)
    {
        Write-Host "No Open Networks on the system" -ForegroundColor Red
        break
    }
    Write-Host "Type in the number of which network profile you want to delete. Enter 0 when finished."
    $userin = Read-Host
    if($userin -eq 0)
    {
        break
    }
    elseif ($userin -lt $SSIDOpen.count) {
        Write-Host "Invalid Entry"
        continue
    }
    else {
        netsh wlan delete profile name=$($SSIDOpen[$userin - 1])
    }
    
}
Write-Host "`nGoodbye!"