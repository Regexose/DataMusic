Window.closeAll;
s.defaultGroup
s.queryAllNodes

SynthDescLib.at(\livegran).controlDict


NetAddr.langPort
x = Synth(\brLive, [\buf, ~liveBuffer.normalize,  \ptrBus, ~ptrBus ], ~sourceGrp);
//x = Synth(\grainBuf2, [\buf, ~liveBuffer.normalize, \rate, 1, \ptrBus, ~ptrBus ]);
x = Synth(\tgrains_live, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  ~liveBuffer], ~grainGrp);
x.free

(
var key = \48;i
//~loops = 100;
(
x = Routine({var syn, harms, buf;
    buf = ~liveBuffer.normalize;
    syn = Synth(\brLive, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.2, \harm, 2, \out, 0, \fade, 0.9], ~sourceGrp);
    harms = Pseq(~scales[1].degrees, inf).asStream;
    loop{var nextHarm;

        nextHarm = harms.next;
        nextHarm.postln;
        syn.set(\harm, nextHarm);
        ~t.beatDur.wait;

    }

}).play
)
x.stop

(
var key=\48;
Routine(~td[key]).stop;
~activeSynths[\60].do({|x| x.postln});
~sourceGrp.all.do(_.free);
Pbindef.all.do(_.stop)
[Scale.major, Scale.minor, Scale.chromatic, Scale.mixolydian].do({|sc| "name % semi % \n".format(sc.name, sc.semitones).postln})
)
s.makeWindow

(var ranges = [[0.0, 4.0], [4.0, 7.0], [7.0, 11.0], [11.0, 15.0], [15.0, 18.0], [18.0, 21.0], [21.0, 24.0], [24.0, 27.0], [27.0, 30.0] ];
var r1Index, data1 = 12.2;
ranges.do({|n,i| if (((data1 >= n[0]) && (data1 < n[1])), {r1Index = i}; )});
r1Index.postln;
)
~activeSynths[\49].do({|x| x.set(\gate, 0)});
~currentData.td[\sm1] = 1

x = Synth(\voweltrig, [\amp, 0.5, \buf, ~buffersByName[\boris][\tension], \rls, 4, \out, 0], ~grainGrp);
x.set(\vow, 3, \dec, 0.1, \ffreq, 1200, \trg, 30, \freqScale, 0.9, \decayScale, 0.1, \att, 0.04)
x.free
y= Synth(\combdelay, [\bus, ~fxBus, \decayTime, 1, \blend,1, \out, 0], ~fxGrp);
y.set(\maxDelTime, 5, \delTime, 0.05, \decayTime, 5)
y.free

~currentData[\60][\reduce].size
s.queryAllNodes
ServerTree.removeAll
ServerTree.objects
o = OSCFunc({ |msg| msg[3].postln; }, '/cursor');
(

s.freqscope
y = Synth(\tgrains, [\buf, ~buffersByName[\nitro][\base],  \grainDur, 1, \grainAmp, 0.9, \amp, 0.5, \out, ~voc.inbus]);
z = Routine({
   loop{ y.set(\fmdur, 0.1, \index, rrand(1.0, 3.0), \numharm, rrand(2, 12), \carfreq, 250 + rrand(-100, 100), \modfreq, 2 * rrand(0.95, 1.0), \fmamp, 0.5 * rrand(0.93, 1.0) , \fmdens, 12 * rrand(0.2, 1.4), \ffreq, exprand(800, 5000), \rq, 0.1,  \lg, 1.4, \centerPos, 3.5, \grainDur, 1.1, \grainAmp, 0.4, \dens, 10 * rrand(0.5, 1.4));
        0.03.wait;}

}).play
)
z.stop
y.free;
~ptrBus.get

(
Pbindef(\arpeggio).play;
)
Pbindef(\spec, \inMix, 0.7, \maxdel, 0.3)
Pbindef(\spec).stop

x = Synth(\array_1b)
x.set(\)
Pbindef.all.do(_.stop)
Pbindef.all.do({|k| k.key.postln})

[0.1, 0.25, 0.5, 0.75, 1.0, 1.25].collect({|n| ~data.temp.maxItem *n})
~sends.keys.do({
    |k|
    k.postln

})

Instr.at([\busfx, \singleDelay]).listArgs
