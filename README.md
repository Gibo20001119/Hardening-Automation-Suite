# Hardening-Automation-Suite

A modular PowerShell-based security auditing and hardening framework for Windows environments.

---

## Overview

The **Hardening-Automation-Suite** is a PowerShell automation toolkit designed to analyze, audit, and improve the security posture of Windows systems.

It focuses on identifying common security weaknesses such as:

- Open and potentially risky network ports
- Misconfigured firewall settings
- Excessive or inactive administrative accounts
- System-level security misconfigurations

The goal is to provide a **repeatable, automated, and extensible security baseline check** for Windows infrastructure.

---

## Objectives

- Automate Windows security baseline checks
- Provide clear and structured audit results
- Enable future remediation (auto-fix capabilities)
- Support modular expansion for enterprise environments
- Generate readable reports for IT/security teams

---

## Features (Current Version)

### System Auditing
- Detection of open TCP listening ports
- Firewall profile status validation
- Enumeration of local administrators

### Output
- Structured PowerShell objects
- Console-based reporting (Format-Table output)
- Extendable for JSON/HTML export

---

## 🧱 Project Structure
