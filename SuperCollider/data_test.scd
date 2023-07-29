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
(
var buf = ~buffers[\boris][19];
x = Synth(\brSec, [\buf, buf, \sec, buf.numFrames/100,  \rate, 1, \sus, 30, \secIdx, 3 ])
)
x.set(\secIdx, 6, \sec, 2000)


