key n2k;
key rad;
integer comChannel = 10;
default
{
    state_entry()
    {
        llListen(comChannel,"","","");
    }
    listen(integer channel,string name,key id,string text)
    {
        llSay(0, name + " is requesting current name for: " + text);
        n2k = llRequestUserKey(text);
    }
    dataserver(key id, string data)
    {
        if (id == rad)
            llSay(0,"That name resolves to: " + data);
        if (id == n2k)
        {
            key uuid = (key)data;
            if (uuid != NULL_KEY)
            {
                llSay(0, "Name resolves to uuid: " + data);
                rad = llRequestAgentData(uuid,DATA_NAME);
            }
            else
                llSay(0,"Invalid/unknown name.");
        }
    }
}

