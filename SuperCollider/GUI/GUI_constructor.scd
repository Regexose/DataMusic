/*
GUI mit verschiedenen SubWindows
- Selector

- playhead über Daten

*/
(

~buildSelectors = {
    | midikeys, keynames, buffers, datakeys, funcs, mode|
    var win, boxes, pauses, keyLabels, bufLabels, knobs, modcase, toggles, fx, toggleLabels, layout, lay=();

    win = Window.new("selector", Rect(150, 30, 800, 400))
    .autoRememberPosition(\select, \w)
    .alwaysOnTop_(true)
    .front;

    boxes = midikeys.collect({
        |k,i|
        Button.new(bounds: Rect(40, 20))
        .autoRememberPosition(\select, \w)
        .states_([
            [(k.asString ++ "__ON"), Color.red], [(k.asString ++ "__OFF"), Color.black]
        ])
        .background_(Color.rand)
        .mouseDownAction_({arg btn; "mouse boxes down".postln; ~onOffUserMouse.(true, ~routines[k], k)})
        .mouseUpAction_({arg btn; "mouse boxes up".postln; ~onOffUserMouse.(false, ~routines[k], k)})

    });

    pauses = midikeys.collect({
        |k,i|
        Button.new(bounds: Rect(40, 20))
        .autoRememberPosition(\select, \w)
        .states_([
            [(k.asString ++ "__PAUS"), Color.blue], [(k.asString ++ "__RESUME"), Color.green],
        ])
        .background_(Color.rand)
        //.mouseDownAction_({arg btn; "mouse down".postln; ~pausUserMouse.(btn.value, ~routines[k], k)})
        .mouseUpAction_({arg btn; "mouse pauses up".postln; ~pausUserMouse.(btn.value, ~routines[k], k)})
        .valueAction_(1)

    });

    keyLabels = midikeys.collect({
        |k,i|
        StaticText.new()
        .autoRememberPosition(\select, \w)
        .string_(keynames[i].asString ++ "__" ++ k)
        .align_(\center)

    });
    ~keySelector = midikeys.collect({
        |k,i|
        PopUpMenu.new()
        .autoRememberPosition(\select, \w)
        .items_(datakeys.asArray)
        .allowsReselection_(True)
        .action_({arg pm; ~selectorAction.(pm)})
        .name_(k)

    });
    knobs = midikeys.collect({
        |k,i|
        Knob.new(bounds: Rect(0, 0, 5, 5))
        .autoRememberPosition(\select, \w)
        .action_({arg kn; ~reduceAction.(kn)})
        .name_(k)

    });

    bufLabels = [\base, \tension, \relax].collect({
        |l,i|
        StaticText.new()
        .autoRememberPosition(\select, \w)
        .string_("buffer " ++ l)

    });

    ~bufSelector = [\base, \tension, \relax].collect({
        |k, i|
        PopUpMenu.new()
        .autoRememberPosition(\select, \w)
        .items_(buffers)
        .allowsReselection_(True)
        .action_({arg pm; ~bufferSelectorAction.(pm)})
        .name_(k)

    });

    modcase = case
    {mode=="midi"}{
        toggles = funcs.values.asArray.collect({
            |func, i|
            var names = midikeys.asArray;
            Button.new(bounds: Rect(40, 20))
            .states_([
                [(names[i] ++ "__ON"), Color.red], [(names[i] ++ "__OFF"), Color.black
                ],
            ])
            .mouseDownAction_({|btn| "switch %  to %".format( names[i], btn.value).postln; func.(btn.value)})
            .focusColor_(Color.blue)
            .valueAction_(1)
            .autoRememberPosition(\select, \w)

            //.action_({|btn| ; func.(btn.value) })
        })
    }
    {mode=="pattern"}{
        toggles = midikeys.collect({
            |name, i|
            Button.new(bounds: Rect(40, 20))
            .states_([
                [(name ++ "__stop"), Color.red], [(name ++ "__start"), Color.green]
            ])
            .mouseDownAction_({|btn| "switch %  to %".format( name, btn.value).postln; ~startPattern.(btn.value, name)})
            .focusColor_(Color.blue)
            .valueAction_(1)
            .autoRememberPosition(\select, \w)

            //.action_({|btn| ; func.(btn.value) })
        }) ++ [
            Button.new(bounds:Rect(40,20))
            .states_([
                ["FX_ON", Color.green], ["FX_OFF", Color.red]
            ])
            .mouseDownAction_({|btn| "switch % ".format(btn.value).postln; ~fxOnOff.(btn.value.asBoolean)})
            .valueAction_(1)
            .autoRememberPosition(\select, \w)
        ]

    }
    {true}{"no modus".postln};

  lay[\keys] = VLayout(HLayout(*keyLabels), HLayout(*~keySelector), HLayout(*knobs));
    lay[\box] = HLayout(*boxes);
    lay[\paus] = HLayout(*pauses);
    lay[\stack1] = StackLayout(View().layout_(VLayout(lay[\keys], lay[\box], lay[\paus]))).mode_(\stackAll);
    lay[\buf] = VLayout( HLayout(*~bufSelector), HLayout(*bufLabels)).margins_(0).spacing_(5);
    layout = VLayout(lay[\stack1], nil, lay[\buf], nil, HLayout(*toggles));
/*    lay[\keys] = HLayout(VLayout(*keyLabels), VLayout(*~keySelector), VLayout(*knobs));
    lay[\box] = VLayout(*boxes);
    lay[\paus] = VLayout(*pauses);
    lay[\stack1] = StackLayout(View().layout_(HLayout(lay[\keys], lay[\box], lay[\paus]))).mode_(\stackAll);
    lay[\data] = VLayout(dataView);
    lay[\buf] = HLayout( VLayout(*~bufSelector), VLayout(*bufLabels)).margins_(0).spacing_(5);

    layout = HLayout(lay[\stack1], nil, lay[\buf], nil, VLayout(*toggles));*/
    win.layout_(layout);

};

~buildDataView = {
    /*
    - Update und Skalierung von Views (UserView)
    - Auswahl von Datenbereichen mit Mouse
    */
    var win, dataView, dataPlot, image, recCountdown, recProgress;
    image = Image.open(~imagePath +/+ "temp.png");
    image.setSize(900, 450, \keepAspectRatio );
    win = Window.new("UserControl", Rect(450, 450, 1000, 460))
    .background_(~style[\top_level_frame_xcolor])
     .acceptsMouseOver_(true)
    .autoRememberPosition(\data, \view);
    win.front;
    //"building dataview ...".postln;
    ~databg = View.new(win, Rect(5, 0, 900, 450))
    .backgroundImage_(image)
    .background_(Color.green)
    .acceptsMouse_(true)
    .mouseDownAction_({|v, x| x.postln; ~currentData.dataIn = x })
    .mouseUpAction_({|v, x|
        "new range % from % to %".format(~currentData.dataIn, x, x - ~currentData.dataIn).postln;
        ~currentData.dataOut = x })
    .front
    ;

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