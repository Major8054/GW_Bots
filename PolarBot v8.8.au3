#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\Danylia\icon.ico
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region About


;~ Updated, compiled, revised and edited by RiflemanX
;~ Main, Pathing, and Skills by Danylia
;~ Additional operations and functions by Phat34
;~ Diconnect Function and Polar Bear Model_ID by Ralle1976
;~ Beta testing by DARKISM & Mystogan
;~ Upgraded stats trackers by so.sad
;~ Thanks for GWA2 Wiki http://wiki.gamerevision.com/index.php/GWA2
;~ Thanks to http://www.gamerevision.com Community for the informative site and knowledgeable community
;~	____________________________________
;~
;~ Summary:  Farms for Polar Bears Mini Pets from the final chest of the mission "Strength of Snow" during the Wintersaday Celebration
;~	_____________________________________
;~
;~ This was tested using an Assasin with the folowing info:
;~	    Level 20
;~		This Build: None.  The skills will be auto set when the mission begins
;~		Alt  Build: None tested at this time
;~		No Armor, Runes, or Insignias needed as the mission will auto-set to a standard index
;~ 		Q9 Caster Spear 20% Enchant, +5 Energy
;~		Q9/16 Shield
;~	_____________________________________
;
;~		 Testing was conducted over an 160 hour period.  At the time this was created the script
;		 was running very well with over 98% success rate with Monks, Assasins, and Ranges.  Others Chars stats not tracked
;~Current issues to address:;~
;~A smart fight system that can help with final battle and Kite back into safe spots
;
;~  _____________________________________
;~
;~ Func HowToUseThisProgram()
;~		Unzip files
;~		Put both GWA2 and Kryra Farmer in same folder
;~		Start Guild Wars
;~ 		Log onto your Ritualist
;~ 		Run the Tangled Seed Farmer in AutoIt
;~      Select the character you want from the dropdown menu
;~ 		Click Start
;~ 		EndIf
;~ EndFunc
#EndRegion About


#include "GWA2.au3"
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include <GuiEdit.au3>
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Opt("TrayIconHide", 1)

;MISC
Global $INTSKILLENERGY[8] = [10, 10, 5, 0, 10, 10, 5, 10]
Global $COORDS[2]
Global $GWPID = -1

