;v1.2
#include-once
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include "GWA2.au3"
#include <File.au3>

; UI const
;Global Const $ss_center = 1
Global Const $cbs_dropdown = 2
Global Const $cbs_autohscroll = 64
Global $mfirstchar = ""

	Local $nbRuns = 0
	Local $nbFails = 0
	Local $running = False
	Local $initialized = False

#Region GUI
	Opt("GUIOnEventMode", 1)
	Local Const $maingui = GUICreate("Snowball")
	Local Const $gui_gsettings = GUICtrlCreateGroup("Settings", 5, 2, 135, 80)
	Local Const $gui_lblname = GUICtrlCreateLabel("Character :", 6, 18, 129, 15, $ss_center)
	Local $gui_txtname = GUICtrlCreateCombo("", 8, 35, 129, 25, BitOR($cbs_dropdown, $cbs_autohscroll))
	GUICtrlSetData(-1, GetLoggedCharNames(), $mfirstchar)
	Local Const $gui_cbdisablegraphics = GUICtrlCreateCheckbox("Disable Graphics", 10, 60, 97, 17)
	;Local Const $gui_lbllog = GUICtrlCreateEdit("", 142, 5, 162, 165, BitOR($es_autovscroll, $es_readonly, $es_wantreturn, $ws_vscroll), 0)
	Local Const $gui_edit = GUICtrlCreateEdit("", 142, 5, 162, 165, BitOR(0x0040, 0x00200000, 0x00800000, 0x0800))
	Local Const $gui_gstats = GUICtrlCreateGroup("Stats", 5, 85, 135, 55)
	Local Const $gui_lblsuccruns = GUICtrlCreateLabel("Success Runs :", 10, 102, 75, 17)
	Local Const $gui_stsuccruns = GUICtrlCreateLabel("0", 90, 102, 49, 17, $ss_center)
	Local Const $gui_lblfailruns = GUICtrlCreateLabel("Fail Runs : ", 10, 120, 75, 17)
	Local Const $gui_stfailruns = GUICtrlCreateLabel("0", 90, 10, 49, 17, $ss_center)
	Local Const $gui_btstart = GUICtrlCreateButton("Start", 4, 145, 67, 25, $bs_vcenter)
	Local Const $gui_bexit = GUICtrlCreateButton("Exit", 74, 145, 67, 25, $bs_vcenter)
	$statusLabel = GUICtrlCreateLabel("Ready to begin", 10, 200, 250)
$status2Label = GUICtrlCreateLabel("runs: 0, fails: 0", 10, 220, 250)
$status3Label = GUICtrlCreateLabel("runs: 0, fails: 0", 10, 240, 250)
$randomTravelCheckbox = GUICtrlCreateCheckbox("Random Travel", 10, 85)
$useTonicsCheckbox = GUICtrlCreateCheckbox("Spam Tonics", 10, 105)
	GUISetOnEvent($gui_event_close, "EventHandler")
	GUICtrlSetOnEvent($gui_cbdisablegraphics, "EventHandler")
	GUICtrlSetOnEvent($gui_btstart, "EventHandler")
	GUICtrlSetOnEvent($gui_bexit, "EventHandler")
	TraySetIcon("icon.ico")
	GUISetIcon("icon.ico")
	GUISetState(@SW_SHOW)
#EndRegion

;GUISetOnEvent($GUI_EVENT_CLOSE, "closeWindowHandler")
GUISetOnEvent($gui_event_close, "EventHandler")
GUISetOnEvent($gui_event_close, "EventHandler")
GUICtrlSetOnEvent($gui_cbdisablegraphics, "EventHandler")
GUICtrlSetOnEvent($gui_btstart, "EventHandler")
GUICtrlSetOnEvent($gui_bexit, "EventHandler")
;GUICtrlSetOnEvent($disableRenderingCheckbox, "toggleRendering")
GUISetState(@SW_SHOW)
;GUICtrlSetState($disableRenderingCheckbox, $GUI_DISABLE)

