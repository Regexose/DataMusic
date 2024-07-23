
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
x = Synth(\oddeven, [\vowelIndex, 5, \modRange2, 0.05])
x.set(\vowelIndex, 13, \amp, 0.05, \stopFilterOrders, Array.fill(5, {4.0.rand}), \lg, 10)

x.set(\startFilterOrders, [2, 0.1, 2.0, 0.25], \stopFilterOrders, [3.0, 3.1, 3.5, 0.25])
x.free

(
~r = Routine({
    var num= 3.0;
    loop{

        var stops= Array.fill(5, {num.rand});
        x.set(\stopFilterOrders, stops, \lg, 0.6);
        0.04.wait;
        num = 3.0.rand;
    }
});

)
~r.play
~r.stop
~fxOnOff.(true)
~fxOnOff.(false)
~play.()
Pbindef.all.do(_.stop)
Pbindef.all.do({|k| k.key.postln})


Pbindef(\arp2).play(~t, quant:4)
Pbindef(\arp2).stop
Pbindef(\klic).isPlaying
[\arp1, \arp3, \array01, \snarl, \seq1, \percvowel, \voc1, \klic, \arp2]

(
~mixer = MixingBoard("mixer", nil, [~ch1,~ch2,~ch3,~ch4,~ch5, ~perc, ~voc, ~master]);
[\arp1,  \array01, \seq1, \percvowel].do{|k| Pbindef(k).play(~t, quant:4)}
)
~sends.keys.do({
    |k|
    k.postln

})
~perc.inbus.index
~sends.perc_snd_vrb1.level= 0.0001
~sends.perc_snd_ring.level=0.1
~sends.perc_snd_chrs.level=0.0

~fx.rev.synth.run(true)˝˝
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