Global $PartyDead = 0
Global $iTakeReward = 1; 1 if you want the reward of the quest, 0 if you dont want it (faster runs)
Global $iGW; Name of your GW
Global $RenderingEnabled = True
Global $bRunning = False
Global $iBounty
Global $Chest = 0
Global $iFailed = 0
Global $iSpawn = 0
Global $iHealth = 0
Global $Alchohol_Array[11] = [910, 2513, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 36682]
;Global $Tonic_Array[

;Model ID's
Global Const $MID_Eggnog = 6375  ;Eggnog
Global Const $MID_WDGift = 21491 ;Wintersday Gift
Global Const $MID_CShard = 556   ;Candy Cane Shard
Global Const $MID_PBear =  21439 ;PolarBear
Global Const $MID_CCake =  22269 ;Cupcake
Global Const $MID_FCake =  21492 ;Fruitcake
Global Const $MID_YTonic = 21490 ;Yuletide
Global Const $MID_FTonic = 6376  ;Frosty

; ==== Constants ====
Global Enum $DIFFICULTY_NORMAL, $DIFFICULTY_HARD
Global Enum $INSTANCETYPE_OUTPOST, $INSTANCETYPE_EXPLORABLE, $INSTANCETYPE_LOADING
Global Enum $RANGE_ADJACENT = 156, $RANGE_NEARBY = 240, $RANGE_AREA = 312, $RANGE_EARSHOT = 1000, $RANGE_SPELLCAST = 1085, $RANGE_SPIRIT = 2500, $RANGE_COMPASS = 5000
Global Enum $RANGE_ADJACENT_2 = 156 ^ 2, $RANGE_NEARBY_2 = 240 ^ 2, $RANGE_AREA_2 = 312 ^ 2, $RANGE_EARSHOT_2 = 1000 ^ 2, $RANGE_SPELLCAST_2 = 1085 ^ 2, $RANGE_SPIRIT_2 = 2500 ^ 2, $RANGE_COMPASS_2 = 5000 ^ 2
Global Enum $PROF_NONE, $PROF_WARRIOR, $PROF_RANGER, $PROF_MONK, $PROF_NECROMANCER, $PROF_MESMER, $PROF_ELEMENTALIST, $PROF_ASSASSIN, $PROF_RITUALIST, $PROF_PARAGON, $PROF_DERVISH

Global Enum $BAG_Backpack = 1, $BAG_BeltPouch, $BAG_Bag1, $BAG_Bag2, $BAG_EquipmentPack, $BAG_UnclaimedItems = 7, $BAG_Storage1, $BAG_Storage2, _
		$BAG_Storage3, $BAG_Storage4, $BAG_Storage5, $BAG_Storage6, $BAG_Storage7, $BAG_Storage8, $BAG_StorageAnniversary

Global $BAG_SLOTS[18] = [0, 20, 5, 10, 10, 20, 41, 12, 20, 20, 20, 20, 20, 20, 20, 20, 20, 9]

Global $g_nMyId = 0
Global $g_nStrafe = 0
Global $lastX
Global $lastY
Global $strafeTimer = TimerInit()
Global $strafeGo = False
Global $leftright = 0
Global $MoveToB = True
Global $BackTrack = True

;RARITY
Global Const $RARITY_GOLD = 2624
Global Const $RARITY_PURPLE = 2626
Global Const $RARITY_BLUE = 2623
Global Const $RARITY_WHITE = 2621
Global Const $golds = 2511

;GUI STATS TIME
Global $status_time = 0
Global $status_total = 0
Global $status_average = 0
Global $status_best = 3600000
Global $status_worst = 0

;GUI STATS
Global $Polarbearcount = 0
Global $AmountPolarBears = 0
Global $SuccessTime = 0
Global $LabelRuns = 0

Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0

Global $MapTimer = 0
Global $tTotal = 0
Global $tRun = 0

Global $iTotalRuns = 0
Global $iTotalRunsSuccess = 0
Global $iTotalRunsFailed = 0
Global $iTotalCanes = 0


Global $tRunFinal = 0

Global $iDeaths = 0
Global $InstTime = 0

Global $RenderingEnabled = True
Global $BotRunning = False
Global $BotInitialized = False
Global $HWND
Global $aItem
Global $PartyDead = 0
Global $hp_start


#Region Vaiables
Global $NightfallChar = True
Global $LAMapID = 809
Global $KamaMapID = 819
Global $QuestMapID = 782
Global $OutPostMapID = $LAMapID
Global $bRunning = False
Global $bInitialized = False
Global $RenderingEnabled = True
Global $OutPostMapID = $LAMapID
Global $leftright = 0
Global $strafeTimer = TimerInit()
Global $currentWP = 0
Global $prof
Global $mSelfID
Global $Chest = 0
Global $DoChest = 0
Global $OutPostMapID = $LAMapID
Global $mAgentMovement = GetAgentMovementPtr()

Global $RunWayPoints = [[-14431, 15110, "WayPoint 1"], _
		[-14747, 11980, "WayPoint 2"], _
		[-17290, 8232, "WayPoint 3"], _
		[-18632, 6120, "WayPoint 4"], _
		[-18210, 3788, "WayPoint 5"], _
		[-15686, 2577, "WayPoint 6"], _
		[-14024, 601, "WayPoint 7"], _
		[-13424, -1823, "WayPoint 8"], _
		[-13397, -5948, "WayPoint 9"], _
		[-14561, -9396, "WayPoint 10"], _
		[-16334, -12974, "WayPoint 11"], _
		[-14839, -16264, "WayPoint 12"], _
		[-10890, -18545, "WayPoint 13"], _
		["Chest", "", ""]]
#EndRegion Vaiables

#Region GUI
Global $BotRunning = False
Global $BotInitialized = False

Global Const $gui_main = GUICreate("Polar Bear Farmer v8.8", 335, 380)
GUISetIcon("icon.ico")
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")


Global $Input = GUICtrlCreateCombo("", 10, 8, 150, 25)
GUICtrlSetData(-1, GetLoggedCharNames())
;Global $gui_ipt_Char = GUICtrlCreateInput("", 10, 8, 150, 25)


;Run Stats
GUICtrlCreateGroup("Run Data", 8, 33, 150, 160)
GUICtrlCreateLabel("Wins:", 18, 55, 60, 20)
$gui_lbl_Wins = GUICtrlCreateLabel($iTotalRunsSuccess, 100, 55, 25, 17)
GUICtrlCreateLabel("Fails:", 18, 75, 60, 20)
$gui_lbl_Fails = GUICtrlCreateLabel($iTotalRunsFailed, 100, 75, 25, 17)

GUICtrlCreateLabel("Runs/Hour:", 18, 95, 80, 15)
$gui_lbl_RunsHour = GUICtrlCreateLabel("-", 100, 95, 60, 15)

GUICtrlCreateLabel("Success Rate:", 18, 115, 85, 15)
GUICtrlCreateLabel("%", 120, 115, 15, 15)
$gui_lbl_SuccRate = GUICtrlCreateLabel("-", 100, 115, 32, 15)

GUICtrlCreateLabel("Last Run:", 18, 135, 85, 15)
$gui_lbl_LastRun = GUICtrlCreateLabel("-", 100, 135, 50, 15)

GUICtrlCreateLabel("Average:", 18, 155, 50, 17)
$gui_lbl_AvgTime = GUICtrlCreateLabel("-", 100, 155, 50, 15)
$MyRunsLabel = GUICtrlCreateLabel("0", 284, 280, 28, 0)

;Loot
GUICtrlCreateLabel("Polar Bears:", 18, 200, 60, 15)
$gui_lbl_PBear = GUICtrlCreateLabel("0", 120, 200, 25, 15)
GUICtrlCreateLabel("Wintersday Gifts:", 18, 215, 100, 20)
$gui_lbl_WGift = GUICtrlCreateLabel("0", 120, 215, 25, 17)
GUICtrlCreateLabel("Candy Cane Shards:", 18, 230, 110, 20)
$gui_lbl_Canes = GUICtrlCreateLabel("0", 120, 230, 25, 17)

;Tools
GUICtrlCreateGroup("Tools", 8, 246, 318, 118)
GUICtrlCreateLabel("Overall Time:", 18, 175, 100, 15)
Global $gui_lbl_Time = 		GUICtrlCreateLabel("00:00:00", 100, 175, 50, 15)
Global $gui_cbx_Alc = 		GUICtrlCreateCheckbox("Drink Eggnog", 170, 260, 80, 17)
Global $gui_cbx_Sweets =	GUICtrlCreateCheckbox("Use Sweets", 170, 280, 80, 17)
Global $gui_cbx_Canes = 	GUICtrlCreateCheckbox("Collect Candy Canes", 170, 300, 120, 17)
Global $gui_cbx_Cupcake = 	GUICtrlCreateCheckbox("Use Cupcakes", 18, 300, 86, 17)
Global $gui_lbl_Cupcake = 	GUICtrlCreateLabel("", 115, 302, 40, 17)
;Global $gui_cbx_Battle = 	GUICtrlCreateCheckbox("Fight in Main Battle", 18, 280, 120, 17)
Global $gui_cbx_District = 	GUICtrlCreateCheckbox("Change Districts", 18, 280, 120, 17)
Global $gui_cbx_Rendering = GUICtrlCreateCheckbox("Disable Rendering", 18, 260, 129, 17)
Global $gui_cbx_Tonic = 	GUICtrlCreateCheckbox("Use Tonic", 18, 320, 100, 17)
Global $gui_cbx_Purge = 	GUICtrlCreateCheckbox("Purge Engine Hook", 170, 320, 140, 17)
Global $gui_cbx_Kamadan =   GUICtrlCreateCheckbox("Run From Kamadan", 170, 340, 140, 17)
Global $gui_cbx_Fight =     GUICtrlCreateCheckbox("Fight in Last Battle", 18, 340, 110, 17)

Global $gui_btn_Toggle = 	GUICtrlCreateButton("Start", 165, 205, 160, 30)

GUICtrlSetState($gui_cbx_Fight, $GUI_DISABLE)
GUICtrlSetState($gui_cbx_Kamadan, $GUI_DISABLE)
GUICtrlSetState($gui_cbx_Alc, $GUI_CHECKED)
GUICtrlSetState($gui_cbx_Sweets, $GUI_CHECKED)
GUICtrlSetState($gui_cbx_Canes, $GUI_CHECKED)
GUICtrlSetState($gui_cbx_Cupcake, $GUI_CHECKED)
;GUICtrlSetState($gui_cbx_Battle, $GUI_DISABLE)
GUICtrlSetState($gui_cbx_District, $GUI_CHECKED)
GUICtrlSetState($gui_cbx_Rendering, $GUI_DISABLE)
GUICtrlSetState($gui_cbx_Tonic, $GUI_CHECKED)
GUICtrlSetState($gui_cbx_Purge, $GUI_CHECKED)


GUICtrlSetOnEvent($gui_btn_Toggle, "GuiButtonHandler")
GUICtrlSetOnEvent($gui_cbx_Rendering, "ToggleRendering")

GUICtrlCreateLabel("v8.8", 284, 260, 28, 0)
Global $GLOGBOX = GUICtrlCreateEdit("Polar Bear Farm v8.8", 165, 8, 160, 185, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL))
GUICtrlSetColor($GLOGBOX, 65280)
GUICtrlSetBkColor($GLOGBOX, 0)
GUISetState(@SW_SHOW)

