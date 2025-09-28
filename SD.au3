#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.12.0
	Author:         4D1

	Script Function:
	SNOW FUCKING BALLS

#ce ----------------------------------------------------------------------------
#include "GWA2_Headers.au3"

#include "gwApi.au3"
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>



; Constant Globals/Data
Global Const $PLAYERNUM_Casey_Carpenter = 6034

Global Const $DIALOGID_Snowball_Dominance_Take = 0x83A601
Global Const $DIALOGID_Snowball_Dominance_Reward = 0x83A607
Global Const $DIALOGID_Snowball_Dominance_Enter = 0x84
Global Const $QUESTID_Snowball_Dominance = 0x3A6

Global Const $MAPID_EOTN_Wintersday = 821
Global Const $MAPID_EOTN_Snowballs = 793

Global Const $Hero_Flag_Coords[2] = [5011.7, -603.2]

;Globalz
Global $totalRuns = 0
Global $failedRuns = 0
Global $bRun = False
Global $RenderingEnabled = True

;; Init
TraySetIcon('icon.ico')

Opt("GUIOnEventMode", 1)

Global $g_fMain = GUICreate("Snowball Dominance", 450, 175, 192, 124)
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

Global $Console = GUICtrlCreateEdit("Ready to Start", 150, 8, 280, 153, BitOR(0x0040, 0x00200000, 0x00800000, 0x0800))
	GUICtrlSetFont($console, 9, 400, 0, "Arial")
	GUICtrlSetColor($console, 0x000000)
	GUICtrlSetBkColor($console, 0xFFFFFF)
	GUICtrlSetCursor($console, 5)

Func Out($text)
	Local $textlen = StringLen($text)
	Local $consolelen = _GUICtrlEdit_GetTextLen($console)
	If $textlen + $consolelen > 30000 Then GUICtrlSetData($console, StringRight(_GUICtrlEdit_GetText($console), 30000-$textlen-1000))
	_GUICtrlEdit_AppendText($console, @CRLF&"["&@HOUR&":"&@MIN&":"&@SEC&"] "&$text)
	_GUICtrlEdit_Scroll ($console, 1) ;1=$SB_LINEDOWN
EndFunc

GUISetIcon('icon.ico')

GUICtrlSetOnEvent($g_cbRendering, 'ToggleRendering')
GUICtrlSetOnEvent($g_bRun, 'ToggleBot')
GUISetOnEvent(-3, '_exit')

GUISetState(1)

