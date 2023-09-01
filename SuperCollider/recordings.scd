////////////////////////////////////////
//workshop
(
~recordUser.("voris", "base");
~recordUser.("test", "tension");
~recordUser.("test", "release");

)
(
/*
Intro: 3 Routinen mit Synths und 3 Datensätzen, die User sich anhören können
*/
(
r({
    var syn, data, compressed, normalized, reduce;
	reduce=10;
	data = ~data.maxdailygust.asArray;
	compressed = data.select({|item, i| i%reduce == 0});
	normalized = compressed.normalize(80.0, 3500.0);
    /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
    wait(0.02);*/
	syn = Synth(\arrayarg, [\amp, 0.1, \freqs, [48, 60, 72].midicps]);
    normalized.do({
        |d, i|
	    "original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
		syn.set(\ffreq, d, \mod, d.linlin(80, 3500, 1.0, 5.0), \pm, d.linlin(80, 3500, 0.0, 2pi)) ;
        0.05.wait;
        if (i == (normalized.size-1), {syn.release(3)});
    })
}).play
);

(
r({
    var syn, data, compressed, normalized;
	data = ~data.maxdailygust.asArray;
	compressed = data.select({|item, i| i%10 == 0});
	normalized = compressed.normalize(60.0, 3500.0);
    /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
    wait(0.02);*/
	syn = Synth(\dynklank, [\amp, 0.2, \pLag, 0.3]);
    normalized.clump(2).do({
        |d, i|
	    "original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
		syn.set(\freqs, d, \rings, d.linlin(60, 3500, 0.0, 20.0), \decayScale, d.linlin(60, 3500, 0.1, 2.4));
        0.1.wait;
        if (i == (normalized.size-1), {syn.release(3)});
    })
}).play
)

)
(
/*
test: 3 Routinen, um sich das Ergebnis anzuhören
Todo: kleine Dramaturgie. dry/wet logik einbauen
*/
(
r({
	var data, normalized, compressed, buf, syn, reduce;
	reduce = 50;
	data = ~data.solarradiation.asArray;
	compressed = data.select({|item, i| i%reduce == 0});
	normalized = compressed.normalize(80, 3000);
	buf = ~buffers[\test][\tension];
	syn = Synth(\br, [\buf, buf, \end, buf.numFrames-1,  \lg1, 0.2, \lg2, 0.2]);
	normalized.do({
		|d, i|
		 "original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
		syn.set(\ffreq, d, \lg2, d.linlin(20,3000, 0.1, 0.5));
		0.04.wait;
		 if (i == (normalized.size-1), {syn.release(3)});
	})
}).play
);

r({
	var data, compressed, reduce,  normalized, buf, syn, sec;
	reduce = 50;
	data = ~data.temp.asArray;
	compressed = data.select({|item, i| i%reduce == 0});
	normalized = compressed.normalize(36.0, 60.0);
	buf = ~buffers[\test][\tension];
	sec = buf.numFrames/s.sampleRate * 10;
	syn = Synth(\tgrains, [\buf, buf, \dens, 10, \grainDur, 1.0]);
	normalized.do({
		|d, i|
		//"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
		syn.set(\ffreq, d.linlin(36.0, 60.0, 150, 3000), \rq, d.linlin(36.0, 60.0, 0.99, 0.01), \pan, d.linlin(36, 60, -0.6, 0.6), \pos, sec * i);
		0.2.wait;
		 if (i == (normalized.size-1), {syn.release(3)});
	})
}).play
);

)
//solar radiation

)

(


)
(
r({
	var data, normalized, buf, syn, sec;
	data = ~data.solarradiation;
	normalized = data.asArray.normalize(13, 114);
	buf = ~buffers[\hugoloris][0];
	sec = buf.numFrames/s.sampleRate * 50;
	syn = Synth(\tgrains, [\buf, buf]);
	normalized.do({
		|d, i|
		"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
		syn.set(\harm, [d, d-12, d+12], \pos, sec *1);
		0.04.wait;
	})
}).play

)
)


































