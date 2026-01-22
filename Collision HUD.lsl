integer linkAgents;
integer linkPrims;
integer linkActivePrims;
integer linkScriptedPrims;

integer detectAgents = FALSE;
integer detectPrims = FALSE;
integer detectActivePrims = FALSE;
integer detectScriptedPrims = FALSE;

init()
{
    linkAgents = 1;
    linkPrims = 2;
    linkActivePrims = 3;
    linkScriptedPrims = 4;
    /*detectAgents = FALSE;
    detectPrims = FALSE;
    detectActivePrims = FALSE;
    detectScriptedPrims = FALSE;*/
    setButtonRGB(linkAgents,detectAgents);
    setButtonRGB(linkPrims,detectPrims);
    setButtonRGB(linkActivePrims,detectActivePrims);
    setButtonRGB(linkScriptedPrims,detectScriptedPrims);
    llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
}

doButtonPush(integer linkNum, integer bool)
{
    setButtonRGB(linkNum, bool);
    if (bool)
    {
        llPlaySound("05b160b2-3095-2e3c-8376-3b7e00793c0b",0.2);
    }
    else
    {
        llPlaySound("62840c4b-c4f7-0c01-ddbe-5e41bfeef027",0.2);
    }
}

setButtonRGB(integer linkNum, integer bool)
{
    if (bool)
    {
        llSetLinkColor(linkNum, <0,1,0>,ALL_SIDES);
    }
    else
    {
        llSetLinkColor(linkNum, <1,1,1>,ALL_SIDES);
    }
}

default
{
    state_entry()
    {
        init();
    }
    on_rez(integer param)
    {
        init();
    }
    attach(key avKey)
    {
        init();
    }
    run_time_permissions(integer perm)
    {
        /*
         * Because no-outside-scripts can eat a dick. This HUD will work even if
         * the parcel owner wants to fuck with you. Of course, an EM can disable
         * scripts at the EM level, but then everything turns off and this HUD
         * won't be necessary :>
         */
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls(CONTROL_ML_LBUTTON, TRUE, TRUE);
        }
    }
    touch_start(integer count)
    {
        integer lnkNum = llDetectedLinkNumber(0);
        if (lnkNum == linkAgents)
        {
            detectAgents = !detectAgents;
            doButtonPush(lnkNum, detectAgents);
        }
        if (lnkNum == linkPrims)
        {
            detectPrims = !detectPrims;
            doButtonPush(lnkNum, detectPrims);
        }
        if (lnkNum == linkActivePrims)
        {
            detectActivePrims = !detectActivePrims;
            doButtonPush(lnkNum, detectActivePrims);
        }
        if (lnkNum == linkScriptedPrims)
        {
            detectScriptedPrims = !detectScriptedPrims;
            doButtonPush(lnkNum, detectScriptedPrims);            
        }
    }
    collision_start(integer count)
    {
        string colliderType = "";
        string colliderName = ""; //Name for objects, slurl for agents
        string colliderOwner = ""; //If not an agent, owner goes here
        string colliderCreator = "";
        key objKey;
        integer isAgent;
        integer isPassivePrim;
        integer isActivePrim;
        integer isScriptedPrim;
        while (--count >= 0) //Because there might be >1 detected collider.
        {
            colliderType = "";
            colliderOwner = "";
            colliderName = "";
            colliderCreator = "";
            isAgent = FALSE;
            isPassivePrim = FALSE;
            isActivePrim = FALSE;
            isScriptedPrim = FALSE;
            objKey = llDetectedKey(count);
            integer type = llDetectedType(count);
            if (type & AGENT)
            {
                if (detectAgents)
                {
                    colliderType += "[Agent]";
                    colliderName = "[Name: secondlife:///app/agent/" + (string)objKey + "/about ]";
                }   
                isAgent = TRUE;
            }
            if (!isAgent)
            {
                if (detectActivePrims | detectPrims | detectScriptedPrims)
                {
                    colliderOwner = "[Owner: secondlife:///app/agent/" + (string)llDetectedOwner(count) + "/about ]";
                    colliderName = "[Name: " + llDetectedName(count) + "]";
                    list oParams = llGetObjectDetails(objKey, [OBJECT_CREATOR]);
                    string creator = llList2String(oParams,0);
                    if (llStringLength(creator) > 0) //Because sometimes LSL poops out.
                    {
                        colliderCreator = "[Creator: secondlife:///app/agent/" + llList2String(oParams,0) + "/about ]";
                    }

                    if ((type & ACTIVE) && detectActivePrims)
                    {
                        colliderType += "[Active]";
                        isActivePrim = TRUE;
                    }
                    if ((type & PASSIVE) && detectPrims)
                    {
                        colliderType += "[Passive]";
                        isPassivePrim = TRUE;
                    }
                    if ((type & SCRIPTED) && detectScriptedPrims)
                    {
                        colliderType += "[Scripted]";
                        isScriptedPrim = TRUE;
                    }
                }
            }
            //llWhisper(0, colliderType + colliderCreator + colliderOwner + colliderName);
            if (isAgent | isPassivePrim | isActivePrim | isScriptedPrim)
                llOwnerSay(colliderType + colliderCreator + colliderOwner + colliderName);
        }
    }
}

