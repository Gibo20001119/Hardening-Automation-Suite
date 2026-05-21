# ============================================================
# Run-FullAudit.ps1
# Entry Point for Hardening-Automation-Suite
# ============================================================

param(
    [string]$OutputPath = ".\Reports\security-report.html",
    [switch]$VerboseOutput
)

# ------------------------------------------------------------
# Module Loading
# ------------------------------------------------------------

$modulePath = Join-Path $PSScriptRoot "..\Modules"

Import-Module "$modulePath\SystemAudit.psm1" -Force
Import-Module "$modulePath\UserAudit.psm1" -Force
Import-Module "$modulePath\NetworkAudit.psm1" -Force
Import-Module "$modulePath\Reporting.psm1" -Force

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " Hardening Automation Suite - Audit " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan


# ------------------------------------------------------------
# Collect Audit Data
# ------------------------------------------------------------

Write-Host "`n[+] Running System Audit..." -ForegroundColor Yellow
$systemResults = Get-SystemHardeningStatus

Write-Host "[+] Running User Audit..." -ForegroundColor Yellow
$userResults = Test-UserHardening

Write-Host "[+] Running Network Audit..." -ForegroundColor Yellow
$networkResults = Test-NetworkHardening


# ------------------------------------------------------------
# Merge Results
# ------------------------------------------------------------

$allResults = @()
$allResults += $systemResults
$allResults += $userResults
$allResults += $networkResults


# ------------------------------------------------------------
# Security Score
# ------------------------------------------------------------

Write-Host "`n[+] Calculating Security Score..." -ForegroundColor Yellow
$score = Get-SecurityScore -Data $allResults

Write-Host "`n===============================" -ForegroundColor Cyan
Write-Host " Security Score: $($score.Score)/100" -ForegroundColor Cyan
Write-Host " Critical Issues: $($score.Critical)" -ForegroundColor Red
Write-Host " Warnings: $($score.Warning)" -ForegroundColor Yellow
Write-Host "===============================`n" -ForegroundColor Cyan


# ------------------------------------------------------------
# Console Output (optional verbose mode)
# ------------------------------------------------------------

if ($VerboseOutput) {
    Write-Host "[+] Detailed Results:`n" -ForegroundColor Cyan
    $allResults | Format-Table -AutoSize
}


# ------------------------------------------------------------
# Generate HTML Report
# ------------------------------------------------------------

Write-Host "[+] Generating HTML Report..." -ForegroundColor Yellow

$reportPath = New-SecurityReport `
    -Data $allResults `
    -Title "Hardening Automation Security Report" `
    -OutputPath $OutputPath


# ------------------------------------------------------------
# Final Output
# ------------------------------------------------------------

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host " Audit Completed Successfully " -ForegroundColor Green
Write-Host " Report saved to: $reportPath" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green