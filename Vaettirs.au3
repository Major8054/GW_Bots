
; ---------------------------- ;
;      Mono Ball Vaettirs      ;
;         Money Only :)        ;
; ---------------------------- ;

; ---------------------------- ;
; ajouter compteurs de materiaux
; ameliorer la GUI
; ---------------------------- ;

#include "GWA2.au3"

#region *COMMON VARS*
; CONST
Global Const $RARITY_GREEN = 2627
Global Const $RARITY_GOLD = 2624
Global Const $RARITY_PURPLE = 2626
Global Const $RARITY_BLUE = 2623
Global Const $RARITY_WHITE = 2621

Global $storeGoldItems = False
Global $salvageItems = False
Global $eventMode = False
Global $salvageNonGold = False
Global $doSalvage = False
Global $restrictSalvage = False
Global $idGolds = False
Global $useScroll = False
Global $BAG_SLOT[4] = [20, 5, 10, 10]
#endregion

#include "Items.au3"
#include "InventoryVaettirs.au3"
#include "Stockage.au3"
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GuiEdit.au3>

Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Opt("MustDeclareVars", False); Opt("MustDeclareVars", True)

#region *VARS/CST*
; ==== Constants ====
Global Enum $DIFFICULTY_NORMAL, $DIFFICULTY_HARD
Global Enum $INSTANCETYPE_OUTPOST, $INSTANCETYPE_EXPLORABLE, $INSTANCETYPE_LOADING
Global Enum $RANGE_ADJACENT=156, $RANGE_NEARBY=240, $RANGE_AREA=312, $RANGE_EARSHOT=1000, $RANGE_SPELLCAST = 1085, $RANGE_SPIRIT = 2500, $RANGE_COMPASS = 5000
Global Enum $RANGE_ADJACENT_2=156^2, $RANGE_NEARBY_2=240^2, $RANGE_AREA_2=312^2, $RANGE_EARSHOT_2=1000^2, $RANGE_SPELLCAST_2=1085^2, $RANGE_SPIRIT_2=2500^2, $RANGE_COMPASS_2=5000^2
Global Enum $PROF_NONE, $PROF_WARRIOR, $PROF_RANGER, $PROF_MONK, $PROF_NECROMANCER, $PROF_MESMER, $PROF_ELEMENTALIST, $PROF_ASSASSIN, $PROF_RITUALIST, $PROF_PARAGON, $PROF_DERVISH
Global $BAG_SLOTS[18] = [0, 20, 5, 10, 10, 20, 41, 12, 20, 20, 20, 20, 20, 20, 20, 20, 20, 9]

Global Const $MAP_ID_BJORA = 482
Global Const $MAP_ID_JAGA = 546
Global Const $MAP_ID_LONGEYE = 650

Global Const $SKILL_ID_SHROUD = 1031
Global Const $SKILL_ID_CHANNELING = 38
Global Const $SKILL_ID_ARCHANE_ECHO = 75
Global Const $SKILL_ID_WASTREL_DEMISE = 1335

Global Const $EventItemModelID1 = 22191
Global Const $EventItemModelID2 = ""
Global Const $EventItemName1 = "golds"
Global Const $EventItemName2 = ""

Global Const $doLoadLoggedChars = True

; ==== Bot global variables ====
Global $EventItemCount1 = 0
Global $EventItemCount2 = " "
Global $RenderingEnabled = True
Global $RunCount = 0
Global $FailCount = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $ChatStuckTimer = TimerInit()

; ==== Build ====
Global Const $SkillBarTemplate = "OwVUI2h5lPP8Id2BkAiAvpLBTAA"
; declare skill numbers to make the code WAY more readable (UseSkill($sf) is better than UseSkill(2))
Global Const $paradox = 1
Global Const $sf = 2
Global Const $shroud = 3
Global Const $wayofperf = 4
Global Const $hos = 5
Global Const $wastrel = 6
Global Const $echo = 7
Global Const $channeling = 8
; Store skills energy cost
Global $skillCost[9]
$skillCost[$paradox] = 15
$skillCost[$sf] = 5
$skillCost[$shroud] = 10
$skillCost[$wayofperf] = 5
$skillCost[$hos] = 5
$skillCost[$wastrel] = 5
$skillCost[$echo] = 15
$skillCost[$channeling] = 5

; ---- golds coins ----
Global $golds = 0
Global $profit = 0
#endregion

#region *GUI*
Global $mainGui = GUICreate("Vaettir Money", 450, 325, 308, 185)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
	GUISetIcon("SF.ico", -1)
