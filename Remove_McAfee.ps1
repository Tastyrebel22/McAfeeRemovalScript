#create destination directory
$directorypath = "C:\kworking\ITA\Apps"
if (-not (Test-Path -Path $directorypath)) {
    New-Item -Path $directorypath -ItemType Directory
} else {
    write-output "Directory already exists at $directorypath."
}

Start-Transcript -Path "$directorypath\Remove_Mcafee.log"

#check for 7zip, install if missing
$zipUrl = "https://7-zip.org/a/7z2409-x64.msi"
$installerPath = "$directorypath\7z2409-x64.msi"
$installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "7-Zip*" }


if (-not $installed) {
    Write-Output "7-Zip is not installed. Downloading and installing..."
    
    # Download the 7-Zip installer
    Invoke-WebRequest -Uri $zipUrl -OutFile $installerPath -Verbose
    
    # Install 7-Zip silently
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $installerPath /qn /L $directorypath\7zinstall.log" -Wait
    
    Write-Output "7-Zip has been installed."
} else {
    Write-Output "7-Zip is already installed."
}


#download Mcafee removal tool
$mcprurl = "https://download.mcafee.com/molbin/iss-loc/SupportTools/MCPR/MCPR.exe"
$mcprdest = "C:\kworking\ITA\apps\MCPR.exe"
Invoke-WebRequest -Uri $mcprurl -OutFile $mcprdest -verbose

#extract McAfee removal tool contents
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"
sz x $mcprdest -r -aoa -o"$directorypath\MCPR"

#download Mccleanup.exe 2022 version and overwrite current version (this bypasses the captcha and allows silent uninstall. Most recent version does not allow this and is blocked by a Captcha)
Invoke-WebRequest -Uri https://github.com/Tastyrebel22/McAfeeRemovalScript/raw/refs/heads/main/mccleanup2022.exe -OutFile "$directorypath\MCPR\`$1\Mccleanup.exe"


#Launch McAfee uninstall tool
Write-Output "McAfee uninstall tool launching..."
start-process "$directorypath\MCPR\`$1\Mccleanup.exe" -argumentlist "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdiver,HW,MAS,MAT,MBK,MCPR,McProxy,McSvcHost,VUL,MHN,MNA,MOBK,MPFP,MPFPCU,MPS,SHRED,MPSCU,MQC,MQCCU,MSAD,MSHR,MSK,MSSPlus,MSKCU,MWL,NMC,RedirSvc,VS,REMEDIATION,MSC,YAP,TRUEKEY,LAM,PCB,Symlink,SafeConnect,MGS,WMIRemover,RESIDUE -v -s" -Wait
Write-Output "McAfee uninstall tool completed, please reboot your computer"

Stop-Transcript