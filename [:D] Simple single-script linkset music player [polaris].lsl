/*
 * Polaris single-script music player
 * By Toothless.Draegonne
 *
 * A very simple notecard-based single-script music player.
 * This script is made to make it wasy for anybody to make their own
 * musicboxes, and is moddable so that you can see how the magic works,
 * and use it to make your own stuff with.
 * 
 * To use:
 * Upload a set of sounds, make sure you know how long each one is.
 * By default, LL limits sounds to <30 seconds, so make yours 29.9 seconds
 * or something. The shorter the sounds, the quicker they preload and the
 * less likely it is that you or other listeners will have breakage due to
 * netlag. There are other ways to optimise sounds, but that's beyond the
 * scope of this tutorial c:
 *
 * Create a notecard, name it.
 * Copy each sample UUID and the length of the sound into the notecard, one pair per line.
 * If you got this thing boxed or as part of a music player, chances are
 * you already have a notecard you can look at.
 *
 * Example notecard:
 * 4146ed38-8058-1922-8d50-8a8b8ce3cc4a 57
 * 6021e628-094c-960d-d356-5c916818a00d 57
 * 638ddc1c-f79c-23f6-98d7-bc210f8d1ae8 57
 * 67ec042e-a93e-0cf0-9788-5feb70580df4 8
 * 
 * Name this notecard "Punch Deck: Longing", and copy into your player
 * prim along with the script.
 * (Obviously, get rid of any asterisks if you copied them directly from the above)
 */
 
/*
 * Pre-declare some global variables
 */
list uuids;
list times;
integer listLength;
integer listPos;
key ncQuery;
string notecardName;
integer notecardLine;
integer playing;
integer cardLoaded;

/*
 * This function is called whenever the script is reset.
 */
init()
{
    playing = FALSE;
    notecardLine = 0;
    cardLoaded = FALSE;
    uuids = [];
    times = [];
    listPos = 0;
    listLength = 0;
    notecardName = llGetInventoryName(INVENTORY_NOTECARD,0);
    ncQuery = llGetNotecardLine(notecardName, notecardLine);
    llSetText("Loading notecard...",<1,1,1>,1.0);
    stopParticles();
}

/*
 * If you want to include some fancy particle systems in your player,
 * insert them in this function. By default, it just turns a light on.
 * Really you could put anything here, but fancy particles are usually
 * enough for most people.
 */
startParticles()
{    
    //light source
    llSetLinkPrimitiveParamsFast(
        LINK_SET,
        [
            PRIM_POINT_LIGHT,
            TRUE, //on
            <1,1,1>, //RGB
            1.0, //intensity 0-1
            10.0, //radius 0-20
            1.6 //falloff 0.01-2
        ]
    );
}

/*
 * Triggered when the player is stopped.
 * By default, this turns off any fancy particle effects and lights,
 * and just starts a simple circle-particle effect.
 */
stopParticles()
{
    llSetLinkPrimitiveParamsFast(
        LINK_SET,
        [
            PRIM_POINT_LIGHT,
            FALSE, //off
            <1,0.0,0.5>, //RGB
            1.0, //intensity 0-1
            10.0, //radius 0-20
            1.6 //falloff 0.01-2
        ]
    );
    llLinkParticleSystem(LINK_SET,[]);
    llLinkParticleSystem(
        LINK_ROOT,
        [
            PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_EXPLODE,
            PSYS_SRC_BURST_RADIUS,0,
            PSYS_SRC_ANGLE_BEGIN,0,
            PSYS_SRC_ANGLE_END,0,
            PSYS_SRC_TARGET_KEY,llGetKey(),
            PSYS_PART_START_COLOR,<1.000000,1.000000,1.000000>,
            PSYS_PART_END_COLOR,<1,1,1>,
            PSYS_PART_START_ALPHA,0,
            PSYS_PART_END_ALPHA,1,
            PSYS_PART_START_GLOW,0,
            PSYS_PART_END_GLOW,0.4,
            PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
            PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
            PSYS_PART_START_SCALE,<2.000000,2.000000,0.000000>,
            PSYS_PART_END_SCALE,<0.100000,0.100000,0.000000>,
            PSYS_SRC_TEXTURE,"d363c372-2e38-3edd-d7c5-16d3c7d73751",
            PSYS_SRC_MAX_AGE,0,
            PSYS_PART_MAX_AGE,6,
            PSYS_SRC_BURST_RATE,2,
            PSYS_SRC_BURST_PART_COUNT,1,
            PSYS_SRC_ACCEL,<0.000000,0.000000,0.000000>,
            PSYS_SRC_OMEGA,<0.000000,0.000000,0.000000>,
            PSYS_SRC_BURST_SPEED_MIN,0,
            PSYS_SRC_BURST_SPEED_MAX,0,
            PSYS_PART_FLAGS,
                0 |
                PSYS_PART_EMISSIVE_MASK |
                PSYS_PART_INTERP_COLOR_MASK |
                PSYS_PART_INTERP_SCALE_MASK |
                PSYS_PART_TARGET_LINEAR_MASK
        ]
    );
}

/*
 * This function is called once per notecard line, and loads the contents into memory.
 */
loadCardLine(string line)
{
    list words = llParseString2List(line,[" "],[]);
    uuids += [llList2Key(words,0)];
    times += [llList2Float(words,1)];
    listLength++;
}

/*
 * This is the default state for the script. It is the entry-point where execution starts.
 */
default
{
    state_entry()
    {
        init(); //Call the init function upon reset.
    }
    on_rez(integer param)
    {
        llResetScript(); //Reset the script whenever the object is rezzed or worn.
    }
    /*
     * The touch_start event is triggered once when you click the object.
     */
    touch_start(integer total_number)
    {
        //Only toggle playing if the card is loaded and the owner clicks it.
        if (cardLoaded && (llDetectedKey(0) == llGetOwner()))
        {
            //trigger the click-beep.
            llTriggerSound("56880494-2e3b-31c7-3b99-e02ab1d7059e",1.0);
            /*
             * "varName = !varName" is a nice way of toggling between true and false.
             * You should use this in your scripts whenever you want to turn something
             * on or off on a buttonpress. c:
             */
            playing = !playing;
            if (!playing) //if not playing, stop everything and reset counters.
            {
                llSetTimerEvent(0.0);
                listPos = 0;
                llStopSound();
                stopParticles();
            }
            else //If playing, say the name of the notecard and start in one second.
            {
                llSay(0, notecardName);
                startParticles();
                llPreloadSound(llList2Key(uuids,0));
                llSetTimerEvent(1.0);
            }
        }
    }
    
    /*
     * This timer is set to go off at the end of each sound, to play the next sound
     * and preload the sound after that.
     */
    timer()
    {
        key uuid = llList2Key(uuids,listPos);
        llPlaySound(uuid,1.0);
        llSetTimerEvent(llList2Float(times,listPos));
        listPos++;
        if (listPos >= listLength)
            listPos = 0;
        llPreloadSound(llList2Key(uuids,listPos));
    }
    
    /*
     * This is where card-loading is handled.
     * Essentially keep triggering the loadCardLine function with
     * incoming new data until there is no more data.
     */
    dataserver(key query, string data)
    {
        if (query == ncQuery)
        {
            if (data == EOF)
            {
                cardLoaded = TRUE;
                llSetText("",<0,0,0>,0.0);
            }
            else
            {
                loadCardLine(data);
                ++notecardLine;
                ncQuery = llGetNotecardLine(notecardName, notecardLine);
            }
        }
    }
}

