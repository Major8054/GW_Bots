
; --------------------- ;
;    INVENTORY TOOLS    ;
;  FOR VAETTIRS MONEY   ;
;#include "GWA2_Headers.au3"
; --------------------- ;
; mettre un Tab d'ID
;#include "Items.au3"
#include "GWA2.au3"

#region *VARS*
; ----- KIT INFOS ----- ;
Global $identifyKit = 6
Global $salvageKit = 4
Global $maxIdentyfyKit = 2
;Global $maxSalvageKit = 3 original
Global $maxSalvageKit = 10

; ----- BAG SLOTS ----- ;
Global $minFreeSlots = 2
; ----- PICK UP ----- ;
Global $pickUpMesmerToms = False
#endregion

$MAT_BONE = 921
$MAT_CHARCOAL = 922
;#include "GWA2_Headers.au3"
$MAT_CLAW = 923
;924 does not exist
$MAT_CLOTH = 925
$MAT_LINEN = 926
$MAT_BOLT_DAMASK = 927
$MAT_SILK = 928
$MAT_DUST = 929
$MAT_ECTO = 930
$MAT_EYE = 931
$MAT_FANG = 932
$MAT_FEATHER = 933
$MAT_FIBER = 934
$MAT_DIAMOND = 935
$MAT_ONYX = 936
$MAT_RUBY = 937
$MAT_SAPPHIRE = 938
$MAT_TEMPERED_GLASS_VIAL = 939
$MAT_TANNED = 940
$MAT_FUR = 941
$MAT_LEATHER = 942
$MAT_ELONIAN_LEATHER = 943
$MAT_VIAL_INK = 944
$MAT_DELDRIMOR_STEEL = 945
$MAT_WOOD = 946
;947 does not exist
$MAT_IRON = 948
$MAT_STEEL = 949
$MAT_50 = 950
$MAT_PARCHMENT = 951
$MAT_VELLUM = 952
$MAT_SCALE = 953
$MAT_CHITIN = 954
$MAT_GRANITE = 955
$MAT_SPIRITWOOD = 956
$MAT_AMBER = 6532
$MAT_JADEITE = 6533


#region *SELL*

Func sellInventory($canSellGolds)
	For $i = 1 To 4
		For $j = 1 To $BAG_SLOT[$i-1]
			Local $item = GetItemBySlot($i, $j)
			If canSell($item, $canSellGolds) Then
				SellItem($item)
				pingSleep(Random(1000,1500,1))
			EndIf
		Next
	Next
 EndFunc

Func Exeptions_sell($item)
    Local $ModelID = DllStructGetData(($item), 'ModelID')
   	If $ModelID = 21233 Then Return True
	If $ModelID = 5595 Then Return True
	If $ModelID = 5611 Then Return True
	If $ModelID = 5594 Then Return True
	If $ModelID = 5975 Then Return True
	If $ModelID = 5976 Then Return True
	If $ModelID = 5853 Then Return True
EndFunc


Func canSell($item, $canSellGolds)
	Local $m = DllStructGetData($item, 'ModelID')
	Local $t = DllStructGetData($item, 'Type')
	Local $e = DllStructGetData($item, 'Extrald')
	If $m == 0 Then Return False
	Local $r = GetRarity($item)

	If Not $canSellGolds And $r == $RARITY_GOLD Then
		Return False
	EndIf

    If $m > 21785 And $m < 21806 Then ;Elite/Normal Tomes
		Return False
	ElseIf $m = 146 Or $m = 22751 Then ;Dyes/Lockpicks
		Return False
	ElseIf $m = 5900 Or $m = 5899 Or $m = 2991 or $m = 2992 Then ;Sup Salvage Or Sup ID
		Return False
	ElseIf $m = 923 Or $m = 931 Or $m = 6533 Then ;Jade/Eye/Claw
		Return False
    ElseIf $m = $MAT_IRON or $m = $MAT_DUST or $m = $MAT_SCALE or $m = $MAT_STEEL or $m = $MAT_DELDRIMOR_STEEL or $m = $MAT_ECTO or $m = $MAT_FEATHER or $m = $MAT_BONE or $m = $MAT_GRANITE  Then
		Return False
  ;  ElseIf Exeptions_sell($item) Then Return False
    EndIf
    return True

	;If $r = $RARITY_GOLD And $salvageItems = False Then Return True
    ;If $ModelID = 946 Then Return True
	;Return False
EndFunc

