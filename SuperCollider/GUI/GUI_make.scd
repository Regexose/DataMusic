(
var window, top, w_width, w_height;

w_width = 100;
w_height = 120;
window = ~buildWindow.("DataMusic", 10, 10, w_width*6+500, w_height + 380);
top = ~buildTopLevel.(window, 10, 10, w_width*5+ 720, w_height*5+360);


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



CmdPeriod.add({
	window.close;
});


)