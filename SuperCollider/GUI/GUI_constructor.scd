/*
GUI mit verschiedenen SubWindows
- Selector

- playhead über Daten

*/
(

~buildSelectors = {
	| midikeys, buffers, datakeys|
	var win, keySelector, keyLabels, bufSelector, bufLabels;
	win = Window.new("selector", Rect(150, 30, 800, 400)).front;
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

	win.layout_(VLayout(HLayout(*keyLabels), HLayout(*keySelector), HLayout(*bufSelector), HLayout(*bufLabels)));

};

~buildUserControl = {
	/*
	- Recording Vorzähler und Fortschritt
	- Knobs mit Auflösung: manipulation des reduce Faktors
	*/
	| midikeys|
	var win, knobs, knobLabels, recCountdown, recProgress;
	win = Window.new("UserControl", Rect(450, 30, 800, 400))
	.background_(~style[\top_level_frame_color])
	.front;
	knobLabels = midikeys.collect({
		|k,i|
		StaticText.new()
		.string_("midikey " ++ k)
	});
	knobs = midikeys.collect({
		|k,i|
		Knob.new()
		.action_({arg kn; ~reduceAction.(kn)})
		.name_(k)
	});

	win.layout_(VLayout(HLayout(*knobLabels), HLayout(*knobs)));

};

)