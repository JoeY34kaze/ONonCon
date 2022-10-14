Scriptname ONonConGlobals

ONonConMCM Function GetONonConMCM() global
    Quest q = Game.GetFormFromFile(0x00000D62, "ONonCon.esp") as Quest; formId changes if it's flagged as esl while being esp. D62 is for .esp
    ONonConMCM mcm = q as ONonConMCM
    if mcm.checkIfFormFileLoaded() != "check"
        Debug.Trace("ONonCon failed to load from formfile. Critical error.",2);
    else
        Debug.Trace("ONonCon successfully fetched via formFile",1);
    endIf
    return mcm
EndFunction

OSexIntegrationMain Function GetOStim() Global
	quest q = game.GetFormFromFile(0x000801, "Ostim.esp") as quest
	return (q as OSexIntegrationMain)
EndFunction