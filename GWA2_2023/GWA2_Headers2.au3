#include-once
;=QUEST=
Global Const $HEADER_QUEST_ACCEPT = 0x41	;Accepts a quest from the NPC
Global Const $HEADER_QUEST_REWARD = 0x41	;Retrieves Quest reward from NPC
Global Const $HEADER_QUEST_ABANDON = 0x10 ;Abandons the quest

;=HERO=
Global Const $HEADER_HERO_AGGRESSION = 0x13	;Sets the heroes aggression level
Global Const $HEADER_HERO_LOCK = 0x14	;Locks the heroes target
Global Const $HEADER_HERO_TOGGLE_SKILL = 0x17	;Enables or disables the heroes skill
Global Const $HEADER_HERO_CLEAR_FLAG = 0x18	;Clears the heroes position flag
Global Const $HEADER_HERO_PLACE_FLAG = 0x18	;Sets the heroes position flag, hero runs to position
Global Const $HEADER_HERO_ADD = 0x1C	;Adds hero to party
Global Const $HEADER_HERO_KICK = 0x1D	;Kicks hero from party
Global Const $HEADER_HEROES_KICK = 0x1D	;Kicks ALL heroes from party
Global Const $HEADER_USE_HERO_SKILL = 0x1A	;for use with UseHeroSkillByPacket() only

;=PARTY=
Global Const $HEADER_PARTY_PLACE_FLAG = 0x19	;Sets the party position flag, all party-npcs runs to position
Global Const $HEADER_PARTY_CLEAR_FLAG = 0x19	;Clears the party position flag
Global Const $HEADER_HENCHMAN_ADD = 0x9D	;Adds henchman to party
Global Const $HEADER_PARTY_LEAVE = 0xA0	;Leaves the party
Global Const $HEADER_HENCHMAN_KICK = 0xA6	;Kicks a henchman from party
Global Const $HEADER_INVITE_TARGET = 0x9E	;Invite target player to party
Global Const $HEADER_INVITE_CANCEL = 0x9B	;Cancel invitation of player
Global Const $HEADER_INVITE_ACCEPT = 0x9A	;Accept invitation to party

;=TARGET (Enemies or NPC)
Global Const $HEADER_CALL_TARGET = 0x21	;Calls the target without attacking (Ctrl+Shift+Space)
Global Const $HEADER_ATTACK_AGENT = 0x24	;Attacks agent (Space IIRC)
Global Const $HEADER_CANCEL_ACTION = 0x26	;Cancels the current action
Global Const $HEADER_AGENT_FOLLOW = 0x31	;Follows the agent/npc. Ctrl+Click triggers "I am following Person" in chat
Global Const $HEADER_NPC_TALK = 0x37	;talks/goes to npc
Global Const $HEADER_SIGNPOST_RUN = 0x57	;Runs to signpost -broken

;=DROP=
Global Const $HEADER_ITEM_DROP = 0x2A	;Drops item from inventory to ground
Global Const $HEADER_GOLD_DROP = 0x2D	;Drops gold from inventory to ground

;=BUFFS=
Global Const $HEADER_STOP_MAINTAIN_ENCH = 0x27	;Drops buff, cancel enchantmant, whatever you call it

;=ITEMS=
Global Const $HEADER_ITEM_EQUIP = 0x2E	;Equips item from inventory/chest/no idea
Global Const $HEADER_ITEM_PICKUP = 0x3D	;Picks up an item from ground
Global Const $HEADER_ITEM_DESTROY = 0x67	;Destroys the item
Global Const $HEADER_ITEM_ID = 0x6A	;Identifies item in inventory
Global Const $HEADER_ITEM_MOVE = 0x70	;Moves item in inventory
Global Const $HEADER_ITEMS_ACCEPT_UNCLAIMED = 0x71	;Accepts ITEMS not picked up in missions
Global Const $HEADER_ITEM_MOVE_EX = 0x79	;Moves an item, with amount to be moved. -broken
Global Const $HEADER_SALVAGE_MATS = 0x78	;Salvages materials from item
Global Const $HEADER_SALVAGE_MODS = 0x79	;Salvages mods from item
Global Const $HEADER_ITEM_USE = 0x7C	;Uses item from inventory/chest
Global Const $HEADER_ITEM_UNEQUIP = 0x4D	;Unequip item
Global Const $HEADER_UPGRADE = 0x84	;used by gwapi. is it even useful? NOT TESTED -broken
Global Const $HEADER_UPGRADE_ARMOR_1 = 0x81	;used by gwapi. is it even useful? NOT TESTED -broken
Global Const $HEADER_UPGRADE_ARMOR_2 = 0x84	;used by gwapi. is it even useful? NOT TESTED -broken

