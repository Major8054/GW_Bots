#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiEdit.au3>
#include "GWA2.au3"
;#include "GWAAddsOn.au3"

$Form1_1 = GUICreate("Underworld Farmer", 362, 375, 475, 128)
$Group1 = GUICtrlCreateGroup("Cons", 8, 8, 169, 137)
$chkConset = GUICtrlCreateCheckbox("Use Conset?", 16, 32, 81, 17)
$chkJustBU = GUICtrlCreateCheckbox("Just BU", 16, 48, 57, 17)
$Group2 = GUICtrlCreateGroup("Pcons", 16, 72, 153, 41)
$chkPcon1 = GUICtrlCreateCheckbox("1", 24, 88, 25, 17)
$chkPcon2 = GUICtrlCreateCheckbox("2", 56, 88, 25, 17)
$chkPcon3 = GUICtrlCreateCheckbox("3", 88, 88, 25, 17)
$chkPcon4 = GUICtrlCreateCheckbox("4", 120, 88, 33, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$chkDPRemove = GUICtrlCreateCheckbox("DP Removal", 80, 48, 81, 17)
$chkSummonStone = GUICtrlCreateCheckbox("Summoning Stone?", 16, 120, 113, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("Run Information", 184, 8, 169, 73)
$lblTotalRun = GUICtrlCreateLabel("Total Runs: 00", 192, 24, 74, 17)
$lblCompleteRun = GUICtrlCreateLabel("Complete Runs: 00", 192, 40, 94, 17)
GUICtrlSetColor(-1, 0x00FF00)
$lblFailRun = GUICtrlCreateLabel("Failed Runs: 00", 192, 56, 78, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$txtName = GUICtrlCreateInput("Charactor Name", 184, 88, 169, 21)
$btnStart = GUICtrlCreateButton("Start The Farming", 184, 112, 169, 33)
GUICtrlSetFont(-1, 11, 400, 0, "Old English Text MT")
$Group4 = GUICtrlCreateGroup("Items/Gold Collected", 8, 152, 169, 89)
$lblGoldMade = GUICtrlCreateLabel("Gold: 0000", 16, 168, 56, 17)
$lblEctoGot = GUICtrlCreateLabel("Ectos: 00", 16, 184, 49, 17)
$lblSapphireGot = GUICtrlCreateLabel("Sapphires: 00", 16, 200, 69, 17)
$lblRubyGot = GUICtrlCreateLabel("Rubys: 00", 16, 216, 55, 17)
$Group5 = GUICtrlCreateGroup("Area", 184, 152, 169, 89)
$rdoToA = GUICtrlCreateRadio("Temple of the Ages", 192, 168, 113, 17)
$rdoCoS = GUICtrlCreateRadio("Chantry of Secrets", 192, 184, 113, 17)
$rdoZKC = GUICtrlCreateRadio("Zin Ku Corridor", 192, 200, 113, 17)
$chkHM = GUICtrlCreateCheckbox("Hard Mode?", 192, 216, 97, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe Script")
Global $gLogBox = GUICtrlCreateEdit("", 8, 248, 345, 121)
Global $fLog = FileOpen("UWF.log", 1) ;Log file



GUISetState(@SW_SHOW)

Opt("GUIOnEventMode", 1)

Global $boolRun = False
Global $boolIDSell = True
Global $intStarted = -1
Global $SR = 14
Global $intTotalRun = 0
Global $intFailRun = 0
Global $intCompleteRun = 0
Global $intGoldMade = 0
Global $intTimesMerched = 0
Global $TotalRun = 0
Global $FailRun = 0
Global $CompleteRun = 0
Global $GoldMade = 0
Global $TimesMerched = 0
Global $intCash = -1
Global $hp_start
Global $intEctoGot = -1
Global $EctoGot = 0
Global $SappGot = 0
Global $RubyGot = 0
Global $intSapphireGot = -1
Global $intyGot = -1
Global $RemoveDP = 0
Global $distance = GetDistance(GetNearestEnemyToAgent(-2))

;Maps
Global $mapToA = 138
Global $mapZKC = 284
Global $mapCoS = 393
Global $mapKam = 370
Global $mapKai = 400
Global $mapLA = 55

;Cons
Global $conCupcake = 1945
Global $conCandyApple = 2605
Global $conCandyCorn = 2604
Global $conGoldenEgg = 1934
Global $conPumpkinPie = 2649
Global $conGreenRock = 2972
Global $conRedRock = 2973
Global $conBlueRock = 2971

GUICtrlSetOnEvent($btnStart, "EventHandler")
GUISetOnEvent($GUI_EVENT_CLOSE, "EventHandler")

;GUICtrlSetOnEvent($chkConset, "EventHandler")
;GUICtrlSetOnEvent($chkJustBU, "EventHandler")
;GUICtrlSetOnEvent($Group2, "EventHandler")
;GUICtrlSetOnEvent($chkPcon1, "EventHandler")
;GUICtrlSetOnEvent($chkPcon2, "EventHandler")
;GUICtrlSetOnEvent($chkPcon3, "EventHandler")
;GUICtrlSetOnEvent($chkPcon4 , "EventHandler")

Main()

Func Main()

   While True
		Sleep(100)
		If $boolRun Then
			$lMe = GetAgentByID(-2)
			StoreGold()
Out("Checking Map")
			If GUICtrlRead($rdoToA) = 1 Then
			   Out("Temple of the Ages Selected, Flying there.")
			   TravelTo($mapToA)
			   Out("Waiting for map to load.")
			   WaitMapLoading()
			   	 Out("Checking Region")
	 	$oldRegion = GetRegion()
	Do
		$region = $oldRegion
		If $region = 4294967294 Then $region = -1
		$region += 1
		If $region > 4 Then $region = -2
		   Out("Changing Region")
		ChangeRegion($region)
		RndSleep(1000)
	 Until $oldRegion <> GetRegion()
	 Out("Loading...")
			   ToAFarmer()
			ElseIf GUICtrlRead($rdoCoS) = 1 Then
			   Out("Chantry of Secrets Selected, Flying there.")
			   TravelTo($mapCoS)
			   Out("Waiting for map to load.")
			   WaitMapLoading()
			   	 Out("Checking Region")
	 	$oldRegion = GetRegion()
	Do
		$region = $oldRegion
		If $region = 4294967294 Then $region = -1
		$region += 1
		If $region > 4 Then $region = -2
		   Out("Changing Region")
		ChangeRegion($region)
		RndSleep(1000)
	 Until $oldRegion <> GetRegion()
	 Out("Loading...")
			   CoSFarmer()
			ElseIf GUICtrlRead($rdoZKC) = 1 Then
			   Out("Zin Ku Corridor Selected, Flying there.")
			   TravelTo($mapZKC)
			   Out("Waiting for map to load.")
			   WaitMapLoading()
			   	 Out("Checking Region")
	 	$oldRegion = GetRegion()
	Do
		$region = $oldRegion
		If $region = 4294967294 Then $region = -1
		$region += 1
		If $region > 4 Then $region = -2
		   Out("Changing Region")
		ChangeRegion($region)
		RndSleep(1000)
	 Until $oldRegion <> GetRegion()
	 Out("Loading...")
			   ZKCFarmer()
			Else
			   Out("No Selected Map, Default ToA")
			   TravelTo($mapToA)
			   Out("Waiting for map to load.")
			   WaitMapLoading()
			   	 Out("Checking Region")
	 	$oldRegion = GetRegion()
	Do
		$region = $oldRegion
		If $region = 4294967294 Then $region = -1
		$region += 1
		If $region > 4 Then $region = -2
		   Out("Changing Region")
		ChangeRegion($region)
		RndSleep(1000)
	 Until $oldRegion <> GetRegion()
	 Out("Loading...")
			   ToAFarmer()
			   EndIf



			$intGoldMade += GetGoldCharacter() - $intCash
			$intCash = GetGoldCharacter()
			GUICtrlSetData($lblGoldMade, "Gold Made: " & $intGoldMade)

			RndSleep(250)

			If Not $boolRun Then
				GUICtrlSetData($btnStart, "Start The Farming")
				GUICtrlSetState($btnStart, $GUI_ENABLE)
				GUICtrlSetState($txtName, $GUI_ENABLE)
			EndIf
		EndIf
	WEnd
 EndFunc ;Main


   Func EventHandler()
	Switch (@GUI_CtrlId)
		Case $btnStart
			$boolRun = Not $boolRun
			If $boolRun Then
				GUICtrlSetData($btnStart, "Looking for GW.exe")
				GUICtrlSetState($btnStart, $GUI_DISABLE)
				GUICtrlSetState($txtName, $GUI_DISABLE)
				If GUICtrlRead($txtName) = "" Then
					If Initialize(ProcessExists("gw.exe")) = False Then
						MsgBox(0, "Error", "Guild Wars it not running.")
						Exit
					EndIf
				Else
					If Initialize(GUICtrlRead($txtName), True, True) = False Then
						MsgBox(0, "Error", "Can't find a Guild Wars client with that character name.")
						Exit
					EndIf
				EndIf
				GUICtrlSetState($btnStart, $GUI_ENABLE)
				GUICtrlSetData($btnStart, "Pause")

				$lMe = GetAgentByID(-2)
				$hp_start = DllStructGetData($lMe, 'MaxHP')

				If $intCash = -1 Then
					$intCash = GetGoldCharacter()
				EndIf
			Else
				GUICtrlSetData($btnStart, "Waiting for run to end.")
				GUICtrlSetState($btnStart, $GUI_DISABLE)
			EndIf
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
 EndFunc   ;EventHandler

 Func ToAFarmer()
	CheckGold()
;To Merch
Out("Running To Merch")
;At Merch Hasrah
GoNearestNPCToCoords(-5055, 19322)
IDAndSell()
;To Portal
Out("Running To Portal")
MoveTo(-4864, 19199)
MoveTo(-4329, 19713)
If GUICtrlRead($chkHM) = 1 Then
			   Out("Hard Mode On!")
			   SwitchMode(1)
			Else
			   Out("Normal Mode On!")
			   SwitchMode(0)
			   EndIf
	Out("Kneeling")
	SendChat('kneel', '/')
	RndSleep(5000)
	MoveTo(-4107, 19764)
	GoNearestNPCToCoords(-4107, 19764)
GoUnderworld()
 EndFunc

 Func CoSFarmer()
	CheckGold()
Out("Running To Merch")
;Merch
GoNearestNPCToCoords(-11208, 2084)
IDAndSell()
;At Merch Merassi
;To Portal
Out("Running To Portal")
MoveTo(-11573, 2245)
MoveTo(-11258, 3193)
MoveTo(-10110, 4486)
MoveTo(-9439, 4206)
MoveTo(-8905, 3587)
MoveTo(-8917, 3719)
If GUICtrlRead($chkHM) = 1 Then
			   Out("Hard Mode On!")
			   SwitchMode(1)
			Else
			   Out("Normal Mode On!")
			   SwitchMode(0)
			   EndIf
;At Portal /kneel
Out("Kneeling")
	SendChat('kneel', '/')
	RndSleep(5000)
	GoNearestNPCToCoords(-9059, 3626)
GoUnderworld()
 EndFunc

 Func ZKCFarmer()
;Merch
CheckGold()
Out("Running To Merch")
MoveTo(8554, -17861)
MoveTo(8843, -18471)
MoveTo(9821, -18484)
;At Merch Lo Ying
GoNearestNPCToCoords(10925, -18891)
IDAndSell()
;Back from Merch
MoveTo(9947, -18491)
MoveTo(8713, -18475)
MoveTo(8402, -17643)
;Merch - End
;To UW Portal
Out("Running To Portal")
MoveTo(8402, -17643)
MoveTo(6944, -17523)
MoveTo(6501, -17277)
MoveTo(3669, -17403)
MoveTo(1805, -17483)
MoveTo(-1873, -17437)
MoveTo(-2140, -16876)
MoveTo(-3035, -15625)
MoveTo(-2988, -14579)
If GUICtrlRead($chkHM) = 1 Then
			   Out("Hard Mode On!")
			   SwitchMode(1)
			Else
			   Out("Normal Mode On!")
			   SwitchMode(0)
			   EndIf
	Out("Kneeling")
	SendChat('kneel', '/')
	RndSleep(5000)
GoNearestNPCToCoords(-2623, -14568)
GoUnderworld()
;End To Portal /Kneel
 EndFunc

  Func EnterUW()
	Out("Talking to Grenth")
   Dialog(132)
 ; Dialog(0x00000084)
	RndSleep(500)
	;Dialog(0x00000085)
	Dialog(133)
	StartFarm()
 EndFunc

 Func GoUnderworld()
		Out("Talking to Grenth")
   Dialog(0x85) ;
	  Sleep(400)
	  DIALOG(0x86)
	  Sleep(100)
	StartFarm()
 EndFunc


 Func CheckGold()
	Out("Checking if you have 1000 Gold")
	If GetGoldCharacter() < 1000 And GetGoldStorage() > 1000 Then
		Out("Grabbing Gold")
		RndSleep(250)
		WithdrawGold(1000)
		RndSleep(250)
	 EndIf
  EndFunc

  Func StoreGold()
	Local $cash
	$cash = GetGoldCharacter()
	If $cash > 75000 Then
		Out("Depositing Gold")
		RndSleep(250)
		DepositGold(50000)
		RndSleep(250)
		$intCash = 0
	EndIf
	RndSleep(250)
EndFunc   ;==>StoreGold


 Func InventoryCheck()
	$temp = CountSlots(1, 20) + CountSlots(2, 5) + CountSlots(3, 10) + CountSlots(4, 10)
	If $temp < 5 Then
		ConsoleWrite("Less Then 10 Space Left" & @CRLF)
		Out("Low Space... Going To Merch")
		Return True
	Else
		ConsoleWrite("More Then 10 Space Left" & @CRLF)
		Return False
	EndIf
EndFunc   ;==>InventoryCheck

Func CountSlots($bagIndex, $numOfSlots)
	$temp = 0
	RndSlp(100)
	For $i = 0 To $numOfSlots - 1
		$aItem = GetItemBySlot($bagIndex, $i)
		Out("Counting Items: " & $bagIndex & ", " & $i)
		If DllStructGetData($aItem, 'ID') = 0 Then
			$temp += 1
		EndIf
	Next
	Return $temp
EndFunc   ;==>CountSlots


Func IDAndSell()
	Out("Cleaning Inventory")
	Sleep(1000)
	Ident(1, 20)
	Ident(2, 5)
	Ident(3, 5)
	;Ident(4, 10)
	SELL(1, 20)
	SELL(2, 5)
	SELL(3, 10)
	;Sell(4, 10)
EndFunc   ;==>IDAndSell


 Func StartFarm()
	Out("Loading Underworld")
	WaitMapLoading()
	UsePcons()
	CheckPcons()
	UseConset()
	UseBU()
	Out("Moving to left of the stairs")
	MoveTo(-495, 6609)
	UseSkills()
	WaitForKills()
    MoveTo(-2191, 5688)
	UseSkills()
	WaitForKills()
	Out("Moving to the middle of the chamber")
	MoveTo(-1371, 7179)
	UseSkills()
	WaitForKills()
    MoveTo(-1244, 7835)
	UseSkills()
	WaitForKills()
	Out("Killing Pop-Up")
	MoveTo(-862, 8923)
	UseSkills()
	WaitForKills()
	Out("Going up Middle of chamber stairs")
	MoveTo(-1669, 10631)
	UseSkills()
	WaitForKills()
	Out("Going Skele")
	MoveTo(-2706, 10149)
	Out("Killing skele")
	WaitForKills()
	MoveTo(-1767, 10583)
	UseSkills()
	WaitForKills()
    MoveTo(-694, 8957)
	Out("Moving to Aatxe at top right of stairs")
	MoveTo(-106, 9116)
	UseSkills()
	WaitForKills()
    MoveTo(848, 9720)
	UseSkills()
	WaitForKills()
	Out("Killing pop-up")
MoveTo(1204, 10380)
UseSkills()
WaitForKills()
Out("Bottem Stairs right side chamber")
MoveTo(1119, 12220)
WaitForKills()
;"top
MoveTo(1659, 12775)
UseSkills()
WaitForKills()
MoveTo(2503, 13092)
WaitForKills()
MoveTo(3242, 12862)
WaitForKills()
MoveTo(2252, 13197)
WaitForKills()
MoveTo(1146, 12451)
WaitForKills()
;back down
out("Going for quest")
MoveTo(1196, 10567)
WaitForKills()
MoveTo(461, 9219)
WaitForKills()
MoveTo(879, 7759)
WaitForKills()
MoveTo(910, 7115)
WaitForKills()
MoveTo(378, 7209)
WaitForKills()
out("Take Quest")
TakeQuestTLS()
;bottem left stairs
MoveTo(187, 6606)
UseSkills()
WaitForKills()
;top
;check left side
MoveTo(-1977, 5802)
UseSkills()
WaitForKills()
;going to right side
;wait to left stair?
MoveTo(-1207, 6524)
UseSkills()
WaitForKills()
MoveTo(-1361, 7832)
WaitForKills()
MoveTo(-805, 8886)
WaitForKills()
MoveTo(553, 9338)
WaitForKills()
;wait top right stair for grasps
MoveTo(540, 9340)
UseSkills()
WaitForKills()
MoveTo(-807, 9024)
WaitForKills()
;middle chamber stairs
;top
MoveTo(-1495, 10562)
UseSkills()
WaitForKills()
MoveTo(-2824, 10222)
WaitForKills()
;doing chamber quest
MoveTo(-4210, 11372)
UseSkills()
WaitForKills()
;wait for dead
MoveTo(-4675, 11733)
UseSkills()
WaitForKills()
;doing left side
MoveTo(-4186, 12722)
UseSkills()
WaitForKills()
;waiting for dead
MoveTo(-4050, 13182)
UseSkills()
WaitForKills()
MoveTo(-5572, 13250)
WaitForKills()
out("Killing Dryders")
;accept reward
MoveTo(-5694, 12772)
WaitForKills()
MoveTo(-5922, 11468)
WaitForKills()
;killing right side
MoveTo(-5897, 12496)
UseSkills()
WaitForKills()
Out("moving to smites")
MoveTo(-5129, 13248)
WaitForKills()
MoveTo(-4, 13337)
WaitForKills()
MoveTo(978, 12601)
WaitForKills()
MoveTo(1263, 10332)
WaitForKills()
MoveTo(1703, 10411)
WaitForKills()
MoveTo(2521, 10263)
WaitForKills()
MoveTo(3189, 9148)
WaitForKills()
;kill skele
MoveTo(3255, 8279)
UseSkills()
WaitForKills()
MoveTo(3960, 7966)
WaitForKills()
Out("Killing Aatxe and Grasps")
MoveTo(3960, 7966)
UseSkills()
WaitForKills()
MoveTo(5286, 7761)
WaitForKills()
MoveTo(5590, 8664)
WaitForKills()
MoveTo(5662, 9962)
WaitForKills()
MoveTo(6399, 10817)
WaitForKills()
MoveTo(7459, 11497)
WaitForKills()
MoveTo(8610, 12048)
UseSkills()
WaitForKills()
;kill skele
;skele check
MoveTo(8966, 12885)
SStone()
UseSkills()
WaitForKills()
MoveTo(8893, 13807)
WaitForKills()
MoveTo(8480, 14491)
WaitForKills()
MoveTo(7321, 15188)
WaitForKills()
Out("Killing Smite mob 1")
MoveTo(7722, 16315)
UseSkills()
WaitForKills()
MoveTo(8881, 17134)
WaitForKills()
MoveTo(9142, 16760)
WaitForKills()
;wait for death
Out("Killing Smite mob 2")
MoveTo(10193, 15872)
UseSkills()
WaitForKills()
MoveTo(11159, 15195)
WaitForKills()
MoveTo(12473, 15153)
WaitForKills()
;wait for dead
Out("Killing Smite mob 3")
MoveTo(13973, 17130)
UseSkills()
WaitForKills()
MoveTo(13920, 19641)
WaitForKills()
MoveTo(12576, 20212)
WaitForKills()
;wait dead
MoveTo(11829, 20188)
UseSkills()
WaitForKills()
MoveTo(11829, 20188)
WaitForKills()
Out("Killing Smite mob 4")
MoveTo(11125, 20565)
UseSkills()
WaitForKills()
MoveTo(9660, 21593)
WaitForKills()
MoveTo(8277, 22011)
WaitForKills()
;wait for dead
Out("Killing Smite mob 5")
MoveTo(7785, 21633)
UseSkills()
WaitForKills()
MoveTo(6229, 20807)
WaitForKills()
MoveTo(6034, 19970)
WaitForKills()
MoveTo(5635, 18749)
WaitForKills()
;wait for dead
Out("Killing Smite mob 6")
MoveTo(5175, 17857)
UseSkills()
WaitForKills()
MoveTo(4217, 16400)
;wait for dead
Out("Killing Smite mob 7")
MoveTo(4121, 15928)
UseSkills()
WaitForKills()
MoveTo(2643, 16990)
WaitForKills()
MoveTo(2754, 18508)
WaitForKills()
;wait for dead
MoveTo(2827, 19050)
UseSkills()
WaitForKills()
;^skele check^
Out("Killing Smite mob 8")
MoveTo(2253, 19856)
UseSkills()
WaitForKills()
MoveTo(784, 19901)
WaitForKills()
MoveTo(-498, 18792)
WaitForKills()
;wait for dead
Out("Killing Smite mob 9")
MoveTo(-837, 18762)
UseSkills()
WaitForKills()
MoveTo(884, 20412)
WaitForKills()
MoveTo(418, 21487)
WaitForKills()
MoveTo(-1481, 20952)
WaitForKills()
;wait for dead
Out("Killing Smite mob 10")
MoveTo(-2031, 20595)
UseSkills()
WaitForKills()
MoveTo(-2568, 18775)
WaitForKills()
MoveTo(-4033, 18700)
WaitForKills()
MoveTo(-4701, 19366)
WaitForKills()
;wait for dead
Out("move to planes")
MoveTo(-3924, 18667)
WaitForKills()
MoveTo(-2977, 18708)
WaitForKills()
MoveTo(-2444, 19337)
WaitForKills()
MoveTo(-2015, 20593)
WaitForKills()
MoveTo(-1365, 21015)
WaitForKills()
MoveTo(398, 21353)
WaitForKills()
MoveTo(892, 20300)
WaitForKills()
MoveTo(2128, 19929)
WaitForKills()
MoveTo(2799, 18863)
WaitForKills()
MoveTo(2514, 17133)
WaitForKills()
MoveTo(3828, 15754)
WaitForKills()
MoveTo(4514, 15732)
WaitForKills()
MoveTo(4718, 16549)
WaitForKills()
MoveTo(6093, 19040)
WaitForKills()
MoveTo(8715, 18244)
WaitForKills()
MoveTo(8929, 17621)
WaitForKills()
MoveTo(7131, 15463)
WaitForKills()
MoveTo(8670, 14309)
WaitForKills()
MoveTo(8888, 13504)
WaitForKills()
MoveTo(8599, 12367)
WaitForKills()
MoveTo(7594, 11607)
WaitForKills()
MoveTo(5472, 10107)
WaitForKills()
MoveTo(5572, 8107)
WaitForKills()
MoveTo(4374, 7121)
WaitForKills()
MoveTo(4144, 5637)
WaitForKills()
MoveTo(3131, 5571)
WaitForKills()
MoveTo(2179, 4514)
WaitForKills()
MoveTo(1545, 4634)
WaitForKills()
MoveTo(217, 3801)
WaitForKills()
Out("Killing skeles")
MoveTo(123, 3678)
UseSkills()
WaitForKills()
Out("Moveing to worms")
MoveTo(-61, 2300)
UseSkills()
WaitForKills()
MoveTo(691, 1431)
UseSkills()
WaitForKills()
;wait for dead
Out("wait for traps")
RndSleep(2000)
;redoing from traps
MoveTo(1835, 2562)
WaitForKills()
MoveTo(2851, 2886)
WaitForKills()
MoveTo(3592, 2494)
WaitForKills()
Out("Killing Worm Mob 1")
MoveTo(3295, 1343)
UseSkills()
WaitForKills()
MoveTo(4075, 1205)
WaitForKills()
MoveTo(4792, 1990)
WaitForKills()
Out("Killing Worm Mob 2")
MoveTo(4865, 550)
UseSkills()
WaitForKills()
Out("Killing Worm Mob 3")
MoveTo(5643, 618)
UseSkills()
WaitForKills()
MoveTo(6585, 1508)
WaitForKills()
Out("kill charged blackness")
MoveTo(7277, 2079)
UseSkills()
WaitForKills()
MoveTo(7983, 938)
WaitForKills()
MoveTo(7865, 136)
WaitForKills()
Out("Killing Worm Mob 4")
MoveTo(8477, -626)
UseSkills()
WaitForKills()
MoveTo(8706, -1135)
WaitForKills()
;popup
MoveTo(7896, -1886)
UseSkills()
WaitForKills()
;wait for dead
MoveTo(8114, -3608)
UseSkills()
WaitForKills()
MoveTo(7934, -4267)
WaitForKills()
MoveTo(8781, -4834)
WaitForKills()
MoveTo(8186, -6531)
WaitForKills()
MoveTo(8040, -7296)
WaitForKills()
;kill mobs
MoveTo(7966, -7743)
UseSkills()
WaitForKills()
MoveTo(8484, -8004)
WaitForKills()
;kill mob
MoveTo(9747, -8488)
UseSkills()
WaitForKills()
MoveTo(9621, -9465)
WaitForKills()
Out("At planes")
Out("Collecting Lords")
MoveTo(9153, -10780)
WaitForKills()
MoveTo(10020, -11292)
WaitForKills()
MoveTo(10533, -10474)
UseSkills()
WaitForKills()
;kill mob
Out("Killing Mindblade Mob 1")
MoveTo(10753, -11413)
UseSkills()
WaitForKills()
Out("Killing Mindblade Mob 2")
MoveTo(11809, -10680)
UseSkills()
WaitForKills()
Out("Killing Mindblade Mob 3")
MoveTo(10555, -10746)
UseSkills()
WaitForKills()
MoveTo(9166, -11161)
UseSkills()
WaitForKills()
Out("Moving to spot two")
MoveTo(10469, -10241)
UseSkills()
WaitForKills()
MoveTo(12146, -10312)
WaitForKills()
MoveTo(12852, -9597)
WaitForKills()
MoveTo(13227, -9181)
UseSkills()
WaitForKills()
Out("Killing...")
MoveTo(13192, -9027)
UseSkills()
WaitForKills()
Out("Killing Mindblade Mob 1")
MoveTo(13102, -9902)
UseSkills()
WaitForKills()
Out("Killing Mindblade Mob 2")
MoveTo(12702, -9263)
UseSkills()
WaitForKills()
MoveTo(11573, -8295)
WaitForKills()
MoveTo(11150, -8305)
UseSkills()
WaitForKills()
Out("Killing Mindblade Mob 3")
MoveTo(11850, -8248)
UseSkills()
WaitForKills()
MoveTo(13077, -7583)
WaitForKills()
;wait for dead
Out("Moving to spot 3")
MoveTo(13280, -9025)
UseSkills()
WaitForKills()
MoveTo(13668, -12144)
WaitForKills()
MoveTo(12009, -13476)
UseSkills()
WaitForKills()
;wair for dead
Out("Killing Mindblade Mob 1")
MoveTo(13019, -12773)
UseSkills()
WaitForKills()
Out("Killing Mindblade Mob 2")
MoveTo(10652, -14686)
UseSkills()
WaitForKills()
Out("Killing Mindblade Mob 3")
MoveTo(11164, -13191)
UseSkills()
WaitForKills()
;wait for dead
Out("Moving to spot 4")
MoveTo(10641, -11650)
UseSkills()
WaitForKills()
MoveTo(8618, -11218)
WaitForKills()
MoveTo(7515, -12059)
WaitForKills()
MoveTo(8327, -13146)
WaitForKills()
MoveTo(8272, -14002)
UseSkills()
WaitForKills()
;wait for dead
Out("Killing Mindblade Mob 1")
MoveTo(8283, -13214)
UseSkills()
WaitForKills()
Out("Killing Mindblade Mob 2")
MoveTo(8098, -13962)
UseSkills()
WaitForKills()
MoveTo(7496, -15081)
WaitForKills()
Out("Killing Mindblade Mob 3")
MoveTo(8268, -13928)
UseSkills()
WaitForKills()
MoveTo(7807, -12111)
WaitForKills()
MoveTo(9218, -11620)
UseSkills()
WaitForKills()
Out("Moving to spot 5")
MoveTo(7322, -12220)
UseSkills()
WaitForKills()
MoveTo(6825, -13247)
WaitForKills()
MoveTo(7392, -14467)
WaitForKills()
MoveTo(6896, -15201)
WaitForKills()
MoveTo(5986, -14869)
WaitForKills()
Out("Killing Skele Mob")
UseSkills()
MoveTo(6971, -16245)
WaitForKills()
MoveTo(6519, -17280)
WaitForKills()


EndFarm()
 EndFunc

 Func TakeQuestTLS()
   RndSleep(1000)
   ;$lQTLS = GetAgentByName("Lost Soul")
   GoNearestNPCToCoords(378, 7209)
   RndSleep(1000)
   ;GoToNpc($lQTLS)
   RndSleep(500)
   AcceptQuest(101)
   RndSleep(500)
EndFunc


  Func WaitForKills()
		$timer = TimerInit()
	Do
	   CheckDead()
	  ; CheckItems()
	  CheckPcons()
		$target = GetNearestEnemyToAgent(-2)
		ChangeTarget($target)
	 Until DllStructGetData($target, 'HP') = 0 Or TimerDiff($timer) > 80000 Or GetDistance($target, -2) > 1150
	 PickUpLoot2()
	 CheckItems()
	 DPRemove()
  EndFunc

  Func UseSkills()
	 $target = GetNearestEnemyToAgent(-2)
	    If GetSkillBarSkillRecharge(1) = 0 Then
		UseSkill(1, $target)
	 EndIf
	 RndSleep(1000)
	If GetSkillBarSkillRecharge(2) = 0 Then
		UseSkill(2, $target)
	 EndIf
	 RndSleep(1000)
	 	If GetSkillBarSkillRecharge(3) = 0 Then
		UseSkill(3, $target)
	 EndIf
	 RndSleep(1000)
	 	If GetSkillBarSkillRecharge(4) = 0 Then
		UseSkill(4, $target)
	 EndIf
	 RndSleep(1000)
	 	If GetSkillBarSkillRecharge(5) = 0 Then
		UseSkill(5, $target)
	 EndIf
	 RndSleep(1000)
	 	If GetSkillBarSkillRecharge(6) = 0 Then
		UseSkill(6, $target)
	 EndIf
	 RndSleep(1000)
	 	If GetSkillBarSkillRecharge(7) = 0 Then
		UseSkill(7, $target)
	 EndIf
	 RndSleep(1000)
	If GetSkillBarSkillRecharge(8) = 0 Then
		UseSkill(8, $target)
	 EndIf
  EndFunc


  Func CheckDead()
	Local $Deads = 0
	For $i =1 to GetHeroCount(); wipe party loop
		Sleep(100)
		If GetIsDead(GetHeroID($i)) = True Then
			RndSleep(40)
			$Deads +=1
			RndSleep(450)
		EndIf
	Next
	If $Deads > 5 Then
		Out("Number of alive heroes " & GetHeroCount() - $Deads)
		Out("Restarting")
	  $intFailRun += 1
	  $FailRun += 1
	  $intTotalRun += 1
	  $TotalRun += 1
	  GUICtrlSetData($lblTotalRun, "Total Runs: " & $intTotalRun)
	  GUICtrlSetData($lblFailRun, "Failed Runs: " & $intFailRun)
		Main()
	EndIf
EndFunc

  Func PickUpLoot2()
		Local $lMe
	Local $lBlockedTimer
	Local $lBlockedCount = 0
	Local $lItemExists = True
	For $i = 1 To GetMaxAgents()
		If GetIsDead(-2) Then Return False
		$lAgent = GetAgentByID($i)
		If Not GetIsMovable($lAgent) Then ContinueLoop
		If Not GetCanPickUp($lAgent) Then ContinueLoop
		$lItem = GetItemByAgentID($i)
			Do
				If GetDistance($lItem) > 150 Then Move(DllStructGetData($lItem, 'X'), DllStructGetData($lItem, 'Y'), 100)
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
	Next
	EndFunc

Func CanPickUp2($aitem)
	$m = DllStructGetData($aitem, 'ModelID')
	$r = GetRarity($aitem)
	If $m == 835 Or $m == 933 Or $m == 921 Or $m == 28434 Or $m == 30855 Or $m = 2511 Then
		Return True
	ElseIf $r = $RARITY_Gold Or $r = $RARITY_Green Then
		Return True
	ElseIf $m = 146 Or $m = 22751 Then ;Dyes/Lockpicks
		Return True
	ElseIf $m > 21785 And $m < 21806 Then ;Elite/Normal Tomes
		Return True
	ElseIf $m = 22191 OR $m = 22190 Then
		Return True
	 ElseIf $m = 930 Then ;Ecto
		$EctoGot+=1
		Return True
	 ElseIf $m = 938 Then ;Sapphire
		$SappGot+=1
		Return True
	 ElseIf $m = 937 Then ;Ruby
		$RubyGot+=1
		Return True
	Else
		Return False
		CheckItems()
	EndIf
EndFunc   ;==>CanPickUp

 Func CheckItems()
	$intGoldMade += GetGoldCharacter() - $intCash
			$intCash = GetGoldCharacter()
			GUICtrlSetData($lblGoldMade, "Gold Made: " & $intGoldMade)
			GUICtrlSetData($lblEctoGot, "Ectos: " & $EctoGot)
			GUICtrlSetData($lblSapphireGot, "Sapphires: " & $SappGot)
			GUICtrlSetData($lblRubyGot, "Rubys: " & $RubyGot)
		 EndFunc


   Func SStone()
	  If GUICtrlRead($chkSummonStone) = 1 Then
	  		Out("Using Summoning Stone")
			UseItem(GetItemBySlot(4, 1))
		 Else
			Out("Not Using Summoning Stone")
		 EndIf
	  EndFunc

	  Func DPRemove()
		If GUICtrlRead($chkDPRemove) = 1 Then
		         $MyLife = DllStructGetData(GetAgentByID(-2), "MaxHP")
        $Hero1 = DllStructGetData(GetAgentByID(GetHeroID(1)), "MaxHP")
        $Hero2 = DllStructGetData(GetAgentByID(GetHeroID(2)), "MaxHP")
        $Hero3 = DllStructGetData(GetAgentByID(GetHeroID(3)), "MaxHP")
        $Hero4 = DllStructGetData(GetAgentByID(GetHeroID(4)), "MaxHP")
        $Hero5 = DllStructGetData(GetAgentByID(GetHeroID(5)), "MaxHP")
        $Hero6 = DllStructGetData(GetAgentByID(GetHeroID(6)), "MaxHP")
        $Hero7 = DllStructGetData(GetAgentByID(GetHeroID(7)), "MaxHP")

        If $MyLife < 350 And $MyLife <> 0 Then
                $RemoveDP = 1
        ElseIf $Hero1 < 350 And $Hero1 <> 0 Then
                $RemoveDP = 1
        ElseIf $Hero2 < 350 And $Hero2 <> 0 Then
                $RemoveDP = 1
        ElseIf $Hero3 < 350 And $Hero3 <> 0 Then
                $RemoveDP = 1
        ElseIf $Hero4 < 350 And $Hero4 <> 0 Then
                $RemoveDP = 1
        ElseIf $Hero5 < 350 And $Hero5 <> 0 Then
                $RemoveDP = 1
        ElseIf $Hero6 < 350 And $Hero6 <> 0 Then
                $RemoveDP = 1
        ElseIf $Hero7 < 350 And $Hero7 <> 0 Then
                $RemoveDP = 1
        EndIf
        If $RemoveDP = 1 Then
                For $I = 0 To 6
                        $AItem = GetItemBySlot(4, 10)
                        UseItem($AItem)
                        RndSleep(300)
                Next
                $RemoveDP = 0
			 EndIf
			 EndIf
			 EndFunc ; Thanks To LFCAndy

	  Func UsePcons()
		 $Cupcake = GetEffect($conCupcake)
			$CandyApple = GetEffect($conCandyApple)
			$CandyCorn = GetEffect($conCandyCorn)
			$GoldenEgg = GetEffect($conGoldenEgg)
			$PumpkinPie = GetEffect($conPumpkinPie)
			$GreenRock = GetEffect($conGreenRock)
			$RedRock = GetEffect($conRedRock)
			$BlueRock = GetEffect($conBlueRock)

		If GUICtrlRead($chkPcon1) = 1 Then
	  		Out("Using Pcon 1")
			UseItem(GetItemBySlot(4, 2))
			EndIf
		 If GUICtrlRead($chkPcon2) = 1 Then
	  		Out("Using Pcon 2")
			UseItem(GetItemBySlot(4, 3))
			EndIf
		 If GUICtrlRead($chkPcon3) = 1 Then
	  		Out("Using Pcon 3")
			UseItem(GetItemBySlot(4, 4))
			EndIf
		 If GUICtrlRead($chkPcon4) = 1 Then
	  		Out("Using Pcon 4")
			UseItem(GetItemBySlot(4, 5))
			EndIf
		 EndFunc

		 Func CheckPcons()
			$Cupcake = GetEffectTimeRemaining($conCupcake)
			$CandyApple = GetEffectTimeRemaining($conCandyApple)
			$CandyCorn = GetEffectTimeRemaining($conCandyCorn)
			$GoldenEgg = GetEffectTimeRemaining($conGoldenEgg)
			$PumpkinPie = GetEffectTimeRemaining($conPumpkinPie)
			$GreenRock = GetEffectTimeRemaining($conGreenRock)
			$RedRock = GetEffectTimeRemaining($conRedRock)
			$BlueRock = GetEffectTimeRemaining($conBlueRock)

			$Cupcake1 = GetEffect($conCupcake)
			$CandyApple1 = GetEffect($conCandyApple)
			$CandyCorn1= GetEffect($conCandyCorn)
			$GoldenEgg1 = GetEffect($conGoldenEgg)
			$PumpkinPie1 = GetEffect($conPumpkinPie)
			$GreenRock1 = GetEffect($conGreenRock)
			$RedRock1 = GetEffect($conRedRock)
			$BlueRock1 = GetEffect($conBlueRock)
		If DllStructGetData($Cupcake, 'SkillID')  < 1000 And $Cupcake1 == 1 Then
		 UsePcons()
		 Else
		 Return False
		 EndIf
	  If DllStructGetData($CandyApple, 'SkillID')  < 1000 And $CandyApple1 == 1  Then
		 UsePcons()
		 Else
		 Return False
		 EndIf
	  If DllStructGetData($CandyCorn, 'SkillID') < 1000 And $CandyCorn1 == 1   Then
		 UsePcons()
	  Else
		 Return False
		 EndIf
		 If DllStructGetData($GoldenEgg, 'SkillID')  < 1000 And $GoldenEgg == 1 Then
		 UsePcons()
		 Else
		 Return False
		 EndIf
		 If DllStructGetData($PumpkinPie, 'SkillID')  < 1000 And $PumpkinPie1 Then
		 UsePcons()
		 Else
		 Return False
		 EndIf
		 If DllStructGetData($GreenRock, 'SkillID')  < 1000 And $GreenRock1 Then
		 UsePcons()
		 Else
		 Return False
		 EndIf
		 If DllStructGetData($RedRock, 'SkillID')  < 1000 And $RedRock1  Then
		 UsePcons()
		 Else
		 Return False
		 EndIf
		 If DllStructGetData($BlueRock, 'SkillID')  < 1000 And $BlueRock1  Then
		 UsePcons()
		 Else
		 Return False
	  EndIf
	  		 EndFunc


  Func UseConset()
	 If GUICtrlRead($chkConset) = 1 Then
		Out("Using Conset")
		UseItem(GetItemBySlot(4, 7))
		RndSleep(200)
		UseItem(GetItemBySlot(4, 8))
		RndSleep(200)
		UseItem(GetItemBySlot(4, 9))
		RndSleep(200)
	 EndIf
  EndFunc

  Func UseBU()
	 If GUICtrlRead($chkJustBU) = 1 Then
	  UseItem(GetItemBySlot(4, 9))
   EndIf
EndFunc


 Func EndFarm()
	Out("Farm Done, Rezoning")
	RndSleep(500)
	  $intCompleteRun += 1
	  $CompleteRun += 1
	  $intTotalRun += 1
	  $TotalRun += 1
	  GUICtrlSetData($lblTotalRun, "Total Runs: " & $intTotalRun)
	  GUICtrlSetData($lblCompleteRun, "Complete Runs: " & $intCompleteRun)
	Main()
 EndFunc

 Func Out($aString)
	FileWriteLine($fLog, @HOUR & ":" & @MIN & " - " & $aString)
	ConsoleWrite(@HOUR & ":" & @MIN & " - " & $aString & @CRLF)
	GUICtrlSetData($gLogBox, GUICtrlRead($gLogBox) & @HOUR & ":" & @MIN & " - " & $aString & @CRLF)
	_GUICtrlEdit_Scroll($gLogBox, 4)
 EndFunc   ;==>Out

 Func ChangeRegion($aRegion)
	;returns true if successful
	;-2 = international, 0 = america, 1 = asia korean, 2 = europe, 3 = asia chinese, 4 = asia japanese
	If ($aRegion < -1 Or $aRegion > 4) And $aRegion <> -2 Then Return False
	If GetRegion() = $aRegion Then Return True
	MoveMap(GetMapID(), $aRegion, 0, GetLanguage());
	Return WaitMapLoading()
EndFunc   ;==>ChangeRegion