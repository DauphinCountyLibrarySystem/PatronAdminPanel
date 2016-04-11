;	Name:		PatronAdminPanel
;	Version:	1.3 (Deployable Version)
;	Author:		Lucas Bodnyk, Edits by Chris Roth
;	Version Notes:  *Removed RunAs command that was causing Network button crash. - CR
;					*Changed Hotkey to Ctrl *, testing potential key blocks on patron computers. -CR
;					*Changed *RunAs options, to force admin for certain commands. - CR
;
;	I based this on the SierraWrapper - they do very similar things.
;	This script draws code from the WinWait framework by berban on www.autohotkey.com, as well as some generic examples.
;	All variables "should" be prefixed with 'z'.
;
;
;	All User Startup is '\\<Machine_Name>\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup'.
;	I recommend placing a shortcut there, pointing to this, but I have no idea where to put this.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Persistent
#InstallKeybdHook ; necessary for A_TimeIdlePhysical
#InstallMouseHook ; necessary for A_TimeIdlePhysical
OnExit("ExitFunc") ; Register a function to be called on exit
global zLocation := RegExReplace(A_ComputerName, "-[\s\S]*$") ; returns everything before (by replacing everything after) the first dash in the machine name
StringLower, zLocation, zLocation
zNumber := RegExReplace(A_ComputerName, "[\s\S]*-") ; returns everything after (by replacing everything before) the last dash in the machine name
global zNameWithSpaces := A_ComputerName . "                "
StringLeft, zNameWithSpaces, zNameWithSpaces, 15 ; adds whitespace so the log will be justified.
SplitPath, A_ScriptName, , , , ScriptBasename
StringReplace, AppTitle, ScriptBasename, _, %A_SPACE%, All
global zSessionEnd := A_TickCount
global zAdminLogPath

;
;	BEGIN INITIALIZATION SECTION
;

Try {
	Log("")
	Log("   PatronAdminPanel initializing for machine: " A_ComputerName)
} Catch	{
	MsgBox Testing PatronAdminPanel.log failed! You probably need to check file permissions. I won't run without my log! Dying now.
	ExitApp
}
Try {
	IniWrite, 1, PatronAdminPanel.ini, Test, zTest
	IniRead, zTest, PatronAdminPanel.ini, Test, 0
	IniDelete, PatronAdminPanel.ini, Test, zTest
} Catch {
	Log("!! Testing PatronAdminPanel.ini failed! You probably need to check file permissions! I won't run without my ini! Dying now.")
	MsgBox Testing PatronAdminPanel.ini failed! You probably need to check file permissions! I won't run without my ini! Dying now.
	ExitApp
}
IniRead, zClosedClean, PatronAdminPanel.ini, Log, zClosedClean, 0
IniRead, zAdminLogPath, PatronAdminPanel.ini, General, zAdminLogPath, %A_Space%
IniRead, zAdminPassword, PatronAdminPanel.ini, General, zAdminPassword, %A_Space%
IniRead, zStaffPassword, PatronAdminPanel.ini, General, zStaffPassword, %A_Space%
Log("## zClosedClean="zClosedClean)
Log("## zAdminLogPath="zAdminLogPath)
Log("## zAdminPassword="zAdminPassword)
Log("## zStaffPassword="zStaffPassword)
If (zClosedClean = 0) {
	Log("!! It is likely that PatronAdminPanel was terminated without warning.")
	}
If (zAdminLogPath = "") {
	zAdminLogPath := A_WorkingDir
	Log("ii I will be logging browser activity locally`, to "zAdminLogPath)
	}
If (zAdminPassword = "") {
	zAdminPassword := "admin"
	IniWrite, "admin", PatronAdminPanel.ini, General, zAdminPassword
	Log("ii The Admin password was blank, it is now `'admin`'!")
	}
If (zStaffPassword = "") {
	zStaffPassword := "staff"
	IniWrite, "staff", PatronAdminPanel.ini, General, zStaffPassword
	Log("ii The Staff password was blank, it is now `'staff`'!")
	}
	
	
IniWrite, 0, PatronAdminPanel.ini, Log, zClosedClean
Log("ii Initialization finished`, starting up...")

return ; obligatory so our first hotkey doesn't actually run.

