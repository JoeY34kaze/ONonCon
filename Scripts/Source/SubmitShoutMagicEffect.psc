Scriptname SubmitShoutMagicEffect extends ActiveMagicEffect  

MagicEffect Property ShoutEffect  Auto  ;is set in CK
Shout Property SubmitShout  Auto  ; is set in CK, but it showed as none.

; Event received when this effect is first started (OnInit may not have been run yet!)
Event OnEffectStart(Actor akTarget, Actor akCaster)
    if(akTarget == none)
        return
    endIf

    ONonConGlobals.OTrace("SHOUT EFFECT STARTED! ON ");+(akTarget.getactorbase() as form).getname()+" Cast by "+(akCaster.getactorbase() as form).getname())
    if(tryToDefeatActorWithEffect(akTarget))
        defeatActor(akTarget)
    endIf
EndEvent

bool function tryToDefeatActorWithEffect(Actor a)
    float percentageOfHp = a.GetActorValuePercentage("Health")
    if(percentageOfHp <= 0.15)
        return true
    elseif (percentageOfHp<= 0.25)
        return Utility.RandomFloat() as bool
    else
        Debug.Notification("OnonCon - You need to reduce "+(a.getactorbase() as form).getname()+"'s hp below 25% for them to be vulnerable.")
    endIf
endFunction

function defeatActor(Actor a)
    ;this actor needs to be placed in some array somewhere. Global method i guess
endFunction