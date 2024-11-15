(
var mkImg, midikeys= ~midi.keys.asArray.sort,
keynames = ["br_ffreq", "SM_nitri", "nitrifikation", "3 mean samples pitch", "3 mean grainScrub", "voweltrig", "vowel hard choose", "vowel Steepness", "MikrobenAktivität", "C/N Akkord"],
trigFuncs = (\holdNote: ~holdNote, \oneShot: ~oneShot),
patternkeys = ~patFuncs.keys.asArray.sort,
patternNames = ~patFuncs.keys.asArray.sort.collect({|n| n.asString}),
patFuncs = (\startPattern: ~startPattern, \stopPattern: ~stopPattern),
livekeys = ~live.keys.asArray.sort,
liveNames = ["harm_index", "harmonized", "rate_temp", "SM_nitrifikatio", "live ffreq"];


~style = (
	// FONTS
	\headerFont: Font("DIN Condensed", 32),
	\subHeaderFont: Font("DIN Condensed", 20),
	\textFont: Font("DIN Condensed", 16),

	// COLORS
	\window_color: Color.fromHexString("#6F6866"),
	\top_level_frame_color: Color.fromHexString("#CDEDFD"),
	\header_frame_color: Color.fromHexString("#A9F8FB"),
	\bank_frame_color: Color.fromHexString("#B6DCFE"),
	\text_color: Color.fromHexString("#6F6866"),

);

Window.closeAll;
~midiSelectors = ~buildSelectors.("midi", midikeys, keynames, ~buffersByName.keys.asArray, ~data.keys.remove(''), trigFuncs, "midi");
"midiSelectors".postln;

~patSelectors = ~buildSelectors.("patFuncs", patternkeys, patternNames, ~buffersByName.keys.asArray, ~data.keys.remove(''), patFuncs, "pattern");
"patternSelectors".postln;
~liveSelectors = ~buildSelectors.("live", livekeys, liveNames, ~buffersByName.keys.asArray, ~data.keys.remove(''), trigFuncs, "midi");
"liveSelectors".postln;
~dataView = ~buildDataView.(\soilmoisture1, 10);
CmdPeriod.add({ [~selectors, ~dataView].close});


)