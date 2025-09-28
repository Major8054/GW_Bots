#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.12.0
	Author:         4D1

	Script Function:
	SNOW FUCKING BALLS

#ce ----------------------------------------------------------------------------
#include "GWA2_Headers.au3"

#include "gwApi.au3"



; Constant Globals/Data
Global Const $PLAYERNUM_Casey_Carpenter = 6034

Global Const $DIALOGID_Snowball_Dominance_Take = 0x83A601
Global Const $DIALOGID_Snowball_Dominance_Reward = 0x83A607
Global Const $DIALOGID_Snowball_Dominance_Enter = 0x84
Global Const $QUESTID_Snowball_Dominance = 0x3A6

Global Const $SKILLID_Yellow_Snow = 1007
Global Const $SKILLID_Hidden_Rock = 1008
Global Const $SKILLID_Snowball = 1002
Global Const $SKILLID_Mega_Snowball = 1003
Global Const $SKILLID_Ice_Fort = 1006

Global Const $MAPID_EOTN_Wintersday = 821
Global Const $MAPID_EOTN_Snowballs = 793

Global Const $Hero_Flag_Coords[2] = [5011.7041015625, -603.1650390625]

;Globalz
Global $totalRuns = 0
Global $failedRuns = 0
Global $bRun = False

;; Init
TraySetIcon('icon.ico')

Opt("GUIOnEventMode", 1)

Global $g_fMain = GUICreate("Snowball Dominance", 151, 170, 192, 124)
Global $g_gSetup = GUICtrlCreateGroup("Setup", 8, 6, 135, 69)
Global $g_cName = GUICtrlCreateCombo("", 16, 25, 118, 25, 3)
SetClientNames($g_cName)
Global $g_cbRendering = GUICtrlCreateCheckbox("Rendering", 16, 52, 97, 17)
Global $g_gRuns = GUICtrlCreateGroup("Runs", 8, 80, 135, 53)
Global $g_lblTotal = GUICtrlCreateLabel("Total:", 20, 94, 31, 17)
Global $g_lblFail = GUICtrlCreateLabel("Failed:", 20, 111, 35, 17)
Global $g_numTotal = GUICtrlCreateLabel("-", 69, 91, 67, 17, 1)
Global $g_numFail = GUICtrlCreateLabel("-", 69, 109, 67, 17, 1)
Global $g_bRun = GUICtrlCreateButton("Run Bot", 10, 136, 131, 25)

GUISetIcon('icon.ico')

GUICtrlSetOnEvent($g_cbRendering, 'ToggleRendering')
GUICtrlSetOnEvent($g_bRun, 'ToggleBot')
GUISetOnEvent(-3, '_exit')

GUISetState(1)

Do
	Sleep(100)
Until $bRun

GUICtrlSetState($g_cName, 128)
GUICtrlSetState($g_bRun, 128)

Initialize(GUICtrlRead($g_cName))

GUISetOnEvent(-3, '_exit_')
OnAutoItExitRegister("_exit_")

While 1
	main()
WEnd

Func main()

	GUICtrlSetData($g_numTotal, $totalRuns)
	GUICtrlSetData($g_numFail, $failedRuns)

	RandomTravel($MAPID_EOTN_Wintersday)

	Local $lCasey = GetAgentIdByPlayerNumber($PLAYERNUM_Casey_Carpenter)
	GoToNPC($lCasey)

	Dialog($DIALOGID_Snowball_Dominance_Take)
	RndSleep(500)
	Dialog($DIALOGID_Snowball_Dominance_Enter)

	WaitMapLoading($MAPID_EOTN_Snowballs, 20000)

	CommandHero(1, $Hero_Flag_Coords[0], $Hero_Flag_Coords[1])

	UseSkill(4, -2)
	Sleep(2250)

	Do
		Sleep(100)
		TargetNearestEnemy()
	Until GetCurrentTargetId() <> 0

	UseHeroSkill(1, 6)
	Sleep(1250)
	UseHeroSkill(1, 7)
	RndSleep(3250)
	UseHeroSkill(1, 8)

	Local $lMe = GetAgentPtr(-2)
	Local $lSkillbar = GetSkillbarPtr()
	Local $lHero = GetHeroID(1)
	Local $lHeroPtr = GetAgentPtr($lHero)
	Local $lPlayerProf = MemoryRead($lMe + 266, 'byte')
	Local $lUseYellowSnow = (MemoryRead($lSkillbar + 96, 'dword') = $SKILLID_Yellow_Snow)

	SetEvent('', '', 'ProDodge')

	Do
		If CanUseSkillbarSkill(8) And MemoryRead($lMe + 304, 'float') < .3 Then
			UseSkill(8, -2)
		ElseIf ($lPlayerProf = 7 Or $lPlayerProf = 3) And CanUseSkillbarSkill(6) And MemoryRead($lMe + 304, 'float') < .6 Then
			UseSkill(6, -2)
		ElseIf $lPlayerProf = 8 And CanUseSkillbarSkill(6) Then
			UseSkill(6, -2)
		ElseIf CanUseSkillbarSkill(7) And MemoryRead($lMe + 304, 'float') < 1 Then
			UseSkill(7, -2)
		ElseIf CanUseSkillbarSkill(4) And Not HasEffect($SKILLID_Hidden_Rock) Then
			UseSkill(4, -2)
		ElseIf $lUseYellowSnow And CanUseSkillbarSkill(5) And Not HasEffect($SKILLID_Yellow_Snow) Then
			UseSkill(5, -2)
		ElseIf Not $lUseYellowSnow And CanUseSkillbarSkill(5) Then
			UseSkill(5, -1)
		ElseIf CanUseSkillbarSkill(2) Then
			UseSkill(2, -1)
		ElseIf $lPlayerProf = 2 Then
			UseSkill(6, -1)
		Else
			UseSkill(1, -1)
		EndIf

		While MemoryRead($lSkillbar + 176) <> 0
			Sleep(125)
		WEnd

		If GetIsDead($lMe) Then
			$failedRuns += 1
			RndSleep(1750)
			ReturnToOutpost()
			ExitLoop
		EndIf
		Sleep(150)
		TargetNearestEnemy()
	Until GetNumberOfFoesInRangeOfAgent(-2, 5000) = 0

	SetEvent('', '', '')
	Sleep(2250)

	RandomTravel($MAPID_EOTN_Wintersday)

	$lCasey = GetAgentIdByPlayerNumber($PLAYERNUM_Casey_Carpenter)
	GoToNPC($lCasey)

	Dialog($DIALOGID_Snowball_Dominance_Reward)

	$totalRuns += 1
