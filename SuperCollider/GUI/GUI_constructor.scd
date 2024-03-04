/*
GUI mit verschiedenen SubWindows
- Selector

- playhead über Daten

*/
(

~buildSelectors = {
	| midikeys, keynames, buffers, datakeys, funcs|
	var win, boxes, keyLabels,  bufLabels, knobs, toggles, toggleLabels, layout, lay=();

	win = Window.new("selector", Rect(150, 30, 800, 400)).front
	.alwaysOnTop_(true);

	boxes = midikeys.collect({
		|k,i|
        Button.new(bounds: Rect(40, 20))
		.states_([
            [(k.asString ++ "__ON"), Color.red], [(k.asString ++ "__OFF"), Color.black]])
        .background_(Color.rand)
        .mouseDownAction_({arg btn; "mouse down".postln; ~onOffUserMouse.(true, ~routines[k], k)})
        .mouseUpAction_({arg btn; "mouse up".postln; ~onOffUserMouse.(false, ~routines[k], k)})

	});

	keyLabels = midikeys.collect({
		|k,i|
		StaticText.new()
		.string_(keynames[i] ++ "__" ++ k)
		.align_(\center)
	});
	~keySelector = midikeys.collect({
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

	~bufSelector = [\base, \tension, \relax].collect({
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

	lay[\keys] = VLayout(HLayout(*keyLabels), HLayout(*~keySelector), HLayout(*knobs));
	lay[\box] = HLayout(*boxes);
	lay[\stack1] = StackLayout(View().layout_(VLayout(lay[\keys], lay[\box]))).mode_(\stackAll);
	lay[\buf] = VLayout( HLayout(*~bufSelector), HLayout(*bufLabels)).margins_(0).spacing_(5);
	lay[\keys].postln;
	//layout = VLayout(lay[\stack1], lay[\stack2], HLayout(*toggles));
	//lay.values.do({|k| k.class.postln});
	layout = VLayout(lay[\stack1], nil, lay[\buf], nil, HLayout(*toggles));
	win.layout_(layout);

};

~buildDataView = {
	/*
	- Recording Vorzähler und Fortschritt
	- Knobs mit Auflösung: manipulation des reduce Faktors
	*/
	var win, dataView, dataPlot, image, recCountdown, recProgress;
	//image = Image.open(~imagePath +/+ "temp.png").setSize(900, 450, \keepAspectRatio );
	image = Image.open(~imagePath +/+ "temp.png");
    image.setSize(900, 450, \keepAspectRatio );
	win = Window.new("UserControl", Rect(450, 450, 1000, 460))
	.background_(~style[\top_level_frame_xcolor]);
	win.front;
	"building dataview ...".postln;
	~databg = View.new(win, Rect(5, 0, 900, 450)).backgroundImage_(image);
	~cursor = UserView.new(win, Rect(0, 0, 900, 450))
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