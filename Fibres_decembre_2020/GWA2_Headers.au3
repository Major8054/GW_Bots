;###########################
;#  by rheek               #
;#  modified by mhaendler  #
;###########################
; v1.6, source: github.com/rheek123/GwBotApiPatcher
;
; This file contains all headers that gwa2 uses to communicate with the gameservers directly.
;
; The headers are named variables. The names should indicate what the header is about.
; The comments give a litte more detail about what the header does.
;
; This makes the source code of gwa2 a little better readable. Also it allows to update headers more easily, as they
; are all now in a small separate place as a list to work yourself through.
; If you need to update the headers, the comments give hints about what action to trigger while recording CtoGS packets.

#include-once
;=QUEST=
;GAME_SMSG_QUEST_ADD
Global Const $HEADER_QUEST_ACCEPT = 0x50	;Accepts a quest from the NPC
Global Const $HEADER_QUEST_REWARD = 0x50	;Retrieves Quest reward from NPC
;GAME_CMSG_QUEST_ABANDON 0x10 or GAME_SMSG_QUEST_REMOVE 0x52
Global Const $HEADER_QUEST_ABANDON = 0x10 ;Abandons the quest

;=HERO=
;GAME_CMSG_HERO_BEHAVIOR
Global Const $HEADER_HERO_AGGRESSION = 0x14	;Sets the heroes aggression level
;GAME_CMSG_HERO_LOCK_TARGET
Global Const $HEADER_HERO_LOCK = 0x15	;Locks the heroes target
;GAME_CMSG_HERO_SKILL_TOGGLE
Global Const $HEADER_HERO_TOGGLE_SKILL = 0x18	;Enables or disables the heroes skill
;GAME_CMSG_HERO_FLAG_SINGLE
Global Const $HEADER_HERO_PLACE_FLAG = 0x19	;Sets the heroes position flag, hero runs to position
Global Const $HEADER_HERO_CLEAR_FLAG = 0x19	;Clears the heroes position flag
;GAME_CMSG_HERO_ADD 0x1D or GAME_SMSG_PARTY_HERO_ADD 0x1C8
Global Const $HEADER_HERO_ADD = 0x1D	;Adds hero to party
;GAME_CMSG_HERO_KICK 0x1E or GAME_SMSG_PARTY_HERO_REMOVE 0x1C9
Global Const $HEADER_HERO_KICK = 0x1E	;Kicks hero from party
Global Const $HEADER_HEROES_KICK = 0x1E	;Kicks ALL heroes from party

;=PARTY=
;GAME_CMSG_HERO_FLAG_ALL
Global Const $HEADER_PARTY_PLACE_FLAG = 0x1A	;Sets the party position flag, all party-npcs runs to position
Global Const $HEADER_PARTY_CLEAR_FLAG = 0x1A	;Clears the party position flag
;GAME_CMSG_PARTY_INVITE_NPC 0x9E or GAME_SMSG_PARTY_HENCHMAN_ADD 0x1C5
Global Const $HEADER_HENCHMAN_ADD = 0x9E	;Adds henchman to party
;GAME_CMSG_PARTY_LEAVE_GROUP
Global Const $HEADER_PARTY_LEAVE = 0xA1	;Leaves the party
;GAME_CMSG_PARTY_KICK_NPC 0xA7 or GAME_SMSG_PARTY_HENCHMAN_REMOVE 0x1C6
Global Const $HEADER_HENCHMAN_KICK = 0xA7	;Kicks a henchman from party
;GAME_CMSG_PARTY_INVITE_PLAYER 0x9F or GAME_SMSG_PARTY_INVITE_ADD 0x01CA
Global Const $HEADER_INVITE_TARGET = 0x9F	;Invite target player to party
;GAME_CMSG_PARTY_ACCEPT_CANCEL 0x9C or GAME_SMSG_PARTY_INVITE_CANCEL 0x01CC
Global Const $HEADER_INVITE_CANCEL = 0x9C	;Cancel invitation of player
;GAME_CMSG_PARTY_ACCEPT_INVITE 0x9B or GAME_SMSG_PARTY_JOIN_REQUEST 0x01CB
Global Const $HEADER_INVITE_ACCEPT = 0x9B	;Accept invitation to party