// tgrains mit basesound und humidity
r({
    var syn, data, name, buf, segment;
    /*s.record(~recordingPath +/+ "tgrains_uvi.wav", duration: 50);
    wait(0.02);*/
    //data = Array.fill(300, {exprand(0.1, 1.0)});
    data = ~data.humidity.asArray.normalize(0.001, 10.0);
    buf = ~grainBuffer;
    syn = Synth(\tgrains_live, [\buf, buf, \grainAmp, 0.24, \sus, 0.5, \dens, 1, \rls, 0.2]);
    segment = (buf.numFrames/data.size)/s.sampleRate;
	data = data[..300];
    data.do({
        |t, i|
        "processing %  %  at   %".format("normalized data ", t, i).postln;
        syn.set(\grainDur, t/10, \dens, t, \pos, segment/2 * i, \harm, [0, 12, t.linlin(0.0, 10.0, 0, 12)], );
        0.11.wait;
        if (i == (data.size-1), {"releasing synth".postln; syn.release(3)});
    })
}).play

// tgrains_live mit humidity
r({
    var syn, data, name, buf, segment;
    /*s.record(~recordingPath +/+ "tgrains_uvi.wav", duration: 50);
    wait(0.02);*/
    //data = Array.fill(300, {exprand(0.1, 1.0)});
    data = ~data.humidity.asArray.normalize(0.001, 10.0);
    buf = ~grainBuffer;
    syn = Synth(\tgrains_live, [\buf, buf, \grainAmp, 0.24, \sus, 0.5, \dens, 1, \rls, 0.2]);
    segment = (buf.numFrames/data.size)/s.sampleRate;
	data = data[..300];
    data.do({
        |t, i|
        "processing %  %  at   %".format("normalized data ", t, i).postln;
        syn.set(\grainDur, t/10, \dens, t, \pos, segment/2 * i, \harm, [0, 12, t.linlin(0.0, 10.0, 0, 12)], );
        0.11.wait;
        if (i == (data.size-1), {"releasing synth".postln; syn.release(3)});
    })
}).play
)

(
// tgrains_live mit humidity
r({
    var syn, data, name, buf, segment;
    /*s.record(~recordingPath +/+ "tgrains_uvi.wav", duration: 50);
    wait(0.02);*/
    //data = Array.fill(300, {exprand(0.1, 1.0)});
    data = ~data.humidity.asArray.normalize(0.001, 10.0);
    buf = ~grainBuffer;
    syn = Synth(\tgrains_live, [\buf, buf, \grainAmp, 0.44, \sus, 0.5, \dens, 1, \amp, 0.9, \rls, 0.4]);
    segment = (buf.numFrames/data.size)/s.sampleRate;
    data.do({
        |t, i|
        "processing %  %  at   %".format("normalized data ", t, i).postln;
        syn.set( \grainDur, t/5, \dens, t, \pos, segment * 200, \harm, [0, 12, t.linlin(0.0, 10.0, 0, 12)], \amp, 0.05 * t);
        0.11.wait;
        if (i == (data.size-1), {"releasing synth".postln; syn.release(3)});
    })
}).play
)

(
// # 04 tgrains_live plus array arg
r({
    var syn1, syn2, data, name, buf, segment;
  s.record(~recordingPath +/+ "#04humidity.wav", duration: 50);
    wait(0.02);
    //data = Array.fill(300, {exprand(0.1, 1.0)});
    data = ~data.humidity.asArray.normalize(0.0, 10.0);
    buf = ~grainBuffer;
    syn1 = Synth(\tgrains_live, [\buf, buf, \grainAmp, 0.44, \grainDur, 1, \sus, 0.2, \dens, 5, \amp, 0.7, \rls, 0.2]);
    syn2 = Synth(\arrayarg, [\amp, 0.06, \which, 1]);
    segment = (buf.numFrames/data.size)/s.sampleRate;
    data.do({
        |t, i|
        "processing %  %  at   %".format("normalized data ", t, i).postln;
        syn1.set(\pos, segment * i, \harm, [0, 12, t.linlin(0.0, 10.0, -12, 12)]);
        syn2.set(\freqs, [48, 72, t.linlin(0.0, 10.0, 48, 72)].midicps, \lag, t/4, \temps, Array.fill(3, {(t* pi/4)}), \atk, 0.05 * t, \rls, 0.2 *2);
        0.31.wait;
        if (i == (data.size-1), {"releasing synths".postln; [syn1, syn2].do(_.release(3))});
    })
}).play
)


