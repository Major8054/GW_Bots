#include "GWA2.au3"
#include "Dependency.au3"
;#include <GUIConstantsEx.au3>
;#include <ComboConstants.au3>
#include <GuiEdit.au3>
#include <Array.au3>


; vers ligne 590 : modification
;retrait salvage car marche pas


;;;; problems fixed ;;;;

; * do not work :
;TargetNearestAlly()

; * need test :
;Resign

; * functions in Dependency.au3 :
;GetSkillPtr()
;MemoryReadAgentPtrStruct()
;GetBagPtr()
;GetItemPtr()
;GetNumberOfFoesInRangeOfAgent (MemoryReadAgentPtrStruct...)
;CountSlots(GetBagPtr...)
;GetItemPtrByAgentID(GetItemPtr...)
;UpdateAgentPosByPtr(MemoryReadStruct())
;PickUpItems(Move_())
;GetPlayerPtrByPlayerNumber(MemoryReadAgentPtrStruct...)
;GetMerchant()
;GetItemPtrBySlot(GetBagPtr...)
;GetIsUnided(GetItemPtr...)
;CountSlotsChest(GetBagPtr...)
;SendSafePacket()
;Prepare()
; ??????????
;OpenStorageSlot()
;;;;;;;;;;;;;;;;;;

; UI const
Global Const $ss_center = 1
Global Const $cbs_dropdown = 2
Global Const $cbs_autohscroll = 64
Global $mfirstchar = ""
Global Const $bs_vcenter = 3072
Global Const $gui_event_close = -3
Global Const $gui_disable = 128
Global Const $gui_enable = 64

Global Const $rarity_white = 2621
Global Const $rarity_blue = 2623
Global Const $rarity_purple = 2626
Global Const $rarity_gold = 2624
Global Const $rarity_green = 2627

Local $Rendering = True

#Region Configuration
	Local Const $version = " v.2019-08-30"
	Local Const $pickupAll = True
#EndRegion
#Region Build
	Local Const $skillbartemplate_player = "OgcTcZ885RgNB1ZHQWZoT48cAA"
	Global Const $skill_return = [1, 15, 770]
	Local Const $skill_serpent = [2, 5, 456]
	Local Const $skill_shadowform = [3, 5, 826]
	Local Const $skill_shroud = [4, 10, 1031]
	Local Const $skill_storm = [5, 5, 1474]
	Local Const $skill_soh = [6, 5, 929]
	Local Const $skill_whirling = [7, 10, 450]
	Local Const $skill_winnowing = [8, 5, 463]
#EndRegion
#Region Variables
	;Global $xs_n
	;Local $dyetosell
	Local $nbRuns = 0
	Local $nbFails = 0
	Local $running = False
	Local $initialized = False
	Local $resignReady = False
#EndRegion
#Region Constants
	Local Const $mapid_anjeka = 349
	Local Const $mapid_drazach = 195
	Local Const $modeid_breambelrecurve = 934
	Local Const $modeid_breambellong = 868
	Local Const $modeid_breambelshort = 957
	Local Const $modeid_breambelflat = 904
	Local Const $modeid_breambelhorn = 906
	Local Const $modelid_echovald = 945
	Local Const $modelid_gothic = 951
	Local Const $modelid_amber = 940
	Local Const $modelid_ornate = 954
	Local Const $modelid_dragonmoss = 3718
	Local Const $modelid_dragonroots = 819
