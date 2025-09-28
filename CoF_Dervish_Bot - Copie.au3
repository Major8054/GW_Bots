#Region About
;~ Func HowToUseThisProgram()
;~ 		Start Guild Wars
;~ 		Log onto your dervish
;~ 		Equip a scythe
;~ 		Run the bot
;~ 		If one instance of Guild Wars is open Then
;~    		Click Start
;~ 		ElseIf multiple instances of Guild Wars are open Then
;~      	Select the character you want from the dropdown menu
;~ 			Click Start
;~ 		EndIf
;~ EndFunc

;~ Preparations:
;~		Dervish Equipment: Windwalker or Blessed Insignia; +4 Windprayers, +1 Scythe Mastery, +1 Mystisicm, +50 HP Rune, +2 Energy Rune
;~		Dervish Weapon: Equip a Zealous Scythe of Enchanting with a random inscription
;~		Skillbar Template: OgCjkqqLrSihdftXYijhOXhX0kA
;~		If You have no IAU: It is no problem, Bot will still work, the failrate will just increase slightly
;~
;~		Remember to get the Quest Temple of the Damned

#EndRegion About



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
#NoTrayIcon

#Region Constants
; === Maps ===
Global Const $MAP_ID_DOOMLORE = 648
Global Const $MAP_ID_COF = 560

; === Dialogs ===
Global Const $FIRST_DIALOG = 0x832105
Global Const $SECOND_DIALOG = 0x88
;test
Global Const $MERCH_DIALOG = 0x7F

; === Build ===
Global Const $SkillBarTemplate = "OgCjkqqLrSihdftXYijhOXhX0kA"

; === Skills ===
Global Const $pious = 1
Global Const $grenths = 2
Global Const $vos = 3
Global Const $mystic = 4
Global Const $crippling = 5
Global Const $reap = 6
Global Const $vop = 7
Global Const $iau = 8

; === Skill Cost ===
Global Const $skillCost[9] = [0, 5, 10, 5, 0, 0, 0, 15, 5]

; === Materials and usefull Items ===
Global Const $ITEM_ID_BONES = 921
Global Const $ITEM_ID_DUST = 929
Global Const $ITEM_ID_DIESSA = 24353
Global Const $ITEM_ID_RIN = 24354
Global Const $ITEM_ID_LOCKPICKS = 22751
Global Const $ITEM_ID_DYES = 146
Global Const $ITEM_EXTRAID_BLACKDYE = 10
Global Const $ITEM_EXTRAID_WHITEDYE = 12

; === Pcons ===
Global Const $ITEM_ID_TOTS = 28434
Global Const $ITEM_ID_GOLDEN_EGGS = 22752
Global Const $ITEM_ID_BUNNIES = 22644
Global Const $ITEM_ID_GROG = 30855
Global Const $ITEM_ID_CLOVER = 22191
Global Const $ITEM_ID_PIE = 28436
Global Const $ITEM_ID_CIDER = 28435
Global Const $ITEM_ID_POPPERS = 21810
Global Const $ITEM_ID_ROCKETS = 21809
Global Const $ITEM_ID_CUPCAKES = 22269
Global Const $ITEM_ID_SPARKLER = 21813
Global Const $ITEM_ID_HONEYCOMB = 26784
Global Const $ITEM_ID_VICTORY_TOKEN = 18345
Global Const $ITEM_ID_LUNAR_TOKEN = 21833
Global Const $ITEM_ID_HUNTERS_ALE = 910
Global Const $ITEM_ID_LUNAR_TOKENS = 28433
Global Const $ITEM_ID_KRYTAN_BRANDY = 35124
Global Const $ITEM_ID_BLUE_DRINK = 21812
#EndRegion Constants

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
#EndRegion Declarations