(
r({
    var data, normalized;
	data = ~data.maxdailygust;
	normalized = data.asArray.normalize(50.0, 350.0);
    /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
    wait(0.02);*/
    x = Synth(\arrayarg, [\which, 2]);
    normalized.do({
        |t, i|
        "processing %  %  original data % at   %".format("normalized data ", t, data[i], i).postln;
		x.set(\freqs, Array.fill(3, {[t/2, t, t*2]}), \temps, [normalized[i-1.max(0)], t, normalized[i+1]], \amp, 0.03, \which, i%3);
        0.05.wait;
        if (i == (data.size-1), {x.release(3)});
    })
}).play

)


(
// #6  [ solar, yearly, relative, relative_low, relative_high, absolute ]
//plus ein tgrains_live signal, das von data2 gespeist wird
r({
    var syn2, data2, buf, segment;
 /*   s.record(~recordingPath +/+ "#06humidity.wav", duration: 40);
    wait(0.02);*/
    data2 = ~data.humidity.asArray.normalize(0.0, 8.0);
    buf = ~grainBuffer;
    segment = (buf.numFrames/data2.size)/s.sampleRate;
    syn2 = Synth(\tgrains_live, [\buf, buf, \grainAmp, 0.44, \sus, 0.2, \dens, 1, \amp, 0.8, \rls, 0.4]);
    r({data2.do({
        |d, i|
        "processing %  %  %  at   %".format("normalized data ", "tgrains", d, i).postln;
        syn2.set(\grainDur, d/4, \dens, d, \pos, i * segment , \harm, [d*2, d, d/2]);
        0.5.wait;
        if (i == (data2.size-1), {syn2.release(3)});
    })
    }).play;
    ~dataGroups.freq.do({
        |frq|
        var synName, data, keyName;
        data = ~data[frq];
        keyName = ~data.findKeyForValue(data);
        data = ~data[frq].asArray.normalize(100, 300);
        synName = "syn_" ++keyName;
        synName = Synth(\array_1b, [\freq, data.mean, \amp, 0.05]);
        r({data.do({
            |t, i|
            "processing %  %  %  at   %".format("normalized data ", keyName, t, i).postln;
            synName.set(\freq, t /1000, \otFreqs, Array.exprand(4, data.mean, t), \otAmps, Array.fill(4, {exprand(0.8, 1.0)}), \freqLag, 0.9);
            0.5.wait;
            if (i == (data.size-1), {synName.release(3)});
        })
        }).play;
    });
}).play
)

 ///////////////////////////

(
// 6 datenreihen, [ solar, yearly, relative, relative_low, relative_high, absolute ]
//die Werte im wahrnehmbaren Frequenzspektrum haben, werden gleichzeitig abgespielt
r({
	/*s.record(~recordingPath +/+ "frequencies.wav", duration: 40);
	wait(0.02);*/
	~dataGroups.freq.do({
		|frq, i|
		var synName, data, data2, keyName;
		data = ~data[frq];
		keyName = ~data.findKeyForValue(data);
		synName = "syn_" ++keyName;
		synName = Synth(\array_1b, [\freq, data.mean, \amp, 0.2]);

		r({
			data.do({
				|t, i|
				 "processing %  %  %  at   %".format("normalized data ", keyName, t, i).postln;
				synName.set(\freq, t /1000, \otFreqs, Array.exprand(4, data.mean, t), \otAmps, Array.fill(4, {exprand(0.8, 1.0)}), \freqLag, 0.9);
				0.1.wait;
				if (i == (data.size-1), {synName.release(3)});
			});

		}).play
	})
}).play
)


(
//  8 weniger volatile datenreihen ()temperature moisture) gleichzeitig
r({
		/*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/steady.wav", duration: 40);
	wait(0.02);*/
	~dataGroups.steady.do({
	|frq, i|
	var synName, data, keyName, freqs;
	data = ~data[frq];
	keyName = ~data.findKeyForValue(data);
	synName = "syn_" ++keyName;
	freqs = data.clump(3).stutter(3);
	synName = Synth(\arrayarg, [\freqs, Array.fill(3, freqs[0] + 35), \amp, 0.01]);
	r({
		data.do({
		|t, i|
			[t,i].postln;
		synName.set(\freqs, freqs[i] +35, \temps, Array.fill(3, {[data[i-1.max(0)], t, data[i+1.min(data.size)]]}));
		0.1.wait;
			if (i == (data.size-1), {synName.release(3)});
	});
	}).play
})

}).play
)

