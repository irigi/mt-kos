DECLARE FUNCTION PRINT_STATUS {
    PARAMETER T_HEADING.

    PRINT "Pitching to " + ROUND(T_HEADING,1) + " degrees" AT(0,15).
    PRINT ROUND(SHIP:PERIAPSIS,0) + "     " AT (0,16).
    PRINT ROUND(SHIP:APOAPSIS,0) + "     " AT (0,17).
    PRINT kuniverse:timewarp:rate + "     " AT (0,18).
}



CLEARSCREEN.
SET GAS TO 1.
SET WARPING TO FALSE.
LOCK THROTTLE TO GAS.   // 1.0 is the max, 0.0 is idle.

//This is our countdown loop, which cycles from 10 to 0
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "Counting down: " + countdown + "     " AT (0,1).
    WAIT 1. // pauses the script here for 1 second.
}

SET MYSTEER TO HEADING(90,90).
SET H1 TO 20000. SET H2 TO 50000. SET H3 TO 2500000.
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER
UNTIL SHIP:PERIAPSIS > H3 { //Remember, all altitudes will be in meters, not kilometers

  IF WARPING { 
    IF TIME:SECONDS > TIME_WARPSTART + 30 AND kuniverse:timewarp:rate < 1.005 { SET WARPING TO FALSE. }.
  } ELSE {
    // Engines to new value
    LOCK THROTTLE TO GAS.

    // This is control loop for asparagus staging
    SET SHOULD_STAGE TO (SHIP:MAXTHRUST = 0).
    LIST ENGINES IN ENGLIST.
    FOR ENG IN ENGLIST 
    {
      IF ENG:FLAMEOUT { SET SHOULD_STAGE TO TRUE. }
    }
    IF SHOULD_STAGE { 
      PRINT "Staging" + "                 " AT(0,15).
      IF ALT:RADAR > 200 { LOCK THROTTLE TO 0.1. WAIT 1. }.
      STAGE. 
      WAIT 1.
      SET SHOULD_STAGE TO FALSE. 
    }


    // Slow down if not well directed
    SET POINTED_WELL TO VDOT(SHIP:FACING:VECTOR, MYSTEER:VECTOR). 
    IF POINTED_WELL < 0.999 AND ALT:RADAR > H1 {
      SET GAS TO 0.1.
    } ELSE {
      SET GAS TO 1.0.
    }

    //For the initial ascent, we want our steering to be straight
    //up and rolled due east
    IF ALT:RADAR < H1 {
        //This sets our steering 90 degrees up and yawed to the compass
        //heading of 90 degrees (east)
        SET MYSTEER TO HEADING(90,90).
        PRINT_STATUS(90).

    } ELSE IF ALT:RADAR < H2 { 
        SET TARGET_HEADING TO 90 - 90*(ALT:RADAR-H1)/(H2-H1).
        SET MYSTEER TO HEADING(90,TARGET_HEADING).
        PRINT_STATUS(TARGET_HEADING).

    } ELSE {
        SET MYSTEER TO HEADING(90,0).
        PRINT_STATUS(0).

        // Warping towards apogeum
        SET APO_TIMEOUT TO 2*60.
        IF ALT:RADAR > 70000 AND ETA:APOAPSIS > APO_TIMEOUT AND (ETA:APOAPSIS < ETA:PERIAPSIS) AND SHIP:PERIAPSIS < 30000 {
            PRINT "Waiting for apogeum, logic 1" + "                 " AT(0,15).
            PRINT "Time until apogeum " + ETA:APOAPSIS + "                 " AT(0,16).
            LOCK THROTTLE TO 0. WAIT 0.7.
            SET WARPMODE TO "RAILS".
            WARPTO(TIME:SECONDS + ETA:APOAPSIS - 15). 
            SET WARPING TO TRUE. SET TIME_WARPSTART TO TIME:SECONDS.
        }.

        // Warping towards apogeum
        IF ALT:RADAR > 70000 AND SHIP:APOAPSIS > H3 {
          DECLARE RATIO TO ETA:APOAPSIS / ETA:PERIAPSIS.
          IF ETA:APOAPSIS > APO_TIMEOUT AND (RATIO > 2.2 OR (RATIO > 0.2 AND RATIO < 0.5)) {
            PRINT "Waiting for apogeum, logic 2, eRAT " + ETA:APOAPSIS / ETA:PERIAPSIS + "                 " AT(0,15).
            PRINT "Time until apogeum " + ETA:APOAPSIS + "                 " AT(0,16).
            LOCK THROTTLE TO 0. WAIT 0.7.
            SET WARPMODE TO "RAILS".
            WARPTO(TIME:SECONDS + ETA:APOAPSIS - 15). 
            SET WARPING TO TRUE. SET TIME_WARPSTART TO TIME:SECONDS.
          } ELSE {
            PRINT "eRAT " + ETA:APOAPSIS / ETA:PERIAPSIS + ETA:APOAPSIS > APO_TIMEOUT + "         " AT (0,18).
          }.
        }.

    }.
  }. // If warp = 1
}.

PRINT "100km periapsis reached, cutting throttle".


LIST RESOURCES IN resList.
FOR res IN resList {
  IF res:NAME = "LIQUIDFUEL" {
    PRINT "Remaining fuel: " + res:AMOUNT.
  }
}.

//At this point, our apoapsis is above 100km and our main loop has ended. Next
//we'll make sure our throttle is zero and that we're pointed prograde
LOCK THROTTLE TO 0.

SET AG1 TO TRUE. // Outer solar panels

//This sets the user's throttle setting to zero to prevent the throttle
//from returning to the position it was at before the script was run.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
