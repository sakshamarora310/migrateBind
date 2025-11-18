Infoblox NS Group Migration Script

This repository contains a PowerShell automation script used to migrate authoritative DNS zones from one Infoblox Name Server Group (NS Group) to another, 
followed by a zone transfer from a specified source server.
All sensitive values such as credentials, server names, and IPs have been intentionally obfuscated.

🚀 Overview

This script was created to assist with DNS modernization efforts during a migration from BIND to Infoblox.
Its primary goal is to automate what would otherwise be a manual and repetitive administrative process.

What the script does:

Retrieves all authoritative DNS zones from Infoblox via the WAPI.

Filters the list to only process forward (FORWARD) zones.
(Can be adjusted to include IPv4/PT/Reverse zones.)

Updates the NS Group for each selected zone (e.g., to "Prod NS Group").

Initiates a zone transfer from an authoritative source server.

Outputs progress and results for each zone processed.

The script is written for and tested with PowerShell 7.