Func GuiButtonHandler()
	If $BotRunning Then
		GUICtrlSetData($gui_btn_Toggle, "Will pause after this run")
		GUICtrlSetState($gui_btn_Toggle, $GUI_DISABLE)
		$BotRunning = False

	ElseIf $BotInitialized Then
		GUICtrlSetData($gui_btn_Toggle, "Pause")
		$BotRunning = True

	Else
		Out("Initializing...")
		Local $CharName = GUICtrlRead($Input)
		If $CharName == "" Then
			If Initialize(ProcessExists("gw.exe"), True, True, False) = False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf

		Else
			If Initialize($CharName, True, True, False) = False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharName & "'")
				Exit
			EndIf
		EndIf

		EnsureEnglish(True)
		GUICtrlSetState($gui_cbx_Rendering, $GUI_ENABLE)
		GUICtrlSetState($Input, $GUI_DISABLE)
		GUICtrlSetData($gui_btn_Toggle, "Pause")
		WinSetTitle($gui_main, "", "P-Bear v8.8-" & GetCharname())
		$BotRunning = True
		$BotInitialized = True

		$tTotal = TimerInit()
		AdlibRegister("TimeUpdater", 2000)
	EndIf
EndFunc   ;==>GuiButtonHandler
#EndRegion GUI


;################# Main Loop ##################
While 1
	If $BotRunning Then
		Global $Me = GetAgentByID(-2)
		ClearMemory()
		Sleep(250)
		ReduceMemory()
		Sleep(250)
		Checkmap()
		While CountFreeSlots() > 2
			Main()
		WEnd
	EndIf

	sleep(100)
WEnd


#Region Functions
Func Main()
	;If GetMapLoading() = 2 Then Disconnected()
	$prof = GetProfessionName()

	;Updating GUI

	;EndIf

	Out("Beginning Main")
	$lBlockedTimer = TimerInit()
	$tRun = TimerInit()
	$Return = 0

	;Accept Loot
	Out("Accepting Loot")
	AcceptAllItems()
	Sleep(500)

	;Selecting Starting Town


	;Change district
	If GUICtrlRead($gui_cbx_District) = $GUI_CHECKED Then
		Out("Changing Districts")
		RndTravel($LAMapID)
		Sleep(400)
	EndIf

	;Eat Sweets
	If GUICtrlRead($gui_cbx_Sweets) = $GUI_CHECKED Then
		Out("Eating Sweets")
		If UseItemByModelId($MID_FCake) Then
			Out("Speed Boost!!!")
		Else
			Out("No Fruitcakes :(")
		EndIf
		Sleep(250)
	EndIf

	;Quest Loop
	EnterQuest()
	If RunQuest() Then
		UpdateStatistics(1)
	Else
		UpdateStatistics(0)
	EndIf

	BackToTown()
