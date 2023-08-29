(
var window, top, w_width=1000, w_height=800, dataSelector, bufferSelector, h_selector=100, itemsize=100, offset=20, midikeys= ~rf.keys.asArray.sort;

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
window = ~buildWindow.("DataMusic", 10, 10, w_width, w_height);
top = ~buildTopLevel.(window, 10, 10, w_width, w_height);
// "toplevel".postln;
//dataSelector = ~buildDataSelector.(top, (itemsize + offset ) * midikeys.size, h_selector, itemsize, offset, midikeys, ~data.keys);
bufferSelector = ~buildBufferSelector.(top, 30, 500, 400,  200, itemsize, offset, ~buffers.keys.asArray);
//~buildBufferGrid.();
CmdPeriod.add({window.close});


)