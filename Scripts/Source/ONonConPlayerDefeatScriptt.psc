Scriptname ONonConPlayerDefeatScriptt extends ReferenceAlias  
{This represents the ONonCon Player.}
ONonConMCM Property mcm = none auto hidden
OSexIntegrationMain OStim
ODatabaseScript ODataBase
Actor[] validActors
;https://www.nexusmods.com/skyrimspecialedition/articles/2490
Event OnInit()
    Utility.Wait(1)
	OStim = OUtils.GetOStim()
    ODataBase = Ostim.GetODatabase()
    RegisterForModEvent("ostim_end", "OnEnd")
endEvent

Event OnEnd(string eventName, string strArg, float numArg, Form sender)
    ONonConGlobals.OTrace("On End - Restoring actors and returning control to user.")
    restoreActors()
    Ostim.DisableOSAControls = false
EndEvent

Event OnEnterBleedout()
    ONonConGlobals.OTrace("Bleedout!")
    Actor p = Game.GetPlayer()
    p.StopCombat();stops combat for player
    p.StopCombatAlarm();stops combat for others who are alarmed by the player
    ;when player enters bleedour, scan for nearby possible enemies who would be willing to persorm noncon scenes. If no one is there, get up after 1 minute.
    ;ONonConGlobals.OTrace("You have entered bleedout and are thus vulnerable to noncon scenes.");
    ;ONonConGlobals.OTrace("Scanning for possible hostile actors.");
    setValidActors(2048.0); almost 30m
    ;ONonConGlobals.OTrace("Found "+actors.Length+" hostile actors.");
    ONonConGlobals.OTrace("found "+validActors.length+" actors within range")

    if (validActors.length >0)
        ONonConGlobals.OTrace("found "+validActors.length+" actors, proceeding with sexual assault.")
        ONonConGlobals.OTrace("valid actors length: "+validActors.length)
        SortActorsByRelationship()
        ONonConGlobals.OTrace("valid actors length: "+validActors.length)
        pacifyValidActors()
        ONonConGlobals.OTrace("valid actors length: "+validActors.length)
        Ostim.DisableOSAControls = true
        ONonConGlobals.OTrace("Player OSA controls set to "+!Ostim.DisableOSAControls)
        handleAssaultsOnPlayer()
    else
        Debug.Notification("No valid hostile actors found. You are left to bleed out, but you should recover in a minute.");
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
    ONonConGlobals.OTrace("Sorting actors by relationship.")
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
    ONonConGlobals.OTrace("Sorting actors by relationship done.")
EndFunction

function handleAssaultsOnPlayer()
    Actor p = Game.getPlayer()
    ONonConGlobals.OTrace("Handling assaults on player.")
    int amount = validActors.length

    Actor zThirdActor = none
    ;If(validActors.length > 1)
       ; zThirdActor = validActors[1]
       ;ONonConGlobals.OTrace("Third actor set to "+(zThirdActor.getactorbase() as form).getname())
   ; EndIf
   ;threesome animations are not working as intended.
        String animationString = getRapeAnimationString(validActors[0],zThirdActor)
        ONonConGlobals.OTrace("Animation string set to "+animationString)
        OStim.StartScene(Dom = validActors[0], Sub=p, zUndressDom=false, zUndressSub = true, zAnimateUndress=false, zStartingAnimation = animationString, zThirdActor=zThirdActor, Bed = none, Aggressive = true, AggressingActor = validActors[0])
        ONonConGlobals.OTrace("Ostim scene started.")
endFunction


int function getAllSexualAnimations()
    int animations
    animations = ODatabase.getDatabaseOArray() ;Get every single OSex animation in the game
    animations = odatabase.getAnimationsWithActorCount(animations, 2) ; start by filtering all but the animations for 2 people
    animations = odatabase.getHubAnimations(animations, false) ;take the results above, and filter out hub animations
    animations = odatabase.getTransitoryAnimations(animations, false) ;again take the results above, and further filter out transitory animations
    
    return animations ;this JArray contains all sexy time animations
    endfunction

string function getRapeAnimationString(Actor dom ,Actor zThirdActor)
    ONonConGlobals.OTrace("Fetching starting animation")
    bool playerIsMale = Game.GetPlayer().GetLeveledActorBase().GetSex() == 0
    int numberOfActors = 2
    if(zThirdActor != none)
        numberOfActors=3
    endIf
    return getRandomAgressiveAnimation(numActors = numberOfActors, playerMale = playerIsMale, maledom = dom.GetLeveledActorBase().GetSex() == 0)