(
// tgrains_live mit exprand
r({
	var syn, data, name, buf, segment;
/*	s.record(~recordingPath +/+ "tgrains_uvi.wav", duration: 50);
	wait(0.02);*/
		//data = Array.fill(300, {exprand(0.1, 1.0)});
		data = ~data.temp.asArray.normalize(0.001, 10.0)[500..800];
		buf = ~grainBuffer;
		syn = Synth(\tgrains_live, [\buf, buf, \grainAmp, 0.44, \sus, 2, \dens, 3, \amp, 0.4]);
		segment = (buf.numFrames/data.size)/s.sampleRate;
	data.do({
		|t, i|
		"processing %  %  at   %".format("exprand data ", t, i).postln;
		syn.set(\grainDur, t, \rate,  [-1, 1].choose, \dens, t, \pos, segment * i, \harm, [t*2, t, t/2]);
		0.15.wait;
        if (i == (data.size-1), {"releasing synth".postln; syn.release(3)});
		})
}).play
)

(
// brBF
r({
	var syn, data, name, buf, segment, rec;
/*	s.record(~recordingPath +/+ "for_back03.wav", duration: 30);
	wait(0.02);*/
		data = Array.fill(300, {exprand(0.1, 1.0)});
		buf = ~buffers[\hugoloris][0];
		segment = buf.numFrames/40;
		syn = Synth(\brBF, [\buf, buf, \sec, segment, \rate, 1, \dirlag, 0.2]);
	data.do({
		|t, i|
		"processing %  %  at   %".format("exprand data ", t, i).postln;
		syn.set(\secIdx, i%data.size, \harm, [t*8, t*4, t*2], \rate, [-1, 1].choose);
		0.1.wait;
		})
}).play
)

(
// brBF + arrayarg
r({
	var syn, syn2, data, name, buf, segment, rec, freqs;
s.record(~recordingPath +/+ "voc_syn.wav", duration: 30);
	wait(0.02);
		data = Array.fill(500, {exprand(0.1, 1.0)});
		buf = ~liveBuffer;
		segment = buf.numFrames/40;
		syn = Synth(\brBF, [\buf, buf, \sec, segment, \rate, 1, \dirlag, 0.2, \amp, 0.9]);
		freqs = data.clump(3).stutter(3);
	    syn2 = Synth(\arrayarg, [\freqs, Array.fill(3, freqs[0] * 35), \amp, 0.001]);
	data.do({
		|t, i|
		"processing %  %  at   %".format("exprand data ", t, i).postln;
		syn.set(\secIdx, i%data.size, \harm, t * freqs[i], \rate, [-1, 1].choose);
		syn2.set(\freqs, freqs[i] * 80, \temps, Array.fill(3, {[data[i-1.max(0)], t, data[i+1.min(data.size)]]}));
		0.1.wait;
		})
}).play
)

{//likes values around 20
		//plays ascending segments of the buffer

	},
)




(
// with voice samples
~test = Routine({
	var syn;
/*	s.record(~recordingPath +/+ "tgrains01.wav", duration: 60);
	wait(0.02);*/

	~temps.do({
		|t, i|
		var c;
		c = case
		{i%18==0}{syn = Synth(\tgrains, [\buf, ~buffers[\boris][i], \sus, 30, \grainAmp, 0.2, \dens, 1])}
		{i%5==0} {syn.set(\harm, Array.fill(4, {|idx| idx / t }), \pos, i/t, \dens, i/3, \grainDur, i/t)}
		{true}{("cases test done" ++ i).postln};
		0.5.wait;
		})
	}).play;

)

