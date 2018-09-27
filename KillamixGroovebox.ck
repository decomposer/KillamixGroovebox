#include(MidiHandler)

class GrooveBox extends MidiHandler
{
    9 => static int firstButton;

    120 => int bpm;

    firstButton => int currentButton;
    1::minute / bpm / 2 => dur beat;
    1 => int step;

    open(1, 1);

    fun void sendControlChange(int channel, int control, int value)
    {
        new ControlChangeMessage @=> ControlChangeMessage m;
        channel => m.channel;
        control => m.control;
        value => m.value;
        send(m);
    }

    fun void sendControlOn(int channel, int control)
    {
        sendControlChange(channel, control, 127);
    }

    fun void sendControlOff(int channel, int control)
    {
        sendControlChange(channel, control, 0);
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
