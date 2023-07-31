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