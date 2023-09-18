(
var mkImg, midikeys= ~rf.keys.asArray.sort, trigFuncs = (\onOffUser: ~onOffUser, \oneShotUser: ~oneShotUser, \onOffLive: ~onOffLive, \oneShotLive: ~oneShotLive);

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

/*mkImg = Routine({
	//~makeDataImages.();
	2.5.wait;
	Window.closeAll;
	~selectors = ~buildSelectors.(midikeys,  ~buffers.keys.asArray, ~data.keys, trigFuncs );
	~dataView = ~buildDataView.();
}).play(AppClock);*/

Window.closeAll;
~selectors = ~buildSelectors.(midikeys,  ~buffers.keys.asArray, ~data.keys, trigFuncs );
~dataView = ~buildDataView.();

CmdPeriod.add({ [~selectors, ~dataView].close});


)