#EndRegion
Global Const $range_adjacent = 156
Global $myptr
#Region GUI
	Opt("GUIOnEventMode", 1)
	Local Const $maingui = GUICreate("Dragon Moss" & $version, 309, 175)
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
	Local Const $gui_stfailruns = GUICtrlCreateLabel("0", 90, 120, 49, 17, $ss_center)
	Local Const $gui_btstart = GUICtrlCreateButton("Start", 4, 145, 67, 25, $bs_vcenter)
	Local Const $gui_bexit = GUICtrlCreateButton("Exit", 74, 145, 67, 25, $bs_vcenter)
	GUISetOnEvent($gui_event_close, "EventHandler")
	GUICtrlSetOnEvent($gui_cbdisablegraphics, "EventHandler")
	GUICtrlSetOnEvent($gui_btstart, "EventHandler")
	GUICtrlSetOnEvent($gui_bexit, "EventHandler")
	TraySetIcon("icon.ico")
	GUISetIcon("icon.ico")
	GUISetState(@SW_SHOW)
#EndRegion

#Region Loops
	Do
		Sleep(100)
	Until $initialized
	;initpacket()
	While 1
		If $running Then
			ManageInventory()
			If GetMapID() <> $mapid_anjeka Then
				TravelTo($mapid_anjeka)
				out("travelto")
				;SwitchMode(1)
				$resignReady = False
			EndIf
			If Not $resignReady Then
			   SwitchMode(1)
			   ;GetResignReady() ; no need because resign is not working
			   $resignReady = True
			EndIf
			If DoJob() Then
			    out("dojob()")
				$nbRuns += 1
				GUICtrlSetData($gui_stsuccruns, $nbRuns)
			Else
				$nbFails += 1
				GUICtrlSetData($gui_stfailruns, $nbFails)
			EndIf
			If Not $running Then _TravelGH()
			; If Mod($nbRuns, 20) = 0 AND Not $Rendering Then _purgehook()
		EndIf
		Sleep(250)
	WEnd

	Func EventHandler()
		Switch @GUI_CtrlId
			Case $gui_event_close
				If Not $Rendering Then ToggleRendering2()
				Exit
			Case $gui_bexit
				If Not $Rendering Then ToggleRendering2()
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
				ToggleRendering2()
		EndSwitch
	EndFunc

#EndRegion

Func GetResignReady()
	LoadSkillTemplate("OgcTcZ885RgNB1ZHQWZoT48cAA")
	Out("Preparing resign")
	Move(-11209, -23100)
	WaitMapLoading($mapid_drazach, 45000)
	Move(-11229, 20150)
	WaitMapLoading($mapid_anjeka, 45000)
	SwitchMode(1)
	$resignReady = True
EndFunc

Func DoJob()
	Local $ldeadlock
	Local $lReturnTarget
	Out("Going outside")
	Move(-11209, -23100)
	Out("move")
	WaitMapLoading($mapid_drazach)
	Out("WaitMapLoading($mapid_drazach)")
	If GetMapID() <> $mapid_drazach Then Return False
	;TargetNearestAlly()
	; Target
	;$lReturnTarget = GetNearestAgentToCoords(-7891, 18376)
	$lReturnTarget = GetNearestAgentToCoords(-8361, 18604)
	Sleep(50)
	UseSkill(2, -2)
	Sleep(50)
	UseSkill(1, $lReturnTarget); Return
	Sleep(3000)
	;_UseSkillex(1, $lReturnTarget, 8000); Return
	MoveTo(-7924, 18281)
	;UseSkill($skill_serpent[0], $myptr)
	;_UseSkillex(3); Shadow Form
	;_UseSkillex(4); Shroud

	;UseSkill(3); Shadow Form
	_UseSkillex(3);SF ADD
	Sleep(1000)
	;UseSkill(4); Shroud
	_UseSkillex(4); Shroud ADD
	Sleep(1000)


	Out("Balling dragons")
	MoveTo(-7086, 17979)
	_UseSkillex(5); Storm
	MoveTo(-6153, 16621)
	MoveTo(-5404, 15538)
	MoveTo(-6111, 17160, 5)
	Out("SoH")
	UseSkill(6, $myptr); SoH
	MoveTo(-6604, 18585, 5)
	_UseSkillex(8); Winnowing
	While GetIsCasting(0);While GetIsCasting()
		Sleep(250)
	WEnd
	Do
	Sleep(250)
	Until GetSkillbarSkillRecharge(3) = 0
	_UseSkillex(3); SF
	Out("Killing.")
	Sleep(250)
	If Not GetIsDead($myptr) Then Out("Killing")
	UseSkill(7, $myptr); Whirling

	$ldeadlock = TimerInit()
	Do
		Sleep(500)
	Until GetNumberOfFoesInRangeOfAgent($myptr, $range_adjacent, $modelid_dragonmoss) = 0 OR GetIsDead($myptr) OR TimerDiff($ldeadlock) > 20000
	RndSleep(250)
	Sleep(10000);add
	;_PickupLoot()
	PickUpLoot()
	If GetIsDead($myptr) Then
		Out("Failed")
		ResignToOutpost(True); travel instead, resign is not working
		Return False
	Else
		ResignToOutpost(False); travel instead, resign is not working
		Return True
	EndIf
