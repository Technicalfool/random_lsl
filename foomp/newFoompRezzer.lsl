integer maxRezCount;
integer currentRezCount;
string objName;
init()
{
    maxRezCount = 100;
    currentRezCount = 0;
    objName = llGetInventoryName(INVENTORY_OBJECT,0);
}
default
{
    state_entry()
    {
        init();
    }
    touch_start(integer count)
    {
        llSetTimerEvent(0.1);
    }
    timer()
    {
        llRezObject(
            objName,
            llGetPos() + <-5+llFrand(10),-5+llFrand(10),2>,
            ZERO_VECTOR,
            ZERO_ROTATION,
            TRUE
        );
        currentRezCount++;
        if (currentRezCount > maxRezCount)
        {
            llRegionSay(-5656, "foomp");
            llSetTimerEvent(0.0);
            currentRezCount = 0;
        }
    }
}

