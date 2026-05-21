# ============================================================
# UserAudit.psm1
# Part of Hardening-Automation-Suite
# ============================================================

function Get-LocalUserAudit {
    [CmdletBinding()]
    param(
        [int]$InactiveDaysThreshold = 30
    )

    $users = Get-LocalUser -ErrorAction SilentlyContinue

    $results = foreach ($user in $users) {

        $lastLogon = $user.LastLogon

        $inactive = $false
        if ($lastLogon) {
            $inactive = ($lastLogon -lt (Get-Date).AddDays(-$InactiveDaysThreshold))
        }

        [PSCustomObject]@{
            UserName    = $user.Name
            Enabled     = $user.Enabled
            LastLogon   = $lastLogon
            Inactive    = $inactive
            Description = $user.Description
        }
    }

    return $results
}


function Get-AdminUsersAudit {
    [CmdletBinding()]
    param()

    $admins = Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue

    return $admins | Select-Object Name, ObjectClass, PrincipalSource
}


function Test-UserHardening {
    [CmdletBinding()]
    param()

    $results = @()

    $users = Get-LocalUser -ErrorAction SilentlyContinue
    $admins = Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue

    # 1. Disabled users check
    $disabled = ($users | Where-Object { $_.Enabled -eq $false }).Count

    $results += [PSCustomObject]@{
        CheckName = "Disabled Accounts Present"
        Status    = "OK"
        Value     = $disabled
        Details   = "$disabled disabled accounts found"
    }

    # 2. Too many admin users
    $adminCount = $admins.Count

    $results += [PSCustomObject]@{
        CheckName = "Admin Group Size"
        Status    = if ($adminCount -gt 5) { "Warning" } else { "OK" }
        Value     = $adminCount
        Details   = "Local administrators detected"
    }

    # 3. Inactive users
    $inactive = ($users | Where-Object {
        $_.LastLogon -and $_.LastLogon -lt (Get-Date).AddDays(-30)
    }).Count

    $results += [PSCustomObject]@{
        CheckName = "Inactive Users"
        Status    = if ($inactive -gt 0) { "Warning" } else { "OK" }
        Value     = $inactive
        Details   = "Users inactive for >30 days"
    }

    return $results
}

Export-ModuleMember -Function Get-LocalUserAudit, Get-AdminUsersAudit, Test-UserHardening