^NumpadMult:: ; Changed the hotkey to Ctrl * - CR
	InputBox, zPassword, Password, Enter the password., HIDE, 192, 128, , , , 10
	If (zPassword == zAdminPassword)
	{
		DisplayAdminPanel()
	} else { If (zPassword == zStaffPassword)
	{
		DisplayStaffPanel()
	} else
	Log("!! Someone entered the password incorrectly!")
	}

return
	
DisplayAdminPanel()	{
	Gui, Add, Text, x12 y12, %A_ComputerName%
	Gui, Add, Text, x128 y12, %A_IPAddress1%
	Gui, Add, Text, x12 y36, You are ADMIN, please pick a function:
;	Gui, Add, Button, x12 y48 w100 h20 , ; Intentional gap
	Gui, Add, Button, x12 y78 w100 h20 , Logoff ; These buttons will work beautifully with up to 12 letter labels.
;	Gui, Add, Button, x12 y108 w100 h20 , ; Intentional gap
	Gui, Add, Button, x12 y138 w100 h20 , Command Line
	Gui, Add, Button, x12 y168 w100 h20 , Task Manager
	Gui, Add, Button, x12 y198 w100 h20 , Network
	Gui, Add, Button, x12 y228 w100 h20 , 
;	Gui, Add, Button, x12 y258 w100 h20 , 
	Gui, Add, Button, x12 y288 w100 h20 , Quit
;	Gui, Add, Button, x128 y48 w100 h20 , ; Intentional gap
	Gui, Add, Button, x128 y78 w100 h20 , Shutdown
;	Gui, Add, Button, x128 y108 w100 h20 , ; Intentional gap
	Gui, Add, Button, x128 y138 w100 h20 gButtonLPTOneReset, LPT:One Reset ; 13 characters, but it appears to work anyway.
	Gui, Add, Button, x128 y168 w100 h20 , Reset IE
	Gui, Add, Button, x128 y198 w100 h20 , 
	Gui, Add, Button, x128 y228 w100 h20 , 
;	Gui, Add, Button, x128 y258 w100 h20 , 
	Gui, Add, Button, x128 y288 w100 h20 Default, Cancel
	Gui, Show, h320 w240 Center, Admin Panel
	Return
}

DisplayStaffPanel()	{
	Gui, Add, Text, x12 y12, %A_ComputerName%
	Gui, Add, Text, x128 y12, %A_IPAddress1%
	Gui, Add, Text, x12 y36, You are STAFF, please pick a function:
	; FIRST ROW
;	Gui, Add, Button, x12 y48 w100 h20 , ; Intentional gap
	Gui, Add, Button, x12 y78 w100 h20 , Logoff ; These buttons will work beautifully with up to 12 letter labels.
;	Gui, Add, Button, x12 y108 w100 h20 , ; Intentional gap
;	Gui, Add, Button, x12 y138 w100 h20 , Command Line
;	Gui, Add, Button, x12 y168 w100 h20 , Task Manager
;	Gui, Add, Button, x12 y198 w100 h20 , Network
	Gui, Add, Button, x12 y228 w100 h20 , 
;	Gui, Add, Button, x12 y258 w100 h20 , 
	Gui, Add, Button, x12 y288 w100 h20 , Quit
	; SECOND ROW
;	Gui, Add, Button, x128 y48 w100 h20 , ; Intentional gap
	Gui, Add, Button, x128 y78 w100 h20 , Shutdown
;	Gui, Add, Button, x128 y108 w100 h20 , ; Intentional gap
;	Gui, Add, Button, x128 y138 w100 h20 gButtonLPTOneReset, LPT:One Reset ; 13 characters, but it appears to work anyway.
	Gui, Add, Button, x128 y168 w100 h20 , Reset IE
	Gui, Add, Button, x128 y198 w100 h20 , 
	Gui, Add, Button, x128 y228 w100 h20 , 
;	Gui, Add, Button, x128 y258 w100 h20 , 
	Gui, Add, Button, x128 y288 w100 h20 Default, Cancel
	Gui, Show, h320 w240 Center, Staff Panel
	Return
}

ButtonLogoff:
	MsgBox, 1, Logoff, Are you sure?
	IfMsgBox, OK
		Run, C:\Windows\system32\shutdown.exe /l
	Gui, Destroy
	Return

ButtonShutdown:
	MsgBox, 1, Shutdown, Are you sure?
	IfMsgBox, OK
		Run, C:\Windows\system32\shutdown.exe /s
	Gui, Destroy
	Return

