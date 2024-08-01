
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
~startFilterOrders = [0.1, 0.1, 2.0, 0.25];
~stopFilterOrders = [3.1, 2.0, 0.25, 3.25];

s.freqscope
x = Synth(\arrayarg, [\freq, [65,71,73] , \mods, [-0.76, 0.25], \rq, 0.1, \out, ~ch1.inbus])
x = Synth(\snare, [ \out, ~ch1.inbus])
x.setn(\mods, Array.rand(3, -240, 240), \freq, Array.fill(3, {exprand(20, 48).midicps}), \lg, 0.6, \rq, 0.1,  \ffreq, 5000, \phsMod, 15)
x.set(\vowelIndex, 13, \amp, 0.05, \stopFilterOrders, Array.fill(5, {4.0.rand}), \lg, 10)

x.set(\startFilterOrders, [2, 0.1, 2.0, 0.25], \stopFilterOrders, [3.0, 3.1, 3.5, 0.25])
x.free


~r.play
~r.stop
~fxOnOff.(true)
~fxOnOff.(false)
~play.()
Pbindef.all.do(_.stop)
Pbindef.all.do({|k| k.key.postln})

~master.outChannels_(10)
Pbindef(\arp2).play(~t, quant:4)
Pbindef(\arp2, \phs, 0.9)
Pbindef(\array01).stop
Pbindef(\klic).isPlaying
0.2/0.8**4
(

c = Synth(\crisps, [\amp, 0.4, \punch, 0.66, \trg, 12, \dec, 0.11, \out, ~perc.inbus]);
c.set(\trg, 2, \dec, 0.03, \amp, 0.4, \ffreq, 80, \rq, 0.3, \punch, 1.7);
c.set(\trg, 5, \dec, 0.03, \amp, 0.4, \ffreq, exprand(80,5110), \rq, 0.3, \punch, 1.0);
c.set(\trg, 10, \dec, 0.03, \amp, 0.4, \ffreq, 80, \rq, 0.3, \punch, 0.7);
c.set(\trg, 20, \dec, 0.03, \amp, 0.4, \ffreq, 100, \rq, 0.3, \punch, 1.0);
c.set(\trg, 25, \dec, 0.02, \amp, 0.4, \ffreq, 80, \rq, 0.1, \punch, 0.7);
//c.setn(\freq, [120, 510, 1010, 800] *5)
//c.free

x= Synth(\arrayarg, [\amp, 0.1, \freq, [65, 71, 73].midicps -24, \mods, [2.0, -12.0, -3.0], \lg, 0.01, \rq, 0.2, \phsMod, 0.5, \out, ~ch1.inbus])
x.setn(\freq, Array.fill(10, {rrand(100, 999)}), \mods, Array.fill(10, {rrand(-12.0, 12.0)}), \phsMod, 1 )

n = Synth(\arrayarg, [\amp, 0.1, \freq, [65, 71, 73].midicps -24, \mods, [2.0, -12.0, -3.0], \lg, 0.01, \rq, 0.2, \phsMod, 0.5, \out, ~ch1.inbus]);
//n.free
)




//// versuch mit ducking
~ducker.set(1)
(
o = OSCFunc({
    |msg, time|
    //[time, msg].postln;
    Routine({
    ~ducker.set(0.2);
        0.1.wait;
    ~ducker.set(1);

    }).play


}, 'tr', s.addr);
// o.free

)
(                // put it in an existing window - margin is 0@0
w = Window("my win", Rect(200, 200, 300, 200)).front;
w.addFlowLayout;
PdefGui(Pbindef(\klic),8, w);
)


)
[\arp1, \arp3, \array01, \snarl, \seq1, \percvowel, \voc1, \klic, \arp2]
Pbindef(\voc1, \ffreq, 4000)
(
~mixer = MixingBoard("mixer", nil, [~ch1,~ch2,~ch3,~ch4, ~perc, ~voc, ~master]);
[\arp1,  \array01, \percvowel].do{|k| Pbindef(k).play(~t, quant:4)};
)
~sends.keys.do({
    |k|
    k.postln

})
~master.postSettings
~perc.inbus.index
~sends.ch1_snd_vrb1.level= 0.1
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
