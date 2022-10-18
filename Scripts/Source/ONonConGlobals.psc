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
    while(i < JArray.count(ONonConGlobals.getDefeatedJArray()))

    i+=1
    endWhile
endFunction

function initJArray() global
    StorageUtil.SetIntValue(none, "ONonCon.JarrayID",JArray.object());save globally. holds objects of type JValue (string, int, float, form, another container)
endFunction

function resetActor(Actor a) global
    ;restore esential status and other possible changes made
    ;remove from JArray
endFunction

function defeatActor(Actor a) global
    ;perform maintenance -> cancel combat for actor
    ;save essential status
    ;set essential if not before
    ;set immune to damage if we can
    ;force him into a kneeling animation if possible
    ;make him interactable
    ;if previously not essential 
        ;> have option to kill him
        ;> have option to sell him as slave
    ;have option to release him
    ;have option to rape him
endFunction

int function getDefeatedJArray() global
    return StorageUtil.getIntValue(none, "ONonCon.JarrayID")
endFunction


