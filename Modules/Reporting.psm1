# ============================================================
# Reporting.psm1
# ============================================================

function New-SecurityReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Data,

        [string]$Title = "Hardening Report",

        [string]$OutputPath = ".\Reports\security-report.html"
    )

    $style = @"
    <style>
        body { font-family: Arial; }
        .ok { color: green; }
        .warning { color: orange; }
        .critical { color: red; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { background-color: #f4f4f4; }
    </style>
"@

    $html = $Data | ForEach-Object {
        $class = $_.Status.ToLower()

        "<tr class='$class'>
            <td>$($_.CheckName)</td>
            <td>$($_.Status)</td>
            <td>$($_.Value)</td>
            <td>$($_.Details)</td>
        </tr>"
    }

    $report = @"
<html>
<head>
    <title>$Title</title>
    $style
</head>
<body>
    <h1>$Title</h1>
    <table>
        <tr>
            <th>Check</th>
            <th>Status</th>
            <th>Value</th>
            <th>Details</th>
        </tr>
        $($html -join "`n")
    </table>
</body>
</html>
"@

    $report | Out-File -FilePath $OutputPath -Encoding UTF8

    return $OutputPath
}


function Get-SecurityScore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Data
    )

    $total = $Data.Count
    $critical = ($Data | Where-Object { $_.Status -eq "Critical" }).Count
    $warning  = ($Data | Where-Object { $_.Status -eq "Warning" }).Count

    $score = 100
    $score -= ($critical * 25)
    $score -= ($warning * 10)

    if ($score -lt 0) { $score = 0 }

    [PSCustomObject]@{
        Score    = $score
        Critical  = $critical
        Warning   = $warning
        Total     = $total
    }
}

Export-ModuleMember -Function New-SecurityReport, Get-SecurityScore