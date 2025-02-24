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

s.waitForBoot({
    //s.dumpOSC(1);
    s.freeAll;
    Buffer.freeAll;
    OSCdef.freeAll;
    MIDIdef.freeAll;
    // s.dumpOSC(0);
    s.sync;
    s.newBusAllocators;
    ~soundIn = Bus.audio(s, 1);
    ~micBus = Bus.audio(s, 1);
    ~ptrBus = Bus.audio(s, 1);
    ~dryBus = Bus.audio(s,2);
    /// load SynthDefs, Constants, Functions
    //"busses \n".postln;
    (~resourcePath ++ "constants.scd").load;
//"constants.scd \n".postln;
    (~resourcePath ++ "rf_midikeys.scd").load;
//"midikeys.scd \n".postln;
    (~resourcePath ++ "td_midikeys.scd").load;
//"midikeys.scd \n".postln;
    (~resourcePath ++ "rf_patterns.scd").load;
//"patterns.scd \n".postln;
    (~resourcePath ++ "rf_live.scd").load;
//"live.scd \n".postln;

    (~resourcePath ++ "synthDefs.scd").load;
   // "synthdefs \n".postln;
      (~resourcePath ++ "osc.scd").load;
   // "synthdefs \n".postln;
    s.sync;
    (~resourcePath ++ "functions.scd").load;
   // "functions\n ".postln;
    s.sync;
    //https://www.youtube.com/watch?v=ztVLMS15n1c&t=1279s  ab 40:00
    ServerTree.add(~makeNodes);
    ServerTree.run;
    s.sync;
    ~patches = (~resourcePath ++ "fx_patches.scd").load;
    (~resourcePath ++ "initialization.scd").load;
    s.sync;
    (~resourcePath ++ "patterns.scd").load;
    //"patterns".postln;
    //thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_constructor.scd");
    //thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_make.scd");
    //"GUI".postln;
    // Send Objekte machen
    s.sync;
    ~sends = ~sends ? ();
    [~ch1, ~ch2, ~ch3, ~ch4, ~ch5, ~ch6, ~ch7, ~ch8, ~perc, ~voc].do{
        |ch, i|
        var sendName;
        //postf("channel %\t i %\n", ch, i);
        [~reverb, ~ringmod, ~delay].do {
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
s.queryAllNodes;
(
~recordUser.("nitro","base");
~recordUser.("boris", "tension");
~recordUser.("boris", "relax");
)

MIDIFunc.trace(false)