;=TARGET (Enemies or NPC)=
;GAME_CMSG_TARGET_CALL 0x22
Global Const $HEADER_CALL_TARGET = 0x22	;Calls the target without attacking (Ctrl+Shift+Space)
;GAME_CMSG_ATTACK_AGENT 0x25
Global Const $HEADER_ATTACK_AGENT = 0x25	;Attacks agent (Space IIRC)
;GAME_CMSG_CANCEL_MOVEMENT 0x27 or GAME_SMSG_SKILL_CANCEL 0xE4
Global Const $HEADER_CANCEL_ACTION = 0x27	;Cancels the current action
;GAME_CMSG_INTERACT_PLAYER 0x32
Global Const $HEADER_AGENT_FOLLOW = 0x32	;Follows the agent/npc. Ctrl+Click triggers "I am following Person" in chat
;GAME_CMSG_INTERACT_LIVING
Global Const $HEADER_NPC_TALK = 0x38	;talks/goes to npc
;GAME_CMSG_INTERACT_ITEM 0x3E or GAME_CMSG_INTERACT_GADGET 0x50
Global Const $HEADER_SIGNPOST_RUN = 0x57	;Runs to signpost

;=DROP=
;GAME_CMSG_DROP_ITEM 0x2B
Global Const $HEADER_ITEM_DROP = 0x2B	;Drops item from inventory to ground
;GAME_CMSG_DROP_GOLD
Global Const $HEADER_GOLD_DROP = 0x2E	;Drops gold from inventory to ground

;=BUFFS=
;GAME_CMSG_DROP_BUFF
Global Const $HEADER_STOP_MAINTAIN_ENCH = 0x28	;Drops buff, cancel enchantmant, whatever you call it

;=ITEMS=
;GAME_CMSG_EQUIP_ITEM
Global Const $HEADER_ITEM_EQUIP = 0x2F	;Equips item from inventory/chest/no idea
;GAME_CMSG_INTERACT_ITEM
Global Const $HEADER_ITEM_PICKUP = 0x3E	;Picks up an item from ground
;GAME_CMSG_ITEM_DESTROY
Global Const $HEADER_ITEM_DESTROY = 0x68	;Destroys the item
;GAME_CMSG_ITEM_IDENTIFY
Global Const $HEADER_ITEM_ID = 0x6B	;Identifies item in inventory
;GAME_CMSG_ITEM_MOVE
Global Const $HEADER_ITEM_MOVE = 0x71	;Moves item in inventory
;GAME_CMSG_ITEM_ACCEPT_ALL
Global Const $HEADER_ITEMS_ACCEPT_UNCLAIMED = 0x72	;Accepts ITEMS not picked up in missions
;GAME_CMSG_ITEM_MOVE
Global Const $HEADER_ITEM_MOVE_EX = 0x74	;Moves an item, with amount to be moved.
;GAME_CMSG_ITEM_SALVAGE_MATERIALS
Global Const $HEADER_SALVAGE_MATS = 0x79	;Salvages materials from item
;GAME_CMSG_ITEM_SALVAGE_UPGRADE
Global Const $HEADER_SALVAGE_MODS = 0x7A	;Salvages mods from item
;GAME_CMSG_ITEM_USE
Global Const $HEADER_ITEM_USE = 0x7D	;Uses item from inventory/chest
;GAME_CMSG_UNEQUIP_ITEM
Global Const $HEADER_ITEM_UNEQUIP = 0x4E	;Unequip item
Global Const $HEADER_UPGRADE = 0x87	;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_UPGRADE_ARMOR_1 = 0x84	;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_UPGRADE_ARMOR_2 = 0x87	;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_EQUIP_BAG = 0x71
;Global Const $HEADER_USE_ITEM = 0x85

;=TRADE=
;GAME_SMSG_TRADE_REQUEST
Global Const $HEADER_TRADE_PLAYER = 0x00	;Send trade request to player
;GAME_SMSG_TRADE_ADD_ITEM
Global Const $HEADER_TRADE_OFFER_ITEM = 0x04	;Add item to trade window
;GAME_CMSG_TRADE_SEND_OFFER
Global Const $HEADER_TRADE_SUBMIT_OFFER = 0x03	;Submit offer
;GAME_SMSG_TRADE_CHANGE_OFFER
Global Const $HEADER_TRADE_CHANGE_OFFER = 0x02	;Change offer
;GAME_CMSG_TRADE_CANCEL
Global Const $HEADER_TRADE_CANCEL = 0x01	;Cancel trade
;GAME_CMSG_TRADE_ACCEPT
Global Const $HEADER_TRADE_ACCEPT = 0x07	;Accept trade