EndFunc   ;==>Main

#Region Main Quest Loop
Func EnterQuest()
	Local $lGrenth
	Local $lChest

	If $OutPostMapID = $LAMapID Then
		$lGrenth = GetNearestNPCToCoords(2537, 8002)
	Else
		$lGrenth = GetNearestNPCToCoords(2537, 8002)
	EndIf

	GoToNPC($lGrenth)

	Out("Grabbing Quest Reward")
	RndSleep(500)
	Dialog(0x839F07) ;tries to get reward if one is still available from previous session


	Out("Entering Mission")
	RndSleep(750)
	If GetQuestByID(927) <> 0 Then
		Out("Clearing Quest ID")
		AbandonQuest(927)
		RndSleep(1000)
	EndIf
	Dialog(0x839F03)
	RndSleep(750)
	Dialog(0x839F01)
	RndSleep(750)

	If GUICtrlRead($gui_cbx_District) = $GUI_CHECKED And GetQuestByID(927) > 1 Then
		Out("Changing Districts")
		RndTravel($LAMapID)
		Sleep(400)
	EndIf

	Dialog(0x86)
	WaitMapLoading()
EndFunc   ;==>EnterQuest

Func RunQuest() ;<  New one with stuck timer
    ;sleep(1000);test
	If GetMapId() <> $QuestMapID Then Return False

	Local $tInstanceTimer = TimerInit()

	;speed boost
	If GUICtrlRead($gui_cbx_Cupcake) = $GUI_CHECKED Then
		Out("Eating Sweets")
		If UseItemByModelId($MID_CCake) Then
			Out("Speed Boost!!!")
		Else
			Out("No Cupcakes :(")
		EndIf
		Sleep(250)
	EndIf

	;tonic
	If GUICtrlRead($gui_cbx_Tonic) = $GUI_CHECKED Then
		Out("Using Tonic")
		If UseItemByModelId($MID_YTonic) Or UseItemByModelId($MID_FTonic) Then
			Out("looking nice!!!")
		Else
			Out("no tonic :(")
		EndIf
		Sleep(250)
	EndIf

	$mSelfID = GetMyID()

	;run to final battle
	For $cWP = 0 To UBound($RunWayPoints) - 1
		$currentWP = $cWP
		If Not GetIsDead(-2) Then
			If IsInt($RunWayPoints[$cWP][0]) Then
				Out($RunWayPoints[$cWP][2])
				MoveRunning($RunWayPoints[$cWP][0], $RunWayPoints[$cWP][1])
			Else
				Out("Final Battle!")
				ReverseDirection()
				Local $StuckTimer = TimerInit()

				If GUICtrlRead($gui_cbx_Alc) = $GUI_CHECKED Then
					Drink()
					Sleep(400)
				EndIf

				If GUICtrlRead($gui_cbx_Purge) = $GUI_CHECKED Then
					Sleep(125000)
					_PurgeHook()
				EndIf

				Sleep(1000)
				TargetNearestItem()

				;Wait for Battle to finish
				;put some fighting logic here
				Do
					Sleep(1000)
					If GetIsDead(-2) = 1 Or GetMapLoading() <> 1 Or GetMapID() <> 782 Then
						Return False
					EndIf
				Until IsDllStruct(GetNearestSignpostToCoords(-11452.18, -17942.34))

				;get spoils
				PickUpLoot2()

				;open chest
				Out("Opening Chest!")
				MoveTo(-11757, -18089) ; Closer Spot in front of chest

				;security checks
				If GetMapLoading() = 2 Then Disconnected()

				;TargetNearestItem()

				;open chest
				$lChest = GetNearestSignpostToCoords(-11452.18, -17942.34)
				If IsDllStruct($lChest) Then
					GoSignPost($lChest)
					Sleep(Random(1500, 3000, 1))
				EndIf
				  PickUpLoot2();test

				;finish
				WaitMapLoading(0, 20000)
				Out("Quest Completed: " & GetTimeString(TimerDiff($tInstanceTimer)))

				Return True
			EndIf
		Else
			Out("Fail " & $RunWayPoints[$cWP][2])
			Out("Changing Districts")
			RndTravel($LAMapID)
			Return False
		EndIf
	Next
EndFunc   ;==>RunQuest

Func BackToTown()
	Out("Back to Town")
	PingSleep(500)
	;_PurgeHook()
	Sleep(500)
	If GetMapID() = $QuestMapID Then HardLeave()
EndFunc   ;==>BackToTown

#EndRegion Main Quest Loop
#Region Helper Functions
#Region Time & Update Functions
Func TimeUpdater()
	GUICtrlSetData($gui_lbl_Time, GetTimeString(TimerDiff($tTotal)))
EndFunc   ;==>TimeUpdater

