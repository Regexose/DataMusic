(
//ServerOptions.devices
//~audioInterface = "MacBook Pro-Lautsprecher";
~audioInterface = "Fireface 400 (BEF)";
Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
//Server.default.options.inDevice_(~audioInterface);
s.newBusAllocators;
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~dataPath = PathName(~projectRoot).parentPath ++ "data";
~samplesPath = PathName(~projectRoot).parentPath ++ "samples";

~resourcePath = ~projectRoot ++ "resources/";

~baromabs= List.new;
~temps = List.new;
~barotemps = List.new;
~buffers = Dictionary.new;

~csvFile = CSVFileReader.read(~dataPath ++ "/test_data.csv", true);
~csvFile.do({
	|row, i|
	var c;
	c = case
	{(i != 0) && row[1].isString}{
		row[1] = row[1].asFloat;
		row[2] = row[2].asFloat;
		~baromabs.add(row[1]);
		~temps.add(row[2]);
		~barotemps.add([row[1], row[2]]);
	}
	{true}{"end csv.postln"}
});

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	Pbindef.all.do(_.clear);
	s.sync;
	MIDIClient.init;
	MIDIIn.connectAll;
	~midiOut = MIDIOut.new(0);
	~midiIn = MIDIIn.new(0);

	PathName(~samplesPath).entries.do({
		arg subfolder;
		//subfolder.postln;
		~buffers.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		)
	});

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

	(~resourcePath ++ "synthDefs.scd").load;

	"done".postln;
})

)
(#[300, 400, 500, 600] +.t [0,0.5]).cubed.sum
[ 998.7137378093677, 998.7137378093677, 998.7137378093677 ] *0.001
1.0 / 998.7137378093677
(4096 / 282).floor
282 * 14 + 148
~baromabs.sort


(


)
~buffers[\wt].free
~makeWaveTable.(4096, ~baromabs, \baro)
Synth(\oscfm, [\atk, 1, \rls, 3])
(
~test = Routine({
		var syn = Synth( \arrayarg, [\amp, 0.03]);
	~barotemps.clump(3).do({
		|bt|
		if (bt.isArray, {
			bt.postln;
			syn.setn(\freqs, bt[0], \temps, bt[1] );
		} );
		1.wait;
	})
}).play;
)
// wavetable
(
//sc_230727_201826_stereo
~test = Routine({
	var syn;
	~barotemps.do({
		|bt|
		~makeWaveTable.(4096, ~temps, \temps);
		~makeWaveTable.(4096, ~baromabs, \baro);
		syn = Synth(\oscfm, [\buf1, ~buffers[\baro], \buf2, ~buffers[\temps], \atk, 0.2, \rls, 1, \modamp, bt[0]/2, \modfreq, bt[0], \freq, bt[1]]);
		0.6.wait;
	})
}).play;
)

(
// with voice samples
~buffers[\boris][15].play


)


(
//sc_230727_164424_stereo
~test = Routine({
	~barotemps.clump(3).do({
		|bt|
		var syn = Synth(\dynklank, [\amp, 0.2, \pan, rrand(-0.1, 0.1), \pLag, 0.3]);
		if (bt.isArray, {
			bt.postln;
			syn.set(\freqs, bt[0], \rings, bt[1], \freqScale, bt[1][1], \decayScale, bt[1][0]);
		} );
		1.wait;
	})
}).play;
)
s.makeWindow

(
p = Pmono(\arrayarg,
	\amp, 0.01,
	\pan, Pwhite(-0.9, 0.9, inf),
	\pLag, 0.1,
	\freqIndex, Pseq((0..(~baromabs.clump(3).size -1)), inf).trace,
	\freqs, Pfunc({|ev| ~baromabs.clump(3)[ev.freqIndex]}).trace,
).play
)
~test.stop