Global $Input = GUICtrlCreateCombo("", 8, 8, 137, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, GetLoggedCharNames())
Global $CheckboxRendering = GUICtrlCreateCheckbox("Disable Rendering", 24, 58, 113, 25)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetOnEvent(-1, "ToggleRendering")
Global $Button = GUICtrlCreateButton("Start", 8, 32, 139, 25)
	GUICtrlSetOnEvent(-1, "GuiButtonHandler")
Global $RadioSalvage = GUICtrlCreateRadio("Salvage All", 32, 168, 100, 17)
	GUICtrlSetOnEvent(-1, "GuiOptionsHandler")
Global $RadioStore = GUICtrlCreateRadio("Store Golds", 32, 184, 65, 17)
	GUICtrlSetOnEvent(-1, "GuiOptionsHandler")
Global $RadioSell = GUICtrlCreateRadio("Sell Golds", 32, 200, 65, 17)
	GUICtrlSetOnEvent(-1, "GuiOptionsHandler")
Global $RadioEvent = GUICtrlCreateRadio("Event Mode", 32, 216, 100, 17)
	GUICtrlSetOnEvent(-1, "GuiOptionsHandler")
Global $CheckboxSalvageNonGold = GUICtrlCreateCheckbox("Salvage white, blue, purple", 32, 240, 900, 20)
	GUICtrlSetOnEvent(-1, "GuiOptionsHandler")
Global $CheckboxRestrictSalvage = GUICtrlCreateCheckbox("Restrict salvage", 32, 260, 900, 20)
	GUICtrlSetOnEvent(-1, "GuiOptionsHandler")
Global $CheckboxIdGolds = GUICtrlCreateCheckbox("ID golds", 32, 280, 900, 20)
	GUICtrlSetOnEvent(-1, "GuiOptionsHandler")
Global $CheckboxScrolls = GUICtrlCreateCheckbox("Use Scroll (more exp points)", 32, 300, 900, 20)
	GUICtrlSetOnEvent(-1, "GuiOptionsHandler")
; TODO : Event mode
Global $Console = GUICtrlCreateEdit("Ready to Start", 160, 8, 275, 190, BitOR(0x0040, 0x00200000, 0x00800000, 0x0800))
	GUICtrlSetFont($console, 9, 400, 0, "Arial")
	GUICtrlSetColor($console, 0x00FFFF)
	GUICtrlSetBkColor($console, 0x000000)
	GUICtrlSetCursor($console, 5)
GUICtrlCreateGroup("", 8, 80, 137, 81)
GUICtrlCreateLabel("Money", 40, 96, 36, 17)
GUICtrlCreateLabel("Runs", 40, 112, 36, 17)
GUICtrlCreateLabel("Fails", 40, 128, 36, 17)
Global $LabelGold = GUICtrlCreateLabel($EventItemCount1, 80, 96, 35, 17, $SS_CENTER)
Global $LabelRuns = GUICtrlCreateLabel($RunCount, 80, 112, 35, 17, $SS_CENTER)
Global $LabelFails = GUICtrlCreateLabel($FailCount, 80, 128, 35, 17, $SS_CENTER)
GUICtrlSetState(-1, $GUI_UNCHECKED)

GUICtrlSetState($RadioSalvage,$GUI_CHECKED)
GUISetState(@SW_SHOW)

GuiOptionsHandler()
#endregion

#region *Main*

Func UpdateStatus()
	$storeGoldItems = False
	$salvageItems = False
	$eventMode = False
	$salvageNonGold = False
	$restrictSalvage = False
	$idGolds = False
	$useScroll = False

	If GUICtrlRead($RadioSalvage) = $GUI_CHECKED Then
		$salvageItems = True
	ElseIf GUICtrlRead($RadioStore) = $GUI_CHECKED Then
		$storeGoldItems = True
	ElseIf GUICtrlRead($RadioEvent) = $GUI_CHECKED Then
		$eventMode = True
	EndIf

	If GUICtrlRead($CheckboxSalvageNonGold) = $GUI_CHECKED Then
		$salvageNonGold = True
	EndIf
	If GUICtrlRead($CheckboxRestrictSalvage) = $GUI_CHECKED Then
		$restrictSalvage = True
	EndIf
	If GUICtrlRead($CheckboxIdGolds) = $GUI_CHECKED Then
		$idGolds = True
	EndIf
    If GUICtrlGetState($CheckboxScrolls) = $GUI_CHECKED Then
		$useScroll = True ; use scrolls to get more skill points
	EndIF

	$doSalvage = $salvageItems or $salvageNonGold
EndFunc