;=TRAVEL=
;GAME_CMSG_PARTY_TRAVEL
Global Const $HEADER_MAP_TRAVEL = 0xB0	;Travels to outpost via worldmap
;GAME_CMSG_PARTY_ENTER_GUILD_HALL
Global Const $HEADER_GUILDHALL_TRAVEL = 0xAF	;Travels to guild hall
;GAME_CMSG_PARTY_LEAVE_GUILD_HALL
Global Const $HEADER_GUILDHALL_LEAVE = 0xB1	;Leaves Guildhall

;=FACTION=
;GAME_CMSG_DEPOSIT_FACTION
Global Const $HEADER_FACTION_DONATE = 0x34	;Donates kurzick/luxon faction to ally

;=TITLE=
;GAME_CMSG_TITLE_DISPLAY 0x57 or GAME_SMSG_TITLE_RANK_DISPLAY 0xF5
Global Const $HEADER_TITLE_DISPLAY = 0x57	;Displays title
;GAME_CMSG_TITLE_HIDE
Global Const $HEADER_TITLE_CLEAR = 0x58	;Hides title

;=DIALOG=
;GAME_CMSG_SEND_DIALOG
Global Const $HEADER_DIALOG = 0x3A	;Sends a dialog to NPC
;GAME_CMSG_SKIP_CINEMATIC
Global Const $HEADER_CINEMATIC_SKIP = 0x62	;Skips the cinematic
Global Const $HEADER_HOM_DIALOG = 0x59

;=SKILL / BUILD=
;GAME_CMSG_SKILLBAR_SKILL_SET
Global Const $HEADER_SET_SKILLBAR_SKILL = 0x5B	;Changes a skill on the skillbar
;GAME_CMSG_SKILLBAR_LOAD
Global Const $HEADER_LOAD_SKILLBAR = 0x5C	;Loads a complete build
;GAME_CMSG_CHANGE_SECOND_PROFESSION
Global Const $HEADER_CHANGE_SECONDARY = 0x40	;Changes Secondary class (from Build window, not class changer)
Global Const $HEADER_SKILL_USE_ALLY = 0x4C	;used by gwapi. appears to have changed
Global Const $HEADER_SKILL_USE_FOE = 0x4C	;used by gwapi. appears to have changed
Global Const $HEADER_SKILL_USE_ID = 0x4C	;
Global Const $HEADER_SET_ATTRIBUTES = 0x10	;hidden in init stuff like sendchat
Global Const $HEADER_OPEN_SKILLS = 0x41
;GAME_CMSG_USE_SKILL
Global Const $HEADER_USE_SKILL = 0x45
Global Const $HEADER_PROFESSION_ULOCK = 0x41

;=CHEST=
;GAME_CMSG_OPEN_CHEST
Global Const $HEADER_CHEST_OPEN = 0x52	;Opens a chest (with key AFAIK)
;GAME_CMSG_ITEM_CHANGE_GOLD
Global Const $HEADER_CHANGE_GOLD = 0x7B	;Moves Gold (from chest to inventory, and otherway around IIRC)

;=MISSION=
;GAME_CMSG_PARTY_SET_DIFFICULTY
Global Const $HEADER_MODE_SWITCH = 0x9A	;Toggles hard- and normal mode
;GAME_CMSG_PARTY_ENTER_CHALLENGE
Global Const $HEADER_MISSION_ENTER = 0xA4	;Enter a mission/challenge
Global Const $HEADER_MISSION_FOREIGN_ENTER = 0xAC	;Enters a foreign mission/challenge (no idea honestly)
;GAME_CMSG_PARTY_RETURN_TO_OUTPOST
Global Const $HEADER_OUTPOST_RETURN = 0xA6	;Returns to outpost after /resign

;=CHAT=
;GAME_CMSG_SEND_CHAT_MESSAGE
Global Const $HEADER_SEND_CHAT = 0x63	;Needed for sending messages in chat

;=MOVEMENT=
;GAME_SMSG_AGENT_MOVEMENT_TICK
Global Const $HEADER_MOVEMENT_TICK = 0x1F

;=OTHER CONSTANTS=
Global Const $HEADER_MAX_ATTRIBUTES_CONST_5 = 0x04	;constant at word 5 of max attrib packet. Changed from 3 to four in most recent update
Global Const $HEADER_MAX_ATTRIBUTES_CONST_22	= 0x04	;constant at word 22 of max attrib packet. Changed from 3 to four in most recent update
Global Const $HEADER_OPEN_GB_WINDOW = 0x9F
Global Const $HEADER_CLOSE_GB_WINDOW = 0xA0
Global Const $HEADER_START_RATING_GVG = 0xA9