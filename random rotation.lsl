/*
 * Drop this script in a thing. The thing will rotate randomly!
 * --Toothless Draegonne, 2019. Have fun with this script.
 */
default
{
    state_entry()
    {
        llSetTimerEvent(0.5);
    }
    timer()
    {
        llTargetOmega(
            llVecNorm( //Normalize the axis vector
                <1.0-llFrand(2.0),1.0-llFrand(2.0),1.0-llFrand(2.0)> //Specify a random axis
            ),
            llFrand(PI*4), //Random speed
            1.0 //Gain. Leave at 1.0.
        );
        llSetTimerEvent(0.5+llFrand(2.0)); //Set the next timer tick for some random time.
    }
}

