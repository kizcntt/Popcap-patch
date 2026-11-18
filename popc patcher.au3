Opt("GUIOnEventMode", 1)
#include <MetroGUI-UDF\MetroGUI_UDF.au3>
#include <MetroGUI-UDF\MetroThemes.au3>
#include <MetroGUI-UDF\_GUIDisable.au3>
; ===============================================================================================================================
; Name ..........: Popcap games 1.2 Patcher
; ===============================================================================================================================
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /rm /pe
#Au3Stripper_Ignore_Funcs=_iHoverOn,_iHoverOff,_iMinBtn,_iMaxBtn,_iCloseBtn,_iRestoreBtn,_iFullscreenToggleBtn,_cHvr_CSCP_X64,_cHvr_CSCP_X86,_iControlDelete
#AutoIt3Wrapper_Res_HiDpi=y

#NoTrayIcon
#include <GUIConstants.au3>
#include <FileConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPISysWin.au3>


_Metro_EnableOnEventMode(True)
_Metro_EnableHighDPIScaling()
_SetTheme("DarkTeal")


$Form1 = _Metro_CreateGUI("Popcaps Patcher", 380, 280, -1, -1, False)
_Metro_SetGUIOption($Form1, True, False)

; Allow drag&drop file
_WinAPI_SetWindowLong($Form1, $GWL_EXSTYLE, BitOR(_WinAPI_GetWindowLong($Form1, $GWL_EXSTYLE), $WS_EX_ACCEPTFILES))


$Control_Buttons = _Metro_AddControlButtons(True, False, True, False, False)
$GUI_CLOSE_BUTTON = $Control_Buttons[0]
$GUI_MINIMIZE_BUTTON = $Control_Buttons[3]

; 1. Header
$lblTitle = GUICtrlCreateLabel("Popcaps Patcher", 25, 30, 330, 26)
GUICtrlSetFont(-1, 13, 700, 0, "Segoe UI")
GUICtrlSetColor(-1, $FontThemeColor)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

; 2. Input choose file (Read-only + Click-to-browse + Drag & Drop)
$inpFile = GUICtrlCreateInput("Click to browse or drag & drop exe here...", 25, 65, 330, 26, $ES_READONLY)
GUICtrlSetFont(-1, 9.5, 400, 0, "Segoe UI")
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
GUICtrlSetCursor(-1, 0)

; 3. Status Label and ProgressBar
$lblStatus = GUICtrlCreateLabel("Status: Ready", 25, 102, 330, 18)
GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")
GUICtrlSetColor(-1, $FontThemeColor)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

$prgBar = _Metro_CreateProgress(25, 125, 330, 16, True)

; 4. Checkbox Backup
$Checkbox3 = _Metro_CreateCheckboxEx2("Backup original file", 25, 155, 220, 26)


; 5. Patch & About button
$btnPatch = _Metro_CreateButtonEx("Patch", 25, 195, 155, 42)
$btnAbout = _Metro_CreateButtonEx2("About", 200, 195, 155, 42)

GUISetState(@SW_SHOW)

; Events register
GUISetOnEvent($GUI_EVENT_CLOSE, "_GUIEvent_ControlButtons")
GUISetOnEvent($GUI_EVENT_DROPPED, "_GUIEvent_Dropped")
GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "_GUIEvent_PrimaryDown")
GUICtrlSetOnEvent($GUI_CLOSE_BUTTON, "_GUIEvent_ControlButtons")
GUICtrlSetOnEvent($GUI_MINIMIZE_BUTTON, "_GUIEvent_ControlButtons")
GUICtrlSetOnEvent($Checkbox3, "_GUIEvent_Checkboxes")
GUICtrlSetOnEvent($btnPatch, "patchClick")
GUICtrlSetOnEvent($btnAbout, "aboutClick")

While 1
	Sleep(20)
WEnd

;=======================================================================Functions=============================================================================

Func _GUIEvent_ControlButtons()
	Switch @GUI_CtrlId
		Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON
			_Metro_GUIDelete($Form1)
			Exit
		Case $GUI_MINIMIZE_BUTTON
			GUISetState(@SW_MINIMIZE, $Form1)
	EndSwitch
EndFunc

Func _GUIEvent_Dropped()
	GUICtrlSetData($inpFile, @GUI_DragFile)
	GUICtrlSetData($lblStatus, "Status: Target executable loaded.")
EndFunc

Func _GUIEvent_PrimaryDown()
	If Not WinActive($Form1) Then Return
	Local $aCInfo = GUIGetCursorInfo($Form1)
	If Not @error And $aCInfo[4] = $inpFile Then
		Local $sChosen = FileOpenDialog("Select Target Executable", @ScriptDir, "Executable Files (*.exe)", $FD_FILEMUSTEXIST, "", $Form1)
		If Not @error Then
			GUICtrlSetData($inpFile, $sChosen)
			GUICtrlSetData($lblStatus, "Status: Target executable loaded.")
		EndIf
	EndIf
EndFunc

Func _GUIEvent_Checkboxes()
	If _Metro_CheckboxIsChecked($Checkbox3) Then
		_Metro_CheckboxUnCheck($Checkbox3)
	Else
		_Metro_CheckboxCheck($Checkbox3)
	EndIf
EndFunc

Func patchClick()
	Local $sTarget = GUICtrlRead($inpFile)
	If $sTarget = "" Or $sTarget = "Click to browse or drag & drop exe here..." Then
		_GUIDisable($Form1, 0, 30)
		_Metro_MsgBox(0, "Warning", "Please select a valid target executable first!", 360, 11, $Form1)
		_GUIDisable($Form1)
		Return
	EndIf
	_ExtractAndReplacePE($sTarget)
