(
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

Server.default.options.outDevice_(~audioOut);
Server.default.options.inDevice_(~audioIn);
Server.default.options.numInputBusChannels_(1);
s.newBusAllocators;

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	/// load SynthDefs, Constants, Functions
	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "synthDefs.scd").load;
	(~resourcePath ++ "initialization.scd").load;
	~createData.(); ~initCurrentData.();
	(~resourcePath ++ "functions.scd").load;
	(~resourcePath ++ "routinefunctions.scd").load;

	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_constructor.scd");
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_make.scd");

	"done".postln;
})

)
~liveBuffer.numFrames/~data.temperature.size
~recordBase.("voris");




~replacePlay.(True)
~replacePlay.(False)
~oneShotPlay.(True)
~oneShotPlay.(False)
~liveGrain.(True)
~liveGrain.(False)
~currentData[\50]
~grainBuffer.play
rrand(48,60)

~liveBuffer.play
~liveBuffer.plot
~baseSound.play
~baseSound.class


b= Buffer.read(s, ~samplesPath ++ "/voris/baseSound.wav")
b.plot

~data.keys
~buildBufferGrid.()
