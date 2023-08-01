(
var buf = ~buffers[\boris][19];
x = Synth(\brSec, [\buf, buf, \sec, buf.numFrames/100,  \rate, 1, \sus, 30, \secIdx, 3 ])
)
x.set(\secIdx, 6, \sec, 2000)

MIDIFunc.trace(false);
~recOnOff.()
~liveBuffer.play

