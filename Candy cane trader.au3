#RequireAdmin
If @AutoItX64 Then
	MsgBox(16, "Error!", "Please run all bots in 32-bit (x86) mode.")
	Exit
 EndIf

 #include <GWA2.au3>
 #include <GUIConstantsEx.au3>

Opt("GUIOnEventMode", 1)

Dim $rendering = True
Dim $anzeigeonoff = False
Dim $time = "00:00:00"
Global $onoff = False

;~ Special Drops
Global $Special_Drops[7] = [5656, 18345, 21491, 37765, 21833, 28433, 28434]

Global $Array_Store_ModelIDs460[147] = [474, 476, 486, 522, 525, 811, 819, 822, 835, 610, 2994, 19185, 22751, 4629, 24630, 4631, 24632, 27033, 27035, 27044, 27046, 27047, 7052, 5123 _
		, 1796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 1805, 910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682 _
		, 6376 , 6368 , 6369 , 21809 , 21810, 21813, 29436, 29543, 36683, 4730, 15837, 21490, 22192, 30626, 30630, 30638, 30642, 30646, 30648, 31020, 31141, 31142, 31144, 1172, 15528 _
		, 15479, 19170, 21492, 21812, 22269, 22644, 22752, 28431, 28432, 28436, 1150, 35125, 36681, 3256, 3746, 5594, 5595, 5611, 5853, 5975, 5976, 21233, 22279, 22280, 6370, 21488 _
		, 21489, 22191, 35127, 26784, 28433, 18345, 21491, 28434, 35121, 921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943 _
		, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533]

Global $Array_pscon[39]=[910, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 35124, 36682, 6376, 21809, 21810, 21813, 36683, 21492, 21812, 22269, 22644, 22752, 28436,15837, 21490, 30648, 31020, 6370, 21488, 21489, 22191, 26784, 28433, 5656, 18345, 21491, 37765, 21833, 28433, 28434]


$form1 = GUICreate("Candy trade by rusco95/koala95", 320, 220, 192, 124)
$label4 = GUICtrlCreateLabel("Char Name:", 30, 20, 100, 20)
$input2 = GUICtrlCreateInput("", 110, 20, 180, 21)
GUICtrlSetState(-1, $gui_checked)
;GUICtrlSetOnEvent(-1, "safety")
$checkbox2 = GUICtrlCreateCheckbox("DisableRendering", 30, 160)
GUICtrlSetOnEvent($checkbox2, "ToggleRendering")
$button1 = GUICtrlCreateButton("Start", 30, 190, 260, 33)
GUICtrlSetOnEvent($button1, "Button1")
GUISetOnEvent($gui_event_close, "Exit_func")
GUISetState(@SW_SHOW)

Func button1()
	$onoff = True
	If $anzeigeonoff = False Then
		GUICtrlSetData($button1, "Start")
		If initialize(GUICtrlRead($input2), True, True) = True Then
			$onoff = True
			$anzeigeonoff = True
			GUICtrlSetData($button1, "Pause")
			Else
			MsgBox(64, "Error", "Wrong Name Fool!")
			Exit
		EndIf
	Else
		GUICtrlSetData($button1, "Last Run")
		$onoff = False
	EndIf
 EndFunc

 Func exit_func()
	Exit
EndFunc

Func togglerendering()
	If $rendering Then
		disablerendering()
		$rendering = False
	Else
		enablerendering()
		$rendering = True
	EndIf
EndFunc

While 1
	Sleep(100)
	If $onoff Then
		main()
		If $onoff = False Then
			$anzeigeonoff = False
			GUICtrlSetData($button1, "Start")
		EndIf
	EndIf
WEnd

Func main()
   If GetMapId() <> 248 Then
		RndTravel(248)
		WaitMapLoading(248)
	 EndIf
	TakeCandy()
 EndFunc

 Func TakeCandy()
	$agent = getnearestnpctocoords(-3434, -7136)
	gotonpc($agent)
	Dialog(0x8D)
	sleep(100)
	Dialog(0x97)
	sleep(100)
	Dialog(0x8D)
	sleep(100)
	Dialog(0x96)
	sleep(100)
	Dialog(0x8D)
	sleep(100)
	Dialog(0x95)
	sleep(100)
	Dialog(0x8D)
	sleep(100)
	Dialog(0x94)
	Takecandy()
EndFunc

Func movetoitem($agent)
	$x = DllStructGetData($agent, "X")
	$y = DllStructGetData($agent, "Y")
	moveto($x, $y, 100)
EndFunc

Func _mstotimeformat($msttf_ms)
	If NOT IsNumber($msttf_ms) Then Return SetError(1, 0, 0)
	Local $msttf_vorzeichen = "", $msttf_endzeit, $msttf_stunden, $msttf_minuten, $msttf_sekunden, $msttf_sret
	If $msttf_ms < 0 Then
		$msttf_ms = Abs($msttf_ms)
		$msttf_vorzeichen = "-"
	EndIf
	$msttf_endzeit = $msttf_ms / 1000
	$msttf_stunden = $msttf_endzeit / 3600
	$msttf_stunden = Int($msttf_stunden)
	$msttf_minuten = (($msttf_endzeit / 60) - ($msttf_stunden * 60))
	$msttf_minuten = Int($msttf_minuten)
	$msttf_sekunden = ($msttf_endzeit - ($msttf_minuten * 60) - ($msttf_stunden * 3600))
	$msttf_sekunden = Int($msttf_sekunden)
	If $msttf_stunden < 10 Then $msttf_stunden = "0" & $msttf_stunden
	If $msttf_minuten < 10 Then $msttf_minuten = "0" & $msttf_minuten
	If $msttf_sekunden < 10 Then $msttf_sekunden = "0" & $msttf_sekunden
	$msttf_sret = $msttf_vorzeichen & $msttf_stunden & ":" & $msttf_minuten & ":" & $msttf_sekunden
	Return $msttf_sret
EndFunc

Func RndTravel($aMapID)
	Local $UseDistricts = 11 ; 7=eu-only, 8=eu+int, 11=all(excluding America)
	; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, us-en, int, asia-ko, asia-ch, asia-ja
	Local $Region[11] = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
	Local $Language[11] = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]
	Local $Random = Random(0, $UseDistricts - 1, 1)
	MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
	waitmaploading($aMapID)
 EndFunc   ;==>RndTravel

 Func isagenthuman($aAgent)
	If DllStructGetData($aAgent, 'Allegiance') <> 1 Then Return
	$thename = GetPlayerName($aAgent)
	If $thename = "" Then Return
	Return True
EndFunc   ;==>isagenthuman


