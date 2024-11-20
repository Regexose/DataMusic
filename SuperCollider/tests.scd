Window.closeAll;
s.defaultGroup

~sends.ch1_snd_dela.level
~ch1.inbus
~voc.postSends[2].level
~fx.delay.gui
~fx.delay.synth.run(false)
~fx.delay.synth.run(true)
~reverb.inbus
SynthDescLib.at(\livegran).controlDict

~board = MixingBoard("3 chan", nil, ~ch1, ~delay, ~master);
~board.postSettings
PeakMonitor(~delay)


(
w = Window.new("I catch keystrokes");
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	var c
	[char, keycode].postln;
	c = case
	{keycode == 18} {"active replacePlay".postln; ~replacePlay.()}
	//{keycode == 19} {"empty replacePlay".postln; [\rplOn, \rplOff].do({|n| MIDIdef(n).free})}
	{keycode == 19} {"empty replacePlay".postln; {~replacePlay = {}}}
	{true}{};
};
w.front;

~grainBuffer.plot
x = Synth(\livegran, [\amp, 0.5, \ptrBus, ~ptrBus, \buf, ~grainBuffer, \dens, 40, \ptrSampleDelay, s.sampleRate/3, \ptrRandSamples, 0, \minPtrDelay,  1000, \out, 0], ~grainGrp);
x.set(\ptrRandSamples, 100)
x.free

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

x = Synth(\tgrains, [\buf, ~liveBuffer, \grainDur, 0.1, \out, 0, \amp, 0.5])
x.set(\ffreq, 3000, \dens, 12, \fmdens, 4, \numharm,3, \carfreq, 200, \modfreq, 1, \index, 2, \grainDur, 0.55, \grainAmp, 0.1, \ampmod, 1,  \amp, 0.1, \rate, 1, \harm, [0.0, -3.6])

x = Synth(\crisps, [\freqs, 3500!3, \rings, 0.3!3, \amps, rrand(0.1, 0.3)!3, \out, ~perc.inbus]
x.setn(\freqScale, rrand(0.1, 0.5)!3, \decayScale, rrand(0.1, 0.5)!3, \dec, 6, \freqs, exprand(100, 1200)!3,  \rings, rrand(0.1, 0.9)!3, \amps, rrand(0.01, 0.9)!3,)
x.isPlaying;
x.free
)
~activeSynths[\52]
~currentData[\51][\data].size
~currentData[\51][\data].size

~data.keys
~fxOnOff.(true)
~fxOnOff.(false)



Pbindef.all.do(_.stop)
Pbindef.all.do({|k| k.key.postln})

Pbindef(\klank).play(~t, quant:4)
Pbindef(\klank, \dec, 3, \dur, 1.2, \rls, 2)
Pbindef(\quirkator, \atk, Prand([0.01, 0.04, 0.08], inf), \rls, 0.1, \sustain, 0.1, \otAmps, Pfunc({rrand(0.01, 0.1)}!4),     \otFreqs, Pfunc({rrand(0.081, 1.6)}!4), \feedb, pi * 1/8, \freqLag, 0.9, \dampExp, 0.02, \otLag, 0.3, \ampA, Prand([0.4, 0.6, 0.77], inf), \ffreq, Pwhite(300, 3000, inf))
Pbindef(\quirkator).stop
Pbindef(\dark).isPlaying


~data.keys.do({
    |k|
    ~data[k].size.postln;
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
