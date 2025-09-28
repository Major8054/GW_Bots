; * Missing functions in GWA2.au3 :
;GetSkillPtr()
;MemoryReadAgentPtrStruct()
;GetBagPtr()
;GetItemPtr()
; + MemoryReadStruct()
; + Move_()
; + GetMaxSlots ??????????
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
;OpenStorageSlot(GetBagPtr..., GetItemPtrBySlot...)
Global $muuid = ""

#region dependency
	Func GetSkillPtr($askillid)
		Local $skillptr = $mskillbase + 160 * $askillid
		Return Ptr($skillptr)
	EndFunc

	Func MemoryReadAgentPtrStruct($amode = 0, $atype = 219, $aallegiance = 3, $adead = False)
		Local $lmaxagents = GetMaxAgents()
		Local $lagentptrstruct = DllStructCreate("PTR[" & $lmaxagents & "]")
		DllCall($mkernelhandle, "BOOL", "ReadProcessMemory", "HANDLE", $mgwprochandle, "PTR", MemoryRead($magentbase), "STRUCT*", $lagentptrstruct, "ULONG_PTR", $lmaxagents * 4, "ULONG_PTR*", 0)
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
					If MemoryRead($ltemp + 156, "long") <> $atype Then ContinueLoop
					$lagentarray[0] += 1
					$lagentarray[$lagentarray[0]] = $ltemp
				Next
			Case 2
				For $i = 1 To $lmaxagents
					$ltemp = DllStructGetData($lagentptrstruct, 1, $i)
					If $ltemp = 0 Then ContinueLoop
					If MemoryRead($ltemp + 156, "long") <> $atype Then ContinueLoop
					If MemoryRead($ltemp + 433, "byte") <> $aallegiance Then ContinueLoop
					$lagentarray[0] += 1
					$lagentarray[$lagentarray[0]] = $ltemp
				Next
			Case 3
				For $i = 1 To $lmaxagents
					$ltemp = DllStructGetData($lagentptrstruct, 1, $i)
					If $ltemp = 0 Then ContinueLoop
					If MemoryRead($ltemp + 156, "long") <> $atype Then ContinueLoop
					If MemoryRead($ltemp + 433, "byte") <> $aallegiance Then ContinueLoop
					If MemoryRead($ltemp + 304, "float") <= 0 Then ContinueLoop
					$lagentarray[0] += 1
					$lagentarray[$lagentarray[0]] = $ltemp
				Next
		EndSwitch
		ReDim $lagentarray[$lagentarray[0] + 1]
		Return $lagentarray
	EndFunc

	Func GetBagPtr($abagnumber)
		Local $loffset[5] = [0, 24, 64, 248, 4 * $abagnumber]
		Local $litemstructaddress = MemoryReadPtr($mbasepointer, $loffset, "ptr")
		Return $litemstructaddress[1]
	EndFunc

	Func GetItemPtr($aitemid)
		Local $loffset[5] = [0, 24, 64, 184, 4 * $aitemid]
		Local $litemstructaddress = MemoryReadPtr($mbasepointer, $loffset, "ptr")
		Return $litemstructaddress[1]
	EndFunc

	Func MemoryReadStruct($aaddress, $astruct = "dword")
		Local $lbuffer = DllStructCreate($astruct)
		DllCall($mkernelhandle, "int", "ReadProcessMemory", "int", $mgwprochandle, "int", $aaddress, "ptr", DllStructGetPtr($lbuffer), "int", DllStructGetSize($lbuffer), "int", "")
		Return $lbuffer
	EndFunc

	Func Move_($ax, $ay)
		If $ax = 0 OR $ay = 0 Then Return
		If GetAgentExists(-2) Then
			DllStructSetData($mmove, 2, $ax)
			DllStructSetData($mmove, 3, $ay)
			Enqueue($mmoveptr, 16)
			Return True
		Else
			Return False
		EndIf
	EndFunc

	Func GetNumberOfFoesInRangeOfAgent($aagent = GetAgentPtr(-2), $amaxdistance = 4000, $modelid = 0)
		If IsPtr($aagent) <> 0 Then
			Local $lagentptr = $aagent
		ElseIf IsDllStruct($aagent) <> 0 Then
			Local $lagentptr = GetAgentPtr(DllStructGetData($aagent, "ID"))
		Else
			Local $lagentptr = GetAgentPtr($aagent)
		EndIf
		Local $ldistance, $lcount = 0
		Local $ltargettypearray = MemoryReadAgentPtrStruct(3)
		For $i = 1 To $ltargettypearray[0]
			If $modelid <> 0 AND MemoryRead($ltargettypearray[$i] + 244, "word") <> $modelid Then ContinueLoop
			$ldistance = GetDistance($ltargettypearray[$i], $lagentptr)
			If $ldistance < $amaxdistance Then
				$lcount += 1
			EndIf
		Next
		Return $lcount
	EndFunc

	Func CountSlots()
		Local $lcount = 0
		For $lbag = 1 To 4
			$lbagptr = GetBagPtr($lbag)
			If $lbagptr = 0 Then ContinueLoop
			$lcount += MemoryRead($lbagptr + 32, "long") - MemoryRead($lbagptr + 16, "long")
		Next
		Return $lcount
	EndFunc

	Func GetItemPtrByAgentID($aagentid)
		Return GetItemPtr(MemoryRead(GetAgentPtr($aagentid) + 200))
	EndFunc

	Func UpdateAgentPosByPtr($aagentptr, ByRef $ax, ByRef $ay)
		Local $lstruct = MemoryReadStruct($aagentptr + 116, "float X;float Y")
		$ax = DllStructGetData($lstruct, "X")
		$ay = DllStructGetData($lstruct, "Y")
	EndFunc

	Func PickUpItems($aptr, $aagentid, $ax, $ay, $adistance, $ame)
		Local $lblocked = 0
		If $adistance > 150 Then
			Do
				Move_($ax, $ay)
				Sleep(250)
				$lblocked += 1
			Until GetDistance($aptr, $ame) <= 150 OR $lblocked > 20
		EndIf
		$ltimer = TimerInit()
		Do
			PickUpItem($aagentid)
			Sleep(250)
		Until GetAgentPtr($aagentid) <> $aptr OR TimerDiff($ltimer) > 6000
	EndFunc

	Func GetPlayerPtrByPlayerNumber($aplayernumber)
		Local $lagentarray = MemoryReadAgentPtrStruct(1)
		For $i = 1 To $lagentarray[0]
			If MemoryRead($lagentarray[$i] + 244, "word") = $aplayernumber Then Return $lagentarray[$i]
		Next
	EndFunc

	Func GetMerchant($amapid)
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

	Func GetItemPtrBySlot($abag, $aslot)
		If IsPtr($abag) Then
			$lbagptr = $abag
		Else
			If $abag < 1 OR $abag > 17 Then Return 0
			If $aslot < 1 OR $aslot > GetMaxSlots($abag) Then Return 0
			Local $lbagptr = GetBagPtr($abag)
		EndIf
		Local $litemarrayptr = MemoryRead($lbagptr + 24, "ptr")
		Return MemoryRead($litemarrayptr + 4 * ($aslot - 1), "ptr")
	EndFunc

	Func GetIsUnided($aitem)
		If IsPtr($aitem) <> 0 Then
			Return BitAND(MemoryRead($aitem + 40, "long"), 8388608) > 0
		ElseIf IsDllStruct($aitem) <> 0 Then
			Return BitAND(DllStructGetData($aitem, "interaction"), 8388608) > 0
		Else
			Return BitAND(MemoryRead(GetItemPtr($aitem) + 40, "long"), 8388608) > 0
		EndIf
	EndFunc

	Func CountSlotsChest()
		Local $lcount = 0
		For $lbag = 8 To 16
			$lbagptr = GetBagPtr($lbag)
			If $lbagptr = 0 Then ContinueLoop
			$lcount += MemoryRead($lbagptr + 32, "long") - MemoryRead($lbagptr + 16, "long")
		Next
		Return $lcount
	EndFunc

	Func SendSafePacket($apacket, $acon = Default)
		If $acon = Default Then
			Local $lgwsocket = TCPConnect($mgwserverinfo, $mgwserverport)
		Else
			Local $lgwsocket = $acon
		EndIf
		TCPSend($lgwsocket, $apacket)
		If $acon = Default Then
			TCPCloseSocket($lgwsocket)
		EndIf
	EndFunc

	Func Prepare($aname, $aargs, $mglobal = Default)
		If $mglobal == Default Then
			$aname &= "/" & $muuid
		EndIf
		For $i = 0 To UBound($aargs) - 1
			$aname &= "/" & $aargs[$i]
		Next
		Return $aname
	EndFunc

	Func OpenStorageSlot()
		For $i = 8 To 16
			$lbagptr = GetBagPtr($i)
			If $lbagptr = 0 Then ExitLoop
			For $j = 1 To MemoryRead($lbagptr + 32, "long")
				If GetItemPtrBySlot($lbagptr, $j) = 0 Then
					Local $lreturnarray[2] = [$i, $j]
					Return $lreturnarray
				EndIf
			Next
		Next
	EndFunc