endFunction

string function getRandomAgressiveAnimation(int numActors = 2, bool playerMale = true, bool maledom=true)
    int animations
    animations = getAllSexualAnimations()
    int numAllAnims = ODatabase.getLengthOArray(animations) 
    ONonConGlobals.OTrace("found "+numAllAnims+" general animations. let us try to filter them.")

    ;try to find animations with corrent amount of actors
    int animsWithNumActors = ODataBase.GetAnimationsWithActorCount(animations,numActors)
    int numNewAnims = ODatabase.getLengthOArray(animations) 
    if(numNewAnims > 0)
        ;some animations were found, lets filter them further
        animations = animsWithNumActors
        numAllAnims = numNewAnims
        ONonConGlobals.OTrace("after filtering for number of actors -> "+numAllAnims)
    else
        ONonConGlobals.OTrace("No animations were found with "+numActors+" actors, we are ignoring the number of actors")
    endIf
    If(maledom);dom is male
        ONonConGlobals.OTrace(" anim should be MALE dom")
        int aggressiveAnims = ODatabase.GetAnimationsByAggression(animations, true)
        ONonConGlobals.OTrace("number of anims with correct number of actors + aggressive -> "+ODatabase.getLengthOArray(aggressiveAnims))
        int maleDomAnims
        if(ODataBase.getLengthOArray(aggressiveAnims)>0);find animations which are aggressive and dom is main actor
            maleDomAnims= ODatabase.GetAnimationsByMainActor(aggressiveAnims, 0)
            ONonConGlobals.OTrace("number of anims with correct number of actors + aggressive + dom as main actor -> "+ODatabase.getLengthOArray(maleDomAnims))
        endIf
        if(ODataBase.getLengthOArray(maleDomAnims)==0);find animations where dom is main actor
            maleDomAnims= ODatabase.GetAnimationsByMainActor(getAllSexualAnimations(), 0)
            ONonConGlobals.OTrace("since previously we had 0, we will use general animation with dom as main actor -> "+ODatabase.getLengthOArray(maleDomAnims))
        endIf
        return getRandomAnimationFromOArray(maleDomAnims);

        ;if(playerMale);find some 3some animation with male as dom and male as sub
           ; return ""
        ;else;find some 3some animation with male as dom and female as sub

           ; return ""
        ;endIf
    Else;dom is female
        ONonConGlobals.OTrace(" anim should be Fem dom")
        ;try to find femdom animations or at least animations where female is leading
        int femdomAnims = ODatabase.GetAnimationsWithName(animations, "Femdom",  AllowPartialResult = True)
        ONonConGlobals.OTrace("number of anims with correct number of actors + femdom flag -> "+ODatabase.getLengthOArray(femdomAnims))

        if(ODatabase.getLengthOArray(femdomAnims) == 0)
            femdomAnims = ODatabase.GetAnimationsByMainActor(animations, 1); mybe this will get us animations where female is leading the role?
            ONonConGlobals.OTrace("since previously we had 0, we will use general animation with sub as main actor -> "+ODatabase.getLengthOArray(femdomAnims))
        endIf
        return getRandomAnimationFromOArray(femdomAnims)
        ;if(playerMale);find some 3some animation with female as dom and male as sub
           ; return ""
        ;else;find some 3some animation with female as dom and female as sub
            ;return ""
        ;endIf
    EndIf
endFunction

string function getRandomAnimationFromOArray(int animations)
    if(ODataBase.getLengthOArray(animations) == 0)
        ONonConGlobals.OTrace(" We tried picking a random animation from an array of length 0!",2)
    endIf
    return ODatabase.GetSceneID(ODatabase.GetObjectOArray(animations, OStim.RandomInt(0, ODatabase.GetLengthOArray(animations))))
endFunction

function pacifyValidActors()
    ONonConGlobals.OTrace("Pacifying valid actors ("+validActors.Length+")")
    int i = 0
    while (i<validActors.length)
        pacifyActor(validActors[i])
        i+=1
    endWhile
    ONonConGlobals.OTrace("Pacified valid actors")
endFunction

