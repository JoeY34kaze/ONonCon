Scriptname ONonConPlayerScript extends ReferenceAlias  
{This represents the ONonCon Player.}

ONonConMCM Property mcm = none auto hidden
OSexIntegrationMain OStim
Actor Property player = none auto hidden
Actor[] validActors
Actor[] allActors
;https://www.nexusmods.com/skyrimspecialedition/articles/2490
Event OnInit()
	OStim = OUtils.GetOStim()
    RegisterForModEvent("ostim_end", "OnEnd")

endEvent

Event OnEnd(string eventName, string strArg, float numArg, Form sender)
    Debug.Trace("On End - Restoring actors and returning control to user.")
    restoreActors()
    Ostim.DisableOSAControls = false
EndEvent

Event OnEnterBleedout()
    Debug.Trace("<ONonCon> Bleedout!")
    Actor p = Game.GetPlayer()
    ;p.StopCombat()
    ;p.StopCombatAlarm()
    ;when player enters bleedour, scan for nearby possible enemies who would be willing to persorm noncon scenes. If no one is there, get up after 1 minute.
    ;Debug.Trace("You have entered bleedout and are thus vulnerable to noncon scenes.");
    ;Debug.Trace("Scanning for possible hostile actors.");
    setValidActors(2048.0); almost 30m
    ;Debug.Trace("Found "+actors.Length+" hostile actors.");
    Debug.Trace("<ONonCon> found "+validActors.length+" actors within range")

    if (validActors.length >0)
        Debug.Trace("<ONonCon> found several actors.")
        SortActorsByRelationship()
        pacifyAllActors()
        Debug.Trace("<ONonCon> pacified")
        Ostim.DisableOSAControls = true
        handleAssaultsOnPlayer()
    else
        Debug.Notification("<ONonCon> No valid hostile actors found. You are left to bleed out, but you should recover in a minute.");
        p.SetNoBleedoutRecovery(True)
        Utility.Wait(60)
        FadeToBlack(5)
        Utility.Wait(6)
        FadeFromBlack(1)
        p.RestoreActorValue("health", 100)
        Game.ShakeCamera(none, 3)
    endif
endEvent


Function SortActorsByRelationship ()
    Int Index1
    Int Index2 = validActors.Length - 1
        While (Index2 > 0)
            Index1 = 0
            While (Index1 < Index2)
                If (validActors[Index1].GetRelationshipRank(Game.GetPlayer()) > validActors[Index1 + 1].GetRelationshipRank(Game.GetPlayer()))
                    Actor temp = validActors [Index1]
                    validActors [Index1] = validActors [Index1 + 1]
                    validActors [Index1 + 1] = temp
                EndIf
                Index1 += 1
            EndWhile
            Index2 -= 1
        EndWhile
    EndFunction

function handleAssaultsOnPlayer()
    Actor p = Game.getPlayer()
    Debug.Notification("<ONonCon> Found "+validActors.length+" villing participants to assault you. Hope you brought some lube.")
    int amount = validActors.length

    Actor thirdActor = none
    If(validActors.length > 1)
        thirdActor = validActors[1]
    EndIf
      ;String animationString
      ;If(validActors[0].GetLeveledActorBase().GetSex() == 0);dom is male
       ; animationString = "OpS|Sta!Sit|Ap|ColiseumMaleStart"
      ;Else;dom is female
       ; animationString = "OpS|LyB!Sta|Ap|ColiseumFemaleStart"
      ;EndIf
      ;OStim.StartScene(validActors[0], p, true, true, false, animationString, thirdActor, none, true, validActors[0])
      OStim.StartScene(validActors[0], p, zThirdActor = thirdActor, aggressive = true, AggressingActor = validActors[0])

endFunction

function pacifyAllActors()
    int i = 0
    while (i<allActors.length)
        pacifyActor(allActors[i])
        i+=1
    endWhile
endFunction

function pacifyActor(Actor a)
    {if an actor is in validActors he should be always pacified}
    int id = (a.getactorbase() as form).GetFormID()
    Debug.Trace("<ONonCon> Pacifying actor "+(a.getactorbase() as form).getname()+" FORM ID: "+id )
    ;stop combat and i guess set relations with player to be neutral
    a.StopCombat()
    a.StopCombatAlarm()    

    string actorKey = "ONonCon.pacifiedActors."+id
    int value = a.GetRelationshipRank(Game.GetPlayer())
    StorageUtil.SetIntValue(a as form, actorKey, value)

    ;we should save this relation somewhere in order to restore it later
    a.SetRelationshipRank(Game.GetPlayer(), 1)
    Debug.Trace("<ONonCon> Pacified actor "+(a.getactorbase() as form).getname()+" FORM ID: "+id )

