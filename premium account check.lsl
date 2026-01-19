integer premCount;
integer accountLevel;
default
{
    state_entry()
    {

    }

    touch_start(integer total_number)
    {
        premCount = 0;
        list agents = llGetAgentList(AGENT_LIST_REGION,[]);
        integer count = llGetListLength(agents);
        while (--count>=0)
        {
            list deets = llGetObjectDetails(llList2Key(agents,count), [OBJECT_NAME,OBJECT_ACCOUNT_LEVEL]);
            accountLevel = (integer)llList2String(deets,1);
            llOwnerSay(llList2String(deets,0) + ": " + (string)accountLevel);
            if (accountLevel > 0)
                premCount++;
        }
        llWhisper(0,"Total premium users in region: " + (string)premCount + " (" + (string)((premCount / (float)llGetListLength(agents)) * 100) + "%)");
    }
}
