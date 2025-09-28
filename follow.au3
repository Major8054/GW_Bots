;#include <dbug.au3>
#include <ButtonConstants.au3>
#include <GWA2.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>

#Region Declarations
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global Const $WEAPON_SLOT_SCYTHE = 1
Global Const $WEAPON_SLOT_STAFF = 2
Global $Runs = 0
Global $Fails = 0
Global $Drops = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $TotalSeconds = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $MerchOpened = False
Global $HWND
Global $MaterialsToSalavage[1]
$MaterialsToSalavage[0] = "Pierre de glace"

Global Const $rarity_white = 2621
Global Const $rarity_blue = 2623
Global Const $rarity_purple = 2626
Global Const $rarity_gold = 2624
Global Const $rarity_green = 2627
#EndRegion Declarations

#Region GUI
$Gui = GUICreate("Bones Farmer", 299, 174, -1, -1)
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
   Do
	  TargetPartyMember(GUICtrlRead($CharToFollowt))
	  ActionFollow()
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

Func _salvage()
		Local $lquantityold, $loldvalue
		SalvageKit()
		;Local $lsalvagekitid = FindSalvageKit(1, 4)
		Local $lsalvagekitid = FindSalvageKit3()
		Local $lsalvagekitptr = GetItemByItemID($lsalvagekitid)
		For $bag = 1 To 4
			$lbagptr = GetBag($bag)
			If $lbagptr = 0 Then ContinueLoop
			;For $slot = 1 To MemoryRead($lbagptr + 32, "long")
			For $slot = 1 To DllStructGetData($lbagptr, "slots")
				$litem = GetItemBySlot($lbagptr, $slot)
				If Not GetCanSalvage($litem) Then ContinueLoop
				;Out("Salvaging : " & $bag & "," & $slot)
				;$lquantity = MemoryRead($litem + 75, "byte")
				$lquantity = DllStructGetData($litem, 'Quantity')
				;$itemmid = MemoryRead($litem + 44, "long")
				;$itemmid = DllStructGetData($aItem, "ModelId")
				$itemrarity = GetRarity($litem)
				If $itemrarity = $rarity_white OR $itemrarity = $rarity_blue Then
					For $i = 1 To $lquantity
						If SalvageKit() Then
							$lsalvagekitid = FindSalvageKit3()
							$lsalvagekitptr = GetItemByItemID($lsalvagekitid)
						EndIf
						;If MemoryRead($lsalvagekitptr + 12, "ptr") = 0 Then
						;	SalvageKit()
						;	;$lsalvagekitid = FindSalvageKit(1, 4)
						;	$lsalvagekitid = FindSalvageKit()
						;	$lsalvagekitptr = GetItemByItemID($lsalvagekitid)
						;EndIf
						$lquantityold = $lquantity
						;$loldvalue = MemoryRead($lsalvagekitptr + 36, "short")
						$loldvalue = DllStructGetData($lsalvagekitptr, "Value")
						;StartSalvage($litem, $lsalvagekitid)
						;Out("WB S")
						StartSalvage2($litem)
						Local $ldeadlock = TimerInit()
						Do
							Sleep(200)
						;Until MemoryRead($lsalvagekitptr + 36, "short") <> $loldvalue OR TimerDiff($ldeadlock) > 5000
						Until DllStructGetData($lsalvagekitptr, "Value") <> $loldvalue OR TimerDiff($ldeadlock) > 5000
					Next
				ElseIf $itemrarity = $rarity_purple OR $itemrarity = $rarity_gold Then
					;$itemtype = MemoryRead($litem + 32, "byte")
					$itemtype = DllStructGetData($litem, "Type")
					If $itemtype = 0 Then
						ContinueLoop
					EndIf
					;If MemoryRead($litem + 12, "ptr") <> 0 Then ; ptr Bag <> 0x0 ???
					;If MemoryRead($lsalvagekitptr + 12, "ptr") = 0 Then
					If SalvageKit() Then
						$lsalvagekitid = FindSalvageKit3()
						$lsalvagekitptr = GetItemByItemID($lsalvagekitid)
					EndIf
					;If MemoryRead($lsalvagekitptr + 12, "ptr") = 0 Then
					;	SalvageKit()
					;	;$lsalvagekitid = FindSalvageKit(1, 4)
					;	$lsalvagekitid = FindSalvageKit()
					;	$lsalvagekitptr = GetItemByItemID($lsalvagekitid)
					;EndIf
					;$loldvalue = MemoryRead($lsalvagekitptr + 36, "short")
					$loldvalue = DllStructGetData($lsalvagekitptr, "Value")
					;StartSalvage($litem, $lsalvagekitid)
					;Out("PG S")
					StartSalvage2($litem)
					Sleep(500 + GetPing())
					SalvageMaterials()
					Local $ldeadlock = TimerInit()
					Do
						Sleep(200)
					;Until MemoryRead($lsalvagekitptr + 36, "short") <> $loldvalue OR TimerDiff($ldeadlock) > 5000
					Until DllStructGetData($lsalvagekitptr, "Value") <> $loldvalue OR TimerDiff($ldeadlock) > 5000
					;EndIf ;litem +12 "ptr"
				EndIf
			Next
		Next
		SalvageKit()
	 EndFunc

  Func StartSalvage2($aItem)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x690]
	Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)

	If IsDllStruct($aItem) = 0 Then
		Local $lItemID = $aItem
	Else
		Local $lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	Local $lSalvageKit = FindSalvageKit3()
	If $lSalvageKit = 0 Then Return

	DllStructSetData($mSalvage, 2, $lItemID)
	DllStructSetData($mSalvage, 3, FindSalvageKit3())
	DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])

	Enqueue2(DllStructGetPtr($mSalvage), 16)
 EndFunc   ;==>StartSalvage

 Func Enqueue2($aPtr, $aSize)
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', 256 * $mQueueCounter + $mQueueBase, 'ptr', $aPtr, 'int', $aSize, 'int', '')
	If $mQueueCounter = $mQueueSize Then
		$mQueueCounter = 0
	Else
		$mQueueCounter = $mQueueCounter + 1
	EndIf
