# ============================================================
# NetworkAudit.psm1
# Part of Hardening-Automation-Suite
# ============================================================

function Get-OpenPorts {
    [CmdletBinding()]
    param(
        [switch]$IncludeProcessInfo
    )

    $connections = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue

    $results = foreach ($conn in $connections) {

        $processName = $null

        if ($IncludeProcessInfo -and $conn.OwningProcess) {
            try {
                $process = Get-Process -Id $conn.OwningProcess -ErrorAction Stop
                $processName = $process.ProcessName
            }
            catch {
                $processName = "Unknown"
            }
        }

        [PSCustomObject]@{
            LocalAddress = $conn.LocalAddress
            LocalPort    = $conn.LocalPort
            State        = $conn.State
            ProcessId    = $conn.OwningProcess
            ProcessName  = $processName
        }
    }

    return $results
}


function Get-SuspiciousPorts {
    [CmdletBinding()]
    param()

    # Typische riskante / häufig angegriffene Ports
    $knownRiskPorts = @(21, 23, 135, 137, 138, 139, 445, 1433, 3389)

    $openPorts = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue

    $suspicious = $openPorts | Where-Object {
        $_.LocalPort -in $knownRiskPorts
    }

    return $suspicious | Select-Object LocalAddress, LocalPort, OwningProcess
}


function Get-NetworkSummary {
    [CmdletBinding()]
    param()

    $openPorts = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue

    $summary = [PSCustomObject]@{
        TotalListeningPorts = $openPorts.Count
        UniquePorts         = ($openPorts.LocalPort | Sort-Object -Unique).Count
        SuspiciousPorts     = (Get-SuspiciousPorts).Count
    }

    return $summary
}


function Test-NetworkHardening {
    [CmdletBinding()]
    param()

    $results = @()

    # 1. Prüfen ob viele offene Ports existieren
    $ports = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue

    $results += [PSCustomObject]@{
        CheckName = "Open Ports Count"
        Status    = if ($ports.Count -gt 50) { "Warning" } else { "OK" }
        Value     = $ports.Count
        Details   = "Listening ports detected on system"
    }

    # 2. Kritische Ports aktiv?
    $suspicious = Get-SuspiciousPorts

    $results += [PSCustomObject]@{
        CheckName = "Suspicious Ports"
        Status    = if ($suspicious.Count -gt 0) { "Critical" } else { "OK" }
        Value     = $suspicious.Count
        Details   = ($suspicious | ForEach-Object { "$($_.LocalPort)" }) -join ", "
    }

    # 3. Remote Desktop offen?
    $rdp = Get-NetTCPConnection -LocalPort 3389 -ErrorAction SilentlyContinue

    $results += [PSCustomObject]@{
        CheckName = "RDP Exposure"
        Status    = if ($rdp) { "Critical" } else { "OK" }
        Value     = if ($rdp) { "Enabled" } else { "Disabled" }
        Details   = "Checks if Remote Desktop port is exposed"
    }

    return $results
}


# Export functions
Export-ModuleMember -Function `
    Get-OpenPorts, `
    Get-SuspiciousPorts, `
    Get-NetworkSummary, `
    Test-NetworkHardening