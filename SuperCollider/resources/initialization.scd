~csvFile = CSVFileReader.read(~dataPath ++ "/zku_noTime.csv", true, true).postcs;

~header = ~csvFile[0];
~lines = ~csvFile[1..287].collect(_.collect(_.interpret));
~lines[0];
~lines[0].size;
~header.size
~header[0]
~data = ();
~header.size.do({
	|i|
	var val= List.new;
	~lines[i].do({
		|line|
		val.add(line[i])
	})
	~data.put(~header[i], [i])
})

// ~csvFile.do({
// 	|row, i|
// 	var c;
// 	c = case
// 	{(i != 0) && row[1].isString}{
// 		row[1] = row[1].asFloat;
// 		row[2] = row[2].asFloat;
// 		~baromabs.add(row[1]);
// 		~temps.add(row[2]);
// 		~barotemps.add([row[1], row[2]]);
// 	}
// 	{true}{"end csv.postln"}
// });

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

/// Todo: collect daten pro spalte in je einer liste
~csvFile[0..1].collect({|row| row.postln; row[1..287].collect({|row, i| [row, i].postln})});
~csvFile[0..1].collect(_.collect({|row, i| [row, i].postln}));
~lines = ~csvFile[1..287].collect(_.collect({|row, idx| }_.interpret));
~csvFile[0][0]