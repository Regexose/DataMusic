
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