EndFunc

#Region CastEngine




	Func _UseSkillex($askillslot, $atarget = $myptr, $atimeout = 3000)
		Local $lskillptr = GetSkillPtr(GetSkillbarSkillID($askillslot))
		;Local $lskillptr = GetSkillPtr(GetSkillbarSkillID($askillslot, 0, $askillbarptr))
		Local $laftercast = MemoryRead($lskillptr + 64, "float") * 1000
		UseSkill($askillslot, $atarget)
		Local $ltimer = TimerInit()
		Do
			Sleep(50)
			If GetIsDead($myptr) Then Return
		Until GetSkillbarSkillRecharge($askillslot) <> 0 OR TimerDiff($ltimer) > $atimeout
	EndFunc

#EndRegion
#Region PickUp

	;Func _PickupLoot($aminslots = 2)
	;	Local $lmex, $lmey, $lagentx, $lagenty
	;	Local $lslots = CountSlots()
	;	Local $lAgentArray = MemoryReadAgentPtrStruct(1, 1024)
	;	For $i = 1 To $lAgentArray[0]
	;		If GetIsDead($myptr) Then Return False
	;		$lagentid = MemoryRead($lAgentArray[$i] + 44, "long")
	;		$litemptr = GetItemPtrByAgentID($lagentid)
	;		If $litemptr = 0 Then ContinueLoop
	;		$litemtype = MemoryRead($litemptr + 32, "byte")
	;		If $lslots < $aminslots Then
	;			If $litemtype <> 11 AND $litemtype <> 20 Then ContinueLoop
	;		EndIf
	;		If Not CanPickup($litemptr) Then ContinueLoop
	;		UpdateAgentPosByPtr($myptr, $lmex, $lmey)
	;		UpdateAgentPosByPtr($lAgentArray[$i], $lagentx, $lagenty)
	;		$ldistance = Sqrt(($lmex - $lagentx) ^ 2 + ($lmey - $lagenty) ^ 2)
	;		If $ldistance > 2000 Then ContinueLoop
	;		PickUpItems($lAgentArray[$i], $lagentid, $lagentx, $lagenty, $ldistance, $myptr)
	;	Next
	;EndFunc

	Func PickUpLoot()
	        Local $lMe
	        Local $lBlockedTimer
	        Local $lBlockedCount = 0
	        Local $lItemExists = True
	        Local $Distance

	        For $i = 1 To GetMaxAgents()
	                If GetIsDead(-2) Then Return False
	                $lAgent = GetAgentByID($i)
	                If Not GetIsMovable($lAgent) Then ContinueLoop
	                $lDistance = GetDistance($lAgent)
	                If $lDistance > 2000 Then ContinueLoop
	                $lItem = GetItemByAgentID($i)
	                If CanPickUp($lItem) Then
	                        Do
	                                If GetDistance($lAgent) > 150 Then Move(DllStructGetData($lAgent, 'X'), DllStructGetData($lAgent, 'Y'), 100)
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
	                                Until Not $lItemExists Or TimerDiff($lBlockedTimer) > Random(500, 1000, 1)
	                                If $lItemExists Then $lBlockedCount += 1
	                        Until Not $lItemExists Or $lBlockedCount > 5
	                EndIf
	        Next
	EndFunc

	Func CanPickUp($aitemptr)
		$lmodelid = DllStructGetData($aitemptr, 'ModelID')
        	$litemtype = DllStructGetData($aitemptr, 'Type')
        	$lextraid = DllStructGetData($aitemptr, 'ExtraID')
        	$lrarity = GetRarity($aitemptr)

		;Local $lmodelid = MemoryRead($aitemptr + 44, "long")
		;Local $litemtype = MemoryRead($aitemptr + 32, "byte")
		If $litemtype = 20 Then Return True
		If $pickupAll Then
			If $lmodelid = 146 Then
				; color dye check ?
				;$extra = MemoryRead($aitemptr + 34, "short")
				If $lextraid = 10 OR $lextraid = 12 Then Return True
				Return False
			EndIf
			;Ele tome
			If $lmodelid = 21799 Then Return False


		    ;If $lmodelid = 28435 Then Return False ; cidre
			;If $lmodelid = 910 Then Return False ; bière
			;If $lmodelid = 18345 Then Return False ; trophée
			;If $lmodelid = 26784 Then Return False ; miel
			;If $lmodelid = 21810 Then Return False ; canon
			;If $lmodelid = 21813 Then Return False ; cierge
			;If $lmodelid = 21812 Then Return False ; boisson sucrée
			;If $lmodelid = 21809 Then Return False ; fusée
			;If $lmodelid = 35124 Then Return False ; cognac
			;If $lmodelid = 21810 Then Return False ; canon
			;If $lmodelid = 21810 Then Return False ; canon
			Return True
		EndIf
		Switch $lmodelid
			Case $modelid_dragonroots
				Return True
			Case $modeid_breambellong, $modeid_breambelrecurve, $modeid_breambelshort, $modeid_breambelflat, $modeid_breambelhorn
				Return True
			Case 22751
				Return True
			Case 146
				;$extra = MemoryRead($litemptr + 34, "short")
				;If $extra = 10 OR $extra = 12 Then Return True
				If $lextraid = 10 OR $lextraid = 12 Then Return True
			Case $modelid_amber, $modelid_echovald, $modelid_gothic, $modelid_ornate
				If GetRarity($aitemptr) = $rarity_gold Then Return True
		EndSwitch
		Return False
	EndFunc

