/*
 * A typing effect suitable for a Void Phoenix.
 * Link two small invisible prims. Make them 
 * occupy the same position. Insert this script
 * into the root prim.
 * Wear the resulting linkset on AVATAR_CENTER
 * or any other suitable attachment point.
 * Enjoy the purpley indigo magic.
 *
 * --toothless.draegonne 2026
 */
 
key startSound = "13e2281c-4358-eba0-efe9-787f6c097de4";
key stopSound = "13e2281c-4358-eba0-efe9-787f6c097de4";

list tones; 
integer currentTone;

float volume = 0.2;
float maxSpin = 6;

integer typing;
integer wasTyping;

startParticles()
{
    //radial spikes
    llLinkParticleSystem(
        LINK_ROOT,
        [
            PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_EXPLODE,
            PSYS_SRC_BURST_RADIUS,0.0,
            PSYS_SRC_ANGLE_BEGIN,0,
            PSYS_SRC_ANGLE_END,0,
            PSYS_SRC_TARGET_KEY,llGetKey(),
            PSYS_PART_START_COLOR,<0.500000,0.000000,1.000000>,
            PSYS_PART_END_COLOR,<0.500000,0.500000,1.000000>,
            PSYS_PART_START_ALPHA,0,
            PSYS_PART_END_ALPHA,0.4,
            PSYS_PART_START_GLOW,0,
            PSYS_PART_END_GLOW,0,
            PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
            PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
            PSYS_PART_START_SCALE,<4,3.5,4>,
            PSYS_PART_END_SCALE,<0,0,4>,
            PSYS_SRC_TEXTURE,"d56a427b-9472-0411-6381-bb1b9a6b88c2",
            PSYS_SRC_MAX_AGE,0,
            PSYS_PART_MAX_AGE,3,
            PSYS_SRC_BURST_RATE,0.1,
            PSYS_SRC_BURST_PART_COUNT,1,
            PSYS_SRC_ACCEL,<0.000000,0.000000,0.000000>,
            PSYS_SRC_OMEGA,<0.000000,0.000000,0.000000>,
            PSYS_SRC_BURST_SPEED_MIN,0.01,
            PSYS_SRC_BURST_SPEED_MAX,0.01,
            PSYS_PART_FLAGS,
                0 |
                PSYS_PART_EMISSIVE_MASK |
                PSYS_PART_FOLLOW_VELOCITY_MASK |
                PSYS_PART_INTERP_COLOR_MASK |
                PSYS_PART_INTERP_SCALE_MASK
        ]
    );
    
    //dots
    llLinkParticleSystem(
        LINK_ALL_CHILDREN,
        [
            PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_ANGLE,
            PSYS_SRC_BURST_RADIUS,0.1,
            PSYS_SRC_ANGLE_BEGIN,1.6,
            PSYS_SRC_ANGLE_END,1.5,
            PSYS_SRC_TARGET_KEY,llGetKey(),
            PSYS_PART_START_COLOR,<0.500000,0.500000,1.000000>,
            PSYS_PART_END_COLOR,<0.000000,0.000000,0.500000>,
            PSYS_PART_START_ALPHA,0,
            PSYS_PART_END_ALPHA,1,
            PSYS_PART_START_GLOW,0,
            PSYS_PART_END_GLOW,0.6,
            PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
            PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
            PSYS_PART_START_SCALE,<0.500000,0.500000,4.000000>,
            PSYS_PART_END_SCALE,<0.031250,0.031250,4.000000>,
            PSYS_SRC_TEXTURE,"d7c53c90-bf46-5379-fb8d-ac04cbd3aa61",
            PSYS_SRC_MAX_AGE,0,
            PSYS_PART_MAX_AGE,5,
            PSYS_SRC_BURST_RATE,0,
            PSYS_SRC_BURST_PART_COUNT,2,
            PSYS_SRC_ACCEL,<0.000000,0.000000,0.000000>,
            PSYS_SRC_OMEGA,<0.000000,0.000000,8.000000>,
            PSYS_SRC_BURST_SPEED_MIN,0,
            PSYS_SRC_BURST_SPEED_MAX,0.03,
            PSYS_PART_FLAGS,
                0 |
                PSYS_PART_EMISSIVE_MASK |
                PSYS_PART_INTERP_COLOR_MASK |
                PSYS_PART_INTERP_SCALE_MASK
    ]);
}

stopParticles()
{
    llLinkParticleSystem(LINK_SET,[]);
}

sensorTick()
{
    llTriggerSound(llList2Key(tones,currentTone++),volume);
    if (currentTone>=llGetListLength(tones))
        currentTone=0;
}

default
{
    state_entry()
    {
        llSetTimerEvent(0.2);
        tones = [
            (key)"a6a9f37a-cd42-8e93-59ca-64bff442791c",
            (key)"b383e4eb-5a09-4d02-d0a6-676d19c0fd9c"
        ];
        currentTone=0;
        if (!llSetMemoryLimit(13000))
            llOwnerSay("Could not set memory limit. Defaulting to 64KiB.");
    }
    sensor(integer count)
    {
        sensorTick();
    }
    no_sensor()
    {
        sensorTick();
    }
    attach(key av)
    {
        if (av)
        {
            llRequestPermissions(av,PERMISSION_TAKE_CONTROLS);
        }
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS)
            llTakeControls(CONTROL_ML_LBUTTON,TRUE,TRUE);
    }
    timer()
    {
        typing = llGetAgentInfo(llGetOwner()) & AGENT_TYPING;
        if (typing)
        {
            if (!wasTyping)
            {
                llTriggerSound(startSound,volume);
                startParticles();
                wasTyping = TRUE;
                llSensorRepeat(
                    "",
                    "",
                    AGENT,
                    0.1,
                    0.1,
                    3.0
                );
            }
            llTargetOmega(llVecNorm(<-1+llFrand(2),-1+llFrand(2),-1+llFrand(2)>),-maxSpin*llFrand(maxSpin*2),1.0);
        }
        else{
            if (wasTyping)
            {
                llSensorRemove();
                llTargetOmega(ZERO_VECTOR,0,0);
                llTriggerSound(stopSound,volume);
                stopParticles();
                wasTyping = FALSE;
                currentTone=0;
            }
        }
    }
}

