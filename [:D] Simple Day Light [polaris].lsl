integer currentState;

vector  rgb = <1.0,1.0,1.0>;
float   intensity  = 1.0;             // 0.0 <= intensity <= 1.0
float   radius     = 20.0;            // 0.1 <= radius <= 20.0
float   falloff    = 0.01;            // 0.01 <= falloff <= 2.0
float   glow = 0.3;

init()
{
    currentState=FALSE;
    llSetLinkColor(LINK_THIS,rgb,ALL_SIDES);
    llSetTimerEvent(60.0);
}
switch(integer lightState)
{
    float thisGlow = glow;
    if (!lightState)
        thisGlow = 0.0;
    llSetLinkPrimitiveParamsFast(
        LINK_THIS,
        [
            PRIM_POINT_LIGHT,
                lightState,
                rgb,
                intensity,
                radius,
                falloff,
            PRIM_FULLBRIGHT,
                ALL_SIDES,
                lightState,
            PRIM_GLOW,
                ALL_SIDES,
                thisGlow
        ]
    );
}

default
{
    state_entry()
    {
        init();
    }
    on_rez(integer param)
    {
        llResetScript();
    }
    timer()
    {
        vector sunDir = llGetSunDirection();
        if (sunDir.z < 0) //triggers if day
        {
            if (currentState == FALSE)
            {
                currentState = TRUE;
                switch(currentState);
            }
        }
        else //triggers if not day
        {
            if (currentState == TRUE)
            {
                currentState = FALSE;
                switch(currentState);
            }
        }   
    }
}

