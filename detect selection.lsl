default
{
    state_entry()
    {
        llSetTimerEvent(1);
    }
    timer()
    {
        list deets = llGetObjectDetails(llGetKey(),[OBJECT_SELECT_COUNT]);
        integer count = llList2Integer(deets,0);
        if (count > 0)
            llSay(0, "someone is selecting me :(");
    }
}

