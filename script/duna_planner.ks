set tgt to Duna.
set minDv to 1000000000.0.
FROM {local j is 0.} UNTIL j > 5000 STEP {set j to j+1.} DO {
    set tnow to time:seconds.

    set tman   to random() * ship:orbit:period.
    set dv     to random() * 3000.

    local nd is node(tnow + tman, 0, 0, dv).
    add nd.

    if nd:orbit:HASNEXTPATCH AND nd:orbit:NEXTPATCH:BODY = Sun
    {
        local orb is nd:orbit:NEXTPATCH.
        if orb:HASNEXTPATCH AND orb:NEXTPATCH:BODY = tgt
        {
           if minDv > dv { set minDv to dv. set bestNode to nd. }.
           print orb:NEXTPATCH:BODY.
        }
    }

    remove nd.

}.

if minDv < 10000000 
{
    add bestNode.
}

