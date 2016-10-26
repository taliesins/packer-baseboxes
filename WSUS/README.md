PSWsusSpringClean
=================

A PowerShell module to assist with cleaning-up superfluous updates in Windows Server Update Services (WSUS).

The Problem
-----------

For the cleanliness obsessed among us, maintaining a pristine WSUS catalogue of approved updates can be a tedious and time-consuming affair. While WSUS itself provides tools to help manage this process, via the graphical *Server Cleanup Wizard* and its PowerShell equivalent `Invoke-WsusServerCleanup`, these tools can only decline or delete updates which WSUS itself is already aware are obsolete via update metadata. Unfortunately, many updates are obsolete but lack the metadata to indicate as such, or are still current but may be unwanted (e.g. Itanium architecture updates). Manually maintaining an ever-increasing catalogue of updates while removing these unwanted updates rapidly becomes a timesink.

The Solution
------------

The PSWsusSpringClean module provides several additional options for cleaning your WSUS server:

- Decline unneeded updates (`DeclineUnneededUpdates`)  
  Declines updates which are likely unneeded (see the [Unneeded Updates](#unneeded-updates) section for more details).
- Decline failover clustering updates (`-DeclineClusterUpdates`)  
  Updates which only apply to **SQL Server 2000/2005** installations in a *failover clustering* configuration.
- Decline farm server & deployment updates (`-DeclineFarmUpdates`)  
  Updates which only apply to *Farm Server* products or product installations in a *farm-deployment* configuration.
- Decline Itanium architecture updates (`-DeclineItaniumUpdates`)  
  Updates which only apply to products installed on *Itanium* architecture systems.
- Flag for review updates which may be incorrectly declined (`-FindSuspectDeclines`)  
  Lists updates which may be incorrectly declined (see the [Suspect Declines](#suspect-declines) section for more details).
- Synchronise the WSUS server catalogue (`-SynchroniseServer`)  
  A synchronisation will be performed before any requested clean-up actions.

The module also provides parameters to wrap the functions of the `Invoke-WsusServerCleanup` cmdlet. The intent is to be able to perform a comprehensive clean-up of the WSUS server catalogue via a single PowerShell cmdlet invocation.

## Unneeded Updates

There are many updates which are likely unwanted in WSUS installations but have no obvious indicator in the metadata which can be used to detect them. To handle these updates a CSV file of categorised potentially unneeded updates is included with this module and can be used to selectively decline listed updates based on their associated category. The CSV file can be easily imported into a spreadsheet application of your choice to review the provided categories and associated updates or make changes.

Two parameters are provided to indicate to the module which unneeded updates should be declined:

- Decline only the updates in the listed categories (`-DeclineCategoriesInclude`) [**Default**]  
  An array of strings corresponding to the categories (per the CSV file) of unneeded updates to be declined. If an empty array is provided (default) then *no* updates listed in the CSV will be declined.
- Decline all unneeded updates except those in the listed categories (`-DeclineCategoriesExclude`)  
  An array of strings corresponding to the categories (per the CSV file) of unneeded updates to exclude from declining. If an empty array is provided (default) then **all** updates listed in the CSV will be declined!

The `-DeclineCategoriesExclude` parameter should be used with caution as it could easily decline updates you did not intend to!

## Suspect Declines

The module also provides a function to identify updates which may have been inadvertently declined via the `-FindSuspectDeclines` parameter. This will identify all declined updates which meet all of the following criteria:

- Are not superseded
- Are not expired
- Would not have been declined by this module based on the provided parameters

This can also be used to assist in reverting declines that were unintentionally made via an earlier invocation of this module with incorrect parameters.

Requirements
------------

- PowerShell 3.0 (or later)

Installing
----------

### PowerShellGet (included with PowerShell 5.0)

The latest release of the module is published to the [PowerShell Gallery](https://www.powershellgallery.com/) for installation via the [PowerShellGet module](https://www.powershellgallery.com/GettingStarted):

```posh
Install-Module -Name PSWsusSpringClean
```

You can find the module listing [here](https://www.powershellgallery.com/packages/PSWsusSpringClean).

### ZIP File

Download the [ZIP file](https://github.com/ralish/PSWsusSpringClean/archive/stable.zip) of the latest release and unpack it to one of the following locations:

- Current user: `C:\Users\<your.account>\Documents\WindowsPowerShell\Modules\PSWsusSpringClean`
- All users: `C:\Program Files\WindowsPowerShell\Modules\PSWsusSpringClean`

### Git Clone

You can also clone the repository into one of the above locations if you'd like the ability to easily update it via Git.

### Did it work?

You can check that PowerShell is able to locate the module by running the following at a PowerShell prompt:

```posh
Get-Module PSWsusSpringClean -ListAvailable
```

Sample Usage
------------

```posh
# Decline all failover clustering, farm server/deployment & Itanium updates:
Invoke-WsusSpringClean -DeclineClusterUpdates -DeclineFarmUpdates -DeclineItaniumUpdates

# Decline all unneeded updates in the Superseded & Pre-release categories:
Invoke-WsusSpringClean -DeclineUnneededUpdates -DeclineCategoriesInclude @('Superseded', 'Pre-release')

# Find all suspect declines using the decline criteria from our previous invocations:
Invoke-WsusSpringClean -DeclineClusterUpdates -DeclineFarmUpdates -DeclineItaniumUpdates -DeclineUnneededUpdates -DeclineCategoriesInclude @('Superseded','Pre-release') -FindSuspectDeclines

# Show what updates would be declined if we were to decline all unneeded updates:
Invoke-WsusSpringClean -DeclineUnneededUpdates -DeclineCategoriesExclude @() -WhatIf
```

License
-------

All content is licensed under the terms of [The MIT License](LICENSE).