param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$name = $(throw "-name is required";),
    [Parameter(Mandatory = $false, Position = 1)]
    [string]$drives = "G,H"
)

$drives.Split(",") | ForEach-Object {
    if(Test-Path -Path "${_}:\VIDEO_TS") {
        $drive = $_
        # Copy-Item "${_}:\VIDEO_TS\*" -Destination ".\${name}" -Recurse
        robocopy "${drive}:\VIDEO_TS" ".\${name}" /s /e

        $sh = New-Object -ComObject "Shell.Application"
        $sh.Namespace(17).Items() |
            Where-Object { $_.Type -eq "CD Drive" -and $_.Path -ieq "${drive}:\" } |
            ForEach-Object { $_.InvokeVerb("Eject") }
    }
}