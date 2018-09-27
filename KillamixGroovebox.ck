#include(MidiHandler)
#include(MidiValues)

class GrooveBox extends MidiHandler
{
    9 => static int firstButton;
    200::ms => static dur flash;

    120 => int bpm;

    firstButton => int currentButton;
    1::minute / bpm / 2 => dur beat;
    1 => int step;
    1 => int channel;
    int notes[16][8];
    new MidiHandler @=> MidiHandler @ output;

    open(1, 1);
    output.open(0, 0);
    clear();

    fun void clear()
    {
        for(1 => int channel; channel <= 16; channel++)
        {
            for(1 => int control; control <= 127; control++)
            {
                sendControlOff(channel, control);
            }
            [ 0, 0, 0, 0, 0, 0, 0, 0 ] @=> notes[channel - 1];
        }
    }

    fun void flashButton(int channel, int button)
    {
        if(notes[channel - 1][button - 1])
        {
            sendControlOff(channel, button + firstButton);
            flash / 2 => now;
            sendControlOn(channel, button + firstButton);
        }
        else
        {
            sendControlOn(channel, button + firstButton);
            flash => now;
            sendControlOff(channel, button + firstButton);
        }
    }

    fun void controlChange(int channel, int control, int value)
    {
        <<< "Control Change: ", channel, control, value >>>;
        if(control >= firstButton && control <= firstButton + 8)
        {
            <<< "setting", channel, control - firstButton, value > 0 ? 1 : 0 >>>;
            value > 0 ? 1 : 0 => notes[channel - 1][control - firstButton - 1];
            <<< notes[channel - 1][control - firstButton - 1] >>>;
        }
        else if(control == 23)
        {
            <<< "channel", channel >>>;
            channel => this.channel;
        }
    }

    fun void groove()
    {
        spork ~ run();

        while(true)
        {
            for(1 => int channel; channel <= 16; channel++)
            {
                if(notes[channel - 1][step - 1])
                {
                    spork ~ output.sendNote(1, channel - 1 + midi["C1"], 127, beat);
                }
            }

            spork ~ flashButton(channel, step);

            if(step++ == 8)
            {
                1 => step;
            }

            beat => now;
        }
    }
}

(new GrooveBox).groove();
