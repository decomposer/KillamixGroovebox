#include(MidiHandler)

new MidiHandler @=> MidiHandler @ midi;

midi.open(1, 1);

120 => int bpm;
9 => int firstButton;
firstButton => int currentButton;
1::minute / bpm / 2 => dur beat;
1 => int step;

while(true)
{
    <<< "step", step >>>;

    new ControlChangeMessage @=> ControlChangeMessage off;
    currentButton => off.control;
    0 => off.value;

    if(step++ == 8)
    {
        1 => step;
    }

    firstButton + step => currentButton;

    new ControlChangeMessage @=> ControlChangeMessage on;
    currentButton => on.control;

    midi.send(off);
    midi.send(on);

    beat => now;
}