#EndRegion
#Region Inventory

	Func HardCodedMerchant($aMapID)
		If $aMapID = 360 Then ; ile de la méditation
			$lMerchant = GetNearestAgentToCoords(-2112, 8014)
			GoToNPC($lMerchant)
			Return True
		EndIf
		If $aMapID = 6 Then ; ile du sorcier
			$lMerchant = GetNearestAgentToCoords(3522, 8940)
			GoToNPC($lMerchant)
			Return True
	    EndIf
		If $aMapID = 179 Then ; ile vabbi
			$lMerchant = GetNearestAgentToCoords(-4050, -1137)
			GoToNPC($lMerchant)
			Return True
	    EndIf
		If $aMapID = 538 Then ; ile des morts
			$lMerchant = GetNearestAgentToCoords(2982, 1605)
			GoToNPC($lMerchant)
			Return True
		EndIf

		Return False
	EndFunc

	Func ManageInventory()
		LoadSkilltemplate("OgcTcZ885RgNB1ZHQWZoT48cAA")
		Out("Load skillbar")
		Local $lmapid_hall
		Out("Checking Inventory")
		If GetGoldCharacter() > 90000 Then DepositGold()
		   Out("If GetGoldCharacter() > 90000 Then DepositGold()")
		If CountSlots() < 5 Then
		;If True Then
			;_TravelGH()
			;$lmapid_hall = GetMapID()
			;If Not HardCodedMerchant($lmapid_hall) Then
			;	GoToNPC(GetPlayerPtrByPlayerNumber(GetMerchant($lmapid_hall)))
			;EndIf
			TravelTo(283); donjon de maatu
			$lMerchant = GetNearestAgentToCoords(-12851,13654)
			GoToNPC($lMerchant)
			_inventory()
		EndIf
    EndFunc


	Func _inventory()
		_identify()
		;_sell()
		SellDMLoot()
		;_salvage(); retiré temporairement
		_store()
		DepositGold()
		Sleep(GetPing() + 500)
	EndFunc

	Func _identify()
		Local $lbag, $litem
		IdKit()
		For $j = 1 To 4
			IdentifyBag($j)
			If IdKit() Then IdentifyBag($j)
		Next
	EndFunc

	Func _salvage()
		Local $lquantityold, $loldvalue
		SalvageKit()
		;Local $lsalvagekitid = FindSalvageKit(1, 4)
		Local $lsalvagekitid = FindSalvageKit()
		Local $lsalvagekitptr = GetItemByItemID($lsalvagekitid)
		For $bag = 1 To 4
			$lbagptr = GetBag($bag)
			If $lbagptr = 0 Then ContinueLoop
			;For $slot = 1 To MemoryRead($lbagptr + 32, "long")
			For $slot = 1 To DllStructGetData($lbagptr, "slots")
				$litem = GetItemBySlot($lbagptr, $slot)
				If Not GetCanSalvage($litem) Then ContinueLoop
				Out("Salvaging : " & $bag & "," & $slot)
				;$lquantity = MemoryRead($litem + 75, "byte")
				$lquantity = DllStructGetData($litem, 'Quantity')
				;$itemmid = MemoryRead($litem + 44, "long")
				;$itemmid = DllStructGetData($aItem, "ModelId")
				$itemrarity = GetRarity($litem)
				If $itemrarity = $rarity_white OR $itemrarity = $rarity_blue Then
					For $i = 1 To $lquantity
						If SalvageKit() Then
							$lsalvagekitid = FindSalvageKit()
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
						Out("WB S")
						StartSalvage($litem)
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
						$lsalvagekitid = FindSalvageKit()
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
					Out("PG S")
					StartSalvage($litem)
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

	Func GetCanSalvage($aitemptr)
		;If MemoryRead($aitemptr + 24, "ptr") <> 0 Then Return False
		If DllStructGetData($aitemptr, "Customized") <> 0 Then Return False

		;Local $litemtype = MemoryRead($aitemptr + 32, "byte")
		Local $litemtype = DllStructGetData($aitemptr, "Type")
		If $litemtype <> 5 Then Return False
		;Local $lmodelid = MemoryRead($aitemptr + 44, "long")
		Local $lmodelid = DllStructGetData($aitemptr, "ModelId")
		Switch $lmodelid
			Case $modeid_breambellong, $modeid_breambelrecurve, $modeid_breambelshort, $modeid_breambelflat, $modeid_breambelhorn
				Return True
		EndSwitch
		Return False
	EndFunc

