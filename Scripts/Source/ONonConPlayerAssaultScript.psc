Scriptname ONonConPlayerAssaultScript extends ReferenceAlias  
{should handle the logic neccessary for player to assault others}
ONonConMCM Property mcm = none auto hidden

Actor[] defeatedActors
OSexIntegrationMain OStim
ODatabaseScript ODataBase

Event OnInit()
    Utility.Wait(1)
	OStim = OUtils.GetOStim()
    ODataBase = Ostim.GetODatabase()
    RegisterForModEvent("ostim_end", "OnEnd")
endEvent

Event OnEnd(string eventName, string strArg, float numArg, Form sender)

EndEvent

ONonConMCM function getMcm()
    if mcm != none
        return mcm
    else
        mcm = ONonConGlobals.GetONonConMCM()
        return mcm
    endIf
endFunction