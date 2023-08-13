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
)