#Region GUI
$Gui = GUICreate("Bones Farmer", 299, 174, -1, -1)
$CharInput = GUICtrlCreateCombo("", 6, 6, 103, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
   GUICtrlSetData(-1, GetLoggedCharNames())
$StartButton = GUICtrlCreateButton("Start", 5, 146, 105, 23)
   GUICtrlSetOnEvent(-1, "GuiButtonHandler")
$RunsLabel = GUICtrlCreateLabel("Runs:", 6, 31, 31, 17)
$RunsCount = GUICtrlCreateLabel("0", 34, 31, 75, 17, $SS_RIGHT)
$FailsLabel = GUICtrlCreateLabel("Fails:", 6, 50, 31, 17)
$FailsCount = GUICtrlCreateLabel("0", 30, 50, 79, 17, $SS_RIGHT)
$DropsLabel = GUICtrlCreateLabel("Bones:", 6, 69, 76, 17)
$DropsCount = GUICtrlCreateLabel("0", 82, 69, 27, 17, $SS_RIGHT)
$AvgTimeLabel = GUICtrlCreateLabel("Average time:", 6, 88, 65, 17)
$AvgTimeCount = GUICtrlCreateLabel("-", 71, 88, 38, 17, $SS_RIGHT)
$TotTimeLabel = GUICtrlCreateLabel("Total time:", 6, 107, 49, 17)
$TotTimeCount = GUICtrlCreateLabel("-", 55, 107, 54, 17, $SS_RIGHT)
$StatusLabel = GUICtrlCreateEdit("", 115, 6, 178, 162, 2097220)
$RenderingBox = GUICtrlCreateCheckbox("Disable Rendering", 6, 124, 103, 17)
   GUICtrlSetOnEvent(-1, "ToggleRendering")
   GUICtrlSetState($RenderingBox, $GUI_DISABLE)
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion GUI

#Region Loops
Out("Ready.")
While Not $BotRunning
   Sleep(500)
WEnd

AdlibRegister("TimeUpdater", 1000)
Setup()
While 1
   If Not $BotRunning Then
	  AdlibUnRegister("TimeUpdater")
	  Out("Bot is paused.")
	  GUICtrlSetState($StartButton, $GUI_ENABLE)
	  GUICtrlSetData($StartButton, "Start")
	  GUICtrlSetOnEvent($StartButton, "GuiButtonHandler")
	  While Not $BotRunning
		 Sleep(500)
	  WEnd
	  AdlibRegister("TimeUpdater", 1000)
   EndIf
   AfterRun();test
   MainLoop()
WEnd
#EndRegion Loops

#Region Functions
Func GuiButtonHandler()
   If $BotRunning Then
	  Out("Will pause after this run.")
	  GUICtrlSetData($StartButton, "force pause NOW")
	  GUICtrlSetOnEvent($StartButton, "Resign")
	  ;GUICtrlSetState($StartButton, $GUI_DISABLE)
	  $BotRunning = False
   ElseIf $BotInitialized Then
	  GUICtrlSetData($StartButton, "Pause")
	  $BotRunning = True
   Else
	  Out("Initializing...")
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
	  GUICtrlSetState($RenderingBox, $GUI_ENABLE)
	  GUICtrlSetState($CharInput, $GUI_DISABLE)
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
   If GetMapID() <> $MAP_ID_DOOMLORE Then
	  Out("Travelling to Doomlore.")
	  RndTravel($MAP_ID_DOOMLORE)
   EndIf
   Out("Loading skillbar.")
   LoadSkillTemplate("OgCjkqqLrSihdftXYijhOXhX0kA")
   RndSleep(500)
   SetUpFastWay()
EndFunc

Func SetUpFastWay()
	Local $Gron = GetNearestNPCToCoords(-19090, 17980)
	Out("Setting up resign.")
	GoToNPC($Gron)
	Dialog($FIRST_DIALOG)
	RndSleep(GetPing()+250)
	Dialog($SECOND_DIALOG)
	WaitMapLoading($MAP_ID_COF)
	Move(-19300, -8250)
	RndSleep(2500)
	WaitMapLoading($MAP_ID_DOOMLORE)
	RndSleep(500)
	Return True
EndFunc

Func MainLoop()
   If GetMapID() == $MAP_ID_DOOMLORE Then
	  Zone_Fast_Way()
   Else
	  Setup()
	  Zone_Fast_Way()
   EndIf
   Out("Enter CoF.")
   ; Aggroing
   MoveTo(-16850, -8930)
   UseSkillEx($vop)
   UseSkillEx($grenths)
   UseSkillEx($vos)
   UseSkillEx($mystic)
   MoveTo(-15220, -8950)
   UseSkill($iau, -2)
   Out("Killing Cryptos.")
   Kill()
   If GetIsDead(-2) Then
	  $Fails += 1
	  Out("I'm dead.")
	  GUICtrlSetData($FailsCount,$Fails)
   Else
	  $Runs += 1
	  Out("Completed in " & GetTime() & ".")
	  GUICtrlSetData($RunsCount,$Runs)
	  GUICtrlSetData($AvgTimeCount,AvgTime())
   EndIf
   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then ClearMemory()
   Out("Returning to Doomlore")
   Resign()
   RndSleep(5000)
   ReturnToOutpost()
   WaitMapLoading($MAP_ID_DOOMLORE)
   AfterRun()
EndFunc

Func Zone_Fast_Way()
	Out("Zoning.")
	Local $Gron = GetNearestNPCToCoords(-19090, 17980)
	GoToNPC($Gron)
	Dialog($FIRST_DIALOG)
	RndSleep(GetPing()+250)
	Dialog($SECOND_DIALOG)
	WaitMapLoading($MAP_ID_COF)
   Return True
EndFunc

Func Kill()
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   CheckVos()
   While GetNumberOfFoesInRangeOfAgent(-2,800) > 0
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  If GetSkillbarSkillAdrenaline($crippling) >= 150 Then
		CheckVoS()
		TargetNearestEnemy()
		UseSkill($crippling, -1)
		RndSleep(800)
	  EndIf
	  If GetSkillbarSkillAdrenaline($reap) >= 120 Then
		 CheckVoS()
		 TargetNearestEnemy()
		 UseSkill($reap, -1)
		 RndSleep(800)
	  EndIf
	  Sleep(100)
	  CheckVos()
	  TargetNearestEnemy()
	  Attack(-1)
   WEnd
   RndSleep(200)
   PickUpLoot()
EndFunc

Func CheckVoS()
	If IsRecharged($vos) Then
		UseSkillEx($pious)
		UseSkillEx($grenths)
		UseSkillEx($vos)
	EndIf
EndFunc

Func WaitForSettle($FarRange,$CloseRange,$Timeout = 10000)
   If GetMapLoading() == 2 Then Disconnected()
   Local $Target
   Local $Deadlock = TimerInit()
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  CheckVoS()
	  If DllStructGetData(GetAgentByID(-2), "HP") < 0.6 Then Return	; from 0.4 up to 0.6, less chance to die
	  Sleep(50)
	  $Target = GetFarthestEnemyToAgent(-2,$FarRange)
   Until GetNumberOfFoesInRangeOfAgent(-2,900) > 0 Or (TimerDiff($Deadlock) > $Timeout)
   Local $Deadlock = TimerInit()
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  CheckVoS()
	  If DllStructGetData(GetAgentByID(-2), "HP") < 0.6 Then Return
	  Sleep(50)
	  $Target = GetFarthestEnemyToAgent(-2,$FarRange)
   Until (GetDistance(-2, $Target) < $CloseRange) Or (TimerDiff($Deadlock) > $Timeout)
EndFunc

Func GetFarthestEnemyToAgent($aAgent = -2, $aDistance = 1250)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lFarthestAgent, $lFarthestDistance = 0
   Local $lDistance, $lAgent, $lAgentArray = GetAgentArray(0xDB)
   If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
   For $i = 1 To $lAgentArray[0]
	  $lAgent = $lAgentArray[$i]
	  If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then ContinueLoop
	  If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
	  If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
	  If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
	  $lDistance = GetDistance($lAgent)
	  If $lDistance > $lFarthestDistance And $lDistance < $aDistance Then
		 $lFarthestAgent = $lAgent
		 $lFarthestDistance = $lDistance
	  EndIf
   Next
   Return $lFarthestAgent
EndFunc

Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lAgent, $lDistance
   Local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
   If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
   For $i = 1 To $lAgentArray[0]
	  $lAgent = $lAgentArray[$i]
	  If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then
		If StringLeft(GetAgentName($lAgent), 7) <> "Servant" Then ContinueLoop
	  EndIf
	  If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
	  If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
	  If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
	  ;If StringLeft(GetAgentName($lAgent), 7) <> "Sensali" Then ContinueLoop
	  $lDistance = GetDistance($lAgent)
	  If $lDistance > $aRange Then ContinueLoop
	  $lCount += 1
   Next
   Return $lCount
EndFunc

Func GetItemCountByID($ID)
   If GetMapLoading() == 2 Then Disconnected()
   Local $Item
   Local $Quantity = 0
   For $Bag = 1 to 4
	  For $Slot = 1 to DllStructGetData(GetBag($Bag), 'Slots')
		 $Item = GetItemBySlot($Bag,$Slot)
		 If DllStructGetData($Item,'ModelID') = $ID Then
			$Quantity += DllStructGetData($Item, 'Quantity')
		 EndIf
	  Next
   Next
   Return $Quantity
EndFunc

Func PickUpLoot()
   If GetMapLoading() == 2 Then Disconnected()
   Local $lMe, $lAgent, $lItem
   Local $lBlockedTimer
   Local $lBlockedCount = 0
   Local $lItemExists = True
   For $i = 1 To GetMaxAgents()
	  If GetMapLoading() == 2 Then Disconnected()
	  $lMe = GetAgentByID(-2)
	  If DllStructGetData($lMe, 'HP') <= 0.0 Then Return
	  $lAgent = GetAgentByID($i)
	  If Not GetIsMovable($lAgent) Then ContinueLoop
	  If Not GetCanPickUp($lAgent) Then ContinueLoop
	  $lItem = GetItemByAgentID($i)
	  If CanPickUp($lItem) Then
		 Do
			If GetMapLoading() == 2 Then Disconnected()
			;If $lBlockedCount > 2 Then UseSkillEx(6,-2)
			PickUpItem($lItem)
			Sleep(GetPing())
			Do
			   Sleep(100)
			   $lMe = GetAgentByID(-2)
			Until DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0
			$lBlockedTimer = TimerInit()
			Do
			   Sleep(3)
			   $lItemExists = IsDllStruct(GetAgentByID($i))
			Until Not $lItemExists Or TimerDiff($lBlockedTimer) > Random(5000, 7500, 1)
			If $lItemExists Then $lBlockedCount += 1
		 Until Not $lItemExists Or $lBlockedCount > 5
	  EndIf
   Next
EndFunc

Func CanPickUp($lItem)
   If GetMapLoading() == 2 Then Disconnected()
   Local $Quantity
   Local $ModelID = DllStructGetData($lItem, 'ModelID')
   Local $ExtraID = DllStructGetData($lItem, 'ExtraID')
   Local $lType = DllStructGetData($lItem, 'Type')
   Local $lRarity = GetRarity($lItem)
   ;If $ModelID == 146 And ($ExtraID == 10 Or $ExtraID == 12) Then Return True	; Black and White Dye
   If $modelid = 146 Then
    ; color dye check ?
    ;$extra = MemoryRead($aitemptr + 34, "short")
	  If $extraid = 10 OR $extraid = 12 Then Return True
		 Return False
   EndIf
   If $ModelID == 921 Then	; Bones
	  $Drops += DllStructGetData($lItem, 'Quantity')
	  GUICtrlSetData($DropsCount,$Drops)
	  Return True
   EndIf
   If $ModelID == 929 Then Return True ; 929 = Dust
   If $ModelID == 24353 Then Return True ; Diessa
   If $ModelID == 24354 Then Return True ; Rin
   If $ModelID == 22751 Then Return True ; Lockpick
   If $ModelID == 22191 Then Return True ; Clover
   If $ModelID == 22752 Then Return True ; egg
   ;If $ModelID == 141 Then Return True ; arc de mort sert à rien car que bois
   ;If $ModelID == 2266 Then Return True ; bouclier du crâne retiré temporairement


   If $ModelID = 22269 Then Return True ; cupcakes
   If $ModelID = 28435 Then Return True ; cidre
   If $ModelID = 910 Then Return True ; bière
   If $ModelID = 18345 Then Return True ; trophée
   If $ModelID = 26784 Then Return True ; miel
   If $ModelID = 21810 Then Return True ; canon
   If $ModelID = 21813 Then Return True ; cierge
   If $ModelID = 21812 Then Return True ; boisson sucrée
   If $ModelID = 21809 Then Return True ; fusée
   If $ModelID = 35124 Then Return True ; cognac
   If $ModelID = 21810 Then Return True ; canon

   ;-- fer/dust au recyclage
   If $ModelID == 255 Then Return True ; bouclier du crâne
   If $ModelID == 251 Then Return True ; bouclier du


   If $ModelID == 2040 Then Return True ; dagues
   If $ModelID == 257 Then Return True; canne

	  ;add
   If $ModelID == 1829 Then Return True
   If $ModelID == 1834 Then Return True
   If $ModelID == 2109 Then Return True
   If $ModelID == 1871 Then Return True
   If $ModelID == 1898 Then Return True
 ;  If $ModelID == 1875 Then Return True ; bois
   If $ModelID == 2043 Then Return True
   If $ModelID == 1869 Then Return True
   If $ModelID == 2224 Then Return True

   If $ModelID == 2511 And GetGoldCharacter() < 99000 Then Return True	;2511 = Gold Coins
   If $lType == 24 Then Return True ;Shields
   ;Return true
    Return False; test plus tard
EndFunc

Func SalvageStuff()
   If GetMapLoading() == 2 Then Disconnected()
   $MerchOpened = False
   Local $Item
   Local $Quantity
   For $Bag = 1 To 4
	  If GetMapLoading() == 2 Then Disconnected()
	  For $Slot = 1 To DllStructGetData(GetBag($Bag), 'Slots')
		 If GetMapLoading() == 2 Then Disconnected()
		 $Item = GetItemBySlot($Bag, $Slot)
		 If CanSalvage($Item) Then
			$Quantity = DllStructGetData($Item, 'Quantity')
			For $i = 1 To $Quantity
			   If GetMapLoading() == 2 Then Disconnected()
			   If FindCheapSalvageKit() = 0 Then BuySalvageKit()
			   StartSalvage1($Item, True)
			   Do
				  Sleep(10)
			   Until DllStructGetData(GetItemBySlot($Bag, $Slot), 'Quantity') = $Quantity - $i
			   $Item = GetItemBySlot($Bag, $Slot)
			Next
		 EndIf
	  Next
   Next
EndFunc

Func StartSalvage1($aItem, $aCheap = false)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lOffset[4] = [0, 0x18, 0x2C, 0x62C]
   Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)
   If IsDllStruct($aItem) = 0 Then
	  Local $lItemID = $aItem
   Else
	  Local $lItemID = DllStructGetData($aItem, 'ID')
   EndIf
   If $aCheap Then
	  Local $lSalvageKit = FindCheapSalvageKit()
   Else
	  Local $lSalvageKit = FindSalvageKit()
   EndIf
   If $lSalvageKit = 0 Then Return
   DllStructSetData($mSalvage, 2, $lItemID)
   DllStructSetData($mSalvage, 3, $lSalvageKit)
   DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])
   Enqueue($mSalvagePtr, 16)