Func GuiOptionsHandler()
	GUICtrlSetState($CheckboxSalvageNonGold, $GUI_ENABLE)
	GUICtrlSetState($CheckboxRestrictSalvage, $GUI_ENABLE)
	GUICtrlSetState($CheckboxIdGolds, $GUI_ENABLE)
	GUICtrlSetState($CheckboxScrolls, $GUI_ENABLE)


	If GUICtrlRead($RadioSalvage) = $GUI_CHECKED Then
		GUICtrlSetState($CheckboxSalvageNonGold, $GUI_DISABLE)
		GUICtrlSetState($CheckboxIdGolds, $GUI_DISABLE)

		GUICtrlSetState($CheckboxSalvageNonGold, $GUI_CHECKED)
		GUICtrlSetState($CheckboxIdGolds, $GUI_CHECKED)

	ElseIf GUICtrlRead($RadioStore) = $GUI_CHECKED Then
		GUICtrlSetState($CheckboxRestrictSalvage, $GUI_DISABLE)

		GUICtrlSetState($CheckboxRestrictSalvage, $GUI_UNCHECKED)

	ElseIf GUICtrlRead($RadioSell) = $GUI_CHECKED Then
		GUICtrlSetState($CheckboxRestrictSalvage, $GUI_DISABLE)
		GUICtrlSetState($CheckboxIdGolds, $GUI_DISABLE)

		GUICtrlSetState($CheckboxRestrictSalvage, $GUI_UNCHECKED)
		GUICtrlSetState($CheckboxIdGolds, $GUI_CHECKED)

	ElseIf GUICtrlRead($RadioEvent) = $GUI_CHECKED Then
		GUICtrlSetState($CheckboxSalvageNonGold, $GUI_DISABLE)
		GUICtrlSetState($CheckboxRestrictSalvage, $GUI_DISABLE)
		GUICtrlSetState($CheckboxIdGolds, $GUI_DISABLE)
		GUICtrlSetState($CheckboxSalvageNonGold, $GUI_DISABLE)

		GUICtrlSetState($CheckboxSalvageNonGold, $GUI_UNCHECKED)
		GUICtrlSetState($CheckboxRestrictSalvage, $GUI_UNCHECKED)
		GUICtrlSetState($CheckboxIdGolds, $GUI_UNCHECKED)
	EndIf

	If GUICtrlRead($CheckboxSalvageNonGold) = $GUI_CHECKED Then
		GUICtrlSetState($CheckboxRestrictSalvage, $GUI_ENABLE)
	EndIf

	UpdateStatus()
EndFunc

Func GuiButtonHandler()
	UpdateStatus()

	Out("$storeGoldItems = " & $storeGoldItems)
	Out("$salvageItems = " & $salvageItems)
	Out("$salvageNonGold = " & $salvageNonGold)
	Out("$restrictSalvage = " & $restrictSalvage)
	Out("$idGolds = " & $idGolds)
	Out("$useScroll = " & $useScroll)
	$doSalvage = $salvageItems or $salvageNonGold

	If $BotRunning Then
		GUICtrlSetData($Button, "Will pause after this run")
		GUICtrlSetState($Button, $GUI_DISABLE)
		$BotRunning = False
	ElseIf $BotInitialized Then
		GUICtrlSetData($Button, "Pause")
		$BotRunning = True
	Else
		Out("Initializing")
		Local $CharName = GUICtrlRead($Input)
		If $CharName=="" Then
			If Initialize(ProcessExists("gw.exe")) = False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf
		Else
			If Initialize($CharName) = False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '"&$CharName&"'")
				Exit
			EndIf
		EndIf
		GUICtrlSetState($CheckboxRendering, $GUI_ENABLE)
		GUICtrlSetState($Input, $GUI_DISABLE)
		GUICtrlSetData($Button, "Pause")
		WinSetTitle($mainGui, "", "VBot-" & GetCharname())
		$BotRunning = True
		$BotInitialized = True
	EndIf
EndFunc

Out("Waiting for input")

While Not $BotRunning
	Sleep(100)
WEnd

$golds = GetGoldCharacter()
If $RunCount == 0 Then BackAndManage()
If GetMapLoading() == $INSTANCETYPE_OUTPOST Then LoadSkillTemplate($SkillBarTemplate)

While $BotRunning
	If GetMapID() <> $MAP_ID_JAGA Then RunThere()
	If GetIsDead(-2) Then ContinueLoop
	While 1
		If Not $BotRunning Then
			Out("Bot Paused")
			GUICtrlSetState($Button, $GUI_ENABLE)
			GUICtrlSetData($Button, "Start")
			While Not $BotRunning
				Sleep(100)
			WEnd
		EndIf
		If CombatLoop() Then
			ContinueLoop
		Else
			ExitLoop
		EndIf
	WEnd
	BackAndManage()
