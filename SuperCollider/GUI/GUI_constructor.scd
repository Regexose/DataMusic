/*
GUI mit verschiedenen SubWindows
- Selector

- playhead über Daten

*/
(

~buildSelectors = {
    |name, winbg,  yfactor, midikeys, keynames, buffers, datakeys, funcs, mode|
    var win, boxes, pauses, keyLabels, bufLabels, res, modcase, toggles, fx, toggleLabels, layout, lay=();

    win = Window.new(name, Rect(10, 10 + (yfactor *400), 800, 400))
    //.autoRememberPosition(\select, \w)
    .alwaysOnTop_(true)
    .background_(winbg)
    .front;

    boxes = midikeys.collect({
        |k,i|
        Button() // initialState
        .states_([
             [(k.asString ++ "__OFF"), Color.black], [(k.asString ++ "__ON"), Color.red],
        ])
        .action_({|btn| btn.value.postln; ~onOffButton.(btn.value, k,  i, name)})


    });

    pauses = midikeys.collect({
        |k,i|
        Button.new(bounds: Rect(40, 20))

        .states_([
            [(k.asString ++ "__PAUS"), Color.blue], [(k.asString ++ "__RESUME"), Color.green],
        ])
        .background_(Color.rand)
        //.mouseDownAction_({arg btn; "mouse down".postln; ~pausUserMouse.(btn.value, ~routines[k], k)})
        .mouseUpAction_({arg btn; "mouse pauses up".postln; ~pausButton.(btn.value, ~routines[k], k)})
        .valueAction_(1)

    });


    keyLabels = midikeys.collect({
        |k,i|
        StaticText.new()

        .string_(keynames[i].asString)
        .align_(\center)

    });
    ~keySelector = midikeys.collect({
        |k,i|
        [k,i].postln;
        PopUpMenu.new()
        .items_(datakeys.asArray)
        .allowsReselection_(True)
        .action_({arg pm; ~selectorAction.(pm)})
        .name_(k)

    });
    res = midikeys.collect({
        |k,i|
       PopUpMenu.new()
        .autoRememberPosition(\select, \w)
        .allowsReselection_(True)
        .items_([2, 5, 8, 10,20] )
        .valueAction_(1)
        .action_({arg pm; ~reduceAction.(pm)})
        .name_(k)
    });

    bufLabels = [\base, \tension, \relax].collect({
        |l,i|
        StaticText.new()
        //.autoRememberPosition(\select, \w)
        .string_("buffer " ++ l)
    });

    ~bufSelector = [\base, \tension, \relax].collect({
        |k, i|
        PopUpMenu.new()
       // .autoRememberPosition(\select, \w)
        .items_(buffers)
        .allowsReselection_(True)
        .action_({arg pm; ~bufferSelectorAction.(pm)})
        .name_(k)
    });

    modcase = case
    {mode=="midi"}{
        //dies schaltet nur die Mididefs an oder aus
        toggles = funcs.keys.asArray.collect({
            |f, i|
            var keys = midikeys.asArray;
            Button.new(bounds: Rect(40, 20))
            .states_([
                [(f.asString ++ "__ON"), Color.red], [(f.asString ++ "__OFF"), Color.black
                ],
            ])
            .mouseDownAction_({|btn| "switch %  to %".format( f, btn.value).postln; funcs[f].(btn.value, name)})
            .focusColor_(Color.blue)
            .valueAction_(1);

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
        ]

    }
    {true}{"no modus".postln};

    lay[\keys] = VLayout(HLayout(*keyLabels), HLayout(*~keySelector), HLayout(*res));
    lay[\box] = HLayout(*boxes);
    lay[\paus] = HLayout(*pauses);
    lay[\stack1] = StackLayout(View().layout_(VLayout(lay[\keys], lay[\box], lay[\paus]))).mode_(\stackAll);
    lay[\buf] = VLayout( HLayout(*~bufSelector), HLayout(*bufLabels)).margins_(0).spacing_(5);
    layout = VLayout(lay[\stack1], nil, lay[\buf], nil, HLayout(*toggles));
    win.layout_(layout);

};

~buildDataView = {
    /*
    - Auswahl von Datenbereichen mit rangeSlider
    */
    | key, reduce|
    var win, recCountdown, recProgress, inIdx, outIdx, dataMin, dataMax, data, dataPt, resetButton, refreshButton, hLines, sliderLine, layout, stack, vLines = 100, loX=400, hiX=1000;
    # inIdx, outIdx = [0, data.size-1];
    //"key % reduce %".format(key, reduce).postln;
    data = ~data[key].select({|n, i| i%reduce==0});
    //" data size %".format( data.size).postln;
    hLines = [0.1, 0.25, 0.75, 1.0, 1.25].collect({|n| data.maxItem *n});
    hLines.insert(2, data.mean);
    win = Window.new("Current Data Display",  Rect(450, 450, 1000, 600))
   .background_(~style[\top_level_frame_xcolor])
    //.autoRememberPosition(\data, \view)
    .front;
    ~drawData = UserView.new(win, Rect(0, 0, 1000, 500))
    .drawFunc_({|uv|
        var  x, y,  in, out, height=500;
        #x, y = [0, 0];
        Pen.fillColor_(Color.black);
        hLines.do({|leg|
            var l = leg.linlin(0, data.maxItem *1.25, height, 0);
            Pen.moveTo(0@l);
            Pen.lineTo(1000@l);
            Pen.stroke;
            StaticText(~drawData, Rect(960, l, 40, 30))
            .string_(leg.round(0.02).asString);
        });
        Pen.fillStroke;
        Pen.width_(2);
        Pen.lineTo(0@0);
        data.do{ |d, i|
            Pen.moveTo(x@y);
            x = (i+1).linlin(0, data.size-1, 0, win.bounds.width).asInteger;
            y = d.linlin(0, data.maxItem *1.25, height, 0);
            dataPt = d;
            Pen.lineTo(x@y);
            if (i%vLines==0, {
                //"d % x  %   y % ".format(d, x, y).postln;
                StaticText(~drawData, Rect(x, 20, 30, 30))
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


    ~dataSlider = RangeSlider(win, bounds: Rect(0, 500, 1000, 50))
    .lo_(0.12)
    .hi_(0.59)
    .action_({|sl|
        loX = sl.lo * 1000;
        hiX = sl.hi * 1000;
        sliderLine.refresh;
        //[loX, hiX].postln;
        inIdx = (sl.lo * ~data[key].size).asInteger;
        outIdx = (sl.hi * ~data[key].size).asInteger;
        //"new range % mit in % out %".format(outIdx- inIdx, inIdx, outIdx).postln;
    });

    sliderLine = UserView(win,Rect(0, 400, 1000, 500))
    .drawFunc_({|uv|
        Pen.strokeColor= Color.grey;
        Pen.width = 2;
        Pen.moveTo(loX @ 0);
        Pen.lineTo(loX @ ~drawData.bounds.height);
        Pen.stroke;
        Pen.strokeColor= Color.magenta;
        Pen.width = 2;
        Pen.moveTo(hiX @ 0);
        Pen.lineTo(hiX @ ~drawData.bounds.height);
        Pen.stroke;
    });

    ~cursor = UserView.new(win, bounds: ~drawData.bounds)
    .drawFunc_({|uv|
        Pen.strokeColor = Color.red;
        Pen.fillColor = Color.red;
        Pen.width = 5;
        Pen.moveTo(~posX@0);
        Pen.lineTo(~posX@win.bounds.height);
        //Pen.addRect(Rect(~posX, 0, 5, win.bounds.height ))
        Pen.stroke;
    });

    resetButton = Button.new(win, bounds: Rect(50, 550, 70, 20))
    .states_([["no", Color.white, Color.grey], ["reset", Color.grey, Color.white]])
    .font_(~style.textFont)

    .action_({|btn|
      //"reset size with %".format(btn.value).postln;
         if (btn.value==0, {
            var k = ~currentData.globalKey;
            var oldsize = data.size;
           "k is % key is %m reduce is %".format(k, key, reduce).postln;
            ~currentData[k][\reduce] = 10;
            ~currentData[k][\data] = data = ~data[key].select({|n, i| i%10==0});
            ~currentData[k][\in] = 0;
            ~currentData[k][\out] = data.size-1;
            "old size % reset data size %".format(oldsize, data.size).postln;
            ~drawData.refresh})
    });


    refreshButton = Button.new(win, bounds: Rect(150, 550, 70, 20))
    .states_([
        [ "refreshON", Color.black, Color.white],
        [ "refreshOFF", Color.red, Color.white]
    ])
     .font_(~style.textFont)
    .action_({|btn|
        var k = ~currentData.globalKey;
        var zoomReduce = 4;
        btn.value.postln;
        if (btn.value==0, {
            data = ~data[key][inIdx..outIdx].select({|n, i| i%zoomReduce==0});
            ~currentData[k][\in] = (~dataSlider.lo * (~data[key].size-1)).asInteger; //der absolute Wert der Originaldaten
            ~currentData[k][\out] = (~dataSlider.hi * (~data[key].size-1)).asInteger;
            ~currentData[k][\data] = data;
            ~currentData[k][\reduce] = zoomReduce;
            "new Data size %  in % out %".format(data.size, ~currentData[k][\in], ~currentData[k][\out]).postln;
            ~drawData.refresh})
    });
    layout = VLayout(resetButton, refreshButton, ~dataSlider);
    win.layout_(StackLayout( ~drawData, sliderLine, ~cursor, layout).mode_(\stackAll));

};

)