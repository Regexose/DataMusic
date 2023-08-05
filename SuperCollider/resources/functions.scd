~makeWaveTable = {
	|size=4096, external, name|
	var sig, wt, buf;
	external = external.sort.reverse.asArray;
	external = external.normalize(external.last, external[0]/2);
	external[0..15].postln;
	r{
		buf = Buffer.alloc(s, size*2);
		s.sync;
		buf.sine1(external[0..15], asWavetable:true);
		//buf.plot;
		s.sync;
		~buffers.put(name.asSymbol, buf);
		"made buffer  %".format(~buffers[name]).postln;

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
