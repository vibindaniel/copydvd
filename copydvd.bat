@echo off
:ask_for_folder_name
SET /P _name="Enter folder name: "
IF "%_name%" equ "" GOTO :ask_for_folder_name

:ask_for_drive
echo Choose a dvd drive
echo g
echo h
SET /P _drive="Your choice is? "
IF not "%_drive%" == "g" (
    if not "%_drive%" == "h" (
        echo Choice is invalid
        GOTO :ask_for_drive
    )
)

pwsh copydvd.ps1 "%_name%" "%_drive%"
