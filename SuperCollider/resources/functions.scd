~makeWaveTable = {
	|size=4096, external, name|
	var sig, wt, buf ;
	//external = external.wrapExtend(size.asInteger).asArray.normalize;
	r{
		buf = Buffer.alloc(s, size*2);
		s.sync;
		buf.sine3(
			({external.choose} !16).sort,
			({exprand(0.05, 0.9)} !16).sort,
			{rrand(0, 2pi)} !16,
			asWavetable: true
		);
		//buf.plot;
		s.sync;
		~buffers.put(name, buf);
		//~buffers[name].postln;

	}.play(AppClock);
};

~recOnOff = {
	var notes, on, off, rec, play, rout, demoNum;
	on = MIDIFunc.noteOn({
		|vel, num|
		if ((rout != nil && rout.isPlaying), {rout.stop});
		rec = Synth(\rec, [\buf, ~liveBuffer]);
		"recording on % ".format(num).postln;
	});
	off = MIDIFunc.noteOff({
		|vel, num|
		"stopped recording".postln;
		rec.free;
		if (~rf.keys.includes(num.asSymbol),{
			rout = Routine(~rf[num.asSymbol]).play
		});

		"playing demo %".format(~rf[num.asSymbol]).postln;

		//wie kann diese Funktion sich wieder resetten, wenn eine neue Note gespielt wird
		//MIDIdef.freeAll??

	});


};
