/*
GUI mit verschiedenen SubWindows
- Selector

- playhead über Daten

*/
(

~buildSelectors = {
	| midikeys, buffers, datakeys|
	var win, keySelector, keyLabels, bufSelector, bufLabels, knobs;
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

	win.layout_(VLayout(HLayout(*keyLabels), HLayout(*keySelector), HLayout(*knobs), HLayout(*bufSelector), HLayout(*bufLabels)));

};

~buildUserControl = {
	/*
	- Recording Vorzähler und Fortschritt
	- Knobs mit Auflösung: manipulation des reduce Faktors
	*/
	| midikeys|
	var win, dataView, recCountdown, recProgress;
	win = Window.new("UserControl", Rect(450, 30, 800, 400))
	.background_(~style[\top_level_frame_color])
	.front;
/*
	dataView = View()
	ToDo: einen dataBufer als backgroundImage und dann einen Playhead analog zur spielenden Funktion
	.backgroundImage_(~data.temp.plot);

	win.layout_(VLayout(HLayout(dataView)));*/


};

)