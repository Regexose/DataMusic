~td = (
    // on Off Play
    \48 : {
        /*
        Idee: ein Grundton im grainBuffer wird entlang bestimmter Scales erweitert
        */
        var key= \48, data1, data2,  buf, synths1, synths2,  mn, mx, scales, ranges;
        //"play TD %  sm %".format(key, ~sm1).postln;
        ranges = [[0.0, 4.0], [4.0, 7.0], [7.0, 9.0], [9.0, 10.0], [10.0, 11.0], [11.0, 12.0], [12.0, 14.0], [14.0, 21.0], [21.0, 25.0], [25.0, 30.0]];
        buf = ~liveBuffer.normalize;
        //buf = ~buffersByName[\boris][\gras].normalize;
        scales = [Scale.major, Scale.minor, Scale.ionian, Scale.phrygian, Scale.spanish, Scale.purvi, Scale.marva, Scale.major, Scale.minor,  Scale.lydian];
        # mn, mx = [7.0, 25.0];
        s.sync;
        synths1 = scales[0].degrees.collect({|d, i| Synth(\brLive, [\amp, 0.7 - (0.04* i), \ptrBus, ~ptrBus,  \buf, buf, \rate, 1.0, \harm, d * [-1,1].choose, \rq, 0.2,  \rls, 1.4, \lg, 0.4, \pan, -1+ (i * 0.05), \out, i], ~sourceGrp)});
        //synths2 = scales[0].degrees.collect({|d, i| Synth(\bellFm, [\amp, 0.051 - (0.01* i), \freq, 60.midicps, \lg, 0.3, \rls, 1.8, \pan, 1 - (i * 0.05)], ~sourceGrp)});

        ~activeSynths.put(key, [synths1, synths2].flat);
        inf.do({|x|
            var degrees1, degrees2, r1Index, r2Index, freq1, freq2;
            data1 = ~currentData.td[\sm1];
            data2 = ~currentData.td[\sm2];
            ranges.do({|n,i| if (((data1 >= n[0]) && (data1 < n[1])), {r1Index = i})});
            ranges.do({|n,i| if (((data2 >= n[0]) && (data2 < n[1])), {r2Index = i})});
            //[scales[r1Index].name, r1Index].postln;

            //"noch % loops  data1  % data2 % r1 % r2 %".format((~loops -n), data1, data2, r1Index, r2Index).postln;
            synths1.do({|syn, i | syn.set(\harm, scales[r1Index].degrees[i], \ffreq, data1.linlin(mn, mx, 500, 3000))});
            //synths2.do({|syn, i|   syn.set(\freq, (data1.linlin(mn, mx, 48, 60).asInteger + scales[r1Index].degrees[i]).midicps)
            //});

            0.1.wait};
        )

    },

    // on Off Play
   /*
        Idee: ein Pattern mit variierenden degrees
        */
    \49 : {

        var key= \49, data1, data2,  buf, synths,  mn, mx, scales;
        //"play TD %  sm %".format(key, ~sm1).postln;
        buf = ~buffersByName[\boris][\gras].normalize;
        scales = 10.collect({Scale.choose(size:7)});
        # mn, mx = [50, 130];
        s.sync;
        Pbindef(\harmonizer).play;

        ~loops.do({|n|
            var degrees;
            data1 = ~currentData.td[\sm1];
            data2 = ~currentData.td[\sm2];
            case
            {(data1 >= 0) && (data1 < 1)}{degrees = scales[0].degrees }
            {(data1 >= 1) && (data1 < 2)}{degrees = scales[1].degrees }
            {(data1 >= 2) && (data1 < 3)}{degrees = scales[2].degrees }
            {(data1 >= 3) && (data1 < 4)}{degrees = scales[3].degrees }
            {(data1 >= 4) && (data1 < 5)}{degrees = scales[4].degrees }
            {(data1 >= 5) && (data1 < 6)}{degrees = scales[5].degrees }
            {(data1 >= 6) && (data1 < 7)}{degrees = scales[6].degrees }
            {(data1 >= 7) && (data1 < 8)}{degrees = scales[7].degrees }
            {(data1 >= 9) && (data1 < 10)}{degrees = scales[8].degrees }
            {(data1 >= 10) && (data1 < 11)}{degrees = scales[9].degrees }

            {true}{"no more scales".postln};

            "noch % loops  data 48 lo? %  degrees %".format((~loops - n), (data1.asInteger % 2 == 0),  degrees).postln;
            Pbindef(\harmonizer, \harm, Pfunc({degrees}));

            0.9.wait};
        )

    },

    \50 :{/* */
        var key= \50, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        buf = ~buffersByName[\boris][\base];
        # mn, mx =[30,120];
        s.sync;
        syn = Synth(\tgrains_live, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.2, \dens, 20, \lg, 0.5,
            \fmffreq, 200, \fmAmp, 0.06, \numharm, 2, \index, 1,
            \out, 0, \fade, 0.9, \outfx, 3], ~grainGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            var harm, dFactor;
            data = ~currentData.td[\trock02];
            dFactor = data.linlin(mn, mx, 0.0, 1.5);
            harm = data.linlin(mn, mx, [-12, -2] , [12, 2]);
            //"data 50 %".format(data).postln;
            syn.set(
                \harm, harm,
                \grainDur, data.linlin(mn, mx, 0.1, 0.5),
                \fmdens, data.linlin(mn, mx, 0.5, 3.0),
                \modfreq, data.linlin(mn, mx, 10, 1),
            );
            0.05.wait};
    },


    \52 :{
        var key= \52, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        // Die Aktivität kommt zum Erliegen
        buf = ~grainBuffer.normalize;
        # mn, mx =[-2.0, 30.0];
        s.sync;
        syn = Synth(\grainScrub, [\amp, 0.7, \ptrBus, ~ptrBus, \buf, buf, \tr, 0.2, \out,0], ~grainGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            data = ~currentData.td[\sm1];
            syn.set(
                \pan, data.linlin(mn, mx, -1, 1),
                \pos, data.linlin(mn, mx, 0.0, buf.numFrames / s.sampleRate),
                \tr, data.linlin(mn, mx, 0.05, 5),
                \harm, data.linlin(mn, mx,-12,8)
            );
            0.1.wait};
    },

    \53 : {
        var key= \53, data, syn, fx, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        # mn, mx =[-2.0, 30.0];
        syn = Synth(\voweltrig, [\amp, 0.5, \buf, ~buffersByName[\boris][\tension], \rls, 4, \out, 0], ~grainGrp);
        fx = Synth(\combdelay, [\amp, 0.4, \bus, ~fxBus, \maxDelTime, 4, \decayTime, 3, \blend, 1, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn]);
        loop{var v;
            data = ~currentData.td[\temp_winter];
            case
            {data > 28.0}{v = 1}
            {(data > 23.0) && (data < 28.0)}{v = 2}
            {(data > 18.0) && (data < 23.0)}{v = 3}
            {(data > 10.0) && (data < 18.0)}{v = 11}
            {(data > 5.0) && (data < 10.0)}{v = 12}
            {(data > 0.0) && (data < 6.0)}{v = 13}
            {data < 0.0}{v = 5}
            {true}{"end of case".postln};
            //"data % \t ffreq % \t deltime %".format(data, data.linlin(0, 1, 1500, 3500), data.linlin(0, 1, 0.02, 0.8) ).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 1500, 3500),
                \vow, v, \trg, data.linlin(mn, mx, 2, 30, \freqScale, data.linlin(mn, mx, 0.1, 0.9), \decayScale, data.linlin(mn, mx, 0.1, 0.9), \att, data.linlin(mn, mx, 0.04, 0.3), \dec, data.linlin(mn, mx, 0.1, 0.33))
            );
            0.5.wait};
    },

    \55 :{
        var key= \55, data, syn, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;

        # mn, mx =[30, 130];
        s.sync;
        syn = Synth(\crisps, [\amp, 0.5, \trg, 5, \freq, [80, 120, 350, 1010], \rq, 0.14, \punch, 0.2, \dec, 0.9, \out, 0]);
        ~activeSynths.put(key, [syn]);
        loop{
            var fr;
            data = ~currentData.td[\trock02];
            fr = Array.fill(4, {|n| (n+1) * data});
            //data.postln;
            syn.set(\ffreq, data.linlin(mn, mx, 400, 2800),
                \freq, fr,
                \trg, data.linlin(mn, mx, 2, 25),
                \dec, data.linlin(mn, mx, 0.9, 0.1),
                \freqScale, data.linlin(mn, mx, 0.1, 1.0),
                \decayScale, data.linlin(mn, mx, 0.1, 1.2),
                \pan,  data.linlin(mn, mx, -1, 1),
            );
            0.05.wait};
    },

    \57 : {
        var key= \57, data, syn, fx, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        # mn, mx =[30, 125];
        syn = Synth(\grainBuf, [\ptrBus, ~ptrBus, \ptrSampleDelay, 800, \amp, 0.4, \buf, ~grainBuffer, \dens, 20, \baseDur, 0.1, \out, ~dryBus, \outfx, ~fxBus, \send, 1], ~grainGrp);
        fx = Synth(\combdelay, [\bus, ~fxBus, \maxDelTime, 3, \decayTime, 3, \blend, 1, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\sm1];
            //"data % \t ffreq % \t deltime %".format(data, data.linlin(0, 1, 1500, 3500), data.linlin(0, 1, 0.02, 0.8) ).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 600, 3500));//);
            //fx.set(\delTime, data.linlin(0, 1, 0.005, 0.5));
            fx.set(\delTime, data.linlin(mn, mx, 0.08, 0.5),
                \decayTime, data.linlin(mn, mx, 2, 0.5)
            );
            0.05.wait};
    },


    \59 : {
        // drone1. arbeitet mit der realen Verdunstung
        var key=\59, data,  mn, mx,  drone, baseFreq=100, fac1, fac2, fac3,
        freq1, freq2, freq3, df1, df2, df3;
        data = ~currentData.td[\drone];
        //"play TD %  drone %".format(key, data).postln;
        # mn, mx =[0.0, 4.5];
        # fac1, fac2, fac3 = [1, 2.2, 3.4];
        # freq1, freq2, freq3 = [fac1, fac2, fac3].collect({|f| baseFreq * f});
        # df1, df2, df3 = [1.8, 1.2, 1.05]; // datafactor
        drone = Synth(\arrayarg, [\freq, [freq1, freq2, freq3], \flg1, 6.1, \flg2, 7.0, \mlg1, 6.0, \mlg2, 7.0]);
        ~activeSynths.put(key, [drone]);
        loop{
            data = ~currentData.td[\drone];
            //"play TD %  drone %".format(key, data).postln;
            drone.set(\mods, Array.fill(3, {var m = data.linlin(mn, mx, 0.05, 0.12); [m * fac1, m*fac2, m*fac3 ]}),
                \freq, Array.fill(3, {[(data * fac1 * df1 * baseFreq), (data * fac2 * df2 * baseFreq), (data * fac3 * df3 * baseFreq)]}));
            0.05.wait};
    },

    \60 : {
        /* \sm1 entscheidet über Scale
        \sm1-4 entscheiden über Lautstärke
        */
        var key= \60, data, buf, synths, syn, ranges, mn, mx, scales,scaleSelect;

        "play TD % ".format(key).postln;
        buf = ~liveBuffer.normalize;
        # mn, mx = [0, 30];
        ranges = [[0.0, 10.0], [10.0, 17.0], [17.0, 21.0], [21.0, 24.0]];
        s.sync;

       synths = 4.collect({|n, i|
            Synth(\brLive, [\amp, 0.2 , \ptrBus, ~ptrBus, \buf, buf, \rate, 1.0, \harm, 0, \rq, 0.2,  \rls, 1.4, \lg, 0.4, \pan, -1 + (n * 0.5), \out, n], ~sourceGrp)
        });

        ~activeSynths.put(key, [syn]);
        loop{

            data = [\sm1, \sm2, \sm3, \sm4].collect({|n| ~currentData.td[n]});

            scaleSelect = ranges.detectIndex({|r, j| ((data[0] >= r[0]) && (data[0] < r[1]))});
            "data 60 % scaleSelect %".format(data,  ~scales[scaleSelect].semitones).postln;
            synths.do({|syn,i|

                syn.set(\harm, ~scales[scaleSelect].semitones[i+1], \amp, data[i].linlin(mn, mx, 0.01, 0.3))
            });

            0.2.wait};

    },
    \62 :{// Synth Arpeggio mit syn.set
        var key= \62, data, buf, syn, mn, mx, ranges, harms, scaleIndex, harmIndex=0;

        buf = ~liveBuffer.normalize;
        # mn, mx = [0.0, 8.0];
        ranges = [[0.0,4.0], [4.0, 6.0], [6.0,7.0], [7.0, 8.0]];
        s.sync;
        syn = Synth(\brLive, [\amp, 0.5, \buf,  buf, \rq, 0.2, \harm, 2, \out, 0, \fade, 0.9], ~sourceGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            var nextHarm;
            data = ~currentData.td[\sm3];
            scaleIndex = ranges.detectIndex({|r, j| ((data >= r[0]) && (data < r[1]))});
            harms = ~scales[scaleIndex].degrees;
            nextHarm = harms[harmIndex % harms.size];
            [scaleIndex, nextHarm].postln;
            syn.set(\harm, nextHarm);
            //"data 50 %".format(data).postln;
            harmIndex = harmIndex +1;
            ~t.beatDur.wait};
    },
    \64 :{
        var key= \64, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        //buf = ~buffersByName[\nitro][\tension];
        buf = ~grainBuffer.normalize;
        # mn, mx =[-2.0, 30.0];
        s.sync;
        syn = Synth(\grainScrub, [\amp, 0.7, \ptrBus, ~ptrBus, \buf, buf, \tr, 0.2, \out,0], ~grainGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            data = ~currentData.td[\temp_winter];
            syn.set(
                \pan, data.linlin(mn, mx, -1, 1),
                \pos, data.linlin(mn, mx, 0.0, buf.numFrames / s.sampleRate),
                \tr, data.linlin(mn, mx, 0.05, 5),
                \harm, data.linlin(mn, mx,-12,8)
            );
            0.1.wait};
    },
       \67:{
        /*
       Arpeggios des Live Buffer
        */
        var key = \67, patName, data, ranges, mn, mx, fr, idx=0, scaleIndex=0, degrees, fx;
        # mn, mx = [7.5, 24.0];
        patName = ("arp" ++ key).asSymbol;
        ranges = [[0.0, 8.5], [8.51, 10.75], [10.75,17.0], [17.01, 21.0],[21.0, 24.0]];
        degrees = ~scales[0].degrees;
        Pbindef(\klic).play(~t);
        if (~patternVals[key][\on] == false, {"starting pattern %".format(key).postln;
            Pchain(Pbindef(\arpeggio), Pbindef(patName,
                \harm, Pfunc({~patternVals[key][\harm]}),
                \ffreq, Pfunc({~patternVals[key][\ffreq]})
            )).play(~t);
            ~patternVals[key][\on]  = true},
            {"stopping pattern %".format(key).postln; Pbindef(patName).stop; ~patternVals[key][\on]  = false});
          fx = Synth(\vibrato, [\bus, ~fxGrp ]);
         ~activeSynths.put(key, [fx]);
        loop{
            data = ~currentData.td[\sm1];
            fx.set(\vFreq, data.linlin(mn, mx, 0.2, 10));
            ~patternVals[key][\ffreq] = data.linlin(mn, mx, 100, 3000);
            ~patternVals[key][\harm] = degrees[idx % degrees.size];
            scaleIndex = ranges.detectIndex({|r, j| ((data >= r[0]) && (data < r[1]))});
            degrees = ~scales[scaleIndex].degrees[0..3];
            "data 67 % scaleSelect %  idx % ".format(data, ~scales[scaleIndex].name, idx).postln;
            idx = idx +1;
            1.wait;
        }
    },
       \69:{
        /*
       Arpeggios des Live Buffer
        */
        var key = \69, patName, data, fx, ranges, mn, mx, fr, idx=0, scaleIndex=0, degrees;
        # mn, mx = [6.0, 30.0];
         patName = ("arp" ++ key).asSymbol;
        ranges = [[0.0, 7.8], [7.8, 11.5], [11.5, 14.0], [14.0, 20.0], [20.0, 30.0]];
         degrees = ~scales[1].degrees;
        if (~patternVals[key][\on] == false, {"starting pattern %".format(key).postln;
            Pchain(Pbindef(\arpeggio), Pbindef(patName,
                \harm, Pfunc({~patternVals[key][\harm]}),
                \ffreq, Pfunc({~patternVals[key][\ffreq]})
        )).play(~t);
            ~patternVals[key][\on]= true},
            {"stopping pattern %".format(key).postln; Pbindef(patName).stop;
            ~patternVals[key][\on]  = false});
        fx = Synth(\vibrato, [\bus, ~fxGrp ]);
         ~activeSynths.put(key, [fx]);
        loop{
            data =  ~currentData.td[\sm2];
            fx.set(\vFreq, data.linlin(mn, mx, 0.2, 10));
            scaleIndex = ranges.detectIndex({|r, j| ((data >= r[0]) && (data < r[1]))});
            degrees = ~scales[scaleIndex].degrees[0..3];
            ~patternVals[key][\ffreq] = data.linlin(mn, mx, 100, 3000);
            ~patternVals[key][\harm] = degrees[idx % degrees.size];
           "data 69 % scaleSelect %  idx % ".format(data, ~scales[scaleIndex].name, idx).postln;
            idx = idx +1;
            1.wait;
        }
    },
       \71:{
        /*
       Arpeggios des Live Buffer
        */
        var key = \71, patName, data, fx, ranges, mn, mx, fr, idx=0, scaleIndex=0, degrees;
        # mn, mx = [0.0, 8.0];
        patName = ("arp" ++ key).asSymbol;
        ranges = [[0.0, 4.0], [4.0, 6.0], [6.0, 6.6], [6.6, 7.1], [7.1, 8.0]];
         degrees = ~scales[2].degrees;
        if (~patternVals[key][\on] == false, {"starting pattern %".format(key).postln;
             Pchain(Pbindef(\arpeggio), Pbindef(patName,
                \harm, Pfunc({~patternVals[key][\harm]}),
                \ffreq, Pfunc({~patternVals[key][\ffreq]})
            )).play(~t);
             ~patternVals[key][\on]= true},
            {"stopping pattern %".format(key).postln; Pbindef(patName).stop;
            ~patternVals[key][\on] = false});
            fx = Synth(\vibrato, [\bus, ~fxGrp ]);
         ~activeSynths.put(key, [fx]);
        loop{
            data = ~currentData.td[\sm3];
            fx.set(\vFreq, data.linlin(mn, mx, 0.2, 10));
            scaleIndex = ranges.detectIndex({|r, j| ((data >= r[0]) && (data < r[1]))});
            degrees = ~scales[scaleIndex].degrees[0..3];
                ~patternVals[key][\ffreq] = data.linlin(mn, mx, 100, 3000);
            ~patternVals[key][\harm] = degrees[idx % degrees.size];
            "data 71% scaleSelect % ".format(data, ~scales[scaleIndex].name).postln;
            idx = idx +1;
            1.wait;
        }
    },
       \72:{
        /*
       Arpeggios des Live Buffer
        */
        var key = \72, patName, fx, data, ranges, mn, mx, fr, idx=0, scaleIndex=0, degrees;
        # mn, mx = [0.0, 5.0];
        patName = ("arp" ++ key).asSymbol;
        ranges = [[0.0, 1.2], [1.2, 2.0], [2.0, 2.8], [2.8, 3.5], [3.5, 5.0]];
         degrees = ~scales[3].degrees;
        if (~patternVals[key][\on] == false, {"starting pattern %".format(key).postln;
             Pchain(Pbindef(\arpeggio), Pbindef(patName,
                \harm, Pfunc({~patternVals[key][\harm]}),
                \ffreq, Pfunc({~patternVals[key][\ffreq]})
            )).play(~t);
             ~patternVals[key][\on]= true},
            {"stopping pattern %".format(key).postln; Pbindef(patName).stop;
            ~patternVals[key][\on] = false});
         fx = Synth(\vibrato, [\bus, ~fxGrp ]);
         ~activeSynths.put(key, [fx]);
        loop{
            data =~currentData.td[\sm4];
            fx.set(\vFreq, data.linlin(mn, mx, 0.2, 10));
            scaleIndex = ranges.detectIndex({|r, j| ((data >= r[0]) && (data < r[1]))});
            degrees = ~scales[scaleIndex].degrees[0..3].scramble;
             ~patternVals[key][\ffreq] = data.linlin(mn, mx, 100, 3000);
            ~patternVals[key][\harm] = degrees[idx % degrees.size];
             "data 72 % scaleSelect %  degree % ".format(data, ~scales[scaleIndex].name, degrees[idx % degrees.size]).postln;
            idx = idx +1;
            1.wait;
        }
    },
);