EndFunc

Func CanSalvage($Item)
   If DllStructGetData($Item, 'ModelID') == 835 Then Return True
   Return False
EndFunc

Func FindCheapSalvageKit()
   If GetMapLoading() == 2 Then Disconnected()
   Local $Item
   Local $Kit = 0
   Local $Uses = 101
   For $Bag = 1 To 16
	  For $Slot = 1 To DllStructGetData(GetBag($Bag), 'Slots')
		 $Item = GetItemBySlot($Bag, $Slot)
		 Switch DllStructGetData($Item, 'ModelID')
			Case 2992
			   If DllStructGetData($Item, 'Value')/2 < $Uses Then
				  $Kit = DllStructGetData($Item, 'ID')
				  $Uses = DllStructGetData($Item, 'Value')/8
			   EndIf
			Case Else
			   ContinueLoop
		 EndSwitch
	  Next
   Next
   Return $Kit
EndFunc

Func BuySalvageKit()
   WithdrawGold(100)
   GoToMerch()
   RndSleep(500)
   BuyItem(2, 1, 100)
   Sleep(1500)
   If FindCheapSalvageKit() = 0 Then BuySalvageKit()
EndFunc

Func GoToMerch()
   Out("Go to merch")
   If GetMapLoading() == 2 Then Disconnected()
   If $MerchOpened = False Then
	  Local $Me = GetAgentByID(-2)
	  Local $X = DllStructGetData($Me, 'X')
	  Local $Y = DllStructGetData($Me, 'Y')
	  If ComputeDistance($X, $Y, 18383, 11202) < 750 Then
		 MoveTo(17715, 11773)
		 MoveTo(17174, 12403)
	  EndIf
	  If ComputeDistance($X, $Y, 18786, 9415) < 750 Then
		 MoveTo(17684, 10568)
		 MoveTo(17174, 12403)
	  EndIf
	  If ComputeDistance($X, $Y, 16669, 11862) < 750 Then
		 MoveTo(17174, 12403)
	  EndIf
	  TargetNearestAlly()
	  ActionInteract()
	  $MerchOpened = True
   EndIf
