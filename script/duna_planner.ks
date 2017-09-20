
set tgt to Duna.

DECLARE FUNCTION DTMAN 
{
   parameter tman.
   parameter dv.
   parameter treach.

   local diff is 10.
   local tnow is time:seconds.

   local nd is node(tnow + tman, 0, 0, dv).
   add nd.
   local dst1 is (POSITIONAT(SHIP,tnow + tman + treach) - POSITIONAT(DUNA,tnow + tman + treach)):mag.
   remove nd.

   local nd is node(tnow + tman + diff, 0, 0, dv).
   add nd.
   local dst2 is (POSITIONAT(SHIP,tnow + tman + treach + diff) - POSITIONAT(DUNA,tnow + tman + treach + diff)):mag.
   remove nd.

   return (dst2 - dst1) / diff.
}.

DECLARE FUNCTION DDV 
{
   parameter tman.
   parameter dv.
   parameter treach.

   local diff is 1.
   local tnow is time:seconds.

   local nd is node(tnow + tman, 0, 0, dv).
   add nd.
   local dst1 is (POSITIONAT(SHIP,tnow + tman + treach) - POSITIONAT(DUNA,tnow + tman + treach)):mag.
   remove nd.

   local nd is node(tnow + tman, 0, 0, dv+diff).
   add nd.
   local dst2 is (POSITIONAT(SHIP,tnow + tman + treach) - POSITIONAT(DUNA,tnow + tman + treach)):mag.
   remove nd.

   return (dst2 - dst1) / diff.
}.

DECLARE FUNCTION DTREACH
{
   parameter tman.
   parameter dv.
   parameter treach.

   local diff is 500.
   local tnow is time:seconds.

   local nd is node(tnow + tman, 0, 0, dv).
   add nd.
   local dst1 is (POSITIONAT(SHIP,tnow + tman + treach) - POSITIONAT(DUNA,tnow + tman + treach)):mag.
   local dst2 is (POSITIONAT(SHIP,tnow + tman + treach + diff) - POSITIONAT(DUNA,tnow + tman + treach + diff)):mag.
   remove nd.

   return (dst2 - dst1) / diff.
}.


set tman to 100.
set treach to 9203545/2.0.
set dv to 800.
set minDv to 1000000000.0.
FROM {local j is 0.} UNTIL j > 5000 STEP {set j to j+1.} DO {
    set tnow to time:seconds.

    set tman   to random() * ship:orbit:period.
    set dv     to random() * 3000.

    local nd is node(tnow + tman, 0, 0, dv).
    add nd.

    if nd:orbit:HASNEXTPATCH AND nd:orbit:NEXTPATCH:BODY = Sun
    {
        print "*" AT(0,0).
        local orb is nd:orbit:NEXTPATCH.
        if orb:HASNEXTPATCH AND orb:NEXTPATCH:BODY = Duna
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

