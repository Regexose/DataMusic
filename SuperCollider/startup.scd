(
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
Server.default.options.inDevice_(~audioInterface);
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
	(~resourcePath ++ "functions.scd").load;
	(~resourcePath ++ "routinefunctions.scd").load;

	"done".postln;
})

)
~recOnOff = {}
~recOnOff.()
~liveBuffer.play
~liveBuffer.plot
~data.keys.do(_.postln)

Synth(\br, [\buf, ~liveBuffer, \rate, 1, \ffreq, 220, \atk, 0.03, \sus, 1, \rls, 0.07, \start, 0, \end, ~liveBuffer.numFrames/2]);

Synth(\oscfm, [\buf1, ~buffers[\rainrate], \buf2, ~buffers[\solar]]) 