EndFunc

Func RndTravel($aMapID)
   If GetMapLoading() == 2 Then Disconnected()
#cs   Local $UseDistricts = 7 ; 7=eu-only, 8=eu+int, 11=all(excluding America)
   ; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, us-en, int, asia-ko, asia-ch, asia-ja
;~    Local $Region[11] = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
;~    Local $Language[11] = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]
   Local $Region[11] = [0, -2, 1, 3, 4]
   Local $Language[11] = [0, 0, 0, 0, 0]
#ce   Local $Random = Random(0, $UseDistricts - 1, 1)
;   MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
   TravelTo($aMapID)
;   WaitMapLoading($aMapID)
EndFunc

Func GetTime()
   Local $Time = GetInstanceUpTime()
   Local $Seconds = Floor($Time/1000)
   Local $Minutes = Floor($Seconds/60)
   Local $Hours = Floor($Minutes/60)
   Local $Second = $Seconds - $Minutes*60
   Local $Minute = $Minutes - $Hours*60
   If $Hours = 0 Then
	  If $Second < 10 Then $InstTime = $Minute&':0'&$Second
	  If $Second >= 10 Then $InstTime = $Minute&':'&$Second
   ElseIf $Hours <> 0 Then
	  If $Minutes < 10 Then
		 If $Second < 10 Then $InstTime = $Hours&':0'&$Minute&':0'&$Second
		 If $Second >= 10 Then $InstTime = $Hours&':0'&$Minute&':'&$Second
	  ElseIf $Minutes >= 10 Then
		 If $Second < 10 Then $InstTime = $Hours&':'&$Minute&':0'&$Second
		 If $Second >= 10 Then $InstTime = $Hours&':'&$Minute&':'&$Second
	  EndIf
   EndIf
   Return $InstTime