; Dragon Moss Sell
	Func SellDMLoot()
		For $j = 1 To 4
			Local $lBag = GetBag($j)
			Local $lNumSlots = DllStructGetData($lBag, "slots")
			For $k = 1 To $lNumSlots
				Local $lItem = GetItemBySlot($j, $k)
				If CandSellDMItem($lItem) == True Then
					SellItem($litem)
					Sleep(GetPing() + 500)
				EndIf
			Next
		Next
	EndFunc

; Dragon Moss Control
	Func CandSellDMItem($aItem)
		; customized?
		;If MemoryRead($aItem + 24, "ptr") <> 0 Then Return False
		;Out("Cust " & DllStructGetData($aItem, "Customized"))
		If DllStructGetData($aItem, "Customized") <> 0 Then Return False

		;If MemoryRead($aItem + 36, "short") <= 0 Then Return False
		;Out("Value " & DllStructGetData($aItem, "Value"))
		If DllStructGetData($aItem, "Value") <= 0 Then Return False

		;Out("Equip " & DllStructGetData($aItem, "Equiped"))
		;Equiped ?
		;If MemoryRead($aItem + 76, "byte") <> 0 Then Return False
		If DllStructGetData($aItem, "Equiped") <> 0 Then Return False
		;Out("CSDM initC")

		Switch GetRarity($aItem)
			Case 2621
			Case 2623, 2624, 2626
				If Not GetIsIDed($aItem) Then Return False
			Case Else
				Return False
		EndSwitch
		;Switch MemoryRead($aItem + 32, "byte")
		Switch DllStructGetData($aItem, "Type")
			Case 5
				;Local $lmodelid = MemoryRead($aItem + 44, "long")
				Local $lmodelid = DllStructGetData($aItem, "ModelId")
				  ; retrait temporaire car func salvage marche pas
				;If $lmodelid = $modeid_breambelrecurve Then Return False
				;If $lmodelid = $modeid_breambellong Then Return False
				;If $lmodelid = $modeid_breambelshort Then Return False
				;If $lmodelid = $modeid_breambelflat Then Return False
				;If $lmodelid = $modeid_breambelhorn Then Return False

				If $lmodelid = $modeid_breambelrecurve Then Return True
				If $lmodelid = $modeid_breambellong Then Return True
				If $lmodelid = $modeid_breambelshort Then Return True
				If $lmodelid = $modeid_breambelflat Then Return True
				If $lmodelid = $modeid_breambelhorn Then Return True
			    If $lmodelid = 910 Then Return False ; bière
			Case 24
				Local $lmod = GetDualModShield($aItem)
				If $lmod <> False Then
					;Local $lmodelid = MemoryRead($aItem + 44, "long")
					Local $lmodelid = DllStructGetData($aItem, "ModelId")
					Local $larr[] = [$lmodelid, getitemreq($aItem), $lmod]
					;SendSafePacket(Prepare("drop", $larr));test retirer cette commande qui bug
				EndIf

				If GetRarity($aItem) = $rarity_gold And DllStructGetData($aItem, "ModStructSize") = 5 Then Return False
				;If GetRarity($aItem) = $rarity_gold And MemoryRead($aItem + 20, "long") = 5 Then Return False
			Case 10
				;Switch MemoryRead($aItem + 34, "short")
				Switch DllStructGetData($aItem, "ExtraId")
					Case 10, 12
						Return False
					Case Else
				EndSwitch
			Case 18
				Return False
			Case 11
				;If MemoryRead($aItem + 44, "long") = 934 Then Return False
				If DllStructGetData($aItem, "ModelId") = 934 Then Return False
			Case 29
				Return False
			Case 30
				Return False
			Case Else
		EndSwitch
	Return True
	EndFunc

	Func _store()
		Local $lbag, $litem, $lslot, $litemtype
		For $j = 1 To 4
			Out("Storing bag " & $j)
			$lbag = GetBag($j)
			If IsChestFull() Then Return
			For $i = 1 To MemoryRead($lbag + 32, "long")
				$litem = GetItemBySlot($lbag, $i)
				If $litem = 0 Then ContinueLoop
				$litemtype = MemoryRead($litem + 32, "byte")
				Switch $litemtype
					Case 11, 30
						If MemoryRead($litem + 75, "byte") <> 250 Then ContinueLoop
					Case 24
					Case Else
						ContinueLoop
				EndSwitch
				$lslot = OpenStorageSlot()
				If IsArray($lslot) Then
					MoveItem($litem, $lslot[0], $lslot[1])
					Sleep(GetPing() + Random(500, 750, 1))
				EndIf
			Next
		Next
	EndFunc

	Func IdKit()
		If FindIDKit() == 0 Then
			Out("Buy ID kit")
			If GetGoldCharacter() < 100 Then
				Out("Golds")
				WithdrawGold(100)
				RndSleep(1000)
			EndIf
			BuyItem(5, 1, 100)
			RndSleep(1000)
			Return true
		EndIf
		Return False
	EndFunc

	Func SalvageKit()
		If FindSalvageKit() == 0 Then
			Out("Buy salvage kit")
			If GetGoldCharacter() < 100 Then
				Out("Golds")
				WithdrawGold(100)
				RndSleep(1000)
			EndIf
			BuyItem(2, 1, 100)
			RndSleep(1000)
			Return true
		EndIf
		Return False
	EndFunc

	Func IsChestFull()
		If CountSlotsChest() = 0 Then
			Out("Chest Full")
			Return True
		EndIf
		Return False
	EndFunc