global $botRunning = false
global $botInitialized = false
Global $renderingEnabled = True
global $amDead = false
global $spamTonics = true
global $runs = 0
global $experienceGained = 0
global $deaths = 0
global $runStuckTimer
global const $stuckTimerTreshold = 300000 ;set to time a run takes * 2000
global const $salvage = 0
global const $runes = 8
global const $consumable = 9
global const $dye = 10
global const $material = 11
global const $candyCaneShard = 17
global const $key = 18
global const $gold = 20
global const $shields = 24
global const $kit = 29
global const $trophy = 30
global const $scroll = 31
global const $minipet = 34
global const $blackDye = 10
global const $whiteDye = 12
global const $lockpick = 22751
global const $itemsToKeep[15] = [$lockpick]

while 1
	if $Running then
		GUICtrlSetData($statusLabel, "Running")
		doRun()
		sleep(100)
		if not $Running then
			GUICtrlSetData($statusLabel, "Ready to begin")
			GUICtrlSetState($startButton, $GUI_ENABLE)
			GUICtrlSetData($startButton, "Start")
			_TravelGH()
		endif
	 else
		sleep(100)
	endif
wend
	Func _TravelGH()
		Local $larray_gh[16] = [4, 5, 6, 52, 176, 177, 178, 179, 275, 276, 359, 360, 529, 530, 537, 538]
		Local $lmapid = GetMapID()
		If _arraysearch($larray_gh, $lmapid) <> -1 Then Return
		TravelGH()
	EndFunc
func doRun()
	$file = fileOpen(@ScriptDir & "\log.log", 1)
	_FileWriteLog($file, "Starting run")
	fileClose($file)
	enter()
	prepare()
	kill()
	endRun()
endFunc

func enter()
	if CountEmptySlots() < 2 then
		$amDead = true
		$botRunning = false
		return
	endIf
	if not $renderingEnabled then
		learMemory()
		sleep(2250)
	endIf
	if not $amDead then GUICtrlSetData($statusLabel, "Entering area")
	if not $amDead and GUICtrlRead($randomTravelCheckbox) = $GUI_CHECKED then
		if not $amDead then randomTravel(821)
	else
		if not $amDead then travelTo(821)
	endIf
	if not $amDead and GUICtrlRead($useTonicsCheckbox) = $GUI_CHECKED then
		if not $amDead then useItemByModelId(30648)
		if not $amDead then sleep(500)
	endIf
	if not $amDead then $casey = GetNearestNPCToCoords(-1492.84,3591.53);getAgentByName("Casey Carpenter")
	if not $amDead then goToNPC($casey)
	if not $amDead then dialog(0x83A601)
	if not $amDead then sleep(500)
	if not $amDead then dialog(0x84)
	if not $amDead then waitMapLoadingFast()
endFunc

func prepare()
	if not $amDead then $runStuckTimer = timerInit()
	if not $amDead then GUICtrlSetData($statusLabel, "waiting for fight")
	if not $amDead and GUICtrlRead($useTonicsCheckbox) = $GUI_CHECKED then
		if not $amDead then useItemByModelId(21490)
		if not $amDead then sleep(500)
	endIf
	if not $amDead then commandHero(1, 5011, -603)
	if not $amDead then commandHero(1, 5011, -603)
    if not $amDead then commandHero(1, 5011, -603)
    if not $amDead then commandHero(1, 5011, -603)
    if not $amDead then commandHero(1, 5011, -603)
    if not $amDead then commandHero(1, 5011, -603)
	if not $amDead then useSkill(4, -2)
	if not $amDead then sleep(1750)
	do
		if not $amDead then sleep(100)
		if not $amDead then targetNearestEnemy()
	until $amDead or getCurrentTargetId() <> 0
endFunc