#endregion

; ----- SALVAGE ----- ;

#region *SALVAGE*

Func salvage($canSalvageGolds, $restrictItems, $lastBag = 4)


	For $i = 1 To $lastBag
		For $j = 1 To $BAG_SLOT[$i-1]
			If Not InventoryIsFull() Then
				Local $item = GetItemBySlot($i, $j)
				If checkSalvageKit() > 0 Then
					If canSalvage($item, $canSalvageGolds, $restrictItems) Then

						StartSalvage($item)
						Out("StartSalvage");test
						If GetRarity($item) <> $RARITY_WHITE Then SalvageMaterials()
						pingSleep(1500)
						If DllStructGetData($item, 'Quantity') > 1 Then $j -= 1
					EndIf
				EndIf
			Else
				Return False
			EndIf
		Next
	Next
EndFunc

Func salvageoriginal($canSalvageGolds, $restrictItems, $lastBag = 4)


	For $i = 1 To $lastBag
		For $j = 1 To $BAG_SLOT[$i-1]
			If Not InventoryIsFull() Then
				Local $item = GetItemBySlot($i, $j)
				If checkSalvageKit() > 0 Then
					If canSalvage($item, $canSalvageGolds, $restrictItems) Then
						;debug(DllStructGetData($item, 'id'))
						StartSalvage($item)
						Out("StartSalvage");test
						;If GetRarity($item) <> $RARITY_WHITE Then SalvageMaterials()
						SalvageMaterials()
						pingSleep(1500)
						If DllStructGetData($item, 'Quantity') > 1 Then $j -= 1
					EndIf
				EndIf
			Else
				Return False
			EndIf
		Next
	Next
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
Func Salvage2($lBag);test
	  Local $aBag
	  If Not IsDllStruct($lBag) Then $aBag = GetBag($lBag)
	  Local $lItem
	  Local $lSalvageType
	  Local $lSalvageCount
	  For $i = 1 To DllStructGetData($aBag, 'Slots')

			   $lItem = GetItemBySlot($aBag, $i)

			   ;SalvageKit()

			$q = DllStructGetData($lItem, 'Quantity')
			$t = DllStructGetData($lItem, 'Type')
			$m = DllStructGetData($lItem, 'ModelID')

			   If (DllStructGetData($lItem, 'ID') == 0) Then ContinueLoop

		 If  canSalvage2($lItem) Then ;$m = 819 Or (racines dragon)
			   If $q >= 1 Then
						For $j = 1 To $q

							  ;SalvageKit()

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

Func buySalvageKit($quantity)
   Local $price = 100
   If FindSalvageKit() = 0 Then
	  If GetGoldCharacter() < 100 Then
		 WithdrawGold(1000)
		 RndSleep(2000)
	  EndIf
	  If $price = 0 Or $quantity = 0 Then Return False
	  For $i = 1 To $quantity
		BuyItem(2, 1, 100)
		pingSleep(Random(1000,1500,1))
	  Next
	  RndSleep(1000)
   EndIf
EndFunc
Func canSalvage2($item) ; <<<< voir les exeptions
	Local $m = DllStructGetData($item, 'ModelID')
	Local $r = GetRarity($item)
	Local $t = DllStructGetData($item, 'Type')
	If $m == 0 Then Return False
    If salvageGoodRarity($r) And isWeapon($t) Then Return True


 	If exeption($item) Then Return True
	Return False
EndFunc

Func exeption($item)
Local $ModelID = DllStructGetData(($item), 'ModelID')

;~ debug($ModelID)_________________________, TEST
   ;~ If $ModelID = 27047 Then Return True
   ;~ If $ModelID = 146 Then Return False
   ;~ If $ModelID = 22751 Then Return False
   ;~ If $ModelID = 2991 Then Return False
   ;~ If $ModelID = 2989 Then Return False
   ;~ If $ModelID = 5899 Then Return False
	 ;add
	If $ModelID = 257 Then Return True
	If $ModelID = 1829 Then Return True
	If $ModelID = 1834 Then Return True
	If $ModelID = 131 Then Return True
	If $ModelID = 1761 Then Return True
	If $ModelID = 1833 Then Return True
	If $ModelID = 353 Then Return True
	If $ModelID = 251 Then Return True
	If $ModelID = 126 Then Return True
	If $ModelID = 1766 Then Return True
	If $ModelID = 155 Then Return True
	If $ModelID = 2344 Then Return True
	If $ModelID = 2310 Then Return True
	If $ModelID = 255 Then Return True
	If $ModelID = 254 Then Return True
	If $ModelID = 1869 Then Return True
	If $ModelID = 151 Then Return True
	If $ModelID = 5976 Then Return True
	If $ModelID = 1767 Then Return True
	If $ModelID = 1784 Then Return True
	If $ModelID = 1911 Then Return True
	If $ModelID = 1916 Then Return True
	If $ModelID = 1865 Then Return True
	If $ModelID = 1914 Then Return True
	If $ModelID = 1793 Then Return True
	If $ModelID = 1910 Then Return True
	If $ModelID = 1785 Then Return True
	If $ModelID = 2089 Then Return True
	If $ModelID = 1830 Then Return True
	If $ModelID = 157 Then Return True
	If $ModelID = 1786 Then Return True
