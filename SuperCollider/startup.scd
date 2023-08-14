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
    ~createData.();
	(~resourcePath ++ "functions.scd").load;
	(~resourcePath ++ "routinefunctions.scd").load;


	"done".postln;
})

)

~replacePlay.(True)
~replacePlay.(False)
~oneShotPlay.(True)
~oneShotPlay.(False)
~liveGrain.(True)

~rf[\59]

~liveBuffer.play
~liveBuffer.plot
MIDIFunc.trace(false);

Synth(\grainBuf, [\buf, ~liveBuffer, \dens, 20, \pos1, 0,  \pos2, 1, \pos3, 1.3, \harm, 1, \grainDur, 0.1]);
Synth(\grainBuf, [\buf, ~liveBuffer, \dens, 20, \pos1, 1,  \pos2, 0, \pos3, 1.3, \harm, 1, \grainDur, 0.1]);
Synth(\tgrains_live, [\buf, ~liveBuffer, \harm, [-12, 2, 12]])
(
var fun;
fun = {
	10.do({|i|
		i.postln;
		i.do({
			|x|
			x.postln;
			0.3.wait;
		});
		1.wait})
};
r(fun).play

)

