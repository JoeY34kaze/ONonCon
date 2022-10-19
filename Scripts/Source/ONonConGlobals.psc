Scriptname ONonConGlobals

;defeatedActors are held in JArray because i cant be fucked to find a better way to deal with global scope view
ONonConMCM Function GetONonConMCM() global
    Quest q = Game.GetFormFromFile(0x00000D62, "ONonCon.esp") as Quest; formId changes if it's flagged as esl while being esp. D62 is for .esp
    ONonConMCM mcm = q as ONonConMCM
    if mcm.checkIfFormFileLoaded() != "check"
        Debug.MessageBox("ONonCon failed to load from formfile. Critical error.");
    else
        Debug.MessageBox("ONonCon successfully fetched via formFile");
    endIf
    return mcm
EndFunction

function OTrace(string s, int severity = 0) global
    if(true)
        Debug.Trace("[ONonCon] "+s,severity)
    endIf
endFunction

function resetDefeatedActors() global
    ;for each actor -> resetActor
    int i =0
    while(i < JArray.count(getDefeatedJArray()))

    i+=1
    endWhile
endFunction

function initJArray() global
    StorageUtil.SetIntValue(none, "ONonCon.JarrayID",JArray.object());save globally. holds objects of type JValue (string, int, float, form, another container)
endFunction

function resetActor(Actor a) global
    ;restore esential status and other possible changes made
    ;remove from JArray
    if(a == none)
        return
    endIf
    int id = (a.getactorbase() as form).GetFormID()
    ONonConGlobals.OTrace("Restoring actor "+(a.getactorbase() as form).getname()+" FORM ID: "+id )
    string actorKey = "ONonCon.essential"
    bool storedEssentialStatus = StorageUtil.GetIntValue(a as form, actorKey) as bool
    a.GetLeveledActorBase().SetEssential(storedEssentialStatus)
    a.RestoreActorValue("health", a.GetActorValueMax("Health")*0.25)
    a.SetNoBleedoutRecovery(false)

    ;reset animations if they're forced into it
endFunction

function defeatActor(Actor a) global
    ;perform maintenance -> cancel combat for actor
    ;save essential status
    ;set essential if not before
    ;set immune to damage if we can
    ;force him into a kneeling animation if possible
    ;make him interactable

    if(a == none)
        return
    endIf
    int id = (a.getactorbase() as form).GetFormID()
    ONonConGlobals.OTrace("Defeating actor "+(a.getactorbase() as form).getname()+" FORM ID: "+id )
    a.StopCombat()
    a.StopCombatAlarm()

    string actorKey = "ONonCon.essential"
    bool actorEssentialStatus = a.GetLeveledActorBase().IsEssential()
    StorageUtil.SetIntValue(a as form, actorKey, actorEssentialStatus as int)

    a.GetLeveledActorBase().SetEssential(true)
    a.AllowBleedoutDialogue(false)
    ;for now, just force them into bleedout with no recovery
    a.SetNoBleedoutRecovery(true)
    a.DamageActorValue("Health", 2 * a.GetActorValueMax("Health"));takes twice full damage so he goes into bleedout

endFunction

int function getDefeatedJArray() global
    return StorageUtil.getIntValue(none, "ONonCon.JarrayID")
endFunction

;For selling actor into slavery
int function getActorGoldWorth(Actor a) global
    return a.GetGoldAmount() + (100 * (1+ (0.1 * a.GetLevel())) as int) + getRaceGoldValue(a)
endFunction

;how much the slavers are willing to pay for a specific race. returns [10 - 100]
int function getRaceGoldValue(Actor a) global
    Race r = a.GetRace()
    bool isMale = a.GetLeveledActorBase().GetSex() == 0
    if(r.IsChildRace())
        if(isMale)
            return 500
        else
            return 1000
        endIf
    ;elseif(r == NordRace)
    endIf
endFunction

;we still need to make defeated actor interactable somehow
;if previously not essential 
        ;> have option to kill him
        ;> have option to sell him as slave
    ;have option to release him
    ;have option to rape him