function pacifyActor(Actor a)
    if( a == none)
        ONonConGlobals.OTrace("Actor for pacification was none.",1)
        return
    endIf
    ;if an actor is in validActors he should be always pacified
    int id = (a.getactorbase() as form).GetFormID()
    ONonConGlobals.OTrace("Pacifying actor "+(a.getactorbase() as form).getname()+" FORM ID: "+id )
    ;stop combat and i guess set relations with player to be neutral
    a.StopCombat()
    a.StopCombatAlarm()    

    string actorKey = "ONonCon.pacifiedActors."+id
    int value = a.GetRelationshipRank(Game.GetPlayer())
    StorageUtil.SetIntValue(a as form, actorKey, value)

    ;we should save this relation somewhere in order to restore it later
    a.SetRelationshipRank(Game.GetPlayer(), 1)
    ONonConGlobals.OTrace("Pacified actor "+(a.getactorbase() as form).getname()+" FORM ID: "+id )

endFunction

function unpacifyActor(Actor a)
    if(a==none)
        ONonConGlobals.OTrace("Unpacifying actor who is none.")
        return;
    endIf
    int id = (a.getactorbase() as form).GetFormID()
    string actorKey = "ONonCon.pacifiedActors."+id
    int value = StorageUtil.GetIntValue(a, actorKey, 0)
    a.SetRelationshipRank(Game.GetPlayer(), value)
    StorageUtil.UnsetIntValue(a, actorKey)
    ONonConGlobals.OTrace("Reverted actor pacification "+(a.getactorbase() as form).getname()+" FORM ID: "+id )
endFunction

function restoreActors()
    int i = 0
    while (i<validActors.length)
        unpacifyActor(validActors[i])
        i+=1
    endWhile
    validActors = none
endFunction

function clearActors()
    if (Ostim.AnimationRunning())
        Ostim.ForceStop()
    endIf
    if(validActors == none || validActors.length ==0)
        return
    else
        restoreActors()
    endIf
endFunction

function setValidActors(float range)
    ONonConGlobals.OTrace("inside actor finding function")
    clearActors();
    ;range : 1 skyrim unit = 1.428 cm. human is about 128 units
    Actor ActorFound
    Actor[] ActorFoundArray = new Actor[20]
    String IDs

    Int i = 0
    Int ScanAmount = 20
    Int FoundCount = 0
    While (i < ScanAmount)
    ActorFound = Game.FindRandomActorFromRef(Game.getPlayer(), range)
        If(ActorFound != none)
            If (ActorFoundArray.Find(ActorFound) == -1 && isAgressorValidActor(ActorFound))
                ActorFoundArray[i] = ActorFound
                FoundCount += 1
            EndIf
            i += 1
        endIf
    endWhile

    validActors = PapyrusUtil.ActorArray(FoundCount)
    i = 0
    Int FoundCountAdded = 0
    While (i < ScanAmount)
        If (ActorFoundArray[i])
            validActors[FoundCountAdded] = ActorFoundArray[i]
            FoundCountAdded += 1
            ONonConGlobals.OTrace("Actor for assault player -> "+(ActorFoundArray[i].getactorbase() as form).getname())
        EndIf
        i += 1
    EndWhile
    ONonConGlobals.OTrace("Actor Scan Done")
endFunction


bool function isAgressorValidActor(Actor a)
    if(a == none || a == Game.GetPlayer())
        return false 
    endIf

    bool validRace = isValidRace(a)
    ;bool validRelationship = a.GetRelationshipRank(Game.GetPlayer()) < 1
    ;ONonConGlobals.OTrace("valid agressor : race "+validRace+" , hostile : "+validRelationship+" ( "+a.GetRelationshipRank(Game.GetPlayer())+")");
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
    ;ONonConGlobals.OTrace("ONonCon : You were defeated by an actor which is not valid for rape. Because of the mod's limitations you will be unflagged as potential victim and you will die. If you have death alternative or similar mod which prevents death this means that you must re-enable player victim in MCM.")
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

;from OStim

function FadeToBlack(float time = 1.25)
    Game.FadeOutGame(True, True, 0.0, Time)
    Utility.Wait(Time * 0.70)
    Game.FadeOutGame(False, True, 25.0, 25.0) ; total blackout
EndFunction

function FadeFromBlack(float time = 4.0)
	Game.FadeOutGame(False, True, 0.0, time) ; welcome back
EndFunction