#EndRegion
#Region Travel

	Func _TravelGH()
		Local $larray_gh[16] = [4, 5, 6, 52, 176, 177, 178, 179, 275, 276, 359, 360, 529, 530, 537, 538]
		Local $lmapid = GetMapID()
		If _arraysearch($larray_gh, $lmapid) <> -1 Then Return
		TravelGH()
	EndFunc

	Func ResignToOutpost($aisdead)
		Out("Resigning 2")
		;Resign(); TODO : test the function
		TravelTo($mapid_anjeka)
		;Do
		;	Sleep(100)
		;Until GetIsDead($myptr)
		;If $aisdead Then
		;	RndSleep(4000)
		;Else
		;	RndSleep(1500)
		;EndIf
		;returntooutpost()
		;TravelTo($mapid_anjeka)
		;WaitMapLoading($mapid_anjeka)
	EndFunc

#EndRegion
#Region GUI Functions

Func Out($text)
	Local $textlen = StringLen($text)
	Local $consolelen = _GUICtrlEdit_GetTextLen($gui_edit)
	If $textlen + $consolelen > 30000 Then GUICtrlSetData($gui_edit, StringRight(_GUICtrlEdit_GetText($gui_edit), 30000-$textlen-1000))
	_GUICtrlEdit_AppendText($gui_edit, @CRLF&"["&@HOUR&":"&@MIN&":"&@SEC&"] "&$text)
	_GUICtrlEdit_Scroll ($gui_edit, 1) ;1=$SB_LINEDOWN
