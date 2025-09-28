
; ----------------------- ;
;    INTERNAL USE FOR     ;
;     VAETTIRS MONEY      ;
; ----------------------- ;
; ajouter pommes d'amour
; mettre un Tab d'ID

#include "GWA2.au3"
#include "Items.au3"
Global Const $MATERIAL_TO_SELL[1] = [$MAT_WOOD]

Func IsMaterialToSell($modelId)
	Local $size = UBound($MATERIAL_TO_SELL)
	For $i = 0 To $size - 1
		If $modelId == $MATERIAL_TO_SELL[$i] Then
			Return True
		EndIf
	Next
	Return False
EndFunc

#region *FCTS*

Func CanStock($item, $doStoreGolds)
    Local $lType = DllStructGetData($Item, 'Type')
	Local $lModelID = DllStructGetData(($item), 'ModelID')
	Local $r = GetRarity($item)
	If $lModelID == 0 Then Return False
	If $lModelID == $ITEM_ID_GLACIAL_STONES	Then Return True
	If $lModelID == $ITEM_ID_LOCKPICKS		Then Return True
	If $lModelID == $ITEM_ID_TOTS			Then Return True
	If $lModelID == $ITEM_ID_GOLDEN_EGGS	Then Return False; True - original
	If $lModelID == $ITEM_ID_BUNNIES 		Then Return True
	If $lModelID == $ITEM_ID_CLOVER 		Then Return True
	If $lModelID == $ITEM_ID_PIE			Then Return True
	If $lModelID == $ITEM_ID_CUPCAKES		Then Return False; true
	If $lModelID == $ITEM_ID_SPARKLER		Then Return True
	If $lModelID == $ITEM_ID_HONEYCOMB		Then Return False
	If $lModelID == $ITEM_ID_VICTORY_TOKEN	Then Return True
	If $lModelID == $ITEM_ID_LUNAR_TOKEN	Then Return False; true
	If $lModelID == $ITEM_ID_HUNTERS_ALE	Then Return True
	If $lModelID == $ITEM_ID_PUMPKIN_COOKIE	Then Return True
	If $lModelID == $ITEM_ID_KRYTAN_BRANDY	Then Return True
	If $lModelID == $ITEM_ID_BLUE_DRINK	Then Return True
	If $lModelID == $ITEM_ID_CLOVER_BEER	Then Return True
    If $lModelID == $ITEM_ID_CLOVER		Then Return False; true

	If IsMaterial($lModelID) and $lType == 11 Then
		Return Not IsMaterialToSell($lModelID)
	EndIf

	If $doStoreGolds And $r == $RARITY_GOLD Then
		Return True
	EndIf
	Return False
EndFunc

; find empty slot in Xunlai
Func FindSlotEmpty(ByRef $array)
	For $i = 8 To 11
		For $j = 1 To 25;20
			If DllStructGetData(GetItemBySlot($i, $j),'ModelID') = 0 Then
				$array[0] = $i
				$array[1] = $j
				Return
			EndIf
		Next
	Next
EndFunc

; find slot in Xunlai with "stackable" items < 250
Func FindSlotToStack($item, ByRef $array)
	Local $modelID = DllStructGetData(($item),'ModelID')
	Local $xunlaitem
	Local $xunlaitemID

	For $i = 8 To 11
		For $j = 1 To 25;20
			$xunlaitem = GetItemBySlot($i, $j)
			$xunlaitemID = DllStructGetData(($xunlaitem),'ModelID')
			If $xunlaitemID = $modelID Then
				If DllStructGetData(($xunlaitem),'Quantity') < 250 Then
					$array[0] = $i
					$array[1] = $j
					Return
				EndIf
			EndIf
		Next
	Next
EndFunc

Func IsVaettirsStackable($item)
    Local $lType = DllStructGetData($Item, 'Type')
	Local $modelId = DllStructGetData($item, 'ModelID')
	Local $result = IsMaterial($modelId) and $lType == 11
	$result = IsEvent($modelId) Or $result
	$result = $modelId == $ITEM_ID_LOCKPICKS Or $result
	$result = $modelId == $ITEM_ID_GLACIAL_STONES Or $result
    $result = $modelId == 819 Or $result ; dragon root
    $result = $modelId == 146 Or $result ; dye
	Return $result
