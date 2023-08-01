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
	|len=4|
	var notes, on, off, rec, play;
	notes = (0..127);
	on = MIDIFunc.noteOn({
		|vel, num|
	/*	rec = {
			RecordBuf.ar(SoundIn.ar(0), ~liveBuffer, recLevel: 1.0.varlag(0.04), doneAction:2);
		}.play;*/
		rec = Synth(\rec, [\buf, ~liveBuffer]);
		"recording on % ".format(notes[num]).postln;
	});
	off = MIDIFunc.noteOff({
		 |vel, num|
		"stopped recording".postln;
		rec.free;
	   //~liveBuffer.plot;
		~liveBuffer.play;
	});

};