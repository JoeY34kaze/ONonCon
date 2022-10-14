Scriptname ONonConPlayerScript extends ReferenceAlias  
{This represents the ONonCon Player.}

ONonConMCM Property mcm = none auto hidden
Actor Property player = none auto hidden

Event OnInit()

endEvent

Event OnEnterBleedout()
    {when player enters bleedour, scan for nearby possible enemies who would be willing to persorm noncon scenes. If no one is there, get up after 1 minute.}
    ;Debug.MessageBox("You have entered bleedout and are thus vulnerable to noncon scenes.");
    ;Debug.MessageBox("Scanning for possible hostile actors.");
    Actor[] actors = getNearbyHostileActors(2048.0); almost 30m
    ;Debug.MessageBox("Found "+actors.Length+" hostile actors.");

    if actors.length >0
        Debug.Notification("Found "+actors.length+" villing participants to assault you. Hope you brought some lube.")
        
    else
        Debug.Notification("No valid hostile actors found. You are left to bleed out, but you should recover in 2 minutes.");
        Actor p = Game.GetPlayer();
        p.SetNoBleedoutRecovery(True)
        Utility.Wait(120)
        FadeToBlack(5)
        Utility.Wait(6)
        FadeFromBlack(1)
        p.RestoreActorValue("health", 100)
        Game.ShakeCamera(none, 3)
    endif

endEvent



Actor[] function getNearbyHostileActors(float range)
    {range : 1 skyrim unit = 1.428 cm. human is about 128 units}
    Actor ActorFound
    Actor[] ActorFoundArray = new Actor[20]
    String IDs

    Int i = 0
    Int ScanAmount = 20
    Int FoundCount = 0
    While (i < ScanAmount)
    ActorFound = Game.FindRandomActorFromRef(Game.getPlayer(), range)
        If (ActorFoundArray.Find(ActorFound) == -1)
            ActorFoundArray[i] = ActorFound
            FoundCount += 1
        EndIf
        i += 1
    endWhile

    Actor[] hostileActors = PapyrusUtil.ActorArray(FoundCount)
    i = 0
    Int FoundCountAdded = 0
    While (i < ScanAmount)
        If (ActorFoundArray[i])
            hostileActors[FoundCountAdded] = ActorFoundArray[i]
            FoundCountAdded += 1
        EndIf
        i += 1
    EndWhile
    Debug.Notification("Scan Done")
    return hostileActors
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
    return isValidRace(akAggressor.GetSelfAsActor())
 
endFunction

bool function isValidRace(Actor a)
    return a.GetRace().IsPlayable()
endFunction

function setPlayerEssential(bool b)
    Actor a = Game.GetPlayer()
    ActorBase ab = a.GetLeveledActorBase()
    ab.SetEssential(false)
endFunction

function handlePlayerDeath()
    ;mcm.setPlayerVictim(false);this will be handled by a victim buff being removed and the player will need to re-apply it
    ;Debug.MessageBox("ONonCon : You were defeated by an actor which is not valid for rape. Because of the mod's limitations you will be unflagged as potential victim and you will die. If you have death alternative or similar mod which prevents death this means that you must re-enable player victim in MCM.")
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


;from ostim

function FadeToBlack(float time = 1.25)
    Game.FadeOutGame(True, True, 0.0, Time)
    Utility.Wait(Time * 0.70)
    Game.FadeOutGame(False, True, 25.0, 25.0) ; total blackout
EndFunction

function FadeFromBlack(float time = 4.0)
	Game.FadeOutGame(False, True, 0.0, time) ; welcome back
EndFunction