WEnd

#endregion

#region *FCTS*
Func UseScroll()
	$item = GetItemByModelID(21233)
	If DllStructGetData($item, 'Bag') <> 0 Then
		Out("Using Lightbringer Scroll")
		UseItem($item)
		Return
	EndIf
	$item = GetItemByModelID(5595)
	If DllStructGetData($item, 'Bag') <> 0 Then
		Out("Using Berserkers Insight")
		UseItem($item)
		Return
	EndIf
	$item = GetItemByModelID(5611)
	If DllStructGetData($item, 'Bag') <> 0 Then
		Out("Using Slayers Insight")
		UseItem($item)
		Return
	EndIf
	$item = GetItemByModelID(5594)
	If DllStructGetData($item, 'Bag') <> 0 Then
		Out("Using Heros Insight")
		UseItem($item)
		Return
	EndIf
	$item = GetItemByModelID(5975)
	If DllStructGetData($item, 'Bag') <> 0 Then
		Out("Using Rampagers Insight")
		UseItem($item)
		Return
	EndIf
	$item = GetItemByModelID(5976)
	If DllStructGetData($item, 'Bag') <> 0 Then
		Out("Using Hunters Insight")
		UseItem($item)
		Return
	EndIf
	$item = GetItemByModelID(5853)
	If DllStructGetData($item, 'Bag') <> 0 Then
		Out("Using Adventurers Insight")
		UseItem($item)
		Return
	EndIf
	Out("No scrolls found")
EndFunc

Func RunThere()
	If GetMapID() <> $MAP_ID_LONGEYE Then
		Out("Travelling to longeye")
		TravelTo($MAP_ID_LONGEYE)
	EndIf

	SwitchMode(1)

	Out("Exiting Outpost")
	Move(-26472, 16217)
	WaitMapLoading($MAP_ID_BJORA)

	Out("Running to Jaga")
	If Not MoveRunning(15003.8, -16598.1) 	Then Return
	If Not MoveRunning(15003.8, -16598.1) 	Then Return
	If Not MoveRunning(12699.5, -14589.8) 	Then Return
	If Not MoveRunning(11628,   -13867.9) 	Then Return
	If Not MoveRunning(10891.5, -12989.5) 	Then Return
	If Not MoveRunning(10517.5, -11229.5) 	Then Return
	If Not MoveRunning(10209.1, -9973.1)  	Then Return
	If Not MoveRunning(9296.5,  -8811.5)  	Then Return
	If Not MoveRunning(7815.6,  -7967.1)  	Then Return
	If Not MoveRunning(6266.7,  -6328.5)  	Then Return
	If Not MoveRunning(4940,    -4655.4)  	Then Return
	If Not MoveRunning(3867.8,  -2397.6)  	Then Return
	If Not MoveRunning(2279.6,  -1331.9)  	Then Return
	If Not MoveRunning(7.2,     -1072.6)  	Then Return
	If Not MoveRunning(7.2,     -1072.6)  	Then Return
	If Not MoveRunning(-1752.7, -1209)    	Then Return
	If Not MoveRunning(-3596.9, -1671.8)  	Then Return
	If Not MoveRunning(-5386.6, -1526.4)  	Then Return
	If Not MoveRunning(-6904.2, -283.2)   	Then Return
	If Not MoveRunning(-7711.6, 364.9)    	Then Return
	If Not MoveRunning(-9537.8, 1265.4)   	Then Return
	If Not MoveRunning(-11141.2,857.4)    	Then Return
	If Not MoveRunning(-12730.7,371.5)    	Then Return
	If Not MoveRunning(-13379,  40.5)     	Then Return
	If Not MoveRunning(-14925.7,1099.6)   	Then Return
	If Not MoveRunning(-16183.3,2753)     	Then Return
	If Not MoveRunning(-17803.8,4439.4)   	Then Return
	If Not MoveRunning(-18852.2,5290.9)   	Then Return
	If Not MoveRunning(-19250,  5431)     	Then Return
	If Not MoveRunning(-19968, 5564) 		Then Return

	Move(-20076,  5580, 30)
	WaitMapLoading($MAP_ID_JAGA)
EndFunc

