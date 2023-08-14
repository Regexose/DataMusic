/*
GUI mit verschiedenen SubWindows
-  drop down data Selektor
- playhead über Daten

*/
(
~buildWindow = {
	// Builds the main window that contains everything
	arg window_title, x=10, y=10, width, height;
	Window(window_title, Rect(x, y, width, height))
	.background_(~style.window_color)
	.front;
};

~buildTopLevel = {
	// Buildts a top level composite view that manages child views' spacing.
	arg window, posx=10, posy=10, width, height;
	var compView = CompositeView(window, Rect(posx, posy, width, height))
	.background_(~style_1["top_level_frame_color"]);
	compView.addFlowLayout(10@10);
	compView.decorator.gap_(0@10);
	//"built toplevel".postln;
	compView;
};

~buildDataSelector = {
	arg top_level, selector_width, button_field_height, buttonsize, offset, rows;
	var selectorData, compView, selectors;
	compView = CompositeView(top_level, Rect(0, 0, selector_width+offset, buttonsize+(2*offset) + button_field_height))
	.background_(~style.bank_frame_color);
	selectors = Dictionary.new;
	~data.keys.do({arg key, i;
		selectors[key] = PopUpMenu(compView, Rect(0, buttonsize+offset+(i*buttonsize), selector_width, buttonsize))
		.items_(key)
		.action_({arg pm; pm.postln})
		.name_(cat);
	});
	selectorData = [compView, selectors];
};
)