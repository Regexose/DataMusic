Window.closeAll;
s.defaultGroup
s.queryAllNodes

SynthDescLib.at(\livegran).controlDict
~routines[\patFunc][0]
~grainBuffer.plot

//~buffersByName[\boris][\gras].play

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
y = Synth(\tgrains_live, [\amp, 0.5, \ptrBus, ~ptrBus, \buf, ~buffersByName[\boris][\gras].normalize, \rq, 0.2, \dens, 20, \lg, 0.5, \grainDur, 0.3,  \out, 0, \rls, 3, \fade, 0.9], ~grainGrp)

x = Synth(\grainBuf2, [\amp, 0.7, \ptrBus, ~ptrBus, \minPtrDelay, 1500, \buf, ~buffersByName[\boris][\gras].normalize, \rq, 0.15, \dens, 20, \rls, 2, \lg, 0.4], ~grainGrp);
z = Routine({
   loop{ y.set(\fmdur, 0.1, \index, rrand(1.0, 3.0), \numharm, rrand(2, 12), \carfreq, 250 + rrand(-100, 100), \modfreq, 2 * rrand(0.95, 1.0), \fmamp, 0.5 * rrand(0.93, 1.0) , \fmdens, 12 * rrand(0.2, 1.4), \ffreq, exprand(800, 5000), \rq, 0.1,  \lg, 1.4, \centerPos, 3.5, \grainDur, 1.1, \grainAmp, 0.4, \dens, 10 * rrand(0.5, 1.4));
        0.03.wait;}

}).play
)
z.stop
y.free;

x = Synth(\tgrains, [\buf, ~grainBuffer, \grainDur, 0.1, \out, 0, \amp, 0.5])
x.set(\ffreq, 3000, \dens, 32, \fmdens, 4, \numharm, 3, \carfreq, 200, \modfreq, 2, \index, 2, \grainDur, 0.55, \drywet, 1, \grainAmp, 0.2, \ampmod, 1,  \amp, 0.1, \rate, 0.3, \harm, [0.0, -3.6] *2
)

x = Synth(\crisps, [\freqs, 3500!3, \rings, 0.3!3, \amps, rrand(0.1, 0.3)!3, \out,0])
x.setn(\freqScale, rrand(0.1, 0.5)!3, \decayScale, rrand(0.1, 0.5)!3, \dec, 6, \freqs, exprand(100, 1200)!3,  \rings, rrand(0.1, 0.9)!3, \amps, rrand(0.01, 0.9)!3,)
x.isPlaying;
x.free
//////////////////////////////
//////////////////////////////
// Touchdesigner Delay  Test
x = Synth(\livegran, [\atk, 0.1, \select, 0, \ptrBus, ~ptrBus, \ptrSampleDelay, 2000, \amp, 0.75, \buf, ~grainBuffer, \dens, 20, \baseDur, 0.05, \out, 0], ~grainGrp);

x = Synth(\grainBuf, [\ptrBus, ~ptrBus, \ptrSampleDelay, 800, \amp, 0.5, \buf, ~grainBuffer, \dens, 20, \baseDur, 0.1, \out, ~fxBus], ~grainGrp);
x.set(\out, ~fxBus)
x.set( \amp, 0.5)
x.free
)

y = Synth(\combdelay, [\bus, ~fxBus, \blend, 0.8, \maxDelTime, 2, \out, 0], ~fxGrp );
y.set(\delTime, 0.1, \decayTime, 2)
y.free;

z = Synth(\ptrTest, [\ptrBus, ~ptrBus])
z.free
~ptrBus.get({|val| val.postln} )
~grainBuffer.plot
~data.keys
~fxOnOff.(true)
~fxOnOff.(false)

762304.0
764224.0
(766144.0- 764224.0)


767500.0

~buffersByName[\boris][\atem].play
Pbindef.all.do(_.stop)
Pbindef.all.do({|k| k.key.postln})

Pbindef(\klank).play(~t, quant:4)
Pbindef(\klank, \dec, 3, \dur, 2.2, \rls, 2)
Pbindef(\quirkator, \atk, Prand([0.01, 0.04, 0.08], inf), \rls, 0.1, \sustain, 0.1, \otAmps, Pfunc({rrand(0.01, 0.1)}!4),  \otFreqs, Pfunc({rrand(0.081, 1.6)}!4), \feedb, pi * 1/8, \freqLag, 0.9, \dampExp, 0.02, \otLag, 0.3, \ampA, Prand([0.4, 0.6, 0.77], inf), \ffreq, Pwhite(300, 3000, inf)).play
Pbindef(\quirkator, \ffreq, Pwhite(500, 2000, inf), \rq, Prand([0.3, 0.13, 0.5], inf), \rls, 0.9, \atk, 0.1, \dur, Pseq([Pn(0.5, 45), Pn(0.25, 16)], inf) )
Pbindef(\quirkator).stop
Pbindef(\dark).play
Pbindef(\dark, \ampMod, Pseq([2, 5, 10, 30], inf), \ffreq, Pwhite(200, 1000, inf, \otFreqs, Array.fill(4, {[120, 125, 90, 201, 223].choose})), \otAmps, Array.fill(4, {[0.5, 0.25, 1, 2, 4].choose}), \ampA, Pwhite(0.1, 0.6, inf));

Pbindef(\array01, \dur, 4, \rls, Pfunc({Array.rand(5, 0.1, 0.3)}), \freqMods, Pwhite(0.01, 1.1, inf), \rls, 0.4, \freq, Pfunc({Array.fill(2, {rrand(30, 71).asInteger})}), \mods,  Pfunc({Array.fill(2, {rrand(0, 1)})}))
Pbindef(\voc2).play
Pbindef(\voc2, \atk, 0.75, \rls, 0.75, \vow, Pseq([0, 5, 9, 15], inf), \fScale,  Pwhite(0.1, 0.7, inf),\dur, 2, \decayScale, Pwhite(0.1, 0.5, inf))

Pbindef(\dark, \freq, Pfunc({var data, d; data = ~currentData.td[\temp_winter]; d = data.linlin(0, 30, 20, 36).midicps; [d, d +5, d +12, d-6].choose})).play

~currentData.keys.do({
    |k|
    [k, ~currentData[k]].postln;
})
~data.temp.size
~sm50.minutes.size
currentEnvironment[\sm50][\minutes]
~currentData[\48][\out]

[0.1, 0.25, 0.5, 0.75, 1.0, 1.25].collect({|n| ~data.temp.maxItem *n})
~sends.keys.do({
    |k|
    k.postln

})
~master.postSettings
~perc.inbus.index
~sends.perc_snd_vrb1.level= 0.5
~sends.ch1_snd_ring.level=0.6
~sends.perc_snd_chrs.level=0.0

~fx.rev.synth.run(true)
~fx.perc_cmp.synth.run(true)
~fx.utt_cmp.synth.run(false)

~fx.keys.do({
    |k|
    k.synth.postln;
})
PeakMonitor(~perc);
PeakMonitor(~chorus);
PeakMonitor(~master)


Instr.at([\busfx, \singleDelay]).listArgs
~mixer = nil
~activeRoutines.live