Func CombatLoop()
	If Not $RenderingEnabled Then ClearMemory()

	If GetNornTitle() < 160000 Then
		Out("Taking Blessing")
		GoNearestNPCToCoords(13318, -20826)
		Dialog(132)
		RndSleep(1000)
	EndIf

	Out("Moving to aggro left")
	MoveTo(13501, -20925)
	MoveTo(13172, -22137)
	TargetNearestEnemy()
	MoveAggroing(12496, -22600)
	MoveAggroing(11375, -22761)
	MoveAggroing(10925, -23466)
	MoveAggroing(10917, -24311)
	MoveAggroing(9910, -24599)
	MoveAggroing(8995, -23177)
	MoveAggroing(8307, -23187)
	MoveAggroing(8213, -22829)
	MoveAggroing(8307, -23187)
	MoveAggroing(8213, -22829)
	MoveAggroing(8740, -22475)
	MoveAggroing(8880, -21384)
	MoveAggroing(8684, -20833)
	MoveAggroing(8982, -20576)

	Out("Waiting for left ball")
	WaitFor(12*1000)

	If GetDistance()<1000 Then
		UseSkillEx($hos, -1)
	Else
		UseSkillEx($hos, -2)
	EndIf

	WaitFor(6000)

	TargetNearestEnemy()

	Out("Moving to aggro right")
	MoveAggroing(10196, -20124)
	MoveAggroing(9976, -18338)
	MoveAggroing(11316, -18056)
	MoveAggroing(10392, -17512)
	MoveAggroing(10114, -16948)
	MoveAggroing(10729, -16273)
	MoveAggroing(10810, -15058)
	MoveAggroing(11120, -15105)
	MoveAggroing(11670, -15457)
	MoveAggroing(12604, -15320)
	TargetNearestEnemy()
	MoveAggroing(12476, -16157)

	Out("Waiting for right ball")
	WaitFor(15*1000)

	If GetDistance()<1000 Then
		UseSkillEx($hos, -1)
	Else
		UseSkillEx($hos, -2)
	EndIf

	WaitFor(5000)

	Out("Blocking enemies in spot")
	MoveAggroing(12920, -17032, 30)
	MoveAggroing(12847, -17136, 30)
	MoveAggroing(12720, -17222, 30)
	WaitFor(300)
	MoveAggroing(12617, -17273, 30)
	WaitFor(300)
	MoveAggroing(12518, -17305, 20)
	WaitFor(300)
	MoveAggroing(12445, -17327, 10)

	Out("Killing")
	If $useScroll = True Then UseScroll()
	Kill()

	WaitFor(1200)

	Out("Looting")
	If PickUpLoot() == False Then
		If IdAndSalvage() == False Then
;~ 			debug("No More Free Slots")
			Return False
		EndIf
		If PickUpLoot() == False Then
;~ 			debug("No More Free Slots")
			Return False
		EndIf
		Return False
	EndIf
	If IdAndSalvage() == False Then
;~ 		debug("No More Free Slots")
		Return False
	EndIf
	If checkIdentifyKit() == 0 Then
;~ 		debug("No More ID Kits")
		Return False
	EndIf
	If checkSalvageKit() == 0 Then
;~ 		debug("No More Salvage Kits")
		Return False
	EndIf

	If GetIsDead(-2) Then
		$FailCount += 1
		GUICtrlSetData($LabelFails, $FailCount)
	Else
		$RunCount += 1
		GUICtrlSetData($LabelRuns, $RunCount)
	EndIf

	Out("Zoning")
	MoveAggroing(12289, -17700)
	MoveAggroing(15318, -20351)

	While GetIsDead(-2)
		Out("Waiting for res")
		Sleep(1000)
	WEnd

	Move(15865, -20531)
	WaitMapLoading($MAP_ID_BJORA)

	MoveTo(-19968, 5564)
	Move(-20076,  5580, 30)

	WaitMapLoading($MAP_ID_JAGA)

	Return True
EndFunc

