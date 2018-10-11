#include(MidiHandler)
#include(MidiValues)

class GrooveBox extends MidiHandler
{
    // These 4 should be set in a subclass

    int inputDevice;
    int outputDevice;
    int firstButton;
    int buttonCount;

    200::ms => static dur flash;

    dur beat;
    int currentButton;

    1 => int step;
    1 => int channel;
    false => int flashing;
    false => int playing;

    int notes[][];

    MidiHandler output;

    fun void setup()
    {
        firstButton => currentButton;

        open(inputDevice, inputDevice);
        output.open(outputDevice, outputDevice);

        setBPM(120);

        clear();
    }

    fun void clear()
    {
        for(1 => int channel; channel <= 16; channel++)
        {
            for(1 => int control; control <= 127; control++)
            {
                sendControlOff(channel, control);
            }
        }

        int notes[16][buttonCount];
        notes @=> this.notes;

        resetControls(this);
        resetControls(output);
    }

    fun void resetControls(MidiHandler @ handler)
    {
        <<< "reset" >>>;
    }

    fun void setBPM(int bpm)
    {
        1::minute / bpm / (buttonCount / 4.0) => beat;
    }

    fun void flashButton(int channel, int button)
    {
        true => flashing;

        if(notes[channel - 1][button - 1])
        {
            sendControlOff(channel, button + firstButton);
            flash / 2 => now;
        }
        else
        {
            sendControlOn(channel, button + firstButton);
            flash => now;
        }

        sendControlChange(channel, button + firstButton,
                          notes[channel - 1][button - 1] ? 127 : 0);
        false => flashing;
    }

    fun void controlChange(int channel, int control, int value)
    {
        <<< "Control Change: ", channel, control, value >>>;
        if(control >= firstButton && control <= firstButton + buttonCount)
        {
            value > 0 ? 1 : 0 => value;

            if(flashing && channel == this.channel && control - firstButton + 1 == step)
            {
                !value => value;
            }

            value => notes[channel - 1][control - firstButton - 1];
            <<< notes[channel - 1][control - firstButton - 1] >>>;
        }
        else
        {
            extraControls(channel, control, value);
        }
    }

    fun void extraControls(int channel, int control, int value)
    {
        <<< "extraControls", channel, control, value >>>;
    }

    fun void groove()
    {
        setup();

        spork ~ run();

        while(true)
        {
            if(playing)
            {
                for(1 => int channel; channel <= 16; channel++)
                {
                    if(notes[channel - 1][step - 1])
                    {
                        spork ~ output.sendNote(1, channel - 1 + midi["C1"], 127, beat);
                    }
                }

                spork ~ flashButton(channel, step);

                if(step++ == buttonCount)
                {
                    1 => step;
                }
            }
            else
            {
                1 => step;
            }

            beat => now;
        }
    }
}

class KillamixGrooveBox extends GrooveBox
{
    1 => inputDevice;
    0 => outputDevice;
    9 => firstButton;
    8 => buttonCount;

    23 => static int channelButton;
    18 => static int playStopButton;

    fun void resetControls(MidiHandler @ handler)
    {
        setForAllChannels(handler, 1, 64);
        setForAllChannels(handler, 2, 0);
        setForAllChannels(handler, 3, 64);
        setForAllChannels(handler, 4, 116);
    }

    fun void extraControls(int ch, int control, int value)
    {
        if(control == playStopButton)
        {
            setForAllChannels(this, playStopButton, value);
            value > 0 ? true : false => playing;
        }
        if(control == channelButton)
        {
            ch => channel;
        }
    }

    fun void setForAllChannels(MidiHandler @ handler, int control, int value)
    {
        for(1 => int ch; ch <= 16; ch++)
        {
            handler.sendControlChange(ch, control, value);
        }
    }
}

KillamixGrooveBox box;
box.groove();
