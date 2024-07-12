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
s.options.numWireBufs = 200;
//s.newBusAllocators;

s.waitForBoot({
	s.freeAll;
    Buffer.freeAll;
	OSCdef.freeAll;
	MIDIdef.freeAll;
	s.newBusAllocators;
	~dryBus = Bus.audio(s,2);
    ~wetBus = Bus.audio(s,2);
	s.sync;
	/// load SynthDefs, Constants, Functions

	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "rf_climart.scd").load;
	(~resourcePath ++ "initialization.scd").load;

	~createData.();
	(~resourcePath ++ "functions.scd").load;
	//(~resourcePath ++ "routinefunctions.scd").load;

	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_constructor.scd");
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_make.scd");
    // ~rout = Routine(~rf[\48]);
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
x = Synth(\dry)
192000 /(48000 )
Quarks.gui
w = Synth(\brsaw, [\buf, ~currentSample[\base]])
w.set(\freq, 0.92, \ffreq, 3000)
w.fre
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