func kill()
	if not $amDead then GUICtrlSetData($statusLabel, "fighting")
	if not $amDead then useHeroSkill(1, 6)
	if not $amDead then sleep(1250)
	if not $amDead then useHeroSkill(1, 7)
	if not $amDead then sleep(3250)

	if not $amDead then local $me = getAgentByID(-2)
	if not $amDead then local $skillbar = getSkillbar()
	if not $amDead then local $playerProfession = DllStructGetData($me, 'primary')
	if not $amDead then local $useYellowSnow = getSkillbarSkillID(5) = 1007

	if not $amDead then adlibregister("checkDead", 1000)
	do
		if not $amDead and canUseSkill(8, 0) and getHealth(-2) < 150 then
			useSkill(8, -2)
		elseIf not $amDead and ($playerProfession = 7 or $playerProfession = 3) and canUseSkill(6, 0) and getHealth(-2) < 300 then
			useSkill(6, -2)
		elseIf not $amDead and $playerProfession = 8 and canUseSkill(6, 0) then
			useSkill(6, -2)
		elseIf not $amDead and canUseSkill(7, 0) and getHealth(-2) < 500 then
			useSkill(7, -2)
		elseIf not $amDead and canUseSkill(4, 0) then
			useSkill(4, -2)
		elseIf not $amDead and $useYellowSnow and canUseSkill(5, 0) then
			useSkill(5, -2)
		elseIf not $amDead and not $useYellowSnow and canUseSkill(5, 0) then
			useSkill(5, -1)
		elseIf not $amDead and canUseSkill(2, 0) then
			useSkill(2, -1)
		elseIf not $amDead and $playerProfession = 2 then
			useSkill(6, -1)
		else
			useSkill(1, -1)
		endIf

		while not $amDead and getIsCasting(-2)
			sleep(50)
		wEnd

		sleep(150)
		$roland = getAgentByName("Roland [Rare Material Trader]")
		$ida = getAgentByName("Ida [Material Trader]")
		if DllStructGetData($roland, "allegiance") = 3 then
			changeTarget($roland)
		elseIf DllStructGetData($ida, "allegiance") = 3 then
			changeTarget($ida)
		else
			targetNearestEnemy()
		endIf
	until $amDead or getNumberOfFoesInRange(5000) = 0
	if not $amDead then GUICtrlSetData($statusLabel, "All dead, waiting 5 seconds for quest to update")
	adlibUnRegister("checkdead")
	if not $amDead then sleep(2250)
endFunc

func endRun()
	if not $amDead then GUICtrlSetData($statusLabel, "getting reward")
	if GUICtrlRead($randomTravelCheckbox) = $GUI_CHECKED then
		if not $amDead then randomTravel(821)
	else
		if not $amDead then travelTo(821)
	endIf
	if GUICtrlRead($useTonicsCheckbox) = $GUI_CHECKED then
		if not $amDead then useItemByModelId(30648)
		if not $amDead then sleep(500)
	endIf
	if not $amDead then $casey = getAgentByName("Casey Carpenter")
	if not $amDead then goToNPC($casey)
	if not $amDead then dialog(0x83A607)
	if not $amDead and getGoldCharacter() > 80000 and getGoldStorage() < 950000 then depositGold(50000)
	if not $amDead then sleep(200)
	if not $amDead then $file = fileOpen(@ScriptDir & "\log.log", 1)
	if not $amDead then _FileWriteLog($file, "Run success")
	if not $amDead then fileClose($file)
	$runs += 1
	GUICtrlSetData($status2Label, "runs: " & $runs & ", fails: " & $deaths)
	$amDead = false
endFunc

;generic stuff

func startButtonClickedHandler()
	if $botRunning then
		GUICtrlSetData($startButton, "Will pause after this run")
		GUICtrlSetState($startButton, $GUI_DISABLE)
		$botRunning = false
	elseIf $BotInitialized then
		GUICtrlSetData($startButton, "Pause")
		$botRunning = true
	else
		GUICtrlSetData($statusLabel, "Initializing")
		if initialize(processExists("gw.exe"), true, true, false) = false then
			msgBox(0, "Error", "Guild Wars is not running.")
			exit
		endIf

		$botRunning = true
		$botInitialized = true
		GUICtrlSetData($startButton, "Pause")
		GUICtrlSetState($disableRenderingCheckbox, $GUI_ENABLE)
	endIf
endFunc

 func getNumberOfFoesInRange($maxDistance = 1050)
	local $count = 0
	local $me = getAgentByID(-2)
	for $i = 1 to getMaxAgents()
		$potentialEnemy = getAgentByID($i)
		if getIsDead($potentialEnemy) <> 0 then continueLoop
		if DllStructGetData($potentialEnemy, 'allegiance') = 0x3 then
			if getDistance($potentialEnemy, $me) < $maxDistance then
				$count += 1
			endIf
		endIf
	next
	return $count
endFunc

func canUseSkill($skillNumber, $energyCost)
	$skillId = getSkillbarSkillID($skillNumber)
	$skill = getSkillByID($skillId)
	$adrenCost = DllStructGetData($skill, 'adrenaline')
	$requiredCombo = DllStructGetData($skill, 'comboReq')
	$effectStruct = getEffect($skillId)
	if not $amDead and DllStructGetData($effectStruct, "skillId") = 0 and getSkillbarSkillRecharge($skillNumber) = 0 and getEnergy() >= $energyCost and GetSkillbarSkillAdrenaline($skillNumber) >= $adrenCost then
		return true
	endIf
	return false