;=TRADE= not touched
Global Const $HEADER_TRADE_PLAYER = 0x47	;Send trade request to player
Global Const $HEADER_TRADE_OFFER_ITEM = 0x02	;Add item to trade window
Global Const $HEADER_TRADE_SUBMIT_OFFER = 0x03	;Submit offer
Global Const $HEADER_TRADE_CHANGE_OFFER = 0x06	;Change offer
Global Const $HEADER_TRADE_CANCEL = 0x01	;Cancel trade
Global Const $HEADER_TRADE_ACCEPT = 0x07	;Accept trade

;=TRAVEL=
Global Const $HEADER_MAP_TRAVEL = 0xAF	;Travels to outpost via worldmap
Global Const $HEADER_GUILDHALL_TRAVEL = 0xAE	;Travels to guild hall
Global Const $HEADER_GUILDHALL_LEAVE = 0xB1	;Leaves Guildhall

;=FACTION= not touched
Global Const $HEADER_FACTION_DONATE = 0x33	;Donates kurzick/luxon faction to ally

;=TITLE=
Global Const $HEADER_TITLE_DISPLAY = 0x56	;Displays title (from Gigis Vaettir Bot)
Global Const $HEADER_TITLE_CLEAR = 0x57	;Hides title (from Gigis Vaettir Bot)

;=DIALOG= Not touched
Global Const $HEADER_DIALOG = 0x39	;Sends a dialog to NPC
Global Const $HEADER_CINEMATIC_SKIP = 0x61	;Skips the cinematic

;=SKILL / BUILD=
Global Const $HEADER_SKILL_CHANGE = 0x5C	;Changes a skill on the skillbar
Global Const $HEADER_BUILD_LOAD = 0x5B	;Loads a complete build
Global Const $HEADER_CHANGE_SECONDARY = 0x48	;Changes Secondary class (from Build window, not class changer)
;= Not touched
Global Const $HEADER_SKILL_USE_ALLY = 0x4D	;used by gwapi. appears to have changed -broken
Global Const $HEADER_SKILL_USE_FOE = 0x4D	;used by gwapi. appears to have changed -broken
Global Const $HEADER_SKILL_USE_ID = 0x44	;
Global Const $HEADER_SET_ATTRIBUTES = 0x0E	;hidden in init stuff like sendchat

;=CHEST= not touched
Global Const $HEADER_CHEST_OPEN = 0x51	;Opens a chest (with key AFAIK)

Global Const $HEADER_GOLD_MOVE = 0x7A	;Moves Gold (from chest to inventory, and otherway around IIRC)

;=MISSION=
Global Const $HEADER_MODE_SWITCH = 0x99	;Toggles hard- and normal mode
Global Const $HEADER_MISSION_ENTER = 0xA3	;Enter a mission/challenge
Global Const $HEADER_MISSION_FOREIGN_ENTER = 0xA3	;Enters a foreign mission/challenge (no idea honestly)
Global Const $HEADER_OUTPOST_RETURN = 0xA5	;Returns to outpost after /resign

;=CHAT=
Global Const $HEADER_SEND_CHAT = 0x62	;Needed for sending messages in chat

;=OTHER CONSTANTS=
Global Const $HEADER_MAX_ATTRIBUTES_CONST_5 = 0x04	;constant at word 5 of max attrib packet. Changed from 3 to four in most recent update -broken
Global Const $HEADER_MAX_ATTRIBUTES_CONST_22	= 0x04	;constant at word 22 of max attrib packet. Changed from 3 to four in most recent update -broken
