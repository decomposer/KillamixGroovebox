#include(MidiHandler)

class GrooveBox extends MidiHandler
{
    9 => static int firstButton;

    120 => int bpm;

    firstButton => int currentButton;
    1::minute / bpm / 2 => dur beat;
    1 => int step;

    open(1, 1);

    clear();

    fun void clear()
    {
        for(1 => int channel; channel <= 16; channel++)
        {
            for(1 => int control; control <= 127; control++)
            {
                sendControlOff(channel, control);
            }
        }
    }

    fun void flashButton(int channel, int button)
    {
        sendControlOn(channel, button + firstButton);
        beat => now;
        sendControlOff(channel, button + firstButton);
    }

    fun void groove()
    {
        spork ~ run();

        while(true)
        {
            <<< step >>>;

            spork ~ flashButton(1, step);

            if(step++ == 8)
            {
                1 => step;
            }

            beat => now;
        }
    }
}

(new GrooveBox).groove();
