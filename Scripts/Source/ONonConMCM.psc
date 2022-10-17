Scriptname ONonConMCM extends SKI_ConfigBase  
{This represents the ONonCon's MCM Menu.}

bool property modEnabled = false auto hidden
bool property playerIsRapist = false auto hidden
bool property playerIsVictim = false auto hidden
string property loadCheck = "check" auto

string function checkIfFormFileLoaded()
    return loadCheck
endFunction

Event OnConfigInit()
    startup()
    ModName = "ONonCon"
    refreshPages()
EndEvent

function startup()
    modEnabled = isModEnabled()
    playerIsRapist = playerIsRapistSU()
    playerIsVictim = playerIsVictimSU()
endFunction

function refreshPages()
    if modEnabled
        Pages = new string[6]
        Pages[0]= "General"
        Pages[1]= "Agressor"
        Pages[2]= "Defeat"
        Pages[3]= "Follower"
        Pages[4]= "NPC"
        Pages[5]= "About"
    else
        Pages = new string[1]
        Pages[0]= "Install"
    endIf
endFunction


event OnPageReset(string page)
    if page == ""
		LoadCustomContent("ONonCon/logo.dds", 300, 40)
    else
        UnloadCustomContent()
    endIf
    if page == "Install"
        AddToggleOptionST("OPTION_INSTALL","Install",false)
    elseif page == "General"
    elseif page == "Agressor"
        AddToggleOptionST("OPTION_RAPIST","Allow Player to rape",playerIsRapist)
    elseif page == "Defeat"
        AddToggleOptionST("OPTION_DEFEAT","Allow Player to be the defeated",playerIsVictim)
    endIf
endEvent

state OPTION_INSTALL
    event OnSelectST()
        Debug.MessageBox("Mod will be installed once the menu is closed.")
        enableMod()
    endEvent
    event OnDefaultST()
        SetToggleOptionValueST(false)
    endEvent
    event OnHighlightSt()
        SetInfoText("Click to enable mod.")
    endEvent
endState

state OPTION_RAPIST
    event OnSelectST()
        setPlayerIsRapist(true)
    endEvent
    event OnDefaultST()
        setPlayerIsRapist(false)
    endEvent
    event OnHighlightSt()
        SetInfoText("Set to true to allow the player to be the agressor.")
    endEvent
endState

state OPTION_DEFEAT
    event OnSelectST()
        setPlayerVictim(true)
    endEvent
    event OnDefaultST()
        setPlayerVictim(false)
    endEvent
    event OnHighlightSt()
        SetInfoText("Set to true if you want to get raped when your health drops to 0.")
    endEvent
endState

function enableMod()
    setModEnabled()
    postInstallationCleanup()
    Utility.Wait(0.01);waits for 0.01 seconds in game time. Basically waits for user to return to game.
    Debug.Notification("ONonCon Successfully installed")
endFunction

function postInstallationCleanup()
    refreshPages()
endFunction

; ------------------------ StorageUtil helpers

bool function isModEnabled() global
    return StorageUtil.GetIntValue(none, "ONonCon.modEnabled") == 1
endFunction

bool function getModEnabled()
    return modEnabled
endFunction

function setModEnabled()
    StorageUtil.SetIntValue(none,"ONonCon.modEnabled",1)
    modEnabled = true
endFunction

bool function playerIsRapistSU() global
    return StorageUtil.GetIntValue(none, "ONonCon.playerIsRapist") == 1
endFunction

bool function getPlayerIsRapist()
    return playerIsRapist
endFunction

bool function setPlayerIsRapist(bool b)
    StorageUtil.SetIntValue(none,"ONonCon.playerIsRapist",b as int)
    playerIsRapist = b;
    SetToggleOptionValueST(b)
endFunction

bool function playerIsVictimSU() global
    return StorageUtil.GetIntValue(none, "ONonCon.playerIsAllowedToBeRaped") == 1
endFunction

bool function getPlayerIsVictim()
    return playerIsVictim
endFunction

bool function setPlayerVictim(bool b)
    StorageUtil.SetIntValue(none,"ONonCon.playerIsAllowedToBeRaped",b as int)
    playerIsVictim = b;
    SetToggleOptionValueST(b)
    Actor a = Game.GetPlayer()
    ActorBase ab = a.GetLeveledActorBase()
    ab.SetEssential(b)
endFunction