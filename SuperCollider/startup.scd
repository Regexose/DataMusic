/*
in diesem Branch will ich Patterns mit LiveStimmManipulation kombinieren
Pattern 1: Klick/Perc Impulse als 1/8 oder 1/16 Noten, die Tonal von einem Datensatz beeinflusst werden
Pattern 2 : Arpeggii oder Akkorde als musikalisches Pattern, willkürlich festgelegt, die Synths werden ebenso variiert von Daten
Pattern 3 : Live Stimme mit ein oder zwei Datensätzen sonifiziert
Pattern 4 : Evtl.. Erzählstimme
*/
(
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

Server.killAll;
Server.default.options.outDevice_(~audioOut);
Server.default.options.inDevice_(~audioIn);
Server.default.options.numInputBusChannels_(1);
Server.default.options.numOutputBusChannels_(16);

Server.default.options.memSize_(100.pow(2));
s.options.numWireBufs = 200;
//s.newBusAllocators;

s.waitForBoot({
    s.freeAll;
    Buffer.freeAll;
    OSCdef.freeAll;
    MIDIdef.freeAll;
    MixerChannel.freeAll;
    s.sync;
    s.newBusAllocators;
    ~soundIn = Bus.audio(s, 1);
    ~dryBus = Bus.audio(s,2);
    ~wetBus = Bus.audio(s,2);
    ~ducker = Bus.control(s, 1);
    s.sync;
    /// load SynthDefs, Constants, Functions

    (~resourcePath ++ "constants.scd").load;
    (~resourcePath ++ "rf_climart.scd").load;
    (~resourcePath ++ "functions.scd").load;
    s.sync;
    ServerTree.add(~makeNodes);
    ServerTree.run;
    s.sync;
    ~patches = (~resourcePath ++ "fx_patches.scd").load;
    (~resourcePath ++ "initialization.scd").load;
    s.sync;
    ~createData.();
    (~resourcePath ++ "patterns.scd").load;
    //"patterns".postln;
    thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_constructor.scd");
    thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_make.scd");
    //"GUI".postln;
    // Send Objekte machen
    ~sends = ~sends ? ();

    [~ch1, ~ch2, ~ch3, ~ch4, ~voc, ~perc, ~bass].do{
        |ch, i|
        var sendName;
        //postf("channel %\t i %\n", ch, i);
        [~reverb, ~ringmod, ~chorus].do {
            |fx|
            //postf("fx name %\n", fx.asString);
            sendName = ch.name.asString ++ "_snd_" ++ fx.asString[13..16];
            ~sends.put(sendName.asSymbol, ch.newPostSend(fx, 0.01) ); // nicht an patch sondern an channel senden
        }
    };
    //"sends".postln;
    s.sync;
    ~initCurrent.();
    "done".postln;
})
)

(
~recordUser.("boris","base");
~recordUser.("boris", "tension");
~recordUser.("boris", "relax");
)
 ~activeSynths[\57].free
// stop all Synths
~currentSample[\base]
s.defaultGroup.freeAll
~vowelDict.keys
~makeDataImages.()
s.makeWindow
MIDIFunc.trace(true)
~nuendo.rout6.set(\out, 6)


SynthDescLib.global.browse
ServerOptions.defaultValues.keys.do{|k|
    var value=ServerOptions.defaultValues[k];
    "key: %  value: %".format(k, value).postln;
}
s.options.numWireBufs

(

{
    var buf = ~currentSample[\relax] , trate, dur, clk, pos, pan;
    trate = MouseY.kr(8,120,1);
    dur = 12 / trate;
    clk = Impulse.kr(trate);
    pos = MouseX.kr(0,BufDur.kr(buf)) + TRand.kr(0, 0.01, clk);
    pan = WhiteNoise.kr(0.6);
    TGrains2.ar(2, clk, buf, 1, pos, dur, pan, 0.1, dur * 0.3, dur * 0.5);
}.play;
)
