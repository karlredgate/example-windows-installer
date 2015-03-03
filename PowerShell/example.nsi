
!define PRODUCT "example"
!include x64.nsh

Name "${PRODUCT}"
Outfile "${PRODUCT}.exe"

InstallDir "$PROGRAMFILES\${PRODUCT}\"
InstallDirRegKey HKLM "Software\Redgates\example" "Install_Dir"
SilentInstall silent

Section "Install"
    ${DisableX64FSRedirection}
    SetOutPath "$WINDIR\System32\WindowsPowerShell\v1.0\Modules\${PRODUCT}\"

    File "Example\Example.psd1"
    File "Example\Example.psm1"

    SetOutPath "$DOCUMENTS\WindowsPowerShell\"
    File "Microsoft.PowerShell_profile.ps1"

    SetRegView 64

    ;write uninstall information to the registry
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "DisplayName" "${PRODUCT} (remove only)"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "UninstallString" "$INSTDIR\Uninstall.exe"

    SetOutPath "$INSTDIR"
    File "megared.ico"
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    WriteRegStr HKLM "Software\Redgates\${PRODUCT}" "Install_Dir" "$INSTDIR"
SectionEnd

Section "Uninstall"
    ;Delete Uninstaller And Unistall Registry Entries
    DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\${PRODUCT}"
    DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}"  
SectionEnd

Section -post
  WriteUninstaller "$INSTDIR\Uninstall Example.exe"
SectionEnd

# vim:autoindent expandtab sw=4