EndFunc

Func FindSalvageKit3()
	Local $lItem
	Local $lKit = 0
	Local $lUses = 101
	For $i = 1 To 16
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItem = GetItemBySlot($i, $j)
			Switch DllStructGetData($lItem, 'ModelID')
				Case 5900
					If DllStructGetData($lItem, 'Value') / 10 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 10
					EndIf
					 ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKit
EndFunc

	 Func SalvageKit()
		If FindSalvageKit3() == 0 Then
			;Out("Buy salvage kit")
			If GetGoldCharacter() < 100 Then
				;Out("Golds")
				WithdrawGold(100)
				RndSleep(1000)
			EndIf
			BuyItem(2, 1, 100)
			RndSleep(1000)
			Return true
		EndIf
		Return False
	EndFunc

	 Func GetCanSalvage($aitemptr)
		;If MemoryRead($aitemptr + 24, "ptr") <> 0 Then Return False
		If DllStructGetData($aitemptr, "Customized") <> 0 Then Return False

		;Local $litemtype = MemoryRead($aitemptr + 32, "byte")
		Local $litemtype = DllStructGetData($aitemptr, "Type")
		If $litemtype <> 5 And $litemtype <> 30 Then Return False
		;Local $lmodelid = MemoryRead($aitemptr + 44, "long")
		Local $lmodelid = DllStructGetData($aitemptr, "ModelId")
		Switch $lmodelid
			Case 27047
				Return True
		EndSwitch
		Return False
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
	  WinSetTitle($Gui, "", "Bones Farmer - " & $charname)
	  $BotRunning = True
	  $BotInitialized = True
	  SetMaxMemory()
   EndIf
EndFunc

Func Setup()

   RndSleep(500)
   ;SetUpFastWay()
EndFunc

;Func Out($msg)
;   GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
;   _GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
;   _GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
;EndFunc

Func _exit()
   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then
	  EnableRendering()
	  WinSetState($HWND, "", @SW_SHOW)
	  Sleep(500)
   EndIf
   Exit
EndFunc