Func StayAlive(Const ByRef $lAgentArray)
	If IsRecharged($sf) Then
		UseSkillEx($paradox)
		UseSkillEx($sf)
	EndIf

	Local $lMe = GetAgentByID(-2)
	Local $lEnergy = GetEnergy($lMe)
	Local $lAdjCount, $lAreaCount, $lSpellCastCount, $lProximityCount
	Local $lDistance
	For $i=1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], "Allegiance") <> 0x3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
		$lDistance = GetPseudoDistance($lMe, $lAgentArray[$i])
		If $lDistance < 1200*1200 Then
			$lProximityCount += 1
			If $lDistance < $RANGE_SPELLCAST_2 Then
				$lSpellCastCount += 1
				If $lDistance < $RANGE_AREA_2 Then
					$lAreaCount += 1
					If $lDistance < $RANGE_ADJACENT_2 Then
						$lAdjCount += 1
					EndIf
				EndIf
			EndIf
		EndIf
	Next

	UseSF($lProximityCount)

	If IsRecharged($shroud) Then
		If $lSpellCastCount > 0 And DllStructGetData(GetEffect($SKILL_ID_SHROUD), "SkillID") == 0 Then
			UseSkillEx($shroud)
		ElseIf DllStructGetData($lMe, "HP") < 0.6 Then
			UseSkillEx($shroud)
		ElseIf $lAdjCount > 20 Then
			UseSkillEx($shroud)
		EndIf
	EndIf

	UseSF($lProximityCount)

	If IsRecharged($wayofperf) Then
		If DllStructGetData($lMe, "HP") < 0.5 Then
			UseSkillEx($wayofperf)
		ElseIf $lAdjCount > 20 Then
			UseSkillEx($wayofperf)
		EndIf
	EndIf

	UseSF($lProximityCount)

	If IsRecharged($channeling) Then
		If $lAreaCount > 5 And GetEffectTimeRemaining($SKILL_ID_CHANNELING) < 2000 Then
			UseSkillEx($channeling)
		EndIf
	EndIf

	UseSF($lProximityCount)
EndFunc

Func UseSF($lProximityCount)
	If IsRecharged($sf) And $lProximityCount > 0 Then
		UseSkillEx($paradox)
		UseSkillEx($sf)
	EndIf
EndFunc

Func MoveAggroing($lDestX, $lDestY, $lRandom = 150)
	If GetIsDead(-2) Then Return

	Local $lMe, $lAgentArray
	Local $lBlocked
	Local $lHosCount
	Local $lAngle
	Local $stuckTimer = TimerInit()

	Move($lDestX, $lDestY, $lRandom)

	Do
		RndSleep(50)

		$lMe = GetAgentByID(-2)

		$lAgentArray = GetAgentArray(0xDB)

		If GetIsDead($lMe) Then Return False

		StayAlive($lAgentArray)

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			If $lHosCount > 6 Then
				Do	; suicide
					Sleep(100)
				Until GetIsDead(-2)
				Return False
			EndIf

			$lBlocked += 1
			If $lBlocked < 5 Then
				Move($lDestX, $lDestY, $lRandom)
			ElseIf $lBlocked < 10 Then
				$lAngle += 40
				Move(DllStructGetData($lMe, 'X')+300*sin($lAngle), DllStructGetData($lMe, 'Y')+300*cos($lAngle))
			ElseIf IsRecharged($hos) Then
				If $lHosCount==0 And GetDistance() < 1000 Then
					UseSkillEx($hos, -1)
				Else
					UseSkillEx($hos, -2)
				EndIf
				$lBlocked = 0
				$lHosCount += 1
			EndIf
		Else
			If $lBlocked > 0 Then
				If TimerDiff($ChatStuckTimer) > 3000 Then	; use a timer to avoid spamming /stuck
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
				EndIf
				$lBlocked = 0
				$lHosCount = 0
			EndIf

			If GetDistance() > 1100 Then ; target is far, we probably got stuck.
				If TimerDiff($ChatStuckTimer) > 3000 Then ; dont spam
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
					RndSleep(GetPing())
					If GetDistance() > 1100 Then ; we werent stuck, but target broke aggro. select a new one.
						TargetNearestEnemy()
					EndIf
				EndIf
			EndIf
		EndIf

	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < $lRandom*1.5
	Return True
EndFunc

Func MoveRunning($lDestX, $lDestY)
	If GetIsDead(-2) Then Return False

	Local $lMe, $lTgt
	Local $lBlocked

	Move($lDestX, $lDestY)

	Do
		RndSleep(500)

		TargetNearestEnemy()
		$lMe = GetAgentByID(-2)
		$lTgt = GetAgentByID(-1)

		If GetIsDead($lMe) Then Return False

		If GetDistance($lMe, $lTgt) < 1300 And GetEnergy($lMe)>20 And IsRecharged($paradox) And IsRecharged($sf) Then
			UseSkillEx($paradox)
			UseSkillEx($sf)
		EndIf

		If DllStructGetData($lMe, "HP") < 0.9 And GetEnergy($lMe) > 10 And IsRecharged($shroud) Then UseSkillEx($shroud)

		If DllStructGetData($lMe, "HP") < 0.5 And GetDistance($lMe, $lTgt) < 500 And GetEnergy($lMe) > 5 And IsRecharged($hos) Then UseSkillEx($hos, -1)

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			Move($lDestX, $lDestY)
		EndIf

	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < 250
	Return True
