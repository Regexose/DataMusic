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
		~buffers.add(name.asSymbol -> buf);
		"made buffer  %".format(~buffers[name]).postln;

	}.play(AppClock);
};

~selectorAction = {
	|menu|
	var key, selected, imgPath, image;
	selected = menu.item.asSymbol;
	key = menu.name;
	imgPath = ~imagePath +/+ selected.asString ++ ".png";
	image = Image.open(imgPath);
	~currentData[key.asSymbol][\data] = ~data[selected];
	~databg.setBackgroundImage(image);
	~dataView.refresh;
	"set % with %".format(key, selected).postln;
};

~bufferSelectorAction = {
	|menu|
	var key, selected, filePath, buf;
	selected = menu.item.asSymbol;
	key = menu.name;
	filePath = PathName(~samplesPath +/+ selected +/+ key ++ ".wav");
	buf = Buffer.read(s, filePath.fullPath);
	~currentSample.add(key.asSymbol -> buf);
	"set % with %".format(key, selected).postln;
};

~reduceAction = {
	|knob|
	var keyKnob, knobVal;
	keyKnob = knob.name.asSymbol;
	knobVal = knob.value.linlin(0.0, 1.0, 1, 50).asInteger;
	~currentData[keyKnob][\reduce] = knobVal;
	"set keyKnob % to  %".format(keyKnob, knobVal).postln;
};


~recordUser = {
	|username, typename|
	var rec, filePath, file, progress=0;
	//make Gui for record progress
	rec = Synth(\recOne, [\buf, ~userSound]);
	o = OSCdef(\listener, { |msg|
		{progress = msg[3]}.defer; if(msg[3] >= (~userSound.numFrames -100), {
			"record done".postln;
			rec.free;
			File.mkdir(~samplesPath +/+ username);
			~userSound.write(~samplesPath +/+ username +/+ typename ++ ".wav", "WAV", "int16");
			/*if (~buffers[username.asSymbol].includesKey(typename.asSymbol),
				{"remove key".postln; ~buffers[username.asSymbol].removeAt(typename.asSymbol)});*/
			filePath = PathName(~samplesPath +/+ username +/+ typename ++ ".wav");
			~buffers[username.asSymbol].add(typename.asSymbol -> Buffer.read(s, filePath.fullPath));
	})}, '/cursor');

};

~moveCursor = {
	|pos|
	~posX = pos;
	~cursor.refresh;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////    PLAY FUNCTIONS   ///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////





//restarts play if new MIDI key is pressed with User Sounds
~onOffUser = {
	|act|
	var rout;
	if (act == 1,
		{
			MIDIdef.noteOn(\onoffUserOn, {
				|vel, num|
				if ((rout.notNil && rout.isPlaying), {"stopping rout".postln; rout.stop});
				/*		syn = ~activeSynths.atFail(num.asSymbol,
				{"making default synth with key %".format(num).postln; Synth(\default)});
				syn.free;*/
				if (~rf.keys.includes(num.asSymbol),{
					rout = Routine(~rf[num.asSymbol]).play
				});
				"playing/restart routine %".format(num.asSymbol).postln;
			});
			MIDIdef.noteOff(\onoffUserOff, {
				|vel, num|
				if (~rf.keys.includes(num.asSymbol),{
					rout.stop;
					~activeSynths[num.asSymbol].release(3);
					"stopped routine %  released Synth %".format(~rf[num.asSymbol],~activeSynths[num.asSymbol]).postln;
				});
			});
		},{
			"freeing MIDIdefs".postln;
			[\onoffUserOn, \onoffUserOff].do{|n| MIDIdef(n).free};

		}
	)

};


//always plays the complete data array with User Sounds
~oneShotUser = {
	|act|
	var rout;
	if (act == 1,
		{
			MIDIdef.noteOn(\osUserOn, {
				|vel, num|
				if ((rout.notNil || rout.isPlaying), {
					rout.stop;
					"stopping rout: %".format(num).postln;
					~activeSynths[num.asSymbol].free;
				});

			});
			MIDIdef.noteOff(\osUserOff, {
				|vel, num|
				if (~rf.keys.includes(num.asSymbol),{
					rout = Routine(~rf[num.asSymbol]).play
				});
				"playing oneShot %".format(num.asSymbol).postln;

			});
		},{

            "freeing MIDIdefs".postln;
			[\osUserOn, \osUserOff].do{|n| MIDIdef(n).free};
		}
	)
};

//restarts play if new MIDI key is pressed with Live Buffer
// ~onOffLive = {
// 	|act|
// 	var rec, rout, syn;
// 	if (act == 1,
// 		{
// 			MIDIdef.noteOn(\onoffLiveOn, {
// 				|vel, num|
// 				if ((rout != nil || rout.isPlaying), {"stopping rout".postln; rout.stop});
// 				syn = ~activeSynths.atFail(num.asSymbol,
// 				{"making synth with key %".format(num).postln; Synth(\default)});
// 				syn.free;
// 				rec = Synth(\rec, [\buf, ~liveBuffer]);
// 				"recording on % ".format(num).postln;
// 			});
// 			MIDIdef.noteOff(\onoffLiveOff, {
// 				|vel, num|
// 				"stopped recording".postln;
// 				rec.free;
// 				~currentSample[\base] = ~liveBuffer;
// 				if (~rf.keys.includes(num.asSymbol),{
// 					rout = Routine(~rf[num.asSymbol]).play
// 				});
// 				"playing demo %".format(~rf[num.asSymbol]).postln;
// 			});
// 		},{
// 			"freeing MIDIdefs".postln;
// 			[\onoffLiveOn, \onoffLiveOff].do{|n| MIDIdef(n).free};
// 		}
// 	)
//
// };
//
// //always plays the complete data array with Live Buffer
// ~oneShotLive = {
// 	|act|
// 	var rec, rout ;
// 	if (act == 1,
// 		{
// 			MIDIdef.noteOn(\osLiveOn, {
// 				|vel, num|
// 				rec = Synth(\rec, [\buf, ~liveBuffer]);
// 				"recording on % ".format(num).postln;
// 			});
// 			MIDIdef.noteOff(\osLiveOff, {
// 				|vel, num|
// 				"stopped recording".postln;
// 				rec.free;
// 				if (~rf.keys.includes(num.asSymbol),{
// 					rout = Routine(~rf[num.asSymbol]).play
// 				});
// 				"playing demo %".format(~rf[num.asSymbol]).postln;
// 			});
// 		},{
// 			"freeing MIDIdefs".postln;
// 			[\osLiveOn, \osLiveOff].do{|n| MIDIdef(n).free};
// 		}
// 	)
// };
//
//
// //using tgrains_live with grainBuffer
// ~liveGrain = {
// 	|act|
// 	var syn, rout ;
// 	if (act == 1,
// 		{
// 			MIDIdef.noteOn(\lgOn, {
// 				|vel, num|
// 				~grainLive = Synth(\tgrains_live, [\buf, ~grainBuffer, \grainAmp, 0.8, \amp, 0.5]);
// 				if (~rf.keys.includes(num.asSymbol),{
// 					"playing demo %".format(num.asSymbol).postln;
// 					rout = Routine(~rf[num.asSymbol]).play;
// 				});
// 			});
// 			MIDIdef.noteOff(\lgOff, {
// 				|vel, num|
// 				rout.stop;
// 				~grainLive.free;
// 			});
// 		},{
// 			"freeing MIDIdefs".postln;
// 			[\lgOn, \lgOff].do{|n| MIDIdef(n).free};
// 			~grainBuffer.free;
// 		}
// 	)
// };