;Parchos
	If $ModelID = 21233 Then Return False
	If $ModelID = 5595 Then Return False
	If $ModelID = 5611 Then Return False
	If $ModelID = 5594 Then Return False
	If $ModelID = 5975 Then Return False
	If $ModelID = 5976 Then Return False
	If $ModelID = 5853 Then Return False


	Return False
EndFunc

Func isWeapon($t)
	If $t == 2 Then Return True ; Axe
	If $t == 5 Then Return True ; Bow
	If $t == 12 Then Return True ; OffHand  (ex : Chalice)
	If $t == 15 Then Return True ; Hammer
	If $t == 22 Then Return True ; Wand (ex : scepter, cane)
	If $t == 24 Then Return True ; Shield
	If $t == 26 Then Return True ; Staff
	If $t == 27 Then Return True ; Sword
	If $t == 32 Then Return True ; Daggers
	If $t == 35 Then Return True ; Scyth
	If $t == 36 Then Return True ; Spear
	Return False
EndFunc

Func canSalvage($item, $canSalvageGolds, $restrictItems) ; <<<< voir les exeptions
	Local $m = DllStructGetData($item, 'ModelID')
	Local $r = GetRarity($item)
	Local $t = DllStructGetData($item, 'Type')
	If $m == 0 Then Return False

	If Not $canSalvageGolds And $r == $RARITY_GOLD Then
		return False
	EndIf

	If $restrictItems Then
		If salvageGoodRarity($r) And salvageGoodTypeWeap($t) Then Return True
	Else
		If salvageGoodRarity($r) And isWeapon($t) Then Return True
	EndIf

 	If exeption($item) Then Return True
	Return False
EndFunc

Func salvageGoodRarity($r)
	If $r == $RARITY_GOLD Then Return True
	If $r == $RARITY_PURPLE Then Return True
	If $r == $RARITY_BLUE Then Return True
	If $r == $RARITY_WHITE Then Return True
	Return False
EndFunc

Func salvageGoodTypeWeap($t)
	If $t == 2 Then Return True ; Axe
	If $t == 15 Then Return True ; Hammer
	If $t == 24 Then Return True ; Shield
	If $t == 27 Then Return True ; Sword
	If $t == 32 Then Return True ; Daggers
	If $t == 35 Then Return True ; Scythe
	If $t == 36 Then Return True ; Spear
	Return False
EndFunc

Func checkSalvageKit($lastBag = 4)
	Local $count = 0
	;Local $salvageKitModId = 5900
	Local $salvageKitModId = 2992
	For $i = 1 To $lastBag
		For $j = 1 To $BAG_SLOT[$i-1]
			Local $item = GetItemBySlot($i, $j)
			If DllStructGetData($item, 'ModelID') = $salvageKitModId Then $count += 1
		Next
	Next
	Return $count
EndFunc

Func buySalvageKitoriginal($quantity)
	Local $price = 2000
	If $price = 0 Or $quantity = 0 Then Return False
	WithdrawGold($price*$quantity)
	pingSleep(Random(1000,1500,1))
	For $i = 1 To $quantity
		BuyItem($salvageKit, 1, $price)
		pingSleep(Random(1000,1500,1))
	Next
	pingSleep(250)
EndFunc

#endregion

; ---- IDENTIFY ---- ;

#region *IDENTIFY*

Func identify($doIdGolds, $bag = 0)
	If $bag = 0 Then
		IdentifyBag(1, False, $doIdGolds)
		IdentifyBag(2, False, $doIdGolds)
		IdentifyBag(3, False, $doIdGolds)
		IdentifyBag(4, False, $doIdGolds)
	Else
		IdentifyBag($bag, False, $doIdGolds)
	EndIf