(
// grains slowly moving forward
~test = Routine({
	var syn;
	s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/tgrains02.wav", duration: 35);
	wait(0.02);

	~temps.do({
		|t, i|
		var c, buf, segment;
		buf = ~buffers[\boris][10];
		segment = buf.numFrames/(~temps.size * s.sampleRate);
		syn = Synth(\tgrains, [\buf, buf, \pos, segment * i, \sus, 0.1, \atk, 0.001, \rls, 0.6, \grainAmp, 0.34, \grainDur, 0.14,  \dens, 3]);
		c = case
		{i%5==0}{syn.set(\harm, Array.fill(4, {|idx| idx / t }), \rate, 1 + t.reciprocal)}
		{i%25==0}{syn.set(\buf, ~buffers[\boris][i%~buffers[\boris].size] )}
		{true}{("cases test done" ++ i).postln};
		0.1.wait;
		})
	}).play;

)

(
// grains slowly moving forward
~test = Routine({
	var syn;
	s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/tgrains03.wav", duration: 25);
	wait(0.02);

	~temps.do({
		|t, i|
		var c, buf, maxInd, segment;
		buf = ~buffers[\boris][7];
		segment = buf.numFrames/(~temps.size * s.sampleRate);
		syn = Synth(\tgrains, [\buf, buf, \pos, segment * i, \sus, 0.1, \atk, 0.001, \rls, 0.8, \grainAmp, 0.34, \grainDur, 0.2,  \dens, 3]);
		c = case
		{i%5==0}{syn.set(\harm, Array.fill(4, {|idx| idx / t }))}
		{i%25==0}{syn.set(\buf, ~buffers[\boris][i%~buffers[\boris].size] )}
		{true}{("cases test done" ++ i).postln};
		0.08.wait;
		})
	}).play;

)
~test.stop
s.makeWindow
s.recSampleFormat = "int16"
s.recHeaderFormat = "wav"

(
//sc_230727_164424_stereo
~test = Routine({
		var syn = Synth(\dynklank, [\amp, 0.2, \pan, rrand(-0.1, 0.1), \pLag, 0.3]);
	~data.temp.clump(3).do({
		|bt|
		syn.set(\freqs, bt, \rings, bt);
		1.wait;
	})
}).play;
)
s.makeWindow
(

~baromabs)

~buffers[\boris][4].play
(
var buf = ~buffers[\boris][4];
~test = Routine({
	var thres, syn, old, divider, duration;
		s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/brBF01.wav", duration: 45);
	wait(0.02);
	duration = buf.numFrames /s.sampleRate;
	thres = ~baromabs.mean;
	divider = 20;

	~baromabs.do({
		|b, i|
		[b, i].postln;
		syn = Synth(\brBF, [\buf, buf, \sec, buf.numFrames/divider, \secIdx, i%divider ]);
		if(b >= thres, {
			buf = ~buffers[\boris][4];
			syn.set(\rate, 1, \harm, Array.fill(3, {[0, 12].choose}))},
		{   buf = [~buffers[\boris][8], ~buffers[\boris][8], ~buffers[\boris][9]].choose;
			duration = buf.numFrames/ s.sampleRate;
			syn.set(\buf, buf, \rate, -1, \harm, Array.fill(3, {[0, -12].choose}))});
		(duration/divider).wait;
	})
}).play

)
(
Pbindef(\br,
	\instrument, \brSec,
	\buf, buf,
	\amp, 0.2,
	\sec, buf.numFrames / divider,
	\secIdx, Pseq((1..~temps), inf),
	\dur, 0.1,
).play
)
Pbindef(\br, \dur, 24.0.reciprocal, \rate, 2)

(
var buf = ~buffers[\boris][7], divider = 10;
Pbindef(\bfb,
	\instrument, \brBF,
	\buf, buf,
	\amp, 0.2,
	\sec, buf.numFrames/divider,
	\secIdx, Pseq((1..divider), inf),
	\dur, 0.1,
).play
)
Pbindef(\bfb, \dur, 0.3, \rate, 1, \harm, Pxrand([[9, 24, 21], [1, -5, -12], [12, -12, 24]], inf))
~test.stop
(
var buf = ~buffers[\boris][4];

)


(
var buf = ~buffers[\boris][6];
  x = {
        SmoothReversal.ar(
            bufnum: buf,
            playbackRate: MouseX.kr(0, 2),
            switchDirectionTrigger: Dust.ar(4) > 0.5,
            threshold: -15.dbamp
        )
    }.play;
)