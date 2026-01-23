integer foompChannel = -5656;
init()
{
    llListen(foompChannel,"","","foomp");
    llSetColor(<llFrand(1.0),llFrand(1.0),llFrand(1.0)>,ALL_SIDES);
    llSetLinkPrimitiveParamsFast(
        LINK_SET,
        [
            PRIM_TEMP_ON_REZ, TRUE
        ]
    );
}
doFoomp()
{
    llSetPrimitiveParams([PRIM_PHYSICS,FALSE]);
    llSetScale(<64,64,64>);
    llSetPrimitiveParams([PRIM_PHYSICS,TRUE]);
    llPlaySound("4ea79eec-a5b6-d27c-e232-0fb955283246",1.0);
}
default
{
    state_entry()
    {
 
    }
    on_rez(integer param)
    {
        if (param)
        {
            init();
        }
    }
    listen(integer channel,string name,key id,string text)
    {
        if (llGetOwnerKey(id) == llGetOwner())
        {
            doFoomp();
        }
    }
}