Func GetTimeString($iTimerdiff)
	local $lTimeString = ""
	local $lTimerdiff[3]
		  $lTimerdiff[0] = Floor($iTimerdiff / 3600000)
		  $lTimerdiff[1] = Floor($iTimerdiff / 60000) - $lTimerdiff[0] * 60
		  $lTimerdiff[2] = Round($iTimerdiff / 1000) - $lTimerdiff[0] * 3600 - $lTimerdiff[1] * 60

	For $i = 0 to 2
		If $lTimerdiff[$i] < 10 Then $lTimeString &= "0"

		$lTimeString &= $lTimerdiff[$i] & ":"
	Next

	Return StringTrimRight($lTimeString, 1)
EndFunc

#EndRegion Time & Update Functions
#Region Movement
Func MoveRunning($lDestX, $lDestY, $lRandom = 250)
	If GetIsDead(-2) Then Return False

	Local $lMe, $lMeX, $lMeY, $lTgt, $lDeadLock

	$lDeadLock = TimerInit()

	$lMe = GetAgentPtr(-2)

	If IsRecharged(6) And $prof = 'W' Then UseSkill(6, -2)

	Move($lDestX, $lDestY, $lRandom)

	Do
		RndSleep(250)

		If GetMapLoading() == 2 Then Disconnected()

		TargetNearestEnemy()

		$lTgt = GetAgentPtr(-1)

		If MemoryRead($lTgt + 436, 'word') == 1002 And GetTarget($lTgt) == $mSelfID And TimerDiff($strafeTimer) > 4000 Then
			Strafe()
		EndIf

		If IsRecharged(6) And GetHealth(-2) < 300 And $prof <> 'W' Then UseSkill(6, -2)

		If GetIsDead(-2) Then Return

		If GetHealth(-2) < 150 And IsRecharged(8) Then UseSkill(8, -2)

		If GetHasHex(-2) And IsRecharged(7) Then
			UseSkill(7, -2)
			Do
				Sleep(100)
			Until GetEffectTimeRemaining(1012) = 0
		EndIf

		If GetMoving(-2) = 0 Then Move($lDestX, $lDestY, $lRandom)

		UpdateAgentPosByPtr($lMe, $lMeX, $lMeY)
	Until ComputeDistance($lMeX, $lMeY, $lDestX, $lDestY) < 250 Or TimerDiff($lDeadLock) > 120000
	Return True
EndFunc   ;==>MoveRunning

Func Strafe()
	$strafeTimer = TimerInit()
	WriteChat("Strafing")
	ToggleAutoRun()
	Sleep(250)
	If $leftright = 0 Then
		StrafeRight(1)
		Sleep(750)
		StrafeRight(0)
		$leftright = 1
	Else
		StrafeLeft(1)
		Sleep(750)
		StrafeLeft(0)
		$leftright = 0
	EndIf
	Move($RunWayPoints[$currentWP][0], $RunWayPoints[$currentWP][1])
EndFunc   ;==>Strafe

Func UpdateAgentPosByPtr($aAgentPtr, ByRef $aX, ByRef $aY)
	Local $lStruct = MemoryReadStruct($aAgentPtr + 116, 'float X;float Y')
	$aX = DllStructGetData($lStruct, 'X')
	$aY = DllStructGetData($lStruct, 'Y')
EndFunc   ;==>UpdateAgentPosByPtr

Func GetMoving($aAgentID)
	Local $lPtr = MemoryRead($mAgentMovement + 4 * ConvertID($aAgentID))
	Return MemoryRead($lPtr + 60, 'long')
EndFunc   ;==>GetMoving

Func MemoryReadStruct($aAddress, $aStruct = 'dword')
	Local $lBuffer = DllStructCreate($aStruct)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
	Return $lBuffer
EndFunc   ;==>MemoryReadStruct

Func GetAgentMovementPtr()
	Local $Offset[4] = [0, 0x18, 0x8, 0xE8]
	Local $lPtr = MemoryReadPtr($mBasePointer, $Offset, 'ptr')
	Return $lPtr[1]
EndFunc   ;==>GetAgentMovementPtr
#EndRegion Movement

Func IsRecharged5($lSkill)
	Return GetSkillBarSkillRecharge($lSkill) == 0
EndFunc   ;==>IsRecharged

Func Disconnected4() ;Ralle's Disconnect ;
	Out("Disconnected!")
	Out("Attempting to Reconnect.")
	Static Local $gs_obj = GetValue('PacketLocation')
	Local $State = MemoryRead($gs_obj)
	If $State = 0 Then
		Do ;Disconnected
			ControlSend($mGWHwnd, '', '', '{ENTER}{ENTER}') ; Hit enter key until you log back in
			Sleep(Random(5000, 10000, 1))
		Until MemoryRead($gs_obj) <> 0
		RndSleep(500)
		Resign()
		Return True
	EndIf
	Return False
EndFunc   ;==>Disconnected

Func ToggleRendering()
	$RenderingEnabled = Not $RenderingEnabled
	If $RenderingEnabled Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
EndFunc   ;==>ToggleRendering

