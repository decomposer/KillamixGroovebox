#include(MidiHandler)

new MidiHandler @=> MidiHandler @ midi;

midi.open(1, 1);

120 => int bpm;
1::minute / bpm / 2 => dur step;
1 => int count;

while(true)
{
    <<< "step", count >>>;

    step => now;

    if(count++ == 8)
    {
        1 => count;
    }
}