EndFunc

Func aboutClick()
	_GUIDisable($Form1, 0, 30)
	_Metro_MsgBox(0, "About", "Popcap Games Patcher" & @CRLF & "Patch any games of Popcaps Games have trial play time" & @CRLF & @CRLF & "Developed by Shu and Gemini", 360, 11, $Form1)
	_GUIDisable($Form1)
EndFunc

Func _SmoothProgress($iStart, $iEnd, $iStepDelay = 12)
	For $p = $iStart To $iEnd
		_Metro_SetProgress($prgBar, $p)
		Sleep($iStepDelay)
	Next
EndFunc

Func _ExtractAndReplacePE($sPath)
	If Not StringInStr($sPath, "\") Then $sPath = @ScriptDir & "\" & $sPath

	If Not FileExists($sPath) Then
		_GUIDisable($Form1, 0, 30)
		_Metro_MsgBox(0, "Error", "Target file not found:" & @CRLF & $sPath, 360, 11, $Form1)
		_GUIDisable($Form1)
		Return
	EndIf

	_Metro_DisableButton($btnPatch)
	_Metro_SetProgress($prgBar, 0)


	GUICtrlSetData($lblStatus, "Status: Reading binary stream into memory...")
	_SmoothProgress(0, 20, 10)

	Local $hFile = FileOpen($sPath, $FO_BINARY)
	If $hFile = -1 Then
		_Metro_EnableButton($btnPatch)
		_GUIDisable($Form1, 0, 30)
		_Metro_MsgBox(0, "Error", "Unable to open target file for reading!", 360, 11, $Form1)
		_GUIDisable($Form1)
		Return
	EndIf
	Local $dData = FileRead($hFile)
	FileClose($hFile)

	Local $iLength = BinaryLen($dData)
	If $iLength < 1024 Then
		_Metro_EnableButton($btnPatch)
		_GUIDisable($Form1, 0, 30)
		_Metro_MsgBox(0, "Error", "File too small to contain valid PE!", 360, 11, $Form1)
		_GUIDisable($Form1)
		Return
	EndIf


	GUICtrlSetData($lblStatus, "Status: Analyzing PE signatures & pointer tables...")
	_SmoothProgress(20, 50, 10)

	Local $tBytes = DllStructCreate("byte[" & $iLength & "]")
	DllStructSetData($tBytes, 1, $dData)
	Local $pBase = DllStructGetPtr($tBytes)
	Local $iFoundOffset = -1

	For $i = 2 To $iLength - 0x100
		Local $tWord = DllStructCreate("ushort", $pBase + $i)
		If DllStructGetData($tWord, 1) = 0x5A4D Then
			Local $tInt = DllStructCreate("int", $pBase + $i + 0x3C)
			Local $e_lfanew = DllStructGetData($tInt, 1)

			If $e_lfanew > 0 And ($i + $e_lfanew + 4) <= $iLength Then
				Local $tSig = DllStructCreate("uint", $pBase + $i + $e_lfanew)
				If DllStructGetData($tSig, 1) = 0x00004550 Then
					$iFoundOffset = $i
					ExitLoop
				EndIf
			EndIf
		EndIf
	Next

	If $iFoundOffset = -1 Then
		_Metro_SetProgress($prgBar, 0)
		_Metro_EnableButton($btnPatch)
		GUICtrlSetData($lblStatus, "Status: Patched failed (No PE header).")
		_GUIDisable($Form1, 0, 30)
		_Metro_MsgBox(0, "Patch Failed", "No valid executable found", 380, 11, $Form1)
		_GUIDisable($Form1)
		Return
	EndIf


	If _Metro_CheckboxIsChecked($Checkbox3) Then
		GUICtrlSetData($lblStatus, "Status: Creating backup file ...")
		_SmoothProgress(50, 65, 10)
		local $sOutPath = StringTrimRight($sPath, 4) & "_backup.exe"
		FileCopy($sPath, $sOutPath , $FC_OVERWRITE)
	Else
		_SmoothProgress(50, 65, 5)
	EndIf


	GUICtrlSetData($lblStatus, "Status: Carving nested payload at 0x" & Hex($iFoundOffset+5, 8) & "...")
	_SmoothProgress(65, 85, 10)

	Local $dSubPE = BinaryMid($dData, $iFoundOffset + 1)


	GUICtrlSetData($lblStatus, "Status: Overwriting target executable container...")
	_SmoothProgress(85, 95, 10)

	Local $hOut = FileOpen($sPath, $FO_BINARY + $FO_OVERWRITE)
	If $hOut = -1 Then
		_Metro_EnableButton($btnPatch)
		GUICtrlSetData($lblStatus, "Status: Write permission denied.")
		_GUIDisable($Form1, 0, 30)
		_Metro_MsgBox(0, "Write Error", "Failed to write output file! Ensure the target process is not running.", 380, 11, $Form1)
		_GUIDisable($Form1)
		Return
	EndIf

	FileWrite($hOut, $dSubPE)
	FileClose($hOut)


	_SmoothProgress(95, 100, 8)
	GUICtrlSetData($lblStatus, "Status: Done! Offset 0x" & Hex($iFoundOffset+18, 6) & " deployed.")
	_Metro_EnableButton($btnPatch)

	_GUIDisable($Form1, 0, 30)
	_Metro_MsgBox(0, "Success", "Patched executable successfully!", 380, 11, $Form1)
	_GUIDisable($Form1)
EndFunc