EndFunc

Func WaitUntilAllFoesAreInRange($lRange)
	Local $lAgentArray
	Local $lAdjCount, $lSpellCastCount
	Local $lMe
	Local $lDistance
	Local $lShouldExit = False
	While Not $lShouldExit
		Sleep(100)
		$lMe = GetAgentByID(-2)
		If GetIsDead($lMe) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)
		$lShouldExit = False
		For $i=1 To $lAgentArray[0]
			$lDistance = GetPseudoDistance($lMe, $lAgentArray[$i])
			If $lDistance < $RANGE_SPELLCAST_2 And $lDistance > $lRange^2 Then
				$lShouldExit = True
				ExitLoop
			EndIf
		Next
	WEnd
EndFunc

Func WaitFor($lMs)
	If GetIsDead(-2) Then Return
	Local $lAgentArray
	Local $lTimer = TimerInit()
	Do
		Sleep(100)
		If GetIsDead(-2) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)
	Until TimerDiff($lTimer) > $lMs
EndFunc

Func Kill()
	If GetIsDead(-2) Then Return

	Local $lAgentArray
	Local $lDeadlock = TimerInit()

	TargetNearestEnemy()
	Sleep(100)
	Local $lTargetID = GetCurrentTargetID()

	While GetAgentExists($lTargetID) And DllStructGetData(GetAgentByID($lTargetID), "HP") > 0
		Sleep(50)
		If GetIsDead(-2) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)

		; Use echo if possible
		If GetSkillbarSkillRecharge($sf) > 5000 And GetSkillbarSkillID($echo)==$SKILL_ID_ARCHANE_ECHO Then
			If IsRecharged($wastrel) And IsRecharged($echo) Then
				UseSkillEx($echo)
				UseSkillEx($wastrel, GetGoodTarget($lAgentArray))
				$lAgentArray = GetAgentArray(0xDB)
			EndIf
		EndIf

		UseSF(True)

		; Use wastrel if possible
		If IsRecharged($wastrel) Then
			UseSkillEx($wastrel, GetGoodTarget($lAgentArray))
			$lAgentArray = GetAgentArray(0xDB)
		EndIf

		UseSF(True)

		; Use echoed wastrel if possible
		If IsRecharged($echo) And GetSkillbarSkillID($echo)==$SKILL_ID_WASTREL_DEMISE Then
			UseSkillEx($echo, GetGoodTarget($lAgentArray))
		EndIf

		; Check if target has ran away
		If GetDistance(-2, $lTargetID) > $RANGE_EARSHOT Then
			TargetNearestEnemy()
			Sleep(GetPing()+100)
			If GetAgentExists(-1) And DllStructGetData(GetAgentByID(-1), "HP") > 0 And GetDistance(-2, -1) < $RANGE_AREA Then
				$lTargetID = GetCurrentTargetID()
			Else
				ExitLoop
			EndIf
		EndIf

		If TimerDiff($lDeadlock) > 60 * 1000 Then ExitLoop
	WEnd
EndFunc

Func GetGoodTarget(Const ByRef $lAgentArray)
	Local $lMe = GetAgentByID(-2)
	For $i=1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], "Allegiance") <> 0x3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
		If GetDistance($lMe, $lAgentArray[$i]) > $RANGE_NEARBY Then ContinueLoop
		If GetHasHex($lAgentArray[$i]) Then ContinueLoop
		If Not GetIsEnchanted($lAgentArray[$i]) Then ContinueLoop
		Return DllStructGetData($lAgentArray[$i], "ID")
	Next
EndFunc

Func UseSkillEx($lSkill, $lTgt=-2, $aTimeout = 3000)
	If GetIsDead(-2) Then Return
	If Not IsRecharged($lSkill) Then Return
	If GetEnergy(-2) < $skillCost[$lSkill] Then Return

	Local $lDeadlock = TimerInit()
	UseSkill($lSkill, $lTgt)
	Do
		Sleep(50)
		If GetIsDead(-2) = 1 Then Return
	Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)

	If $lSkill > 1 Then RndSleep(750)
EndFunc

Func IsRecharged2($lSkill)
	Return GetSkillBarSkillRecharge($lSkill)==0
EndFunc

