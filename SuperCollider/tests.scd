
(
w = Window.new("I catch keystrokes");
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	var c;
	[char, keycode].postln;
	c = case
	{keycode == 18} {"active replacePlay".postln; ~replacePlay.()}
	//{keycode == 19} {"empty replacePlay".postln; [\rplOn, \rplOff].do({|n| MIDIdef(n).free})}
	{keycode == 19} {"empty replacePlay".postln; {~replacePlay = {}}}
	{true}{};
};
w.front;
)


o = OSCFunc({ |msg| msg[3].postln; }, '/cursor');
(

s.freqscope
x = Synth(\bpfstack , [\buf, ~currentSample[\base].normalize , \out, ~voc.inbus, \rls, 1])
x = Synth(\snare, [ \out, ~ch1.inbus])
x.setn(\mods, Array.rand(3, -240, 240), \freq, Array.fill(3, {exprand(20, 48).midicps}), \lg, 0.6, \rq, 0.1,  \ffreq, 5000, \phsMod, 15)
x.set(\vowelIndex, 13, \amp, 0.05, \stopFilterOrders, Array.fill(5, {4.0.rand}), \lg, 10)

x.set(\startFilterOrders, [2, 0.1, 2.0, 0.25], \stopFilterOrders, [3.0, 3.1, 3.5, 0.25])
x.free
)

~fxOnOff.(true)
~fxOnOff.(false)

Pbindef.all.do(_.stop)
Pbindef.all.do({|k| k.key.postln})

Pbindef(\dark).play(~t, quant:4)
Pbindef(\arp2, \phs, 0.9)
Pbindef(\quirkator).stop
Pbindef(\klic).isPlaying


~drawData.bounds
(0.12 * 1352).asInteger

)

~currentData.keys

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

~reverb.groupBusInfo
~reverb.inbus
~ringmod.inbus
~master.outChannels = 10
~buffersByCat[\base]

s.makeWindow
~routingGrp.query
