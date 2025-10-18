
#NoTrayIcon
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiEdit.au3>
#include "include/GWA2.au3"
#include "include/Halloween/Constants.au3"

Opt("MustDeclareVars", True) 	; have to declare variables with either Local or Global.
Opt("GUIOnEventMode", True)		; enable gui on event mode

Global Const $SkillBarTemplate = "OwNS44PTTQIQrg2k4OYhxkoE"
Global Const $Dash = 1
Global Const $HoS = 2
Global Const $ShadowSanctuary = 3
Global Const $YMLaD = 4
Global Const $DeathsCharge = 5
Global Const $smokepowderdefense = 6
Global Const $FinishHim = 7
Global Const $BaneSignet = 8

Global Const $MainGui = GUICreate("Skelefarm - Leader", 172, 190)
	GUICtrlCreateLabel("Skelefarm - Leader", 8, 6, 156, 17, $SS_CENTER)
	Global Const $inputCharName = GUICtrlCreateCombo("", 8, 24, 150, 22)
		GUICtrlSetData(-1, GetLoggedCharNames())
	Global Const $cbxHideGW = GUICtrlCreateCheckbox("Disable Graphics", 8, 48)
	Global Const $cbxOnTop = GUICtrlCreateCheckbox("Always On Top", 8, 68)
	GUICtrlCreateLabel("Runs:", 8, 92)
	Global Const $lblRunsCount = GUICtrlCreateLabel(0, 80, 92, 30)
	GUICtrlCreateLabel("Fails:", 8, 112)
	Global Const $lblFailsCount = GUICtrlCreateLabel(0, 80, 112, 30)
	Global Const $lblLog = GUICtrlCreateLabel("", 8, 130, 154, 30)
	Global Const $btnStart = GUICtrlCreateButton("Start", 8, 162, 154, 25)

GUICtrlSetOnEvent($cbxOnTop, "EventHandler")
GUICtrlSetOnEvent($cbxHideGW, "EventHandler")
GUICtrlSetOnEvent($btnStart, "EventHandler")
GUISetOnEvent($GUI_EVENT_CLOSE, "EventHandler")
GUISetState(@SW_SHOW)

#include "Shared.au3"

Out("Ready")

Do
	Sleep(100)
Until $boolInitialized

MapCheck()
Out("Loading bar")


While 1
	If $boolRunning Then
		Main()
	Else
		Out("Bot Paused")
		GUICtrlSetState($btnStart, $GUI_ENABLE)
		GUICtrlSetData($btnStart, "Start")
		While Not $boolRunning
			Sleep(100)
		WEnd
	EndIf
WEnd

Func Main()
	If Not GoldCheck() Then Return

	Out("Moving to grenth's statue")
	MoveTo(-4170, 19759)

	; TODO: check for being stuck

	Local $Avatar
	$Avatar = GetNearestNPCToCoords(-4124, 19829)	; try to get the avatar, might be there already.
	If DllStructGetData($Avatar, "PlayerNumber") <> $MODELID_AVATAR_OF_GRENTH Then		; nope avatar is not there, spawn him.
		Out("Spawning grenth")
		SendChat("kneel", "/")
		Local $lDeadlock = TimerInit()
		Local $lFailPops = 0
		Do
			Sleep(1500)	; wait until grenths is up.
			$Avatar = GetNearestNPCToCoords(-4124, 19829)

			If TimerDiff($lDeadlock) > 5000 Then
				MoveTo(-4170, 19759)
				SendChat("kneel", "/")
				$lDeadlock = TimerInit()
				$lFailPops += 1
			EndIf

			If $lFailPops >= 3 Then
				; probably I am stuck by an NPC somewhere in ToA.
				; As far as i know there is only 1 spot where i can get stuck (behind the tree, stuck on the patrolling NPC), so move away from there.

				MoveTo(-3470, 18550)
				MoveTo(-4170, 19759)
				$lFailPops = 0
			EndIf

		Until DllStructGetData($Avatar, "PlayerNumber") == $MODELID_AVATAR_OF_GRENTH ; TODO: make a deadlock check
	EndIf
    Local $lDeadlock2 = TimerInit()
	Do
    If TimerDiff($lDeadlock2) > 5000 Then
	  Out("Stuck !")
	  ;If DllStructGetData(GetAgentByID(-2), "PlayerNumber") == 1 Then Rndtravel($TOA_ID)
	  ;Out("Change district")
	  MoveTo(-3385,18411)
	  ;waitmaploading($town)
	  ;Return false
    EndIf

	Out("Talking to the avatar of grenth")
	GoNpc($Avatar)
    Sleep(700);500;wait till he spawns
	Dialog(0x85) ; "yes, to the service of grenth"
	Sleep(500);300
	DIALOG(0x86) ; "accept"

	Out("Waiting for uw to load")
	 ; Do ; // EDIT
	  WaitMapLoading($UW_ID)
     Until GetMapID() == $UW_ID Or (TimerDiff($lDeadlock2) > 15000)
     If GetMapID() <> $UW_ID Then Return
	  ;If GetMapID() == $TOA_ID Then Return ; dialogs to enter uw failed. restart.

	  ;If GetMapID() == $UW_ID Then SkeleBoom()
    SkeleBoom()

	  Do
		WaitMapLoading($TOA_ID)
    Until GetMapID() == $TOA_ID
	UpdateStatistics()