ButtonResetIE:
	SplashTextOn, 192, 128, Resetting IE, Please wait a moment...
	Process, WaitClose, iexplore.exe, 3
	Runwait, "%A_WinDir%\System32\RunDll32.exe" InetCpl.cpl`,ClearMyTracksByProcess 4351, "%A_WinDir%\System32\", , Hide
	SplashTextOff
	Gui, Destroy
	Return
	
ButtonTaskManager:
	Run *RunAs C:\Windows\system32\taskmgr.exe ;fixed RunAs issue, command now runs as admin - CR
	Gui, Destroy
	Return
	
ButtonLPTOneReset:
	MsgBox, 1, LPT:One Reset, This will edit the registry and clear out Envisionware's printers.`nAre you sure?
	IfMsgBox, OK
		MsgBox registry edits go here
	Gui, Destroy
	Return

ButtonCommandLine:
	Run, cmd.exe
	Gui, Destroy
	Return

ButtonCancel:
	Gui, Destroy
	Return
	
ButtonQuit:
	ExitApp
	Return
	
ButtonNetwork:
	Run *RunAs explorer.exe ::{7007acc7-3202-11d1-aad2-00805fc1270e} ;Possibly fixed *RunAs issue. -CR
	Return
	
ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}
	
; functions to log and notify what's happening, courtesy of atnbueno
Log(Message, Type="1") ; Type=1 shows an info icon, Type=2 a warning one, and Type=3 an error one ; I'm not implementing this right now, since I already have custom markers everywhere.
{
	global ScriptBasename, AppTitle
	IfEqual, Type, 2
		Message = WW: %Message%
	IfEqual, Type, 3
		Message = EE: %Message%
	IfEqual, Message, 
		FileAppend, `n, %ScriptBasename%.log
	Else
		FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%.%A_MSec%%A_Tab%%Message%`n, %ScriptBasename%.log
	Sleep 50 ; Hopefully gives the filesystem time to write the file before logging again
	Type += 16
	;TrayTip, %AppTitle%, %Message%, , %Type% ; Useful for testing, but in production this will confuse my users.
	;SetTimer, HideTrayTip, 1000
	Return
	HideTrayTip:
	SetTimer, HideTrayTip, Off
	TrayTip
	Return
}
LogAndExit(message, Type=1)
{
	global ScriptBasename
	Log(message, Type)
	FileAppend, `n, %ScriptBasename%.log
	Sleep 1000
	ExitApp
}

ExitFunc(ExitReason, ExitCode)
{
    if ExitReason in Exit
	{
		MsgBox, 4, , This will be hard to start back up again (you will probably need to reboot).`nAre you sure you want to exit?
        IfMsgBox, No
            return 1  ; OnExit functions must return non-zero to prevent exit.
		IniWrite, 1, PatronAdminPanel.ini, Log, zClosedClean
		Log("xx User correctly entered password and chose to quit`, dying now.")
	}
	if ExitReason in Menu
    {
        MsgBox, 4, , This will be hard to start back up again (you will probably need to reboot).`nAre you sure you want to exit?
        IfMsgBox, No
            return 1  ; OnExit functions must return non-zero to prevent exit.
		IniWrite, 1, PatronAdminPanel.ini, Log, zClosedClean
		Log("xx It seems like this was closed from the notification area menu`, dying now.")
    }
	if ExitReason in Logoff,Shutdown
	{

		Process, Close, iexplore.exe
		IniWrite, 1, PatronAdminPanel.ini, Log, zClosedClean
		Log("xx System logoff or shutdown in process`, dying now.")
	}
		if ExitReason in Close
	{

		Process, Close, iexplore.exe
		IniWrite, 1, PatronAdminPanel.ini, Log, zClosedClean
		Log("!! The system issued a WM_CLOSE or WM_QUIT`, or some other unusual termination is taking place`, dying now.")
	}
		if ExitReason not in Close,Exit,Logoff,Menu,Shutdown
	{
		Process, Close, iexplore.exe
		IniWrite, 1, PatronAdminPanel.ini, Log, zClosedClean
		Log("!! I am closing unusually`, with ExitReason: " ExitReason "`, dying now.")
	}
    ; Do not call ExitApp -- that would prevent other OnExit functions from being called.
}