#endregion

; #region outDep
;
; Global Const $__editconstant_wm_gettextlength = 14
; Global Const $__editconstant_wm_gettext = 13
; Global Const $em_replacesel = 194
;
; Func _sendmessage($hwnd, $imsg, $wparam = 0, $lparam = 0, $ireturn = 0, $wparamtype = "wparam", $lparamtype = "lparam", $sreturntype = "lresult")
; 	Local $aresult = DllCall("user32.dll", $sreturntype, "SendMessageW", "hwnd", $hwnd, "uint", $imsg, $wparamtype, $wparam, $lparamtype, $lparam)
; 	If @error Then Return SetError(@error, @extended, "")
; 	If $ireturn >= 0 AND $ireturn <= 4 Then Return $aresult[$ireturn]
; 	Return $aresult
; EndFunc
;
; ; Out : 4 direct dependencies
;
; Func _guictrledit_gettextlen($hwnd)
; 	If Not IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
; 	Return _sendmessage($hwnd, $__editconstant_wm_gettextlength)
; EndFunc
;
; Func _guictrledit_gettext($hwnd)
; 	If Not IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
; 	Local $itextlen = _guictrledit_gettextlen($hwnd) + 1
; 	Local $ttext = DllStructCreate("wchar Text[" & $itextlen & "]")
; 	_sendmessage($hwnd, $__editconstant_wm_gettext, $itextlen, $ttext, 0, "wparam", "struct*")
; 	Return DllStructGetData($ttext, "Text")
; EndFunc
;
; Func _guictrledit_appendtext($hwnd, $stext)
; 	If Not IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
; 	Local $ilength = _guictrledit_gettextlen($hwnd)
; 	_guictrledit_setsel($hwnd, $ilength, $ilength)
; 	_sendmessage($hwnd, $em_replacesel, True, $stext, 0, "wparam", "wstr")
; EndFunc
;
; Func _guictrledit_scroll($hwnd, $idirection)
; 	If Not IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
; 	If BitAND($idirection, $__editconstant_sb_linedown) <> $__editconstant_sb_linedown AND BitAND($idirection, $__editconstant_sb_lineup) <> $__editconstant_sb_lineup AND BitAND($idirection, $__editconstant_sb_pagedown) <> $__editconstant_sb_pagedown AND BitAND($idirection, $__editconstant_sb_pageup) <> $__editconstant_sb_pageup AND BitAND($idirection, $__editconstant_sb_scrollcaret) <> $__editconstant_sb_scrollcaret Then Return 0
; 	If $idirection == $__editconstant_sb_scrollcaret Then
; 		Return _sendmessage($hwnd, $em_scrollcaret)
; 	Else
; 		Return _sendmessage($hwnd, $em_scroll, $idirection)
; 	EndIf
; EndFunc
;
; #endregion