endFunc

func checkDead()
	if getHealth(-2) = 0 or timerDiff($runStuckTimer) > $stuckTimerTreshold then
		$deaths = $deaths + 1
		$amDead = true
		adlibUnRegister("checkDead")
	endIf
	$file = fileOpen(@ScriptDir & "\log.log", 1)
	if getHealth(-2) = 0 then
		GUICtrlSetData($status2Label, "Died")
		_FileWriteLog($file, "Died")
	endIf
	if timerDiff($runStuckTimer) > $stuckTimerTreshold then
		GUICtrlSetData($status2Label, "Stuck, restarting")
		_FileWriteLog($file, "Stuck, restarting")
	endIf
	fileClose($file)
endFunc

func countEmptySlots()
	local $bag
	local $temp = 0
	$bag = getBag(1)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'itemsCount')
	$bag = getBag(2)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'itemsCount')
	$bag = getBag(3)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'itemsCount')
	$bag = getBag(4)
	$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'itemsCount')
	return $temp
endFunc

func randomTravel($mapId)
	local $region
	local $language = 0
	do
		$region = random(1, 4, 1)
		if $region = 2 then
			$language = random(0, 7, 1)
			if $language = 6 or $language = 7 then
				$language = random(9, 10, 1)
			endIf
		endIf
	until $region <> getRegion() and $language <> getLanguage()
	if moveMap($mapId, $region, 0, $language) then
		return waitMapLoadingFast()
	endIf
EndFunc

func waitMapLoadingFast()
	local $mapLoading
	local $deadLock = timerInit()
	initMapLoad()
	do
		sleep(100)
		$mapLoading = getMapLoading()
		if $mapLoading == 2 then $deadLock = timerInit()
		if timerDiff($deadLock) > 15000 then return false
	until $mapLoading <> 2 and getMapIsLoaded()
	rndSleep(500)
	return true
endFunc

func toggleRendering()
	$renderingEnabled = not $renderingEnabled
	if $renderingEnabled then
		enableRendering()
		winSetState(getWindowHandle(), "", @SW_SHOW)
	else
		disableRendering()
		winSetState(getWindowHandle(), "", @SW_HIDE)
		clearMemory()
	endIf
endFunc

func useItemByModelId($modelId)
	local $item = getItemByModelID($modelId)
	if DllStructGetData($item, 'bag') <> 0 then
		useItem($item)
		return true
	endIf
	return false
endFunc

func closeWindowHandler()
	exit
endFunc

	Func EventHandler()
		Switch @GUI_CtrlId
			Case $gui_event_close
		;		If Not $Rendering Then ToggleRendering()
				Exit
			Case $gui_bexit
		;		If Not $Rendering Then ToggleRendering()
				Exit
			Case $gui_btstart
				If $running Then
					GUICtrlSetData($gui_btstart, "Resume")
					$running = False
				ElseIf $initialized Then
					GUICtrlSetData($gui_btstart, "Pause")
					$running = True
				Else
					$running = True
					GUICtrlSetData($gui_btstart, "Initializing...")
					GUICtrlSetState($gui_btstart, $gui_disable)
					GUICtrlSetState($gui_txtname, $gui_disable)
					WinSetTitle($maingui, "", GUICtrlRead($gui_txtname))
					TraySetToolTip(GUICtrlRead($gui_txtname))
					If GUICtrlRead($gui_txtname) = "" Then
						If Initialize(ProcessExists("gw.exe"), True, True, False) = False Then
							MsgBox(0, "Error", "Guild Wars it not running.")
							Exit
						EndIf
					Else
						If Initialize(GUICtrlRead($gui_txtname), True, True, False) = False Then
							MsgBox(0, "Error", "Can't find a Guild Wars client with that character name.")
							Exit
						EndIf
					EndIf
					GUICtrlSetData($gui_btstart, "Pause")
					GUICtrlSetState($gui_btstart, $gui_enable)
					$initialized = True
				EndIf
			Case $gui_cbdisablegraphics
				ToggleRendering()
		EndSwitch
	EndFunc