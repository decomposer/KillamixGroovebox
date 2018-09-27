#include(MidiHandler)

new MidiHandler @=> MidiHandler @ midi;

midi.open(1, 1);

120 => int bpm;
9 => int firstButton;
firstButton => int currentButton;
1::minute / bpm / 2 => dur beat;
1 => int step;

fun void flashButton(int channel, int button)
{
    new ControlChangeMessage @=> ControlChangeMessage on;
    button + firstButton => on.control;

    new ControlChangeMessage @=> ControlChangeMessage off;
    button + firstButton => off.control;
    0 => off.value;

    midi.send(on);
    beat => now;
    midi.send(off);
}

while(true)
{
    <<< "step", step >>>;

    spork ~ flashButton(1, step);

    if(step++ == 8)
    {
        1 => step;
    }

    beat => now;
}