endFunction

function unpacifyActor(Actor a)
    int id = (a.getactorbase() as form).GetFormID()
    string actorKey = "ONonCon.pacifiedActors."+id
    int value = StorageUtil.GetIntValue(a, actorKey, 0)
    a.SetRelationshipRank(Game.GetPlayer(), value)
    StorageUtil.UnsetIntValue(a, actorKey)
    Debug.Trace("<ONonCon> Reverted actor pacification "+(a.getactorbase() as form).getname()+" FORM ID: "+id )
endFunction

function restoreActors()
    int i = 0
    while (i<allActors.length)
        unpacifyActor(validActors[i])
        i+=1
    endWhile
    validActors = none
    allActors = none
endFunction

function clearAllActors()
    if (Ostim.AnimationRunning())
        Ostim.ForceStop()
    endIf
    pacifyAllActors()
endFunction

function setValidActors(float range)
    Debug.Trace("<ONonCon> inside actor finding function")
    clearAllActors();
    ;range : 1 skyrim unit = 1.428 cm. human is about 128 units
    Actor ActorFound
    Actor[] ActorFoundArray = new Actor[20]
    allActors = new Actor[50]
    String IDs

    Int i = 0
    Int ScanAmount = 20
    Int FoundCount = 0
    While (i < ScanAmount)
    ActorFound = Game.FindRandomActorFromRef(Game.getPlayer(), range)
        If (ActorFoundArray.Find(ActorFound) == -1 && isAgressorValidActor(ActorFound))
            ActorFoundArray[i] = ActorFound
            FoundCount += 1
        EndIf
        if(ActorFoundArray.Find(ActorFound) == -1)
            allActors[i]=ActorFound
        endIf
        i += 1
    endWhile

    validActors = PapyrusUtil.ActorArray(FoundCount)
    allActors = PapyrusUtil.ActorArray(allActors.length)
    i = 0
    Int FoundCountAdded = 0
    While (i < ScanAmount)
        If (ActorFoundArray[i])
            validActors[FoundCountAdded] = ActorFoundArray[i]
            FoundCountAdded += 1
            Debug.Trace("<ONonCon> Actor for assault player -> "+(ActorFoundArray[i].getactorbase() as form).getname())
        EndIf
        i += 1
    EndWhile
    Debug.Trace("<ONonCon> Actor Scan Done")
endFunction


bool function isAgressorValidActor(Actor a)
    if(a == none || a == Game.GetPlayer())
        return false 
    endIf

    bool validRace = isValidRace(a)
    ;bool validRelationship = a.GetRelationshipRank(Game.GetPlayer()) < 1
    ;Debug.Trace("<ONonCon> valid agressor : race "+validRace+" , hostile : "+validRelationship+" ( "+a.GetRelationshipRank(Game.GetPlayer())+")");
    return validRace; && validRelationship
endFunction

bool function isValidRace(Actor a)
    return a.GetRace().HasKeyword(Keyword.GetKeyword("ActorTypeNPC"))
endFunction

function setPlayerEssential(bool b)
    Actor a = Game.GetPlayer()
    ActorBase ab = a.GetLeveledActorBase()
    ab.SetEssential(false)
endFunction

function handlePlayerDeath()
    ;mcm.setPlayerVictim(false);this will be handled by a victim buff being removed and the player will need to re-apply it
    ;Debug.Trace("ONonCon : You were defeated by an actor which is not valid for rape. Because of the mod's limitations you will be unflagged as potential victim and you will die. If you have death alternative or similar mod which prevents death this means that you must re-enable player victim in MCM.")
    Actor p = setPlayerEssential(false);
    Game.GetPlayer().DamageActorValue("Health",1000) ;kills the player i guess since he was defeated by something which cannot rape him, shame
endFunction

ONonConMCM function getMcm()
    if mcm != none
        return mcm
    else
        mcm = ONonConGlobals.GetONonConMCM()
        return mcm
    endIf
endFunction



Actor function getPlayer()
    if player == none
        player = GetActorReference()
    endIf
    return player
endFunction


;from OStim

function FadeToBlack(float time = 1.25)
    Game.FadeOutGame(True, True, 0.0, Time)
    Utility.Wait(Time * 0.70)
    Game.FadeOutGame(False, True, 25.0, 25.0) ; total blackout
EndFunction

function FadeFromBlack(float time = 4.0)
	Game.FadeOutGame(False, True, 0.0, time) ; welcome back
EndFunction