EndFunc   ;==>main

Func SetClientNames($aCombo)
	Local $lGWList = WinList("[CLASS:ArenaNet_Dx_Window_Class; REGEXPTITLE:^\D+$]")
	Local $lFirstChar
	Local $lStr = ''
	For $i = 1 To $lGWList[0][0]
		MemoryOpen(WinGetProcess($lGWList[$i][1]))
		$lStr &= ScanForCharname()
		If $i = 1 Then $lFirstChar = GetCharname()
		MemoryClose()
		If $i <> $lGWList[0][0] Then $lStr &= '|'
	Next
	Return GUICtrlSetData($aCombo, $lStr, $lFirstChar)
EndFunc   ;==>SetClientNames

Func ToggleBot()
	$bRun = Not $bRun
EndFunc   ;==>ToggleBot


Func ProDodge($aCaster, $aTarget, $aSkill)
	If $aTarget = GetMyId() And $aCaster <> GetMyId() Then
		If $aSkill = $SKILLID_Snowball Or $aSkill = $SKILLID_Mega_Snowball Then
			If Not HasEffect($SKILLID_Ice_Fort) Then
				Local $lX, $lY, $lAngle = Random(0, 3.1415926 * 2)
				UpdateAgentPosByPtr(GetAgentPtr(-2), $lX, $lY)
				MoveTo($lX + 300 * Cos($lAngle), $lY + 300 * Sin($lAngle))
			EndIf
		EndIf
	EndIf
EndFunc   ;==>ProDodge


Func RandomTravel($aMapID)
	Local $aRegion
	Local $aLang = 0

	Do
		$aRegion = Random(1, 4, 1)
		If $aRegion = 2 Then
			$aLang = Random(0, 7, 1)
			If $aLang = 6 Or $aLang = 7 Then
				$aLang = Random(9, 10, 1)
			EndIf
		EndIf
	Until $aRegion <> GetRegion() And $aLang <> GetLanguage()

	If MoveMap($aMapID, $aRegion, 0, $aLang) Then
		Return WaitMapLoading($aMapID)
	EndIf
EndFunc   ;==>RandomTravel

;Get skill energy cost of specified skill. No giant struct attached.
Func GetSkillEnergyCost(Const $aSkillID)
	Local $lSkillCost = MemoryRead(($mSkillBase + 160 * $aSkillID) + 53, 'byte')
	Switch $lSkillCost
		Case 11
			$lSkillCost = 15
		Case 12
			$lSkillCost = 25
	EndSwitch
	Return $lSkillCost
EndFunc   ;==>GetSkillEnergyCost

;Get adrenaline requirement of specified skill. No giant struct attached.
Func GetSkillAdrenalineReq(Const $aSkillID)
	Return MemoryRead(($mSkillBase + 160 * $aSkillID) + 56, 'dword')
EndFunc   ;==>GetSkillAdrenalineReq

; Check if a skillbar number is ready to be used.
Func CanUseSkillbarSkill(Const $aSkillNum, $aSkillbarPtr = GetSkillbarPtr(), $aPlayerPtr = GetAgentPtr(-2))
	Local $lSkillId = MemoryRead($aSkillbarPtr + 16 + (20 * ($aSkillNum - 1)), 'dword')
	Local $lEnergy = GetSkillEnergyCost($lSkillId)

	If MemoryRead($aSkillbarPtr + 12 + (20 * ($aSkillNum - 1)), 'dword') <> 0 Then Return False
	If $lEnergy > (MemoryRead($aPlayerPtr + 284, 'float') * MemoryRead($aPlayerPtr + 288, 'long')) Then Return False
	If GetSkillAdrenalineReq($lSkillId) > MemoryRead($aSkillbarPtr + 8 + (20 * ($aSkillNum - 1)), 'long') Then Return False
	Return True
EndFunc   ;==>CanUseSkillbarSkill

Func GetAgentIdByPlayerNumber(Const $aPlayerNumber)
	Local $lPlayerNumber, $lAgPtr, $lMaxAgents = GetMaxAgents()

	For $i = 1 To $lMaxAgents
		$lAgPtr = GetAgentPtr($i)
		If $lAgPtr = 0 Then ContinueLoop
		$lPlayerNumber = MemoryRead($lAgPtr + 244, 'word')
		If $lPlayerNumber = $aPlayerNumber Then Return $i
	Next

	Return -1
EndFunc   ;==>GetAgentIdByPlayerNumber

Func _exit()
	Exit
EndFunc   ;==>_exit

Func _exit_()
	WriteBinary('558BEC8B41', GetLabelInfo('DialogLogStart'))
	Exit
EndFunc   ;==>_exit_