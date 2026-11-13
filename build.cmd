@echo off

echo.
echo.  _______        __  _____      _                  _             
echo. ^|  ___\ \      / / ^| ____^|_  _^| ^|_ _ __ __ _  ___^| ^|_ ___  _ __ 
echo. ^| ^|_   \ \ /\ / /  ^|  _^| \ \/ / __^| '__/ _` ^|/ __^| __/ _ \^| '__^|
echo. ^|  _^|   \ V  V /   ^| ^|___ ^>  ^<^| ^|_^| ^| ^| ^(_^| ^| ^(__^| ^|^| ^(_^) ^| ^|   
echo. ^|_^|      \_/\_/    ^|_____/_/\_\\__^|_^|  \__,_^|\___^|\__\___/^|_^|   
echo.                                                                 

REM winner Root Key Hash
set RKH=B7E5F19B85968ED452900BB7E621E023BFBDB3C10DAAD414B8D123968AF3A70D
B7E5F19B85968ED452900BB7E621E023BFBDB3C10DAAD414B8D123968AF3A70D
F8AB20526358C4FA4CEF96D78C45180DC3DB75E8F24051AD624448C134B4E861
F8AB20526358C4FA4CEF96D78C45180DC3DB75E8F24051AD624448C134B4E861


set SOC=8150

echo.
echo Target: winner
echo SoC   : SM%SOC%
echo RKH   : %RKH_LIST% (Samsung Attestation CA) (From: Jan 4 2025 GMT To: Oct 29 2043 GMT)
echo.

for /f %%f in ('dir /b /s extracted\*.mbn.unsigned') do (
    call :moveUnsigned %%f
)

for /f %%f in ('dir /b /s extracted\*_unsigned.mbn') do (
    call :moveUnsigned %%f
)

echo Checking MBN files validity... (This may take a while!)

for /f %%f in ('dir /b /s extracted\*.mbn') do (
    call :checkRKH %%f
)

echo Checking ELF files validity... (This may take a while!)

for /f %%f in ('dir /b /s extracted\*.elf') do (
    call :checkRKH %%f
)

echo Checking BIN files validity... (This may take a while!)

for /f %%f in ('dir /b /s extracted\*.bin') do (
    call :checkRKH %%f
)

echo Checking IMG files validity... (This may take a while!)

for /f %%f in ('dir /b /s extracted\*.img') do (
    call :checkRKH %%f
)

REM echo Cleaning up Output Directory...
REM rmdir /Q /S output

mkdir output
mkdir output\Subsystems


REM ADSP
mkdir output\Subsystems\ADSP
mkdir output\Subsystems\ADSP\ADSP

echo Converting Analog DSP Image...
python tools\pil-squasher.py ./output/Subsystems/ADSP/qcadsp%SOC%.mbn ./extracted/vendor/firmware_mnt/image/adsp.mdt

echo Copying ADSP Protection Domain Registry Config files...
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\adspr.jsn output\Subsystems\ADSP\adspr.jsn
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\adsps.jsn output\Subsystems\ADSP\adsps.jsn
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\\adspua.jsn output\Subsystems\ADSP\adspua.jsn

echo Copying ADSP lib files...
REM xcopy /qcheriky extracted\vendor\lib\rfsa\adsp output\Subsystems\ADSP\ADSP
xcopy /qcheriky extracted\dsp\adsp output\Subsystems\ADSP\ADSP

echo Generating ADSP FASTRPC INF Configuration...
tools\SuBExtInfUpdater-ADSP.exe output\Subsystems\ADSP\ADSP > output\Subsystems\ADSP\inf_configuration.txt


REM CDSP
mkdir output\Subsystems\CDSP
mkdir output\Subsystems\CDSP\CDSP

echo Converting Compute DSP Image...
python tools\pil-squasher.py ./output/Subsystems/CDSP/qccdsp%SOC%.mbn ./extracted/vendor/firmware_mnt/image/cdsp.mdt

echo Copying CDSP Protection Domain Registry Config files...
xcopy /qchky /-i extracted/vendor/firmware_mnt/image/cdspr.jsn output\Subsystems\CDSP\cdspr.jsn

echo Copying CDSP lib files...
xcopy /qcheriky extracted\dsp\cdsp output\Subsystems\CDSP\CDSP

echo Generating CDSP FASTRPC INF Configuration...
tools\SuBExtInfUpdater-CDSP.exe output\Subsystems\CDSP\CDSP > output\Subsystems\CDSP\inf_configuration.txt


REM SDSP
mkdir output\Subsystems\SDSP
mkdir output\Subsystems\SDSP\SDSP

echo Converting Compute DSP Image...
python tools\pil-squasher.py ./output/Subsystems/SDSP/qccdsp%SOC%.mbn ./extracted/vendor/firmware_mnt/image/slpi.mdt

echo Copying SDSP Protection Domain Registry Config files...
xcopy /qchky /-i extracted/vendor/firmware_mnt/image\slpir.js output\Subsystems\SDSP\slpir.jsn
xcopy /qchky /-i extracted/vendor/firmware_mnt/image\slpius.jsn output\Subsystems\SDSP\slpius.jsn

echo Copying SDSP lib files...
xcopy /qcheriky extracted\dsp\sdsp output\Subsystems\SDSP\SDSP

echo Generating SDSP FASTRPC INF Configuration...
tools\SuBExtInfUpdater-SDSP.exe output\Subsystems\SDSP\SDSP > output\Subsystems\SDSP\inf_configuration.txt


REM ICP
mkdir output\Subsystems\ICP

xcopy /qchky /-i extracted\vendor\firmware\CAMERA_ICP.elf output\Subsystems\ICP\CAMERA_ICP_AAAAAA.elf


REM IPA
mkdir output\Subsystems\IPA

python tools\pil-squasher.py ./output\Subsystems\IPA\ipa_fws.elf .\extracted\vendor\firmware\ipa_fws.mdt
python tools\pil-squasher.py ./output\Subsystems\IPA\ipa_uc.elf .\extracted\vendor\firmware\ipa_uc.mdt
REM SPSS
mkdir output\Subsystems\SPSS
echo Converting SPSS1p Image...
python tools\pil-squasher.py ./output/Subsystems/SPSS/qcspss1p%SOC%.mbn ./extracted/vendor/firmware_mnt/image/spss1p.mdt

echo Converting SPSS2p Image...
python tools\pil-squasher.py ./output/Subsystems/SPSS/qcspss2p%SOC%.mbn ./extracted/vendor/firmware_mnt/image/spss2p.mdt

xcopy /qchky /-i extracted\vendor\firmware_mnt\image\asym1p.sig output\Subsystems\SPSS\asymw1p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\crypt1p.sig output\Subsystems\SPSS\cryptw1p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\keym1p.sig output\Subsystems\SPSS\keymw1p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\echo1p.sig output\Subsystems\SPSS\echo1p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\iris1p.sig output\Subsystems\SPSS\iris1p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\macch1p.sig output\Subsystems\SPSS\macch1p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\smpl1p.sig output\Subsystems\SPSS\smpl1p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\spsmt1p.sig output\Subsystems\SPSS\spsmt1p.sig

xcopy /qchky /-i extracted\vendor\firmware_mnt\image\asym2p.sig output\Subsystems\SPSS\asymw2p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\crypt2p.sig output\Subsystems\SPSS\cryptw2p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\keym2p.sig output\Subsystems\SPSS\keymw2p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\echo2p.sig output\Subsystems\SPSS\echo2p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\iris2p.sig output\Subsystems\SPSS\iris2p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\macch2p.sig output\Subsystems\SPSS\macch2p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\smpl2p.sig output\Subsystems\SPSS\smpl2p.sig
xcopy /qchky /-i extracted\vendor\firmware_mnt\image\spsmt2p.sig output\Subsystems\SPSS\spsmt2p.sig

REM MCFG
mkdir output\Subsystems\MCFG
mkdir output\Subsystems\MCFG\MCFG

echo Generating MCFG TFTP INF Configuration...
tools\SuBExtInfUpdater-MCFG.exe extracted\modem\image\modem_pr output\Subsystems\MCFG\MCFG > output\Subsystems\MCFG\inf_configuration.txt

xcopy /qchky /-i extracted\modem\image\qdsp6m.qdb output\Subsystems\MCFG\qdsp6m.qdb


REM MPSS
mkdir output\Subsystems\MPSS

echo Copying MPSS Protection Domain Registry Config files...
xcopy /qchky /-i extracted\modem\image\modemr.jsn output\Subsystems\MPSS\modemr.jsn

echo Converting Modem Processor Subsystem DSP Image...
python tools\pil-squasher.py ./output/Subsystems/MPSS/qcmpss%SOC%.mbn ./extracted/modem/image/modem.mdt


REM Generate VENUS
mkdir output\Subsystems\VENUS

echo Converting Video Encoding Subsystem DSP Image...
python tools\pil-squasher.py ./output/Subsystems/VENUS/qcvss%SOC%.mbn .\extracted\vendor\firmware_mnt\image\venus.mdt


REM ZAP
mkdir output\Subsystems\ZAP

echo Converting GPU ZAP Shader Micro Code DSP Image...
python tools\pil-squasher.py ./output/Subsystems/ZAP/qcdxkmsuc%SOC%.mbn .\extracted\vendor\firmware_mnt\image\a640_zap.mdt

mkdir output\Camera

mkdir output\Camera\Rear

xcopy /qchky /-i extracted\vendor\lib\camera\com.samsung.sensormodule.8_sony_imx374_full_winner.bin output\Camera\Rear\com.samsung.sensormodule.8_sony_imx374_full_winner.bin
xcopy /qchky /-i extracted\vendor\lib\camera\com.samsung.sensormodule.2_lsi_s5k4ha.bin output\Camera\Rear\com.samsung.sensormodule.2_lsi_s5k4ha.bin
xcopy /qchky /-i extracted\vendor\lib\camera\com.samsung.sensormodule.4_lsi_s5k3m3.bin output\Camera\Rear\com.samsung.sensormodule.4_lsi_s5k3m3.bin

mkdir output\Camera\Front

xcopy /qchky /-i extracted\vendor\lib\camera\com.samsung.sensormodule.5_sony_imx374_top_winner.bin output\Camera\Front\com.samsung.sensormodule.5_sony_imx374_top_winner.bin
xcopy /qchky /-i extracted\vendor\lib\camera\com.samsung.sensormodule.3_lsi_s5k3p9sn.bin output\Camera\Front\com.samsung.sensormodule.3_lsi_s5k3p9sn.bin

REM Touch
mkdir output\Touch
mkdir output\Touch\FW

xcopy /qchky /-i extracted\y761_winner.bin output\Touch\FW\y761_winner.bin
xcopy /qchky /-i extracted\fts9cu80f_winner.fw output\Touch\FW\fts9cu80f_winner.fw

REM Bluetooth
mkdir output\BT

echo Copying Blueooth Firmware Files...
xcopy /qchky /-i extracted\vendor\firmware-mnt\image\wil6436_.fw output\BT\wil6436_.fw

REM WCNSS
mkdir output\Subsystems\WCNSS

xcopy /qchky /-i extracted\vendor\firmware\bcm4375B1_murata.hcd output\Subsystems\WCNSS\bcm4375B1_murata.hcd
xcopy /qchky /-i extracted\vendor\firmware\bcmdhd_clm.blob output\Subsystems\WCNSS\bcmdhd_clm.blob
xcopy /qchky /-i extracted\vendor\firmware\bcmdhd_mfg.bin_b1 output\Subsystems\WCNSS\bcmdhd_mfg.bin_b1
xcopy /qchky /-i extracted\vendor\firmware\bcmdhd_mon.bin_b1 output\Subsystems\WCNSS\bcmdhd_mon.bin_b1
xcopy /qchky /-i extracted\vendor\firmware\bcmdhd_sta.bin_b1 output\Subsystems\WCNSS\bcmdhd_sta.bin_b1

xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_1rh_es11_b0 output\Subsystems\WCNSS\nvram.txt_1rh_es11_b0
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_1rh_es12_b0 output\Subsystems\WCNSS\nvram.txt_1rh_es12_b0
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_1rh_es13_b0 output\Subsystems\WCNSS\nvram.txt_1rh_es13_b0
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_1rh_es32_b0 output\Subsystems\WCNSS\nvram.txt_1rh_es32_b0
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_1rh_es41_b1 output\Subsystems\WCNSS\nvram.txt_1rh_es41_b1
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_1rh_es42_b1 output\Subsystems\WCNSS\nvram.txt_1rh_es42_b1
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_1rh_es43_b1 output\Subsystems\WCNSS\nvram.txt_1rh_es43_b1
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_CS01_semco_b1 output\Subsystems\WCNSS\nvram.txt_CS01_semco_b1
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_ES00_semco_b0 output\Subsystems\WCNSS\nvram.txt_ES00_semco_b0
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_ES01_semco_b0 output\Subsystems\WCNSS\nvram.txt_ES01_semco_b0
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_ES02_semco_b0 output\Subsystems\WCNSS\nvram.txt_ES02_semco_b0
xcopy /qchky /-i extracted\vendor\firmware\nvram.txt_ES03_semco_b0 output\Subsystems\WCNSS\nvram.txt_ES03_semco_b0

REM WDSP
mkdir output\Subsystems\WDSP

echo Converting Wave DSP Image...
python tools\pil-squasher.py ./output/Subsystems/WDSP/qcwdsp%SOC%.mbn ./extracted/modem/image/cpe_9340.mdt


REM Sensors
mkdir output\Sensors
mkdir output\Sensors\Config

xcopy /qchky /-i extracted\vendor\etc\sensors\sns_reg_config output\Sensors\Config\sns_reg_config
xcopy /qcheriky extracted\vendor\etc\sensors\config output\Sensors\Config

echo Generating SLPI FASTRPC INF Configuration...
tools\SuBExtInfUpdater-SLPI.exe output\Sensors\Config > output\Sensors\inf_configuration.txt
move output\Sensors\inf_configuration.txt output\Sensors\Config\inf_configuration.txt

mkdir output\Sensors\Proto

xcopy /qcheriky extracted\vendor\etc\sensors\proto output\Sensors\Proto


REM Audio
mkdir output\Audio
mkdir output\Audio\Cal

xcopy /qchky /-i extracted\vendor\etc\acdbdata\adsp_avs_config.acdb output\Audio\Cal\adsp_avs_config.acdb


mkdir output\Regulatory


REM TrEE
mkdir output\TrEE

echo Converting engmode (n=engmode;p=8:c477a8cf3e4089,61,82:6004,b4) QSEE Applet...
python tools\pil-squasher.py ./output/TrEE/engmode.mbn .\extracted\vendor\firmware_mnt\engmode.mdt

echo Converting hdcpsrm (n=hdcpsrm;p=8:c47728cf3e4089,5d:8,82:6004,b4;s=5e) QSEE Applet...
python tools\pil-squasher.py ./output/TrEE/hdcpsrm.mbn ./extracted/vendor/firmware_mnt/image/hdcpsrm.mdt"

echo Converting qcom.tz.hdcp2p2 (n=qcom.tz.hdcp2p2;p=8:c47728cf3e408911,5a:94,82:6004,b4;s=43,56) QSEE Applet...
python tools\pil-squasher.py ./output/TrEE/hdcp2p2.mbn ./extracted/vendor/firmware_mnt/image/hdcp2p2.mdt"

echo Converting hdcp1 (n=hdcp1;p=8:c477a8cf3e40893,61,82:6004,b4;s=55) QSEE Applet...
python tools\pil-squasher.py ./output/TrEE/hdcp1.mbn ./extracted/vendor/firmware_mnt/image/hdcp1.mdt"

echo Converting tz_iccc (n=tz_iccc;p=8:c477a8cf3ec089,61,80:a1001,b4,400;s=106:81) QSEE Applet...
python tools\pil-squasher.py ./output/TrEE/tz_iccc.mbn .\extracted\vendor\firmware_mnt\tz_iccc.mdt

echo Converting vaultkeeper (n=vaultkeeper;p=8:c477a8cf3e4089,61,82:6004,b4,1036640) QSEE Applet...
python tools\pil-squasher.py ./output/TrEE/vaultkee.mbn .\extracted\vendor\firmware_mnt\vaultkee.mdt

echo Converting voicepri (n=voiceprint;p=8:c47728cf3e4089,61,82:6004,b4) QSEE Applet...
python tools\pil-squasher.py ./output/TrEE/voicepri.mbn .\extracted\vendor\firmware_mnt\voicepri.mdt

echo Copying widevine (n=widevine;p=8:c47728cf3e4089,5a:24,82:68048,b4,32b,4b1,dac;s=dac) QSEE Applet...
python tools\pil-squasher.py ./output\TrEE\widevine.mbn .\extracted\vendor\firmware_mnt\widevine.mdt 

echo Copying rtic (n=rtic;p=8:c47728cf3e4289,60:30080400a3001,b4;s=46;u=6238333e1eb7ea11b3de0242ac130004) QSEE Applet...
python tools\pil-squasher.py ./output\TrEE\haventkn.mbn .\extracted\vendor\firmware_mnt\haventkn.mdt

echo Converting cppf (n=cppf;p=b:9ea409f7c90031,5a,82:6) QSEE Applet...
python tools\pil-squasher.py ./output/TrEE/cppf.mbn ./extracted/vendor/firmware_mnt/image/cppf.mdt

REM START: Do we need those? They should already be loaded in UEFI.

REM TODO: Trim
echo Copying qcom.tz.uefisecapp (n=qcom.tz.uefisecapp;p=b:9ea409f7c90031,82:6) QSEE Applet...
xcopy /qchky /-i extracted\uefisecapp.img output\TrEE\uefisecapp.mbn

REM TODO: Trim
echo Copying keymaster64 (n=keymaster64;p=8:c47728cf3e4489,61,82:6024,b4;s=96) QSEE Applet...
xcopy /qchky /-i extracted\keymaster.img output\TrEE\keymaster.mbn

REM END: Do we need those? They should already be loaded in UEFI.

mkdir output\UEFI

echo Extracting XBL Image...
tools\UEFIReader.exe extracted\xbl.img output\UEFI

mkdir output\UEFI\ABL

echo Extracting ABL Image...
tools\UEFIReader.exe extracted\abl.img output\UEFI\ABL

:eof
exit /b 0

:checkRKH

set "x=INVALID"
for /F "eol=; tokens=1-2 delims=" %%a in ('tools\RKHReader.exe "%~1" 2^>^&1') do (
    set "x=%%a"
)

echo.
echo File: %~1
echo RKH : %x%
echo.
set "directory=%~dp1"
call set "directory=%%directory:%cd%\=%%"

echo %RKH_LIST% | findstr /I /C:"%x%" >nul
if NOT errorlevel 1 (
    exit /b 1
)

if /I "%x%"=="FAIL!" (
    exit /b 2
)

if /I "%x%"=="EXCEPTION!" (
    exit /b 2
)

echo %~1 is a valid MBN file and is not production signed (%x%). Moving...
mkdir "unsigned\%directory%" 2>nul
move "%~1" "unsigned\%directory%"
exit /b 0

:moveUnsigned

echo.
echo File: %~1
echo.
set "directory=%~dp1"
call set "directory=%%directory:%cd%\=%%"

echo %~1 is a valid MBN file and is not signed. Moving...
mkdir "unsigned\%directory%" 2>nul
move "%~1" "unsigned\%directory%"
exit /b 0