EndFunc

Func checkIdentifyKit()
	Local $count = 0
	Local $idKit = 5899
	For $i = 1 To 4
		For $j = 1 To $BAG_SLOT[$i-1]
			Local $item = GetItemBySlot($i, $j)
			If DllStructGetData($item, 'ModelID') = $idKit Then
				$count += 1
			EndIf
		Next
	Next
	Return $count
EndFunc

Func buyIdentifyKit($quantity)
Local $price = 500
Local $i = 1
If $price = 0 Or $quantity = 0 Then Return False
WithdrawGold($price*$quantity)
pingSleep(Random(1000,1500,1))
For $i = 1 To $quantity
	BuyItem($identifyKit, 1, $price)
	pingSleep(Random(1000,1500,1))
Next
pingSleep(250)
EndFunc

#endregion

; ---- FIND NPC ---- ;

#region *FIND NPC*

Func findXunlai()
	Return GetAgentByName("Coffre Xunlai")
EndFunc

Func findMerchant()
	Return GetAgentByName("Marchand")
EndFunc

Func pingSleep($time)
Sleep(GetPing()+$time)
EndFunc

#endregion

; ---- PICK-UP ---- ;

#region *PICK-UP*

Func CanPickUp($aItem, $restrictPickUp, $eventOnly)
	Local $lModelID = DllStructGetData(($aItem), 'ModelID')
	Local $lRarity = GetRarity($aItem)
	Local $t = DllStructGetData($aItem, 'Type')
	If $lModelID == 0 Then Return False
	If $lModelID == 2511 And GetGoldCharacter() < 99000 Then Return True	; gold coins (only pick if character has less than 99k in inventory)
	If $lModelID == 21797 Then Return $pickUpMesmerToms
	If $lModelID > 21785 And $lModelID < 21806 Then Return True	; Elite/Normal Tomes
	If $lModelID == $ITEM_ID_DYES Then	; if dye
		Switch DllStructGetData($aItem, "ExtraID")
			Case $ITEM_EXTRAID_BLACKDYE, $ITEM_EXTRAID_WHITEDYE ; only pick white and black ones
				Return True
			Case Else
				Return False
		EndSwitch
	 EndIf

	If $lModelID == 24629 Or $lModelID == 24630 Or $lModelID == 24631 Or $lModelID == 24632 Then ;map piece
	  Return False
    EndIf

	If $lModelID == $ITEM_ID_LOCKPICKS 		Then Return True
	If $lModelID == $ITEM_ID_GLACIAL_STONES Then Return True

	If $eventOnly Then
		Return IsEvent($lModelID)
	ElseIf IsEvent($lModelID) Then
		Return True
	EndIf

	If $restrictPickUp And PickUpRarity($lRarity) And isWeapon($t) Then
		Return salvageGoodTypeWeap($t)
	ElseIf PickUpRarity($lRarity) Then
		Return True
	EndIf

	Return False
EndFunc

Func PickUpRarity($lRarity)
	If $lRarity == $RARITY_PURPLE			Then Return True
	If $lRarity == $RARITY_BLUE				Then Return True
	If $lRarity == $RARITY_WHITE 			Then Return True
	If $lRarity == $RARITY_GOLD 			Then Return True
Return False
EndFunc

Func PickUpType($t)
	If $t = 2 Then Return True
	If $t = 15 Then Return True
	If $t = 24 Then Return True
	If $t = 27 Then Return True
	If $t = 32 Then Return True
	If $t = 35 Then Return True
	If $t = 36 Then Return True
	Return False
EndFunc

#endregion

; ---- UTILITY ---- ;

#region *UTILITY*

Func freeSlot()
Local $count = 0
	For $i = 1 To 4
		For $j = 1 To $BAG_SLOT[$i - 1]
			If DllStructGetData(GetItemBySlot($i, $j), 'ModelID') == 0 Then $count = $count + 1
		Next
	Next
Return $count
EndFunc

Func debug($txt)
;~ 	MsgBox(0, "", "Debug : " & $txt)
	SendChat($txt, '#')
EndFunc

Func CheckInventory()
	If freeSlot() > $minFreeSlots Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func InventoryIsFull()
	If freeSlot() > 0 Then
		Return False
	Else
		Return True
	EndIf
EndFunc

#endregion
