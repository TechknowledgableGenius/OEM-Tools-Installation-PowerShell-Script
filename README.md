# OEM Tools Installation Script (`OEMTools.ps1`)

**A robust PowerShell script for silently installing essential vendor-specific diagnostic and update tools based on the detected system manufacturer.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![PowerShell Compatibility](https://img.shields.io/badge/PowerShell-5.1%2B-blueviolet.svg)](https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/starting-windows-powershell)

## 🌟 Overview

The `OEMTools.ps1` script simplifies post-OS deployment and refurbishment processes by automatically detecting the computer's manufacturer (e.g., Dell, HP, Lenovo) and installing the respective vendor-specific maintenance utilities (like driver updaters and diagnostics) in an unattended, silent manner.

This ensures every machine is immediately ready for easy driver management and troubleshooting, saving system administrators and refurbishers significant time and effort.

***

## ✨ Features

The script employs the intelligent `Install-IfNotPresent` function, which guarantees a reliable installation workflow:

1.  **Local Installer Check:** First, it checks for the installer executable in the same directory as the script (ideal for offline or bulk deployment).
2.  **Download Fallback:** If the local file is not found, it downloads the installer directly from the predefined vendor URL.
3.  **Silent Execution:** Uses robust command-line arguments to ensure the installation is completely quiet (`/qn`) and non-interactive.

### Supported Vendors and Tools:

| Manufacturer | Tool Installed | Purpose |
| :--- | :--- | :--- |
| **Dell** | Dell Command | Update (DCU) | Driver, BIOS, Firmware Updates |
| | Dell SupportAssist | Diagnostics and Automated Support |
| | Dell Digital Delivery (DDD) | Software License Management |
| **HP** | HP Support Assistant (HPSA) | Driver and System Optimization |
| **Lenovo** | Lenovo System Update (LSU) | Driver and Software Updates (ThinkPad/ThinkCentre) |
| | Lenovo Vantage | System Health and Settings Management |

***

## 🚀 Requirements and Setup

* **Operating System:** Windows 10 / Windows 11
* **PowerShell Version:** PowerShell 5.1 or newer.
* **Privileges:** The script **MUST** be run with **Administrator privileges**.
* **Execution Policy:** Ensure the execution policy allows running local scripts (e.g., `Set-ExecutionPolicy RemoteSigned`).

## **Deployment Optimization (Local Installers)**

For faster, network-free deployment, place the required installer executables directly into the same folder as OEMTools.ps1. The script will automatically detect and use these local files, bypassing the download step.

**Example Folder Structure:**

/YourDeploymentPath |- OEMTools.ps1 |- Dell-Command-Update.exe |- HPSupportAssistant.exe |- SystemUpdate.exe


# 🤝 Contribution

This project is licensed under the GNU General Public License, Version 3 (GPLv3). We believe in keeping essential deployment tools open and free for everyone.

Your contributions are highly valued! We need the community to help keep vendor URLs current and ensure silent switches remain effective.

## Ways on how you can help improve this code for everyone (including system admins, computer refurbishers, and even small computer shops that sell and prepare second-hand computers for their clients and customers that will want to use this script to get their job done)
 *  Report Broken Links/Switches: Open an issue if an installer URL is dead or a silent switch is causing prompts. 
 *  Submit Updates: Create a Pull Request to fix URLs, update installer versions, or refine silent arguments. 
 *  Enhance Compatibility: Add robust support blocks for other OEMs (e.g., Microsoft Surface, ASUS, MSI). 
 *  Refactor Code: Suggest improvements like converting to a proper PowerShell Module (.psm1) or using external JSON/XML files for URL management.

## 📜 License

This project is licensed under the GNU General Public License, Version 3 (GPLv3).

By using or contributing to this project, you agree that any modifications or derived works must also be released under the GPLv3 license.


# Usage Steps

1.  **Download:** Clone or download the `OEMTools.ps1` file.
2.  **Run:** Open a PowerShell prompt as **Administrator** and navigate to the script's directory.
3.  **Execute:**
```powershell
.\OEMTools.ps1
