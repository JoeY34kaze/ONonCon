Scriptname ONonConGlobals

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