EndFunc

	; TODO : check if used
	; Func GetChecked($guictrl)
	; 	Return (GUICtrlRead($guictrl) == $gui_checked)
	; EndFunc

#EndRegion GUI Functions

Func GetDualModShield($aitem)
	Local $lhp, $lhpench, $lhpstan
	Local $lredench, $lredstance, $lredhexed, $lreddam
	Local $larmorvs, $larmort
	$lhp = GetModByIdentifier($aitem, "4823")[1]
	$lhpench = GetModByIdentifier($aitem, "6823")[1]
	$lredench = GetModByIdentifier($aitem, "8820")[0]
	$lreddam = GetModByIdentifier($aitem, "7820")[1]
	$larmorvs = GetModByIdentifier($aitem, "4821")[0]
	$larmort = GetModByIdentifier($aitem, "4821")[1]
	If $larmort = 8 AND $larmorvs = 10 Then
		If $lhp = 30 Then
			Return "+10 Demons/+30"
		EndIf
		If $lhpench = 45 Then
			Return "+10 Demons/+45^e"
		EndIf
		If $lredench = 2 Then
			Return "+10 Demons/-2^e"
		EndIf
	EndIf
	If $lhp = 30 Then
		If $lreddam = 20 Then
			Return "+30/-5"
		EndIf
	EndIf
	Return False
EndFunc
