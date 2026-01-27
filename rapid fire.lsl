default
{
    state_entry()
    {

    }
    attach(key avKey)
    {
        if (avKey)
        {
            llRequestPermissions(avKey, PERMISSION_TAKE_CONTROLS);
        }
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls(CONTROL_ML_LBUTTON, TRUE, TRUE);
        }
    }
    control(key id, integer level, integer edge)
    {
        integer start = level & edge;
        integer end = ~level & edge;
        integer held = level & ~edge;
        integer untouched = ~(level | edge);
        //llOwnerSay(llList2CSV([level, edge, start, end, held, untouched]));
        if (held & CONTROL_ML_LBUTTON)
        {
            llRezObject(
                llGetInventoryName(INVENTORY_OBJECT,0),
                llGetPos(),
                llRot2Fwd(llGetRot()) * 20,
                llGetRot(),
                5
            );
            llTriggerSound("shoot",1.0);
        }
    }
}
