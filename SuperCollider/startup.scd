(
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

Server.default.options.outDevice_(~audioInterface);
Server.default.options.inDevice_(~audioInterface);
Server.default.options.numInputBusChannels_(1);
//s.newBusAllocators;

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	OSCdef.freeAll;
	MIDIdef.freeAll;
	s.sync;
	/// load SynthDefs, Constants, Functions

	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "synthDefs.scd").load;
	(~resourcePath ++ "rf_climart.scd").load;
	(~resourcePath ++ "initialization.scd").load;
	~createData.(); ~initCurrent.();
	(~resourcePath ++ "functions.scd").load;
	//(~resourcePath ++ "routinefunctions.scd").load;

	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_constructor.scd");
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_make.scd");

	"done".postln;
})

)

(
~recordUser.("gunter", "base");
~recordUser.("gunter", "tension");
~recordUser.("gunter", "relax");

)

~onOffUser.(True)
~onOffUser
~onOffUser.(False)
MIDIFunc.trace(false)
(

~activeSynths[\50].free
)
s.defaultGroup.freeAll

~liveBuffer.plot
~buffers[\claudia][\base].play
~posX
~cursor.bounds.

(

)

(
		"background image for % ".format(\temp).postln;
		~path = "~/Desktop/humidity.png";
		~dataPlot = ~data[\humidity].asArray.plot(bounds: Rect(0, 0, 800, 400));
		0.05.wait;
		~image = Image.fromWindow(~dataPlot.parent, ~dataPlot.interactionView.bounds); // get image from the view
~image.plot(showinfo:false);
~image.asCompileString
		~image.write(~path.standardizePath);
		0.05.wait;
		~image.bounds.h;


)

View
~dataView.dataView
)

