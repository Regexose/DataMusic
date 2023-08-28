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

~selectorAction = {
	|menu|
	var key, selected;
	selected = menu.item.asSymbol;
	key = menu.name;
	~currentData[key.asSymbol] = ~data[selected];
	"set % with %".format(key, selected).postln;
};

~recordUser = {
	|username, typename|
	var rec, filePath, file, progress=0;
	//make Gui for record progress
	rec = Synth(\recOne, [\buf, ~baseSound]);
	o = OSCdef(\listener, { |msg|
		{progress = msg[3]}.defer; if(msg[3] >= (~baseSound.numFrames -200), {
			"record done".postln;
			rec.free;
			File.mkdir(~samplesPath +/+ username);
			~baseSound.write(~samplesPath +/+ username +/+ typename ++ "Sound.wav", "WAV", "int16");
			~buffers.put(username, ~baseSound);
	})}, '/cursor');

};


//restarts play if new MIDI key is pressed
~replacePlay = {
	|act|
	var rec, rout, syn;
	if (act == True,
		{
			MIDIdef.noteOn(\rplOn, {
				|vel, num|
				if ((rout != nil && rout.isPlaying), {"stopping rout".postln; rout.stop});
				syn = ~activeSynths.atFail(num.asSymbol,
					{"making synth with key %".format(num).postln; Synth(\default)});
				syn.free;
				rec = Synth(\rec, [\buf, ~liveBuffer]);
				"recording on % ".format(num).postln;
			});
			MIDIdef.noteOff(\rplOff, {
				|vel, num|
				"stopped recording".postln;
				rec.free;
				if (~rf.keys.includes(num.asSymbol),{
					rout = Routine(~rf[num.asSymbol]).play
				});
				"playing demo %".format(~rf[num.asSymbol]).postln;
			});
		},{
			"freeing MIDIdefs".postln;
			[\rplOn, \rplOff].do{|n| MIDIdef(n).free};
		}
	)

};

//always plays the complete data array
~oneShotPlay = {
	|act|
	var rec, rout ;
	if (act == True,
		{
			MIDIdef.noteOn(\osOn, {
				|vel, num|
				rec = Synth(\rec, [\buf, ~liveBuffer]);
				"recording on % ".format(num).postln;
			});
			MIDIdef.noteOff(\osOff, {
				|vel, num|
				"stopped recording".postln;
				rec.free;
				if (~rf.keys.includes(num.asSymbol),{
					rout = Routine(~rf[num.asSymbol]).play
				});
				"playing demo %".format(~rf[num.asSymbol]).postln;
			});
		},{
			"freeing MIDIdefs".postln;
			[\osOn, \osOff].do{|n| MIDIdef(n).free};
		}
	)
};

//using tgrains_live with grainBuffer
~liveGrain = {
	|act|
	var syn, rout ;
	if (act == True,
		{
			MIDIdef.noteOn(\lgOn, {
				|vel, num|
				~grainLive = Synth(\tgrains_live, [\buf, ~grainBuffer, \grainAmp, 0.8, \amp, 0.5]);
				if (~rf.keys.includes(num.asSymbol),{
					"playing demo %".format(num.asSymbol).postln;
					rout = Routine(~rf[num.asSymbol]).play;
				});
			});
			MIDIdef.noteOff(\lgOff, {
				|vel, num|
				rout.stop;
				~grainLive.free;
			});
		},{
			"freeing MIDIdefs".postln;
			[\lgOn, \lgOff].do{|n| MIDIdef(n).free};
			~grainBuffer.free;
		}
	)
};
