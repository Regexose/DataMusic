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
	var compView;
	compView = CompositeView(window, Rect(posx, posy, width, height))
	.background_(~style.top_level_frame_color);
	compView.addFlowLayout(10@10);
	compView.decorator.gap_(0@10);
	//"built toplevel".postln;
	compView;
};

~buildDataSelector = {
	arg top_level, all_selectors_width, selector_height, selectorsize, offset, midikeys, items;
	var selectorData, compView, selectors, selector_labels;
	midikeys.postln;
	compView = CompositeView(top_level, Rect(0, 0, all_selectors_width, selector_height *2))
	.background_(~style.bank_frame_color);
	selectors = Dictionary.new;
	midikeys.do({
		|mid, i|
		mid.class.postln;
		selectors[mid.asString] = PopUpMenu(compView, Rect((selectorsize+offset) * i, offset, selectorsize, selectorsize/2))
		.items_(items.asArray)
		.allowsReselection_(True)
		.action_({arg pm; ~selectorAction.(pm)})
		.name_(mid.asString);
	});
	selector_labels = midikeys.do({
		|mid, i|
		StaticText(compView,  Rect((selectorsize+offset) * i, offset*3, selectorsize, selectorsize/2))
		.align_(\center)
		.stringColor_(Color.black)
		.string_("midikey "++ mid);
	});
	selectorData = [compView, selectors, selector_labels];
};
)