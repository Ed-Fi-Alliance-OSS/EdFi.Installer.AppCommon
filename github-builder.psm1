# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.


#requires -version 7

$ErrorActionPreference = "Stop"

function Get-VersionNumber {

    $prefix = "v"

    # Install the MinVer CLI tool
    &dotnet tool install --global minver-cli

    $version = $(&minver -t $prefix)

    "appcommon-v$version" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    "appcommon-semver=$($version -Replace $prefix)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
}

function Invoke-DotnetPack {
    [CmdletBinding()]
    param (
        [string]
        [Parameter(Mandatory = $true)]
        $Version
    )

    &dotnet pack -p:PackageVersion=$Version -o ./
}

function Invoke-NuGetPush {
    [CmdletBinding()]
    param (
        [string]
        [Parameter(Mandatory = $true)]
        $NuGetFeed,

        [string]
        [Parameter(Mandatory = $true)]
        $NuGetApiKey
    )

    (Get-ChildItem -Path $_ -Name -Include *.nupkg) | ForEach-Object {
        &dotnet nuget push $_ --api-key $NuGetApiKey --source $NuGetFeed
    }
}

Export-ModuleMember -Function Get-VersionNumber, Invoke-DotnetPack