EndFunc

Func FindSlot($item, ByRef $array)
	If IsVaettirsStackable($item) Then
		FindSlotToStack($item, $array)

		If $array[0] == 0 And $array[1] == 0 Then
			FindSlotEmpty($array)
		EndIf
	Else
		FindSlotEmpty($array)
	EndIf
EndFunc

Func StorageItem($item)
	Local $array[2] = [0,0]
	FindSlot($item, $array)
	Local $bag = $array[0]
	Local $slot = $array[1]

	MoveItem($item, $bag, $slot)
	Sleep(1500)
EndFunc

Func Storage($doStoreGolds)
	For $i = 1 To 4
		For $j = 1 To $BAG_SLOT[$i-1]
			Local $item = GetItemBySlot($i, $j)
			If CanStock($item, $doStoreGolds) Then
				StorageItem($item)
				If DllStructGetData(GetItemBySlot($i,$j),'ModelID') <> 0 Then
					$j = $j -1
				EndIf
			EndIf
		Next
	Next
EndFunc
Func Storagef()

	For $i = 1 To 4
	   $lbag = GetBag($i)
	   Local $lNumSlots = DllStructGetData($lBag, "slots")
		For $j = 1 To $lNumSlots
			Local $item = GetItemBySlot($i, $j)
			If CanStockf($item) Then
				StorageItem($item)
				If DllStructGetData(GetItemBySlot($i,$j),'ModelID') <> 0 Then
					$j = $j -1
				EndIf
			EndIf
		Next
	Next
 EndFunc
 Func CanStockf($item)
	Local $lModelID = DllStructGetData(($item), 'ModelID')
    Local $lType = DllStructGetData($Item, 'Type')
	Local $r = GetRarity($item)
				If $lmodelid = 956 Then Return True ; boispirite
			    If $lmodelid = 937 Then Return True ; rubis
			    If $lmodelid = 948 Then Return True ; fer
			    If $lmodelid = 929 Then Return True ; dust
			    If $lmodelid = 934 Then Return True ; fibers
			    If $lmodelid = 22751 Then Return True ; Lockpick
			    If $lmodelid = 819 Then Return True ; dragon root
			    ;If $lmodelid = 146 Then Return True; dye

	;If IsMaterial($lModelID) Then
	;	Return Not IsMaterialToSell($lModelID)
	;EndIf

	Return False
 EndFunc
 Func Storagecof()
	For $i = 1 To 4
	   $lbag = GetBag($i)
	   Local $lNumSlots = DllStructGetData($lBag, "slots")
		For $j = 1 To $lNumSlots
			Local $item = GetItemBySlot($i, $j)
			If CanStockcof($item) Then
				StorageItem($item)
				If DllStructGetData(GetItemBySlot($i,$j),'ModelID') <> 0 Then
					$j = $j -1
				EndIf
			EndIf
		Next
	Next
 EndFunc
 Func CanStockcof($item)
	 Local $lType = DllStructGetData($Item, 'Type')
	Local $lModelID = DllStructGetData(($item), 'ModelID')
	Local $r = GetRarity($item)
			    If $lmodelid = 22751 Then Return True ; Lockpick
			    ;If $lmodelid = 819 Then Return True ; dragon root
			    ;If $lmodelid = 146 Then Return True; dye
			    ;If $lmodelid = $MAT_BONE and $lType == 11 Then Return True
			    ;If $lmodelid = $MAT_BONE Then Return True
    If IsMaterial($lModelID) and $lType == 11 Then
		Return True
	EndIf

	Return False
 EndFunc
 ;Func IsMaterial($modelId)
;	Local $size = UBound($MATERIALS)
;	For $i = 0 To $size - 1
;		If $modelId == $MATERIALS[$i] Then
;			Return True
;		EndIf
;	Next
;
;	Return False
;EndFunc
#endregion