Func GetProfessionName($aProf = GetAgentPrimaryProfession())
	Switch $aProf
		Case 0 ; $PROFESSION_None
			Return "x"
		Case 1 ; $PROFESSION_Warrior
			Return "W"
		Case 2 ; $PROFESSION_Ranger
			Return "R"
		Case 3 ; $PROFESSION_Monk
			Return "Mo"
		Case 4 ; $PROFESSION_Necromancer
			Return "N"
		Case 5 ; $PROFESSION_Mesmer
			Return "Me"
		Case 6 ; $PROFESSION_Elementalist
			Return "E"
		Case 7 ; $PROFESSION_Assassin
			Return "A"
		Case 8 ; $PROFESSION_Ritualist
			Return "Rt"
		Case 9 ; $PROFESSION_Paragon
			Return "P"
		Case 10 ; $PROFESSION_Dervish
			Return "D"
	EndSwitch
EndFunc   ;==>GetProfessionName

Func GetAgentPrimaryProfession($aAgent = GetAgentPtr(-2))
	If IsPtr($aAgent) <> 0 Then
		Return MemoryRead($aAgent + 266, 'byte')
	ElseIf IsDllStruct($aAgent) <> 0 Then
		Return DllStructGetData($aAgent, 'Primary')
	Else
		Return MemoryRead(GetAgentPtr($aAgent) + 266, 'byte')
	EndIf
EndFunc   ;==>GetAgentPrimaryProfession

Func Out($TEXT)
	Local $TEXTLEN = StringLen($TEXT)
	Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($GLOGBOX)
	If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($GLOGBOX, StringRight(_GUICtrlEdit_GetText($GLOGBOX), 30000 - $TEXTLEN - 1000))
	_GUICtrlEdit_AppendText($GLOGBOX, @CRLF & $TEXT)
	_GUICtrlEdit_Scroll($GLOGBOX, 1)
EndFunc   ;==>Out

Func PingSleep($msExtra = 0)
	$ping = GetPing()
	Sleep($ping + $msExtra)
EndFunc   ;==>PingSleep

Func HardLeave()
	Resign()
	PingSleep(Random(5000, 7500, 1))
	ReturnToOutpost()
	WaitMapLoading()
EndFunc   ;==>HardLeave

Func CountFreeSlots()
	Local $temp = 0
	Local $bag
	Out("Checking Inventory")
	Out("3 Slots Minimum Needed")
	$bag = GetBag(1)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(2)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(3)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(4)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	Return $temp
EndFunc   ;==>CountFreeSlots

Func Checkmap()
	If GetMapID() <> $LAMapID Then
		Out("Mapping to Lions Arch")
		RndTravel($LAMapID)
	EndIf
EndFunc   ;==>Checkmap

Func UseItemByModelId($iModelID)
	local $aItem = GetItemByModelID($iModelID)

	If DllStructGetData($aItem, 'Bag') <> 0 Then
		UseItem($aItem)
		Return True
	EndIf

	Return False
EndFunc

Func Drink() ;Drink Eggnog
	$item = GetItemByModelID($MID_Eggnog)
	If DllStructGetData($item, 'Bag') <> 0 Then
		Out("Drinking Alcohol x1!")
		Out("Cheers!!!")
		UseItem($item)
		Sleep(60000) ;<-----One minute
		Out("Drinking Alcohol x2!")
		Out("Another Sip!!!")
		UseItem($item)
		Sleep(60000) ;<-----One minute
		Out("Drinking Alcohol x3!")
		Out("Shots all Round!!!")
		UseItem($item)
		Sleep(60000) ;<-----One minute
		Out("Watching Fights 4 minutes")
		Return
	EndIf
EndFunc   ;==>Drink


Func _Exit()
	Exit
EndFunc   ;==>_Exit

Func ReduceMemory()
	If $GWPID <> -1 Then
		Local $AI_HANDLE = DllCall("kernel32.dll", "int", "OpenProcess", "int", 2035711, "int", False, "int", $GWPID)
		Local $AI_RETURN = DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", $AI_HANDLE[0])
		DllCall("kernel32.dll", "int", "CloseHandle", "int", $AI_HANDLE[0])
	Else
		Local $AI_RETURN = DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", -1)
	EndIf
	Return $AI_RETURN[0]
EndFunc   ;==>ReduceMemory

Func GetItemCount($iModelID, $iMaxBag = 4)
	Local $iItemCount
	local $aBag, $aItem

	For $i = 1 To $iMaxBag
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") = $iModelID Then
				$iItemCount += DllStructGetData($aItem, "Quantity")
			EndIf
		Next
	Next
	Return $iItemCount
EndFunc

Func RndTravel($aMapID)
	Local $UseDistricts = 7 ; 7=eu-only, 8=eu+us, 9=eu+us+int, 12=all(incl. asia)
	; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, us-en, int, asia-ko, asia-ch, asia-ja
	Local $Region[11] = [2, 2, 2, 2, 0, -2, 1, 3, 4]
	Local $Language[11] = [4, 5, 9, 10, 0, 0, 0, 0, 0]
	Local $Random = Random(0, $UseDistricts - 1, 1)
	MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
	WaitMapLoading($aMapID, 30000)
	Sleep(3000)
EndFunc   ;==>RndTravel

Func _PurgeHook()
	Out("Purging Engine Hook")
	Sleep(Random(2000, 2500))
	ToggleRendering()
	Sleep(Random(2000, 2500))
	ClearMemory()
	Sleep(Random(2000, 2500))
	ToggleRendering()
EndFunc   ;==>_PurgeHook

