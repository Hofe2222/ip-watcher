# 🔍 IP Watcher

A PowerShell tool that scans all files in a folder, detects IP addresses, and sends an alert.

## Features
- Scans all files in a folder, including subfolders
- Shows the file name and line number of every IP found
- Skips fake IPs (like 999.300.1.1)
- Classifies each IP:
  - 🔴 **Public**: from the internet (most dangerous)
  - 🟡 **Private**: from the internal network
  - 🔵 **Localhost**: the machine itself
- Prints a summary
- Saves a CSV report (opens in Excel)
- Shows an alert window with sound

## How to run
