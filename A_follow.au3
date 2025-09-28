;#include <dbug.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#include "include/GWA2.au3"

;#include <_Dbug.au3>

#Region Declarations
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global $Runs = 0
Global $Fails = 0
Global $Drops = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $TotalSeconds = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $HWND
#EndRegion Declarations

#Region GUI
$Gui = GUICreate("Follow by N.L.", 299, 174, -1, -1)
$CharInput = GUICtrlCreateCombo("", 6, 6, 103, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
   GUICtrlSetData(-1, GetLoggedCharNames())
$CharToFollowt = GUICtrlCreateCombo("", 6, 75, 103, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
   GUICtrlSetData($CharToFollowt, "1|2|3|4|5|6|7|8")
$StartButton = GUICtrlCreateButton("Start", 5, 146, 105, 23)
   GUICtrlSetOnEvent(-1, "GuiButtonHandler")
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion GUI

;Out("Ready.")
;While Not $BotRunning
;   Sleep(500)
;WEnd


Setup()
While 1
   If Not $BotRunning Then
	  ;AdlibUnRegister("TimeUpdater")
	  ;Out("Bot is paused.")
	  GUICtrlSetState($StartButton, $GUI_ENABLE)
	  GUICtrlSetData($StartButton, "Start")
	  GUICtrlSetOnEvent($StartButton, "GuiButtonHandler")
	  While Not $BotRunning
		 Sleep(500)
	  WEnd
	  ;AdlibRegister("TimeUpdater", 1000)
   EndIf
   ;AfterRun();test
   MainLoop()
WEnd

Func MainLoop()
   $tPartyID = GUICtrlRead($CharToFollowt)
   ;$tName = GetPlayerName(GetAgentByID(-1))
   Local $refID = 0
   Local $tx = 0
   Local $ty = 0
   Local $mapID = 0

   Do
	  Local $c_mapID = GetMapID()

	  ; Agent ID changes when loading a new zone => update
	  If $c_mapID <> $mapID Then
		 Do
			Sleep(250)
			TargetPartyMember($tPartyID)
			$refID = GetCurrentTargetID()
		 Until $refID <> 0
	  EndIf

	  Local $agentT = GetAgentByID($refID)
	  Local $c_tx = DllStructGetData($agentT, 'X')
	  Local $c_ty = DllStructGetData($agentT, 'Y')

	  If $c_tx <> $tx Or $c_ty <> $ty Then
		 Move($c_tx, $c_ty)
	  EndIf

	  $tx = $c_tx
	  $ty = $c_ty
	  $mapID = $c_mapID
	  Sleep(250)
   Until Not $BotRunning
EndFunc
;~ Description: Returns agent by player name.
Func GetAgentByPlayerName2($aPlayerName)
	For $i = 1 To GetMaxAgents()
		If GetPlayerName2($i) = $aPlayerName Then
			Return GetAgentByID($i)
		EndIf
	Next
 EndFunc

 Func GetPlayerName2($aAgent)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Local $lLogin = DllStructGetData($aAgent, 'LoginNumber')
	Local $lOffset[6] = [0, 0x18, 0x2C, 0x80C, 76 * $lLogin + 0x28, 0]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset, 'wchar[30]')
	Return $lReturn[1]
EndFunc


 Func Enqueue2($aPtr, $aSize)
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', 256 * $mQueueCounter + $mQueueBase, 'ptr', $aPtr, 'int', $aSize, 'int', '')
	If $mQueueCounter = $mQueueSize Then
		$mQueueCounter = 0
	Else
		$mQueueCounter = $mQueueCounter + 1
	EndIf
EndFunc

Func GuiButtonHandler()
   If $BotRunning Then
	  ;Out("Will pause after this run.")
	  GUICtrlSetData($StartButton, "force pause NOW")
	  GUICtrlSetOnEvent($StartButton, "Resign")
	  GUICtrlSetState($StartButton, $GUI_DISABLE)
	  $BotRunning = False
   ElseIf $BotInitialized Then
	  GUICtrlSetData($StartButton, "Pause")
	  $BotRunning = True
   Else
	  ;Out("Initializing...")
	  Local $CharName = GUICtrlRead($CharInput)
	  If $CharName == "" Then
		 If Initialize(ProcessExists("gw.exe"), True, True) = False Then
			   MsgBox(0, "Error", "Guild Wars is not running.")
			   Exit
		 EndIf
	  Else
		 If Initialize($CharName, True, True) = False Then
			   MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharName & "'")
			   Exit
		 EndIf
	  EndIf
	  $HWND = GetWindowHandle()
	  ;GUICtrlSetState($RenderingBox, $GUI_ENABLE)
	  GUICtrlSetState($CharInput, $GUI_DISABLE)
	  GUICtrlSetState($CharToFollowt, $GUI_DISABLE)
	  Local $charname = GetCharname()
	  GUICtrlSetData($CharInput, $charname, $charname)
	  GUICtrlSetData($StartButton, "Pause")
	  WinSetTitle($Gui, "", "Follow - " & $charname)
	  $BotRunning = True
	  $BotInitialized = True
	  SetMaxMemory()
   EndIf
EndFunc

Func Setup()

   RndSleep(500)
   ;SetUpFastWay()
EndFunc

Func Out($msg)
;~    GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
;~    _GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
;~    _GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc

Func _exit()
#CS    If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then
### 	  EnableRendering()
### 	  WinSetState($HWND, "", @SW_SHOW)
### 	  Sleep(500)
###    EndIf
 #CE
   Exit
EndFunc