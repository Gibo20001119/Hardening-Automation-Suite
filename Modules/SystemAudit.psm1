# ============================================================
# SystemAudit.psm1
# ============================================================

function Get-SystemHardeningStatus {
    [CmdletBinding()]
    param()

    $results = @()

    # Firewall check
    $fw = Get-NetFirewallProfile -ErrorAction SilentlyContinue

    $results += [PSCustomObject]@{
        CheckName = "Firewall Status"
        Status    = if ($fw.Enabled -contains $false) { "Critical" } else { "OK" }
        Value     = ($fw | Select-Object Name, Enabled)
        Details   = "Windows Firewall state per profile"
    }

    # Windows Defender check
    try {
        $defender = Get-MpComputerStatus

        $results += [PSCustomObject]@{
            CheckName = "Windows Defender"
            Status    = if ($defender.AntivirusEnabled) { "OK" } else { "Critical" }
            Value     = $defender.AntivirusEnabled
            Details   = "Real-time protection status"
        }
    }
    catch {
        $results += [PSCustomObject]@{
            CheckName = "Windows Defender"
            Status    = "Unknown"
            Value     = "N/A"
            Details   = "Defender status not available"
        }
    }

    # UAC check
    $uac = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
        -Name EnableLUA -ErrorAction SilentlyContinue

    $results += [PSCustomObject]@{
        CheckName = "UAC Enabled"
        Status    = if ($uac.EnableLUA -eq 1) { "OK" } else { "Critical" }
        Value     = $uac.EnableLUA
        Details   = "User Account Control setting"
    }

    return $results
}

Export-ModuleMember -Function Get-SystemHardeningStatus