Func GoNearestNPCToCoords($x, $y)
	Local $guy, $Me
	Do
		RndSleep(250)
		$guy = GetNearestNPCToCoords($x, $y)
	Until DllStructGetData($guy, 'Id') <> 0
	ChangeTarget($guy)
	RndSleep(250)
	GoNPC($guy)
	RndSleep(250)
	Do
		RndSleep(500)
		Move(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
		RndSleep(500)
		GoNPC($guy)
		RndSleep(250)
		$Me = GetAgentByID(-2)
	Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
	RndSleep(1000)
EndFunc

Func PickUpLoot()
	Local $lAgent
	Local $lItem
	Local $lDeadlock
	For $i = 1 To GetMaxAgents()
		If Not CheckInventory() Then Return False
		If GetIsDead(-2) Then Return True
		$lAgent = GetAgentByID($i)
		If DllStructGetData($lAgent, 'Type') <> 0x400 Then ContinueLoop
		$lItem = GetItemByAgentID($i)
		If CanPickup($lItem, $restrictSalvage, $eventMode) Then
			PickUpItem($lItem)
			$lDeadlock = TimerInit()
			While GetAgentExists($i)
				Sleep(100)
				If GetIsDead(-2) Then Return True
				If TimerDiff($lDeadlock) > 10000 Then ExitLoop
			WEnd
		EndIf
	Next
	$profit = $profit + GetGoldCharacter() - $golds
	$golds = GetGoldCharacter()
	GUICtrlSetData($LabelGold, $profit)
EndFunc

Func ToggleRendering()
	$RenderingEnabled = Not $RenderingEnabled
	If $RenderingEnabled Then
		EnableRendering()
	;	WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
	;	WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
EndFunc   ;==>ToggleRendering

Func Out($text)
	Local $textlen = StringLen($text)
	Local $consolelen = _GUICtrlEdit_GetTextLen($console)
	If $textlen + $consolelen > 30000 Then GUICtrlSetData($console, StringRight(_GUICtrlEdit_GetText($console), 30000-$textlen-1000))
	_GUICtrlEdit_AppendText($console, @CRLF&"["&@HOUR&":"&@MIN&":"&@SEC&"] "&$text)
	_GUICtrlEdit_Scroll ($console, 1) ;1=$SB_LINEDOWN
EndFunc

Func _exit()
	Exit
EndFunc

Func BackAndManage()
	Local $canSellGolds = Not $storeGoldItems
	Out("$canSellGolds = " & $canSellGolds)

	If GetMapID() <> 645 Then
		Out("TP OlafStead")
		Sleep(1000)
		TravelTo(645)
		WaitMapLoading(645)
	EndIf
	IdAndSalvage()
	Out("Find Xunlai")
	;~ MoveTo(148,-538)
	GoToNPC(GetNearestNPCToCoords(1351.8037109375,771.013366699219))
	;~ GoToNPC(findXunlai())
	Out("Find Merchant")
	GoToNPC(GetNearestNPCToCoords(1491.46728515625,-997.674682617188))
	;~ GoToNPC(findMerchant())
	Out("Storage (1)")
	Storage($storeGoldItems)
	Out("Selling")
	sellInventory($canSellGolds)
	Out("Buy Kits (1)")
	$profit = $profit + GetGoldCharacter() - $golds
	GUICtrlSetData($LabelGold, $profit)
	DepositGold(0)
	buyIdentifyKit($maxIdentyfyKit - checkIdentifyKit())
	If $doSalvage Then buySalvageKit($maxsalvageKit - checkSalvageKit())
	IdAndSalvage()
	Out("Storage (2 : mat)")
	Storage($storeGoldItems)
	Out("Buy Kits (2)")
	buyIdentifyKit($maxIdentyfyKit - checkIdentifyKit())
	If $doSalvage Then buySalvageKit($maxSalvageKit - checkSalvageKit())
	DepositGold(0)
	$golds = GetGoldCharacter()
EndFunc


Func IdAndSalvage()
	Out("Identify")
	identify($idGolds)
	If $doSalvage Then
		Out("Salvage")
		Return salvage($salvageItems, $restrictSalvage)

	EndIf
	Return True
EndFunc

Func UpdateStatistics()
	GUICtrlSetData($LabelDeaths, $iDeaths)
	GUICtrlSetData($LabeltRuns, $iTotalRuns)
	GUICtrlSetData($labelRunsHour, "Runs/hour: " & Round($iTotalRuns / (TimerDiff($tTotal) / 3600000)))
	$tRunFinal = TimerDiff($tRun)
	GUICtrlSetData($labelLastRun, "Last Run: " & Int($tRunFinal/60000) & "min" & Int($tRunFinal/1000) - 60*Int($tRunFinal/60000) )
 EndFunc   ;==>UpdateStatistics

#endregion

