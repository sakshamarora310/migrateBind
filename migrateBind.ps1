<#
Author: Saksham Arora

Script Summary:
---------------
• Retrieves all authoritative zones from Infoblox
• Filters zones by type (example uses IPv4/forward zones)
• Switches the NS Group for each zone
• Triggers a zone transfer to pull data from the source server

Note: All sensitive values have been intentionally obfuscated.

PS: I used PowerShell 7 for running this script
#>


$prdCreds = (Get-Credential) # <username>
$infobloxServer = "fqdn.example.com"

Write-Host "Getting All Zones ..."

$allZones = (Invoke-RestMethod -Authentication Basic -Credential $prdCreds -SkipCertificateCheck -Method GET -Uri "https://$($infobloxServer)/wapi/v2.13.1/zone_auth?_return_fields=fqdn,zone_format,ns_group" -ErrorAction Stop)

Write-Host "Filtering Zones based on NS Group"

#Change FORWARD TO IPV4 for migrating the reverse zone

$forwardZones = $allZones | Where-Object {$_.zone_format -like "FORWARD"}

Write-Host "Switching NS Group to Prod NS Group"
Start-Sleep 1

Write-Host "Setting NS Group Variable.."
Start-Sleep 1
$body = @{"ns_group"="Prod NS Group";}

Try {
    Write-Host "Changing NS Group"
    Start-sleep 1
    
    $forwardZones | ForEach-Object {
        Write-Host "Working on $($_.fqdn)"
        $ref = $($_._ref)
        $changeNS = Invoke-RestMethod -Authentication Basic -Credential $prdCreds -SkipCertificateCheck -Method PUT -Uri "https://$($infobloxServer)/wapi/v2.13.1/$ref" -ContentType "application/json" -Body ($body| ConvertTo-Json)

        if ($changeNS) {
            Write-Host "Performing a zone transfer from source server"
            Start-Sleep 1
            Invoke-RestMethod -Authentication Basic -Credential $prdCreds -SkipCertificateCheck -Method PUT -Uri "https://$($infobloxServer)/wapi/v2.13.1/$($ref)?import_from=<AUTH Server IP>"
            Write-Host "Migration Successful`n"
        }
    }
    
}
Catch {
    Write-Host "Error Occured Whilst running the change"
    Write-Host "$_"
}   
