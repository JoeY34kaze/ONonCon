Scriptname ONonConPlayerScript extends ReferenceAlias  
{This represents the ONonCon Player.}

ONonConMCM Property mcm = none auto hidden
OSexIntegrationMain OStim
Actor Property player = none auto hidden
Actor[] currentActors
;https://www.nexusmods.com/skyrimspecialedition/articles/2490
Event OnInit()
	OStim = OUtils.GetOStim()
endEvent

Event OnEnterBleedout()
    Debug.Trace("<ONonCon> Bleedout!")
    Actor p = Game.GetPlayer()
    ;when player enters bleedour, scan for nearby possible enemies who would be willing to persorm noncon scenes. If no one is there, get up after 1 minute.
    ;Debug.Trace("You have entered bleedout and are thus vulnerable to noncon scenes.");
    ;Debug.Trace("Scanning for possible hostile actors.");
    setHostileActors(2048.0); almost 30m
    ;Debug.Trace("Found "+actors.Length+" hostile actors.");
    Debug.Trace("<ONonCon> found "+currentActors.length+" actors within range")

    if (currentActors.length >0)
        pacifyCurrentActors()
        handleAssaultsOnPlayer()
    else
        Debug.Notification("<ONonCon> No valid hostile actors found. You are left to bleed out, but you should recover in 2 minutes.");
        p.SetNoBleedoutRecovery(True)
        Utility.Wait(2)
        FadeToBlack(5)
        Utility.Wait(6)
        FadeFromBlack(1)
        p.RestoreActorValue("health", 100)
        Game.ShakeCamera(none, 3)
    endif
endEvent

function pacifyCurrentActors()
    int i = 0
    while (i<currentActors.length)
        unpacifyActor(currentActors[i])
        i+=1
    endWhile
endFunction

function handleAssaultsOnPlayer()
    Actor p = Game.getPlayer()
    p.StopCombat()
    p.StopCombatAlarm()  
    Debug.Notification("<ONonCon> Found "+currentActors.length+" villing participants to assault you. Hope you brought some lube.")
    OStim.StartScene(p,  currentActors[0])

    while OStim.animationrunning()
        Utility.wait(1)
        if OStim.getactorexcitement(p) > 95
            OStim.warptoanimation("0MF|Sy6!KNy9|Po|KnStraApPo")
            OStim.SetCurrentAnimationSpeed(5)
            ;return ;v skripti je return pa nevem zakaj
        endif
    endwhile
endFunction


function pacifyActor(Actor a)
    {if an actor is in currentActors he should be always pacified}
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

function clearCurrentActors()
    if (Ostim.AnimationRunning())
        Ostim.ForceStop()
    endIf

    pacifyCurrentActors()
endFunction

function setHostileActors(float range)
    Debug.Trace("<ONonCon> inside actor finding function")
    clearCurrentActors();
    ;range : 1 skyrim unit = 1.428 cm. human is about 128 units
    Actor ActorFound
    Actor[] ActorFoundArray = new Actor[20]
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
        i += 1
    endWhile

    currentActors = PapyrusUtil.ActorArray(FoundCount)
    i = 0
    Int FoundCountAdded = 0
    While (i < ScanAmount)
        If (ActorFoundArray[i])
            currentActors[FoundCountAdded] = ActorFoundArray[i]
            FoundCountAdded += 1
            Debug.Trace("<ONonCon> Actor for assault player -> "+(ActorFoundArray[i].getactorbase() as form).getname())
        EndIf
        i += 1
    EndWhile
    Debug.Trace("<ONonCon> Actor Scan Done")
endFunction

bool function willBeDefeated(ObjectReference akAggressor, Form akSource, Projectile akProjectile)
    {calculates whether the incoming hit will defeat the player.}
    float hp = getPlayer().getActorValue("Health")
    bool result = false
    Debug.Notification(""+hp) 
    if hp <= 0
        if isAgressorValidActor(akAggressor) 
            result = true 
        else
            handlePlayerDeath()
        endif 
    endIf 
    return result
endFunction

bool function isAgressorValidActor(ObjectReference akAggressor)
    bool valid = isValidRace(akAggressor.GetSelfAsActor())
    return valid
endFunction

bool function isValidRace(Actor a)
    return true
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