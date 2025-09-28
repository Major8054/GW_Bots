
#NoTrayIcon
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiEdit.au3>
#include "GWA2.au3"
#include "Constants.au3"


Opt("GUIOnEventMode", True)		; enable gui on event mode

Global $boolInitialized = False
Global $boolRunning = False
Global Const $SleepTime = 50 ; in milliseconds


;==> Sweets
Global Const $ID_Cupcake = 22269
Global Const $ID_DeliciousCake = 36681
Global Const $ID_SugarBlueDrink = 21812
Global Const $ID_GoldenEgg = 22752
Global Const $ID_ChocolateBunny = 22644
Global Const $ID_PumpkinPie = 28436
Global Const $ID_Fruitcake = 21492

;==> Alcohol
Global Const $ID_KrytanBrandy = 35124
Global Const $ID_BattleIsleIcedTea = 36682
Global Const $ID_HuntersAle = 910
Global Const $ID_Eggnong = 6375
Global Const $ID_SharmrockAle = 22190
Global Const $ID_HardAppleCider = 28435
Global Const $ID_Grog = 30855
Global Const $ID_Absinthe = 6367
Global Const $ID_Witch = 6049
Global Const $ID_EGG2 = 6366

;==> Party
Global Const $ID_PartyBeacon = 36683
Global Const $ID_MischievousTonic = 31020
Global Const $ID_FrostyTonic = 30648
Global Const $ID_BottleRocket = 21809
Global Const $ID_SnowmandSummoner = 6376
Global Const $ID_ChampagnePoper = 21810
Global Const $ID_Sparkler = 21813
Global Const $ID_Serum = 6369
Global Const $ID_GITB = 6368
Global Const $ID_Trensfo = 15837


;==> All Other Event Items
Global Const $ID_LunarToken = 21833
Global Const $ID_VictoryToken = 18345
Global Const $ID_FourLeafClover = 22191
Global Const $ID_Honeycomb = 26784
Global Const $ID_TrickOrTreatBag = 28434
Global Const $ID_WayfarersMark = 37765
Global Const $ID_CandyCaneShards = 556
Global Const $ID_Gifts = 21491

Global Const $MainGui = GUICreate("Title spam", 172, 190)
	GUICtrlCreateLabel("Alcohol/party/sweet", 8, 6, 156, 17, $SS_CENTER)
    Global Const $inputCharName = GUICtrlCreateCombo("", 8, 24, 150, 22)
		GUICtrlSetData(-1, GetLoggedCharNames())
    Global Const $cbxHideGW = GUICtrlCreateCheckbox("Disable Graphics", 8, 48)
	   GUICtrlSetOnEvent(-1, "ToggleRendering")
	Global Const $cbxOnTop = GUICtrlCreateCheckbox("Always On Top", 8, 68)
	Global Const $lblLog = GUICtrlCreateLabel("", 8, 130, 154, 30)
	Global Const $btnStart = GUICtrlCreateButton("Start", 8, 162, 154, 25)

GUICtrlSetOnEvent($cbxOnTop, "EventHandler")
GUICtrlSetOnEvent($cbxHideGW, "EventHandler")
GUICtrlSetOnEvent($btnStart, "EventHandler")
GUISetOnEvent($GUI_EVENT_CLOSE, "EventHandler")
GUISetState(@SW_SHOW)
Do
	Sleep(100)
Until $boolInitialized

While 1
	If $boolRunning Then
		RapeATot()
	Else
		Sleep(250)
	EndIf
 WEnd

Func ToggleRendering22()
	If $Rendering Then
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		$Rendering = False
		Sleep(Random(1000,3000))
		_ReduceMemory()
		AdlibRegister("_ReduceMemory",20000)
	Else
		AdlibUnRegister("_ReduceMemory")
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
		$Rendering = True
	EndIf
	UpdateConfig()
 EndFunc   ;==>ToggleRendering

Func RapeATot()
	For $bag=1 To 4
		For $slot=1 To DllStructGetData(GetBag($bag), 'Slots')
			Local $item = GetItemBySlot($bag, $slot)
			If DllStructGetData($item, 'ModelID') == $ID_Serum Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_HuntersAle Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_BottleRocket Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_HardAppleCider Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_Sparkler Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_KrytanBrandy Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_SugarBlueDrink Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_ChampagnePoper Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_Absinthe Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_Eggnong Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_Witch Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_Fruitcake Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_GITB Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_SnowmandSummoner Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_MischievousTonic Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_Trensfo Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_FrostyTonic Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == 21490 Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == $ID_EGG2 Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			  If DllStructGetData($item, 'ModelID') == $ID_ChocolateBunny Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			 EndIf
			 If DllStructGetData($item, 'ModelID') == 22190 Then
				For $i=1 To DllStructGetData($item, 'Quantity')
					UseItem($item)
					Sleep($SleepTime)
				Next
				Return
			EndIf
		Next
	Next
EndFunc

Func EventHandler()
	Switch @GUI_CtrlId
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btnStart
			If $boolRunning Then
				GUICtrlSetData($btnStart, "Resume")
				$boolRunning = False
			ElseIf $boolInitialized Then
				GUICtrlSetData($btnStart, "Pause")
				$boolRunning = True
			Else
				$boolRunning = True
				GUICtrlSetData($btnStart, "Initializing...")
				GUICtrlSetState($btnStart, $GUI_DISABLE)
				GUICtrlSetState($inputCharName, $GUI_DISABLE)
				WinSetTitle($MainGui, "", GUICtrlRead($inputCharName))
				If GUICtrlRead($inputCharName) = "" Then
					If Initialize(ProcessExists("gw.exe"), True, False, False) = False Then	; don't need string logs or event system
						MsgBox(0, "Error", "Guild Wars it not running.")
						Exit
					EndIf
				Else
					If Initialize(GUICtrlRead($inputCharName), True, False, False) = False Then ; don't need string logs or event system
						MsgBox(0, "Error", "Can't find a Guild Wars client with that character name.")
						Exit
					EndIf
				EndIf
				GUICtrlSetData($btnStart, "Pause")
				GUICtrlSetState($btnStart, $GUI_ENABLE)
				$boolInitialized = True
			EndIf

	EndSwitch
 EndFunc

Func Out($aString)
	Local $timestamp = "[" & @HOUR & ":" & @MIN & "] "
	GUICtrlSetData($lblLog, $timestamp & $aString)
 EndFunc   ;==>Out
