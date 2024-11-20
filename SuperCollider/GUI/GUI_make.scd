(
var mkImg, midikeys= ~midi.keys.asArray.sort,
keynames = ["br_ffreq", "SM_nitri", "nitrifikation", "3 mean samples pitch", "3 mean grainScrub", "vowel hard choose", "vowel Steepness", "MikrobenAktivität", "C/N Akkord"],
midiPlayFuncs = (\holdNote: ~holdNote, \oneShot: ~oneShot),
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
    \midi_bg: Color.fromHexString("#a2e876"),
    \live_bg: Color.fromHexString("#e39332"),
    \pattern_bg: Color.fromHexString("#51c9a9"),
	\top_level_frame_color: Color.fromHexString("#CDEDFD"),
	\header_frame_color: Color.fromHexString("#A9F8FB"),
	\bank_frame_color: Color.fromHexString("#B6DCFE"),
	\text_color: Color.fromHexString("#6F6866"),

);

Window.closeAll;
/*~midiSelectors = ~buildSelectors.("midi", ~style.midi_bg, 0,  midikeys, keynames,  ~buffersByName.keys.asArray, ~data.keys.remove(''), midiPlayFuncs, "midi");*/

~liveSelectors = ~buildSelectors.("live", ~style.live_bg, 1, livekeys, liveNames, ~buffersByName.keys.asArray, ~data.keys.remove(''), midiPlayFuncs, "midi");

~patSelectors = ~buildSelectors.("patFuncs", ~style.pattern_bg, 2, patternkeys, patternNames, ~buffersByName.keys.asArray, ~data.keys.remove(''), patFuncs, "pattern");

~dataView = ~buildDataView.(\soilmoisture1, 10);
CmdPeriod.add({ [~selectors, ~dataView].close});


)