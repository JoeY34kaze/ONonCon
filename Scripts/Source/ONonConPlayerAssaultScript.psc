Scriptname ONonConPlayerAssaultScript extends ReferenceAlias  
{should handle the logic neccessary for player to assault others}
ONonConMCM Property mcm = none auto hidden
OSexIntegrationMain OStim
ODatabaseScript ODataBase

;actors will get defeated by shouts. Player can interact with them only after combat has ended. (18.10 20:38)

Event OnInit()
    Utility.Wait(1)
	OStim = OUtils.GetOStim()
    ODataBase = Ostim.GetODatabase()
    RegisterForModEvent("ostim_end", "OnEnd")
    RegisterForUpdate(2.0)
endEvent

Event OnEnd(string eventName, string strArg, float numArg, Form sender)
;fired when ostim scene ends

EndEvent

bool function playerInCombat()
return Game.GetPlayer().GetCombatState() == 1
endFunction

ONonConMCM function getMcm()
    if mcm != none
        return mcm
    else
        mcm = ONonConGlobals.GetONonConMCM()
        return mcm
    endIf
endFunction


;(18.10 16:38)
;1 somehow mark every person the player has defeated as defeated. (save essential status, set essential, prevent breaking actions on essential characters.)
;2. after combat has ended for the player, provide a way for the player to interact with defeated actor / actors
    ; -> we will make a custom shout which will have a chance to defeat actors and have them submit. Something like mybe if they are delow 25% there is a chance they get defeated and if they are below 10% they are always defeated.
    
;3 perform sex animation
;4 optionally try to sell them to slavery ( separate simple script?)
;5 abduct them ( separate script?)
;
;
;