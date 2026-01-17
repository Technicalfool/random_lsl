/*
 * A basic Combat2-compatible script for damageable objects.
 * This script also implements a damageable shield system,
 * and resistances to damage types.
 *
 * In this script, shielding is an extra resistance value.
 * You still take damage when shielded, but the damage is
 * reduced by the percent of remaining shield.
 *
 * Requires the region to have combat enabled, and
 * to allow damage adjustment.
 *
 * Default parameters should be okay for a semi-toughened
 * target that can be killed by a standard machine gun doing
 * 100 damage per shot.
 *
 * --Toothless.Draegonne, 2025
 */
 
//Variable declarations. Values are set in the init() function.
list damageModifiers;
list shieldDamageModifiers;
float maxShieldPoints;
float shieldPoints;
float shieldIntegrity;
float shieldRegenerationPerTick;
float tickRate;
float health;
float maxHealth;
float regenerationPerTick;
string emptyChar;
string fullChar;

//Called upon script reset.
init()
{
    /*
     * Lists of damage type modifiers.
     * For each type of damage, 1.0 is no resistance, 0.0 is total resistance.
     * Values above 1.0 will act as a weakness and will INCREASE damage applied.
     */
    
    //Damage modifiers to be applied to health.
    damageModifiers = [
        DAMAGE_TYPE_GENERIC, 1.0,
        DAMAGE_TYPE_ACID, 1.0,
        DAMAGE_TYPE_BLUDGEONING, 1.0,
        DAMAGE_TYPE_COLD, 1.0,
        DAMAGE_TYPE_ELECTRIC, 1.0,
        DAMAGE_TYPE_FIRE, 1.0,
        DAMAGE_TYPE_FORCE, 1.0,
        DAMAGE_TYPE_NECROTIC, 1.0,
        DAMAGE_TYPE_PIERCING, 1.0,
        DAMAGE_TYPE_POISON, 1.0,
        DAMAGE_TYPE_PSYCHIC, 1.0,
        DAMAGE_TYPE_RADIANT, 1.0,
        DAMAGE_TYPE_SLASHING, 1.0,
        DAMAGE_TYPE_SONIC, 1.0,
        DAMAGE_TYPE_EMOTIONAL, 1.0
    ];
    //Damage modifiers to be applied to the shield.
    shieldDamageModifiers = [
        DAMAGE_TYPE_GENERIC, 1.0,
        DAMAGE_TYPE_ACID, 1.0,
        DAMAGE_TYPE_BLUDGEONING, 1.0,
        DAMAGE_TYPE_COLD, 1.0,
        DAMAGE_TYPE_ELECTRIC, 1.0,
        DAMAGE_TYPE_FIRE, 1.0,
        DAMAGE_TYPE_FORCE, 1.0,
        DAMAGE_TYPE_NECROTIC, 1.0,
        DAMAGE_TYPE_PIERCING, 1.0,
        DAMAGE_TYPE_POISON, 1.0,
        DAMAGE_TYPE_PSYCHIC, 1.0,
        DAMAGE_TYPE_RADIANT, 1.0,
        DAMAGE_TYPE_SLASHING, 1.0,
        DAMAGE_TYPE_SONIC, 1.0,
        DAMAGE_TYPE_EMOTIONAL, 1.0
    ];
    
    //Starting values. Tweak to your taste.
    maxShieldPoints = 10000.0;
    shieldPoints = 0.0;
    shieldRegenerationPerTick = 80.0;
    maxHealth = 1000.0;
    health=maxHealth;
    regenerationPerTick = 10.0;
    shieldIntegrity=0.0;
        
    //Do not adjust these unless you know what you are doing.
    tickRate = 0.25; //how much delay between each tick (in seconds).
    emptyChar = "▱";
    fullChar = "▰";
    llSetTimerEvent(tickRate);
}
float getDamageMod(list damageMods,integer damageType)
{
    integer index = llListFindList(damageMods, [damageType]);
    return llList2Float(damageMods, index+1);
}
updateText()
{
    integer s = (integer)(10.0*shieldIntegrity);
    string tString = "🛡 ";
    integer index=0;
    for (; index < s; ++index)
    {
        tString += fullChar;
    }
    for (; index < 10.0; ++index)
    {
        tString += emptyChar;
    }
    index=0;
    s = (integer)((health/maxHealth)*10.0);
    tString += "\n🤍 ";
    for (; index < s; ++index)
    {
        tString += fullChar;
    }
    for (; index < 10.0; ++index)
    {
        tString += emptyChar;
    }
    llSetText(
        tString,
        <1,1,1>,
        1.0
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
    on_damage(integer count)
    {
        integer index;
        for (index = 0; index < count; ++index)
        {
            key id=llDetectedKey(index);
            list damage=llDetectedDamage(index);
            float damagePoints = llList2Float(damage,0);
            integer damageType = llList2Integer(damage,1);
            //First apply shield damage
            if (maxShieldPoints != 0.0)
            {
                shieldPoints -= (damagePoints * getDamageMod(shieldDamageModifiers,damageType));
                if (shieldPoints <= 0)
                    shieldPoints = 0;
                shieldIntegrity = shieldPoints / maxShieldPoints;
            }
            //then apply damage modifiers including shielding
            llAdjustDamage(
                index,
                llList2Float(damage,0)*getDamageMod(damageModifiers,damageType)*(1.0-shieldIntegrity)
            );
        }
    }
    final_damage(integer count)
    {
        health = llList2Float(llGetLinkPrimitiveParams(LINK_THIS,[PRIM_HEALTH]),0);
        integer index;
        list damage = [];
        for (index = 0; index < count; ++index)
        {
            damage=llDetectedDamage(index);
            health -= llList2Float(damage,0);
        }
        if (health <= 0.0)
        {
            llWhisper(0, "DEAD!");
            health = 0.0;
        }
        if (health > maxHealth)
            health = maxHealth;
        llSetLinkPrimitiveParamsFast(
            LINK_THIS,
                [
                    PRIM_HEALTH,
                    health
                ]
        );
    }
    timer()
    {
        health = llList2Float(llGetLinkPrimitiveParams(LINK_THIS,[PRIM_HEALTH]),0);
        if (maxShieldPoints != 0.0)
        {
            shieldPoints += shieldRegenerationPerTick;
            if (shieldPoints > maxShieldPoints)
                shieldPoints = maxShieldPoints;
            shieldIntegrity = shieldPoints / maxShieldPoints;
        }
        health += regenerationPerTick;
        if (health > maxHealth)
            health = maxHealth;
        llSetLinkPrimitiveParamsFast(
            LINK_THIS,
                [
                    PRIM_HEALTH,
                    health
                ]
        );
        updateText();
    }
}

