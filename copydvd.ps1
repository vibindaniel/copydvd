function Get-CDDrives {
    $drives = ([string](wmic CDROM where "MediaType!='unknown' and MediaLoaded='True'" get Drive)).
                ToLowerInvariant();
    $drives = [regex]::Replace($drives, "\s+", " ");
    return $drives.Split(" ") | Select-Object -Skip 1 | Where-Object { $_ -ne "" } | ForEach-Object {
        $_.SubString(0, 1);
    };
}

function ValidateName {
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]
        $Name
    )
}

function ValidateDrive {
    Param (
        [Parameter(Mandatory=$true, Position = 1)]
        [ValidateScript({ (Get-CDDrives) -contains $_ })]
        [string]
        $Drive
    )
}

function ValidateNameResult {
    Param (
        $Name
    )
    try {
        ValidateName($Name);
        return $true;
    } catch {
        Write-Error $_;
        return $false;
    }
}

function ValidateDriveResult {
    Param (
        $Drive
    )
    try {
        ValidateDrive($Drive);
        return $true;
    } catch {
        Write-Error $_;
        return $false;
    }
}

$Name = "";
$Drive = "";
Do{
    $Name = $(Read-Host -Prompt "Enter Destination Folder Name");
} while(-Not (ValidateNameResult($Name)))

Do{
    $Drive = $(Read-Host -Prompt `
    "
List of available loaded drive choices
$((Get-CDDrives) | ForEach-Object { $i = 0 } {
    $i++;
    if($i -eq 1) {
        " ${i}. ${_}`r`n";
    } else {
        "${i}. ${_}`r`n";
    }
})
Enter your drive choice");
} while(-Not (ValidateDriveResult($Drive)))

if(Test-Path -Path "${Drive}:\VIDEO_TS") {
    robocopy "${Drive}:\VIDEO_TS" ".\${Name}" /s /e;

    $sh = New-Object -ComObject "Shell.Application";
    $sh.Namespace(17).Items() |
        Where-Object { $_.Type -eq "CD Drive" -and $_.Path -ieq "${Drive}:\" } |
        ForEach-Object { $_.InvokeVerb("Eject") }
}