Func UpdateStatistics($iSuccess)
	Out("Updating Statistics")

	$iTotalRuns += 1
	If $iSuccess Then
		$iTotalRunsSuccess += 1

		$status_time = TimerDiff($tRun)
		$status_total += $status_time
		$status_average = Round($status_total / $iTotalRunsSuccess)

		If $status_time < $status_best then $status_best = $status_time
		If $status_time > $status_worst then $status_worst = $status_time

		Out("Best Run: " & GetTimeString($status_best))
		Out("Worst Run: " & GetTimeString($status_worst))

	Else
		$iTotalRunsFailed += 1

		Out("best run: " & GetTimeString($status_best))
		Out("worst run: " & GetTimeString($status_worst))
	EndIf

	GUICtrlSetData($gui_lbl_WGift, GetItemCount($MID_WDGift))
	GUICtrlSetData($gui_lbl_Cupcake, GetItemCount($MID_CCake))
	GUICtrlSetData($gui_lbl_Canes, GetItemCount($MID_CShard))
	GUICtrlSetData($gui_lbl_Wins, $iTotalRunsSuccess)
	GUICtrlSetData($gui_lbl_Fails, $iTotalRunsFailed)
	GUICtrlSetData($gui_lbl_RunsHour, Round($iTotalRuns / (TimerDiff($tTotal) / 3600000)))
	GUICtrlSetData($gui_lbl_LastRun, GetTimeString(TimerDiff($tRun)))
	GUICtrlSetData($gui_lbl_AvgTime, GetTimeString($status_average))
	GUICtrlSetData($gui_lbl_SuccRate, Round($iTotalRunsSuccess / $iTotalRuns, 2))
	GUICtrlSetData($gui_lbl_PBear, GetItemCount($MID_PBear))
	If CountItemInBagsByModelID($MID_PBear) > 0 Then
		PolarBearAlert()
	EndIf
EndFunc   ;==>UpdateStatistics

Func PolarBearAlert() ;
	$GUI = GUICreate("Text Blink", 200, 200)
	$s_text = "POLAR BEAR   DETECTED!"
	$RED = 1
	$lbl_text = GUICtrlCreateLabel($s_text, 10, 50, 180, 60, $SS_SUNKEN)
	GUICtrlSetColor($lbl_text, 0x008000)
	GUICtrlSetFont($lbl_text, 20, 700)

	GUISetState(@SW_SHOW)
	$sec = @SEC
	While 1
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				ExitLoop
			Case Else
				If @SEC <> $sec Then
					$sec = @SEC
					If $RED Then
						GUICtrlSetColor($lbl_text, 0xffffff)
					Else
						GUICtrlSetColor($lbl_text, 0x008000)
					EndIf
					$RED = Not $RED
				EndIf
		EndSelect
	WEnd
	Exit
EndFunc   ;==>PolarBearAlert

Func CountItemInBagsByModelIDff($ItemModelID) ;
	$count = 0
	For $i = $BAG_Backpack To $BAG_Bag2
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItemInfo = GetItemBySlot($i, $j)
			If DllStructGetData($lItemInfo, 'ModelID') = $ItemModelID Then $count += DllStructGetData($lItemInfo, 'quantity')
		Next
	Next
	Return $count
EndFunc   ;==>CountItemInBagsByModelID

Func PickUpLoot2()
	Local $lMe = GetAgentByID(-2)
	Local $lBlockedTimer
	Local $lBlockedCount = 0
	Local $lItemExists = True
	Local $iCurDistance = 99999999
	Local $iBestDistance = 99999999
	Local $lAgent, $lTempAgent, $lTempIndex

	Local $lItemList[GetMaxAgents() + 1]
	Local $lPickupList[GetMaxAgents() + 1]

	Out("Picking Up Loot")
	For $i = 1 To GetMaxAgents()
		If GetIsDead(-2) Then Return False
		$lAgent = GetAgentByID($i)
		If Not GetIsMovable($lAgent) Then ContinueLoop
		$lDistance = GetDistance($lAgent)
		;If $lDistance > 2500 Then ContinueLoop ;<----Increased from 2,000 to try to pickup all canes
		$lItem = GetItemByAgentID($i)

		;add Items to pick up to item list
		If GuiCtrlRead($gui_cbx_Canes) = $GUI_CHECKED And CanPickUp2($lItem) Then
			$lItemList[0] += 1
			$lItemList[$lItemList[0]] = $lAgent
		EndIf
	Next

	;calculate shortest paths for picking up items
	$lTempAgent = GetAgentByID(-2)
	While $lItemList[0] > 0
		$iBestDistance = 99999999

		For $i = 1 to $lItemList[0]
			$iCurDistance = GetDistance($lItemList[$i], $lTempAgent)

			If $iCurDistance < $iBestDistance Then
				$iBestDistance = $iCurDistance
				$lTempIndex = $i
			EndIf
		Next

		;check if it's viable to run to the item
		If $iBestDistance > 2000 Then ExitLoop

		;add Item to pickup list
		$lPickupList[0] += 1
		$lPickupList[$lPickupList[0]] = $lItemList[$lTempIndex]
		$lTempAgent = $lItemList[$lTempIndex]

		;remove Item from Itemlist
		$lItemList[$lTempIndex] = $lItemList[$lItemList[0]]
		$lItemList[0] -= 1
	WEnd

	;pickup items using shortest path
	For $i = 1 to $lPickupList[0]
		$lBlockedCount = 0

		Do
			If GetDistance($lPickupList[$i]) > 150 Then
				MoveTo(DllStructGetData($lPickupList[$i], 'X'), DllStructGetData($lPickupList[$i], 'Y'), 0)
			EndIf

			$lBlockedTimer = TimerInit()
			$lItem = GetAgentByID(DllStructGetData($lPickupList[$i],"Id"))
			If IsDllStruct($lItem) Then
				Do
					PickUpItem($lItem)
					Sleep(250)
					$lItemExists = IsDllStruct(GetAgentByID(DllStructGetData($lPickupList[$i],"Id")))
				Until Not $lItemExists Or TimerDiff($lBlockedTimer) > 2500
			Else
				$lItemExists = 0
			EndIf

			If $lItemExists Then $lBlockedCount += 1
		Until Not $lItemExists Or $lBlockedCount > 5
	Next