Func GetNearestNPCToCoords($aX, $aY)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray(0xDB)

	For $i = 1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], 'Allegiance') <> 6 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop

		$lDistance = ($aX - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + ($aY - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2

		If $lDistance < $lNearestDistance Then
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
 EndFunc   ;==>GetNearestNPCToCoords
 Func GetAgentArray($aType = 0)
	Local $lStruct
	Local $lCount
	Local $lBuffer = ''
	DllStructSetData($mMakeAgentArray, 2, $aType)
	MemoryWrite($mAgentCopyCount, -1, 'long')
	Enqueue($mMakeAgentArrayPtr, 8)
	Local $lDeadlock = TimerInit()
	Do
		Sleep(1)
		$lCount = MemoryRead($mAgentCopyCount, 'long')
	Until $lCount >= 0 Or TimerDiff($lDeadlock) > 5000
	If $lCount < 0 Then $lCount = 0
	For $i = 1 To $lCount
		$lBuffer &= 'Byte[448];'
	Next
	$lBuffer = DllStructCreate($lBuffer)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $mAgentCopyBase, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
	Local $lReturnArray[$lCount + 1] = [$lCount]
	For $i = 1 To $lCount
		$lReturnArray[$i] = DllStructCreate('ptr vtable;byte unknown1[24];byte unknown2[4];ptr NextAgent;byte unknown3[8];long Id;float Z;byte unknown4[8];float BoxHoverWidth;float BoxHoverHeight;byte unknown5[8];float Rotation;byte unknown6[8];long NameProperties;byte unknown7[24];float X;float Y;byte unknown8[8];float NameTagX;float NameTagY;float NameTagZ;byte unknown9[12];long Type;float MoveX;float MoveY;byte unknown10[28];long Owner;byte unknown30[8];long ExtraType;byte unknown11[24];float AttackSpeed;float AttackSpeedModifier;word PlayerNumber;byte unknown12[6];ptr Equip;byte unknown13[10];byte Primary;byte Secondary;byte Level;byte Team;byte unknown14[6];float EnergyPips;byte unknown[4];float EnergyPercent;long MaxEnergy;byte unknown15[4];float HPPips;byte unknown16[4];float HP;long MaxHP;long Effects;byte unknown17[4];byte Hex;byte unknown18[18];long ModelState;long TypeMap;byte unknown19[16];long InSpiritRange;byte unknown20[16];long LoginNumber;float ModelMode;byte unknown21[4];long ModelAnimation;byte unknown22[32];byte LastStrike;byte Allegiance;word WeaponType;word Skill;byte unknown23[4];word WeaponItemId;word OffhandItemId')
		$lStruct = DllStructCreate('byte[448]', DllStructGetPtr($lReturnArray[$i]))
		DllStructSetData($lStruct, 1, DllStructGetData($lBuffer, $i))
	Next
	Return $lReturnArray
 EndFunc   ;==>GetAgentArray


;=======================================================================


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


;~ Description: get agent ptr and coords of foes in range, [foe1, x1, y1, ...]
Func GetFoesPositionInRangeOfAgent($aAgent = GetAgentPtr(-2), $aMaxDistance = 4000, $ModelID = 0)
	Dim $lFoes[0]
	If IsPtr($aAgent) <> 0 Then
		Local $lAgentPtr = $aAgent
	ElseIf IsDllStruct($aAgent) <> 0 Then
		Local $lAgentPtr = GetAgentPtr(DllStructGetData($aAgent, 'ID'))
	Else
		Local $lAgentPtr = GetAgentPtr($aAgent)
	EndIf
	Local $lDistance, $lCount = 0
	Local $lTargetTypeArray = MemoryReadAgentPtrStruct(3)
	For $i = 1 To $lTargetTypeArray[0]
		If $ModelID <> 0 And MemoryRead($lTargetTypeArray[$i] + 244, 'word') <> $ModelID Then ContinueLoop
		$lDistance = GetDistance($lTargetTypeArray[$i], $lAgentPtr)
		If $lDistance < $aMaxDistance Then
			$lCount += 1
			Local $lEl = [$lTargetTypeArray[$i], XLocation($lTargetTypeArray[$i]), YLocation($lTargetTypeArray[$i])]
			_ArrayAdd($lFoes, $lEl)
		EndIf
	Next
	Return $lFoes
EndFunc   ;==>GetNumberOfFoesInRangeOfAgent

;~ Return agent ptr of the foe to target
Func ChooseTarget()
	Local $lFoes = GetFoesPositionInRangeOfAgent(GetAgentPtr(-2), 4000)
	Local $lAdjacentDistance = 148.0
	Local $lTargetCandidate
	Local $lTargetPtr = -1
	Local $lTargetAdjFoes = -1

	Local $lAdjacentFoes
	Local $lDistance

	Local $li = 0, $lj = 0
	Local $lFoesSize = UBound($lFoes)
	While $li < $lFoesSize
		$lTargetCandidate = $lFoes[$li]
		$lAdjacentFoes = 0

		$lj = 0
		While $lj < $lFoesSize
			If $li <> $lj Then
				$lDistance = ($lFoes[$li + 1] - $lFoes[$lj + 1])^2
				$lDistance = $lDistance + ($lFoes[$li + 2] - $lFoes[$lj + 2])^2
				$lDistance = Sqrt($lDistance)

				If $lDistance <= $lAdjacentDistance Then
					$lAdjacentFoes += 1
				EndIf
			EndIf
			$lj += 3
		WEnd

		If $lAdjacentFoes > $lTargetAdjFoes Then
			$lTargetPtr = $lTargetCandidate
			$lTargetAdjFoes = $lAdjacentFoes

			If $lTargetAdjFoes >= 4 Then
				ExitLoop
			EndIf
		EndIf

		$li += 3
	WEnd

	Return $lTargetPtr
EndFunc

Func main()
	Out("Run " & $totalRuns + 1)
	GUICtrlSetData($g_numTotal, $totalRuns)
	GUICtrlSetData($g_numFail, $failedRuns)

	RandomTravel($MAPID_EOTN_Wintersday)

	Local $lCasey = GetNearestNPCToCoords(-1490, 3511)
	GoToNPC($lCasey)

	Dialog($DIALOGID_Snowball_Dominance_Take)
	RndSleep(500)
	Dialog($DIALOGID_Snowball_Dominance_Enter)

	WaitMapLoading($MAPID_EOTN_Snowballs, 20000)

	; Caution : agent ptr can change after map loading
	Local $lMe = GetAgentPtr(-2)
	Local $lSkillbar = GetSkillbarPtr()
	Local $lHeroID = GetHeroID(1)
	Local $lHero = GetAgentPtr($lHeroID)
	Local $lPlayerProf = MemoryRead($lMe + 266, 'byte')

	Local $lHeroMaxHP = GetHealth($lHero)
	Local $lHeroHealth = GetHealth($lHero)

	Local $targets

	Out("Preparing to fight")
	CommandHero(1, $Hero_Flag_Coords[0], $Hero_Flag_Coords[1])

 	MoveTo(4085, -1670)
	UseSkill(4, -2)
	Sleep(2250)

	Do
		Sleep(100)
		TargetNearestEnemy()
	Until GetCurrentTargetId() <> 0

	Out("Using hero")
	UseHeroSkill(1, 6)
	Sleep(1250)
	UseHeroSkill(1, 7)
	Sleep(1250)

	While (not GetIsDead($lHero))
		$lHeroHealth = GetHealth($lHero)
 		If $lHeroHealth <= $lHeroMaxHP - 300 Then
			UseHeroSkill(1, 8)
		Else
			UseHeroSkill(1, 1)
		EndIf
		Sleep(125)
	WEnd

	SetEvent('', '', 'ProDodge')

	Out("Dominating em")
	Do
		; Snowcone
		If CanUseSkillbarSkill(8) And MemoryRead($lMe + 304, 'float') < .3 Then
			UseSkill(8, -2)
		; Ice Fort
		ElseIf CanUseSkillbarSkill(7) And MemoryRead($lMe + 304, 'float') < 1 Then
			UseSkill(7, -2)
		ElseIf CanUseSkillbarSkill(2) Then
			UseSkill(2, -1)
		Else
			UseSkill(6, ChooseTarget())
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

	$lCasey = GetNearestNPCToCoords(-1490, 3511)
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