EndFunc

Func AvgTime()
   Local $Time = GetInstanceUpTime()
   Local $Seconds = Floor($Time/1000)
   $TotalSeconds += $Seconds
   Local $AvgSeconds = Floor($TotalSeconds/$Runs)
   Local $Minutes = Floor($AvgSeconds/60)
   Local $Hours = Floor($Minutes/60)
   Local $Second = $AvgSeconds - $Minutes*60
   Local $Minute = $Minutes - $Hours*60
   If $Hours = 0 Then
	  If $Second < 10 Then $AvgTime = $Minute&':0'&$Second
	  If $Second >= 10 Then $AvgTime = $Minute&':'&$Second
   ElseIf $Hours <> 0 Then
	  If $Minutes < 10 Then
		 If $Second < 10 Then $AvgTime = $Hours&':0'&$Minute&':0'&$Second
		 If $Second >= 10 Then $AvgTime = $Hours&':0'&$Minute&':'&$Second
	  ElseIf $Minutes >= 10 Then
		 If $Second < 10 Then $AvgTime = $Hours&':'&$Minute&':0'&$Second
		 If $Second >= 10 Then $AvgTime = $Hours&':'&$Minute&':'&$Second
	  EndIf
   EndIf
   Return $AvgTime
EndFunc

Func TimeUpdater()
	$Seconds += 1
	If $Seconds = 60 Then
		$Minutes += 1
		$Seconds = $Seconds - 60
	EndIf
	If $Minutes = 60 Then
		$Hours += 1
		$Minutes = $Minutes - 60
	EndIf
	If $Seconds < 10 Then
		$L_Sec = "0" & $Seconds
	Else
		$L_Sec = $Seconds
	EndIf
	If $Minutes < 10 Then
		$L_Min = "0" & $Minutes
	Else
		$L_Min = $Minutes
	EndIf
	If $Hours < 10 Then
		$L_Hour = "0" & $Hours
	Else
		$L_Hour = $Hours
	EndIf
	GUICtrlSetData($TotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
EndFunc


Func Out($msg)
   GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc

Func _exit()
   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then
	  EnableRendering()
	  WinSetState($HWND, "", @SW_SHOW)
	  Sleep(500)
   EndIf
   Exit
EndFunc

#Region Merch
Func AfterRun($aBags = 4)
	CountSlots()
	Sleep(2000)
	;storegold()
	If CountSlots() < 6 Then
		Sleep(2000)
		Merchant()
		RndSleep(1000)
		Ident(1)
		Ident(2)
		Ident(3)
		Ident(4)
			For $i = 1 to $aBags ; retiré temporairement car salvage ne marche pas
				Salvage($i)
			Next
		RndSleep(1000)

		;SellLoot();
		;Sell(1)
		;Sell(2)
		;Sell(3)
		;RndSleep(1000)

	;Else
	;	RndSleep(2000)
	;	Main()
	EndIf
	;Main()
	Sleep(1000)
 EndFunc
 Func Salvage($lBag)
	  Local $aBag
	  If Not IsDllStruct($lBag) Then $aBag = GetBag($lBag)
	  Local $lItem
	  Local $lSalvageType
	  Local $lSalvageCount
	  For $i = 1 To DllStructGetData($aBag, 'Slots')

			   $lItem = GetItemBySlot($aBag, $i)

			   SalvageKit()

			$q = DllStructGetData($lItem, 'Quantity')
			$t = DllStructGetData($lItem, 'Type')
			$m = DllStructGetData($lItem, 'ModelID')

			   If (DllStructGetData($lItem, 'ID') == 0) Then ContinueLoop


		 If  $m = 2266 or $m = 255 or $m = 251 or $m = 2254 or $m = 2040 or $m = 257 or $m = 1829 or $m = 1834 or $m = 2109 or $m = 1871 or $m = 1898 or $m = 2043 or $m = 1869 or $m = 2224 Then ;bouclier du crane + cannes
			   If $q >= 1 Then
						For $j = 1 To $q

							  SalvageKit()

							  StartSalvage($lItem)
							  Sleep(GetPing() + Random(1000, 1500, 1))

							  SalvageMaterials()

							  While (GetPing() > 1250)
									   RndSleep(250)
							  WEnd

							  Local $lDeadlock = TimerInit()
							  Local $bItem
							  Do
									   Sleep(300)
									   $bItem = GetItemBySlot($aBag, $i)
									   If (TimerDiff($lDeadlock) > 20000) Then ExitLoop
							  Until (DllStructGetData($bItem, 'Quantity') = $q - $j)
						Next
			   EndIf
			   EndIf
	  Next
	  Return True
   EndFunc

   Func Ident($BAGINDEX)
	Out("Ident")
	Local $bag
	Local $I
	Local $AITEM
	$BAG = GETBAG($BAGINDEX)
	For $I = 1 To DllStructGetData($BAG, "slots")
		If FINDIDKIT() = 0 Then
			If GETGOLDCHARACTER() < 500 And GETGOLDSTORAGE() > 499 Then
				WITHDRAWGOLD(500)
				Sleep(GetPing()+500)
			EndIf
			Local $J = 0
			Do
				BuyItem(6, 1, 500)
				Sleep(GetPing()+500)
				$J = $J + 1
			Until FINDIDKIT() <> 0 Or $J = 3
			If $J = 3 Then ExitLoop
			Sleep(GetPing()+500)
		EndIf
		$AITEM = GETITEMBYSLOT($BAGINDEX, $I)
		If DllStructGetData($AITEM, "Id") = 0 Then ContinueLoop
		IDENTIFYITEM($AITEM)
		Sleep(GetPing()+500)
	Next
 EndFunc
 Func Merchant()
	Out("Go to merch")
	;GoNearestNPCToCoords(-10607.00, -20517.00)
	GoNearestNPCToCoords(-19166.00, 17980.00)
	Dialog($MERCH_DIALOG)
		;	_travelgh()
		;	$lmapid_hall = getmapid()
		;	gotonpc(getplayerptrbyplayernumber(getmerchant($lmapid_hall)))
	If GetGoldCharacter() > 80000 Then

		DepositGold(70000)
		Sleep(GetPing()+500)
	EndIf

	$i = 0;
	Do
		If FindIDKit() = 0 Then
			If GetGoldCharacter() < 100 And GetGoldStorage() > 99 Then
				WithdrawGold(100)
				Sleep(GetPIng()+250)
			EndIf
			BuyIDKit()
			Do
				Sleep(200)
			Until FindIDKit() <> 0
		EndIf
		Sleep(GetPing())
		$i += 1
	Until FindIDKit() <> 0 Or $i > 4
 EndFunc


 	Func _travelgh()
		Local $larray_gh[16] = [4, 5, 6, 52, 176, 177, 178, 179, 275, 276, 359, 360, 529, 530, 537, 538]
		Local $lmapid = getmapid()
		If _arraysearch($larray_gh, $lmapid) <> -1 Then Return
		travelgh()
	 EndFunc
     Func travelgh2()
		Local $loffset[3] = [0, 24, 60]
		Local $lgh = memoryreadptr($mbasepointer, $loffset)
		sendpacket(0x18, $HEADER_GUILDHALL_TRAVEL, MemoryRead($lGH[1] + 0x64), MemoryRead($lGH[1] + 0x68), MemoryRead($lGH[1] + 0x6C), MemoryRead($lGH[1] + 0x70), 1)
		Return waitmaploading()
	EndFunc
Func CountSlots()
	Local $FreeSlots = 0, $lBag, $aBag
	For $aBag = 1 To 4
		$lBag = GetBag($aBag)
		$FreeSlots += DllStructGetData($lBag, 'slots') - DllStructGetData($lBag, 'ItemsCount')
	Next
	Return $FreeSlots
 EndFunc ; Counts open slots in your Imventory

 	Func getplayerptrbyplayernumber($aplayernumber)
		Local $lagentarray = memoryreadagentptrstruct(1)
		For $i = 1 To $lagentarray[0]
			If memoryread($lagentarray[$i] + 244, "word") = $aplayernumber Then Return $lagentarray[$i]
		Next
	EndFunc

Func _arraysearch(Const ByRef $aarray, $vvalue, $istart = 0, $iend = 0, $icase = 0, $icompare = 0, $iforward = 1, $isubitem = -1, $brow = False)
	If $istart = Default Then $istart = 0
	If $iend = Default Then $iend = 0
	If $icase = Default Then $icase = 0
	If $icompare = Default Then $icompare = 0
	If $iforward = Default Then $iforward = 1
	If $isubitem = Default Then $isubitem = -1
	If $brow = Default Then $brow = False
	If NOT IsArray($aarray) Then Return SetError(1, 0, -1)
	Local $idim_1 = UBound($aarray) - 1
	If $idim_1 = -1 Then Return SetError(3, 0, -1)
	Local $idim_2 = UBound($aarray, $ubound_columns) - 1
	Local $bcomptype = False
	If $icompare = 2 Then
		$icompare = 0
		$bcomptype = True
	EndIf
	If $brow Then
		If UBound($aarray, $ubound_dimensions) = 1 Then Return SetError(5, 0, -1)
		If $iend < 1 OR $iend > $idim_2 Then $iend = $idim_2
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(4, 0, -1)
	Else
		If $iend < 1 OR $iend > $idim_1 Then $iend = $idim_1
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(4, 0, -1)
	EndIf
	Local $istep = 1
	If NOT $iforward Then
		Local $itmp = $istart
		$istart = $iend
		$iend = $itmp
		$istep = -1
	EndIf
	Switch UBound($aarray, $ubound_dimensions)
		Case 1
			If NOT $icompare Then
				If NOT $icase Then
					For $i = $istart To $iend Step $istep
						If $bcomptype AND VarGetType($aarray[$i]) <> VarGetType($vvalue) Then ContinueLoop
						If $aarray[$i] = $vvalue Then Return $i
					Next
				Else
					For $i = $istart To $iend Step $istep
						If $bcomptype AND VarGetType($aarray[$i]) <> VarGetType($vvalue) Then ContinueLoop
						If $aarray[$i] == $vvalue Then Return $i
					Next
				EndIf
			Else
				For $i = $istart To $iend Step $istep
					If $icompare = 3 Then
						If StringRegExp($aarray[$i], $vvalue) Then Return $i
					Else
						If StringInStr($aarray[$i], $vvalue, $icase) > 0 Then Return $i
					EndIf
				Next
			EndIf
		Case 2
			Local $idim_sub
			If $brow Then
				$idim_sub = $idim_1
				If $isubitem > $idim_sub Then $isubitem = $idim_sub
				If $isubitem < 0 Then
					$isubitem = 0
				Else
					$idim_sub = $isubitem
				EndIf
			Else
				$idim_sub = $idim_2
				If $isubitem > $idim_sub Then $isubitem = $idim_sub
				If $isubitem < 0 Then
					$isubitem = 0
				Else
					$idim_sub = $isubitem
				EndIf
			EndIf
			For $j = $isubitem To $idim_sub
				If NOT $icompare Then
					If NOT $icase Then
						For $i = $istart To $iend Step $istep
							If $brow Then
								If $bcomptype AND VarGetType($aarray[$j][$j]) <> VarGetType($vvalue) Then ContinueLoop
								If $aarray[$j][$i] = $vvalue Then Return $i
							Else
								If $bcomptype AND VarGetType($aarray[$i][$j]) <> VarGetType($vvalue) Then ContinueLoop
								If $aarray[$i][$j] = $vvalue Then Return $i
							EndIf
						Next
					Else
						For $i = $istart To $iend Step $istep
							If $brow Then
								If $bcomptype AND VarGetType($aarray[$j][$i]) <> VarGetType($vvalue) Then ContinueLoop
								If $aarray[$j][$i] == $vvalue Then Return $i
							Else
								If $bcomptype AND VarGetType($aarray[$i][$j]) <> VarGetType($vvalue) Then ContinueLoop
								If $aarray[$i][$j] == $vvalue Then Return $i
							EndIf
						Next
					EndIf
				Else
					For $i = $istart To $iend Step $istep
						If $icompare = 3 Then
							If $brow Then
								If StringRegExp($aarray[$j][$i], $vvalue) Then Return $i
							Else
								If StringRegExp($aarray[$i][$j], $vvalue) Then Return $i
							EndIf
						Else
							If $brow Then
								If StringInStr($aarray[$j][$i], $vvalue, $icase) > 0 Then Return $i
							Else
								If StringInStr($aarray[$i][$j], $vvalue, $icase) > 0 Then Return $i
							EndIf
						EndIf
					Next
				EndIf
			Next
		Case Else
			Return SetError(2, 0, -1)
	EndSwitch
	Return SetError(6, 0, -1)
 EndFunc
Func SellLoot(); pas encore fait
   For $j = 1 To 4
	  Local $lBag = GetBag($j)
	  Local $lNumSlots = DllStructGetData($lBag, "slots")
	  For $k = 1 To $lNumSlots
			Local $lItem = GetItemBySlot($j, $k)
			If CandSellLoot($lItem) == True Then
			   SellItem($litem)
			   Sleep(GetPing() + 500)
			EndIf
	  Next
   Next
EndFunc
Func getmerchant($amapid)
	Switch $amapid
		Case 4, 5, 6, 52, 176, 177, 178, 179
			Return 209
		Case 275, 276, 359, 360, 529, 530, 537, 538
			Return 196
		Case 10, 11, 12, 139, 141, 142, 49, 857
			Return 2030
		Case 109, 120, 154
			Return 1987
		Case 116, 117, 118, 152, 153, 38
			Return 1988
		Case 122, 35
			Return 2130
		Case 123, 124
			Return 2131
		Case 129, 348, 390
			Return 3396
		Case 130, 218, 230, 287, 349, 388
			Return 3397
		Case 131, 21, 25, 36
			Return 2080
		Case 132, 135, 28, 29, 30, 32, 39, 40
			Return 2091
		Case 133, 155, 156, 157, 158, 159, 206, 22, 23, 24
			Return 2101
		Case 134, 81
			Return 2005
		Case 136, 137, 14, 15, 16, 19, 57, 73
			Return 1983
		Case 138
			Return 1969
		Case 193, 234, 278, 288, 391
			Return 3612
		Case 194, 213, 214, 225, 226, 242, 250, 283, 284, 291, 292
			Return 3269
		Case 216, 217, 249, 251
			Return 3265
		Case 219, 224, 273, 277, 279, 289, 297, 350, 389
			Return 3611
		Case 220, 274, 51
			Return 3267
		Case 222, 272, 286, 77
			Return 3395
		Case 248
			Return 1201
		Case 303
			Return 3266
		Case 376, 378, 425, 426, 477, 478
			Return 5379
		Case 381, 387, 421, 424, 427, 554
			Return 5380
		Case 393, 396, 403, 414, 476
			Return 5660
		Case 398, 407, 428, 433, 434, 435
			Return 5659
		Case 431
			Return 4715
		Case 438, 545
			Return 5615
		Case 440, 442, 469, 473, 480, 494, 496
			Return 5607
		Case 450, 559
			Return 4983
		Case 474, 495
			Return 5608
		Case 479, 487, 489, 491, 492, 502, 818
			Return 4714
		Case 555
			Return 4982
		Case 624
			Return 6752
		Case 638
			Return 6054
		Case 639, 640
			Return 6751
		Case 641
			Return 6057
		Case 642
			Return 6041
		Case 643, 645, 650
			Return 6377
		Case 644
			Return 6378
		Case 648
			Return 6583
		Case 652
			Return 6225
		Case 675
			Return 6184
		Case 808
			Return 7442
		Case 814
			Return 104
	EndSwitch
 EndFunc
 		Func memoryreadagentptrstruct($amode = 0, $atype = 219, $aallegiance = 3, $adead = False)
			Local $lmaxagents = getmaxagents()
			Local $lagentptrstruct = DllStructCreate("PTR[" & $lmaxagents & "]")
			DllCall($mkernelhandle, "BOOL", "ReadProcessMemory", "HANDLE", $mgwprochandle, "PTR", memoryread($magentbase), "STRUCT*", $lagentptrstruct, "ULONG_PTR", $lmaxagents * 4, "ULONG_PTR*", 0)
			Local $ltemp
			Local $lagentarray[$lmaxagents + 1]
			Switch $amode
				Case 0
					For $i = 1 To $lmaxagents
						$ltemp = DllStructGetData($lagentptrstruct, 1, $i)
						If $ltemp = 0 Then ContinueLoop
						$lagentarray[0] += 1
						$lagentarray[$lagentarray[0]] = $ltemp
					Next
				Case 1
					For $i = 1 To $lmaxagents
						$ltemp = DllStructGetData($lagentptrstruct, 1, $i)
						If $ltemp = 0 Then ContinueLoop
						If memoryread($ltemp + 156, "long") <> $atype Then ContinueLoop
						$lagentarray[0] += 1
						$lagentarray[$lagentarray[0]] = $ltemp
					Next
				Case 2
					For $i = 1 To $lmaxagents
						$ltemp = DllStructGetData($lagentptrstruct, 1, $i)
						If $ltemp = 0 Then ContinueLoop
						If memoryread($ltemp + 156, "long") <> $atype Then ContinueLoop
						If memoryread($ltemp + 433, "byte") <> $aallegiance Then ContinueLoop
						$lagentarray[0] += 1
						$lagentarray[$lagentarray[0]] = $ltemp
					Next
				Case 3
					For $i = 1 To $lmaxagents
						$ltemp = DllStructGetData($lagentptrstruct, 1, $i)
						If $ltemp = 0 Then ContinueLoop
						If memoryread($ltemp + 156, "long") <> $atype Then ContinueLoop
						If memoryread($ltemp + 433, "byte") <> $aallegiance Then ContinueLoop
						If memoryread($ltemp + 304, "float") <= 0 Then ContinueLoop
						$lagentarray[0] += 1
						$lagentarray[$lagentarray[0]] = $ltemp
					Next
			EndSwitch
			ReDim $lagentarray[$lagentarray[0] + 1]
			Return $lagentarray
		EndFunc
Func SalvageKit()
   If FindSalvageKit() = 0 Then
	  If GetGoldCharacter() < 100 Then
		 WithdrawGold(100)
		 RndSleep(2000)
	  EndIf
	  BuyItem(2, 1, 100)
	  RndSleep(1000)
   EndIf
EndFunc	;=> SalvageKit
 Func GoNearestNPCToCoords($x, $y)
	Do
		RndSleep(250)
		$guy = GetNearestNPCToCoords($x, $y)
	Until DllStructGetData($guy, 'Id') <> 0
	ChangeTarget($guy)
	RndSleep(250)
	MoveTo(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 0)
	RndSleep(500)
	GoNPC($guy)
	RndSleep(250)
	Do
		RndSleep(500)
		MoveTo(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 0)
		RndSleep(500)
		GoNPC($guy)
		RndSleep(250)
		$Me = GetAgentByID(-2)
	Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
	RndSleep(1000)
 EndFunc   ;==>GoNearestNPCToCoords
#EndRegion Merch

Func UseSkillEx($lSkill, $lTgt = -2, $aTimeout = 3000)
	If GetIsDead(-2) Then Return
	If Not IsRecharged($lSkill) Then Return
	Local $Skill = GetSkillByID(GetSkillbarSkillID($lSkill, 0))
	Local $Energy = StringReplace(StringReplace(StringReplace(StringMid(DllStructGetData($Skill, 'Unknown4'), 6, 1), 'C', '25'), 'B', '15'), 'A', '10')
	If GetEnergy(-2) < $Energy Then Return
	Local $lAftercast = DllStructGetData($Skill, 'Aftercast')
	Local $lDeadlock = TimerInit()
	UseSkill($lSkill, $lTgt)
	Do
		Sleep(50)
		If GetIsDead(-2) = 1 Then Return
	Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)
	Sleep($lAftercast * 1000)
EndFunc   ;==>UseSkillEx


#EndRegion Functions