EndFunc   ;==>PickUpLoot2

Func CanPickUp2($aItem)
	If GetMapLoading() = 2 Then Disconnected()
	Local $m = DllStructGetData($aItem, 'ModelId')
	Local $t = DllStructGetData($aItem, 'Type')
	Local $r = GetRarity($aItem)
	Local $Req = GetItemReq($aItem)
	Local $lRarity = GetRarity($aItem)
	If $r = $RARITY_GOLD Then Return True
	If $m > 21785 And $m < 21806 Then Return True ; Elite/Normal Tomes
	Switch $m
		Case 21439 ; Polar Bear
			$Polarbearcount = $Polarbearcount + 1
			GUICtrlSetData($gui_lbl_PBear, $Polarbearcount)
			Return True
		Case 2624 ; Gold Items
			Return True
		Case 556 ; Candy Cane Shard
			Return True
	EndSwitch
	Return False
EndFunc   ;==>CanPickUp2
#EndRegion HelperFunctions
#EndRegion Functions

Func GoToRift()
	Local $me, $x, $y, $DistanceToRift
	$me = GetAgentByID(-2)
	$x = DllStructGetData($me, 'X')
	$y = DllStructGetData($me, 'Y')
	$DistanceToRift = Sqrt(($x + 10918) ^ 2 + ($y - 14536) ^ 2)
	If $DistanceToRift > 4000 Then
		If $x > -4000 Then
			MoveTo(-5687, 9244)
		EndIf
		$x = DllStructGetData($me, 'X')
		$y = DllStructGetData($me, 'Y')
		$DistanceToRift = Sqrt(($x + 10918) ^ 2 + ($y - 14536) ^ 2)
		If $DistanceToRift > 6700 Then
			MoveTo(-8295, 10705)
		EndIf
	EndIf
	MoveTo(-10912, 14491)
	rndSleep(500)
	MoveTo(-10918, 14536)
	rndSleep(1500)
EndFunc   ;==>GoToRift

Func GoToRiftLA()

	MoveTo(1098, 7772)
	Local $me, $x, $y, $DistanceToRift
	$me = GetAgentByID(-2)
	$x = DllStructGetData($me, 'X')
	$y = DllStructGetData($me, 'Y')
	$DistanceToRift = Sqrt(($x - 2519) ^ 2 + ($y - 7931) ^ 2)
	If $DistanceToRift > 4000 Then
		If $x > 4000 Then
			MoveTo(1098, 7772)
		EndIf
		$x = DllStructGetData($me, 'X')
		$y = DllStructGetData($me, 'Y')
		$DistanceToRift = Sqrt(($x - 2519) ^ 2 + ($y - 7931) ^ 2)
		If $DistanceToRift > 6700 Then
			MoveTo(924, 7773)
		EndIf
	EndIf
	MoveTo(2467, 7974)
	rndSleep(1500)
EndFunc   ;==>GoToRiftLA

Func GetLoggedCharNames2()
	Local $array = ScanGW()
	If $array[0] <= 1 Then Return ''
	Local $ret = $array[1]
	For $i=2 To $array[0]
		$ret &= "|"
		$ret &= $array[$i]
	Next
	Return $ret
EndFunc

Func ScanGW2()
	Local $lWinList = WinList("Guild Wars")
	Local $lReturnArray[1] = [0]
	Local $lPid

	For $i=1 To $lWinList[0][0]

		$mGWHwnd = $lWinList[$i][1]
		$lPid = WinGetProcess($mGWHwnd)
		If __ProcessGetName($lPid) <> "gw.exe" Then ContinueLoop
		MemoryOpen(WinGetProcess($mGWHwnd))

		If $mGWProcHandle Then
			$lReturnArray[0] += 1
			ReDim $lReturnArray[$lReturnArray[0] + 1]
			$lReturnArray[$lReturnArray[0]] = ScanForCharname()
		EndIf

		MemoryClose()

		$mGWProcHandle = 0
	Next

	Return $lReturnArray
EndFunc

Func __ProcessGetNameju($i_PID)
	If Not ProcessExists($i_PID) Then Return SetError(1, 0, '')
	If Not @error Then
		Local $a_Processes = ProcessList()
		For $i = 1 To $a_Processes[0][0]
			If $a_Processes[$i][1] = $i_PID Then Return $a_Processes[$i][0]
		Next
	EndIf
	Return SetError(1, 0, '')
EndFunc
;-11757, -18089 ; Point in front of chest
;-13627, -17521 ; Point out past frosties to collect Candy Canes


