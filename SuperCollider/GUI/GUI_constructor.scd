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
        .valueAction_(1)
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
    - Auswahl von Datenbereichen mit rangeSlider
    */
    |data, reduce|
    var win, dataPlot, image, recCountdown, recProgress, inIdx, outIdx, dataMin, dataMax, data2, resetButton, refreshButton, vLines = 100, hLines;
    image = Image.open(~imagePath +/+ "temp.png");
    image.setSize(900, 450, \keepAspectRatio );
    # inIdx, outIdx = [0, data.size-1];
    data = data[inIdx.. outIdx].select({|n, i| i%reduce==0});
    data2 = data.copy;
    hLines = [0.1, 0.25, 0.75, 1.0, 1.25].collect({|n| data.maxItem *n});
    hLines.insert(2, data.mean);
    win = Window.new("UserControl", Rect(450, 450, 1000, 600))
    .background_(~style[\top_level_frame_xcolor])
    //.autoRememberPosition(\data, \view)
    .front;

    ~drawData = UserView.new(win,  Rect(0, 0, 1000, 500))
    .background_(~style.top_level_frame_color)
    .drawFunc_({|uv|
        var  x, y,  in, out, height=500;
        #x, y = [0, 0];
        Pen.fillColor_(Color.black);
        hLines.do({|leg|
            var l = leg.linlin(0, 80, height, 0);
            Pen.moveTo(0@l);
            Pen.lineTo(1000@l);
            StaticText(win, Rect(960, l, 40, 30)).string_(leg.asString)
        });
        Pen.fillStroke;
        Pen.width_(2);
        Pen.lineTo(0@0);
        data.do{ |d, i|
            Pen.moveTo(x@y);
            x = (i+1).linlin(0, data.size-1, 0, win.bounds.width).asInteger;
            y = d.linlin(data.minItem, data.maxItem, height, 0);
            Pen.lineTo(x@y);
            if (i%vLines==0, {
                //"d % x  %   y % ".format(d, x, y).postln;
                StaticText(win, Rect(x, 20, 30, 30))
                .string_(d.asString)
                .align_(\left);
                //lines
                Pen.strokeColor_(Color.grey);
                Pen.moveTo(x@y);
                Pen.lineTo(x@50);
                Pen.fillStroke;

            });
            Pen.strokeColor_(Color.blue);
            Pen.fillStroke;
        };
    });


    ~dataSlider = RangeSlider.new(win, Rect(0, 550, 1000, 50))
    .lo_(0.12)
    .hi_(0.59)
    .background_(Color.green(0.5, 0.1))
    .action_({|sl|
        [ inIdx, outIdx].postln;
        [sl.lo, sl.hi ].postln;
        inIdx = (sl.lo * (data.size-1)).asInteger;
        outIdx = (sl.hi * (data.size-1)).asInteger;
        "new range % mit in % out %".format(outIdx- inIdx, inIdx, outIdx).postln;

    });


    ~cursor = UserView.new(win, ~drawData.bounds)
    .drawFunc_({|uv|
        Pen.strokeColor = Color.red;
        Pen.fillColor = Color.red;
        Pen.width = 5;
        Pen.moveTo(~posX@0);
        Pen.lineTo(~posX@win.bounds.height);
        //Pen.addRect(Rect(~posX, 0, 5, win.bounds.height ))
        Pen.stroke;
    })

    ;

    resetButton = Button.new(win, Rect(50, 510, 70, 20))
    .states_([["no", Color.white, Color.grey], ["reset", Color.grey, Color.white]])
    .font_(~style.textFont)

    .action_({|btn|
      "reset size with %".format(btn.value).postln;
         if (btn.value==0, {
            var key= ~currentData.globalKey;
            data = data2;
            ~currentData[key][\data] = data;
            "data2 size % reset data size %".format(data2.size, data.size).postln;
            ~drawData.refresh})
    });


    refreshButton = Button.new(win, Rect(150, 510, 70, 20))
    .states_([
        [ "refreshON", Color.black, Color.white],
        [ "refreshOFF", Color.red, Color.white]
    ])
     .font_(~style.textFont)

    .action_({|btn|
        var key;
        btn.value.postln;
        if (btn.value==0, {
            (data[0..data2.size].size).postln;
            data = data[inIdx..outIdx];
            key= ~currentData.globalKey;
            ~currentData[key][\data] = data;
            "new Data size %".format(data.size).postln;
            ~drawData.refresh})
    });

    //win.layout_(StackLayout( ~cursor, ~drawData, ~dataSlider, resetButton, refreshButton ).mode_(\stackAll));

};

)