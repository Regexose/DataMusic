/*
GUI mit verschiedenen SubWindows
- Selector

- playhead über Daten

*/
(

~buildSelectors = {
	| midikeys, buffers, datakeys, funcs|
	var win, keySelector, keyLabels, bufSelector, bufLabels, knobs, toggles, toggleLabels;

	win = Window.new("selector", Rect(150, 30, 800, 400)).front
	.alwaysOnTop_(true);
	keyLabels = midikeys.collect({
		|k,i|
		StaticText.new()
		.string_("midikey " ++ k)
	});
	keySelector = midikeys.collect({
		|k,i|
		PopUpMenu.new()
		.items_(datakeys.asArray)
		.allowsReselection_(True)
		.action_({arg pm; ~selectorAction.(pm)})
		.name_(k)
	});
		knobs = midikeys.collect({
		|k,i|
		Knob.new(bounds: Rect(0, 0, 5, 5))
		.action_({arg kn; ~reduceAction.(kn)})
		.name_(k)
	});

	bufLabels = [\base, \tension, \relax].collect({
		|l,i|
		StaticText.new()
		.string_("buffer " ++ l)
	});

	bufSelector = [\base, \tension, \relax].collect({
		|k, i|
		PopUpMenu.new()
		.items_(buffers)
		.allowsReselection_(True)
		.action_({arg pm; ~bufferSelectorAction.(pm)})
		.name_(k)
	});

	toggles = funcs.values.asArray.collect({
		|func, i|
		var names = funcs.keys.asArray;
		Button.new(bounds: Rect(40, 20))
		.states_([
			[(names[i] ++ "__ON"), Color.red], [(names[i] ++ "__OFF"), Color.black],
		])
		.mouseDownAction_({|btn| "switch %  to %".format( names[i], btn.value).postln; func.(btn.value)})
		.focusColor_(Color.blue)
		.valueAction_(1)
		//.action_({|btn| ; func.(btn.value) })

	});

	win.layout_(VLayout(HLayout(*keyLabels), HLayout(*keySelector), HLayout(*knobs), HLayout(*bufSelector), HLayout(*bufLabels), HLayout(*toggles)));

};

~buildDataView = {
	/*
	- Recording Vorzähler und Fortschritt
	- Knobs mit Auflösung: manipulation des reduce Faktors
	*/
	var win, dataView, dataPlot, image, recCountdown, recProgress;
	image = Image.open(~imagePath +/+ "temp.png");
	win = Window.new("UserControl", Rect(450, 450, 800, 420))
	.background_(~style[\top_level_frame_xcolor]);
	win.front;
	"building dataview ...".postln;
	~databg = View.new(win, Rect(5, 0, 800, 400)).backgroundImage_(image);
	~cursor = UserView.new(win, Rect(0, 0, 800, 400))
	.drawFunc_({|uv|
		Pen.strokeColor = Color.red;
		Pen.moveTo(~posX@0);
		Pen.lineTo(~posX@win.bounds.height);
		Pen.fillStroke;
	});
	win.layout_(StackLayout(~cursor, ~databg ).mode_(\stackAll));


	//ToDo: einen dataBufer als backgroundImage und dann einen Playhead analog zur spielenden Funktion



};

)