EndFunc   ;==>Main

Func GoldCheck()
	Local $lGold = GetGoldCharacter()
	If $lGold < 1000 Then
		If GetGoldStorage() < 20000 Then
			Out("Ran out of gold")
			$boolRunning = False
			Return False
		EndIf
		Out("Withdrawing gold from chest")
		WithdrawGold(20000)
	EndIf
	Return True
EndFunc

Func SkeleBoom()
	Local $lSkeleID = GetSkeleID()

	; spike it.
	ChangeTarget($lSkeleID)
	Out("Pulling Skeleton...")
	UseSkill($Dash, -2)
	UseSkill($HoS, $lSkeleID)
	Do
		Sleep(300)
	Until GetSkillbarSkillRecharge($HoS) > 0
	UseSkill($ShadowSanctuary, -2)
	Sleep(750)
	Out("Spiking...")
	UseSkill($smokepowderdefense, -2)
	Sleep(100)
	UseSkill($DeathsCharge, $lSkeleID, True)
	Do
		Sleep(150)
	Until GetSkillbarSkillRecharge($DeathsCharge) > 0
	UseSkill($YMLaD, $lSkeleID)
	Sleep(100)
 	UseSkill($BaneSignet, $lSkeleID)
	Do
		Sleep(200)
	Until DllStructGetData(GetAgentByID($lSkeleID), 'HP') < .5 Or GetIsDead(-2) Or GetIsDead($lSkeleID)
	UseSkill($FinishHim, $lSkeleID)
	Do
		Sleep(200)
	Until GetIsDead($lSkeleID) Or GetIsDead(-2)

	If Not GetIsDead(-2) Then
		Out("Harvesting Skeleton Soul")
		UseItem(GetItemByModelID($MODEL_ID_MOBSTOPPER))
		Out("Checking for Ectos and shinies.")
		PickUpLoot()
	Else
		$fails += 1
	EndIf

	Out("Run over, resigning")
	Resign()

	WaitForPartyWipe()

    Sleep(2000)

	Out("Returning to ToA")
	If DllStructGetData(GetAgentByID(-2), "PlayerNumber") == 1 Then ReturnToOutpost()
EndFunc   ;==>SkeleBoom

Func RndTravel($aMapID)
   	Local $UseDistricts = 11 ; 7=eu-only, 8=eu+int, 11=all(excluding America)
	; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, us-en, int, asia-ko, asia-ch, asia-ja
	Local $Region[11] = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
	Local $Language[11] = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]
	Local $Random = Random(0, $UseDistricts - 1, 1)
	MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
	waitmaploading($amapid)
EndFunc   ;==>RndTravel