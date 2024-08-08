
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
x = Synth(\arrayarg, [\freq, [65,71,73] , \mods, [-0.76, 0.25], \rq, 0.1, \out, ~ch1.inbus])
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

~dataSlider.bounds
(0.12 * 1352).asInteger
(
var w, data, u, x2, y2, in, out, legend, reduce=100;

# x2, y2 = [ 0, 0];
# in, out = [0, 40000];
data = ~data.soilmoisture1[in.. out].select({|n, i| i%reduce==0});

w = Window.new("test", Rect(200, 200, 1000, 460)).front;

u = UserView(w, Rect(0, 0, 1000, 460));
u.drawFunc = {
    Pen.fillColor_(Color.blue);
    [20, 40, 60, 80].do({|leg|
        var l = leg.linlin(0, 80, w.bounds.height, 0);
        Pen.moveTo(0@l);
        Pen.lineTo(1000@l);
        StaticText(w, Rect(0, l, 40, 30)).string_(leg.asString)
    });
      Pen.fillStroke;
    Pen.strokeColor_(Color.black);
        Pen.lineTo(0@0);
    data.do{ |d, i|
        //x1 = i.linlin(0, data.size-1, 0, w.bounds.width).asInteger;
        Pen.moveTo(x2@y2);
        x2 = (i+1).linlin(0, data.size-1, 0, w.bounds.width).asInteger;
        y2 = d.linlin(0, 80, w.bounds.height, 0);
        Pen.lineTo(x2@y2);
        if (i%50==0, {
            "d %  x2 % y2 %".format(d, x2,y2).postln;
            StaticText(u, Rect(x2, 20, 30, 30))
            .string_(d.asString)
            .align_(\left);

            Pen.strokeColor_(Color.red);
            Pen.moveTo(x2@y2);
            Pen.lineTo(x2@50);
            Pen.fillStroke;
           Pen.strokeColor_(Color.black);


        });
        //y1 = y2;

    };
};

u.mouseDownAction = { |v, x, y|
in = x.linlin(0, 1000, 0, data.size-1).asInteger;
out = in + 100;
in.postln;
};

u.mouseUpAction = { |v, x, y|
out = x.linlin(0, 1000, 0, ~data.soilmoisture1.size-1).asInteger;
[in, out, (out-in)].postln;
data = ~data.soilmoisture1[in..out].select({|n, i| i%reduce==0});
data.size.postln;
w.refresh;
};

/*u.mouseMoveAction = { |v, x, y|

    //out = x.linlin(0, 1000, 0, ~data.soilmoisture1.size-1).asInteger;
    //out.postln;
    //data = data[in ..out];
    //w.refresh;
};*/


)

(
w = Window.new.front;
w.view.background_(Color.white);
w.bounds.postln;
w.drawFunc = {
    var x=0, y=0, x2=0, y2=0, p1, p2, data;
    data = ~data.soilmoisture1[..390];
    // set the Color
    Pen.fillColor = Color.red;
    Pen.strokeColor = Color.black;
    data.do({
        |d|
         //Pen.moveTo(x@y);
         y2 = d.linlin(0, 80, 0, w.bounds.height);
         x2 = x+1;
         p2 = Point(x2, y2);
         p1 = Point(x, y);
         Pen.line(p2, p1);
        x = x + 1;
        p1 = Point(x, y2 );

    });
    Pen.fillStroke; // fill and then stroke
};
w.refresh;
)
~currentData.globalPos

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
