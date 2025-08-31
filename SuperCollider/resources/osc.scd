/*
Hier werden die Oscdefs zur Kommunikation mit Touchdesigner geladen
*/


OSCdef(\TDOnKeyhold, {|msg, time, addr, recvPort|
    var key, rout, funcDict;
    key = msg[1].asSymbol;
    funcDict = ~td;
    "receiving  NoteOn from TD Onkeyhold:key %  funcDict %".format(key, funcDict[key]).postln;
     ~activeRoutines[\td].put(key, Routine(funcDict[key]));
    rout = ~activeRoutines[\td][key];
    if ((rout.notNil && rout.isPlaying), {"stopping rout".postln; rout.stop});
    //"~activeRoutines % ".format(~activeRoutines).postln;
    rout.play;
},
'/OnKeyhold'
);

OSCdef(\TDOffKeyhold, {|msg, time, addr, recvPort|
    var key, funcDict, rout;
    key = msg[1].asSymbol;
    rout = ~activeRoutines[\td][key];
    rout.stop;
    //~activeRoutines[\td].removeAt(key);
    ~activeSynths[key].do({|x| x.set(\gate, 0);});
    "stopped rout %  activesynths % routine active= %".format(key, ~activeSynths, rout.isActive).postln;
},
'/OffKeyhold'
);

OSCdef(\TDOffPattern, {|msg, time, addr, recvPort|
    var key, funcDict, rout;
    key = msg[1].asSymbol;
    rout = ~activeRoutines[\td][key];
    rout.stop;
    if (key == \71, {Pbindef(\voc2).stop}, {Pbindef(\array01).stop});
    "stopped rout %  activesynths % routine active= %".format(key, ~activeSynths, rout.isActive).postln;
},
'/OffPattern'
);


OSCdef(\resetAll, {|msg, time, addr, recvPort|
    msg[1].postln;
    ~activeRoutines[\td].keys.do({|k| ~activeRoutines[\td].removeAt(k) })
},
    '/reset'
);

OSCdef(\record, {|msg, time, addr, recvPort|
    var user, kind;
    msg.postln;
    user = msg[1];
    kind = msg[2];
    ~recordUser.(user, kind)
},
    '/record'
);


OSCdef(\fade, {|msg, time, addr, recvPort|
    var key, val;
   msg.postln;
    key = msg[1];
    val = msg[2];
    [key, val].postln;
    ~currentData[\fade][key.asSymbol] = val.asFloat;

},
    '/fade'

);

OSCdef(\sm, {|msg, time, addr, recvPort|
   //"receiving sm1 %".format(msg[1]).postln;
    ~currentData[\td][\sm] = msg[1].asInteger;
},
    '/sm'
);
OSCdef(\trock02, {|msg, time, addr, recvPort|
    //msg[1].postln;
    ~currentData[\td][\sm] = msg[1].asInteger;
},
    '/trock02'
);

OSCdef(\temp, {|msg, time, addr, recvPort|
    //msg[1].postln;
    ~currentData[\td][\temp] = msg[1].asFloat;
},
    '/temp'
);

OSCdef(\evap, {|msg, time, addr, recvPort|
     //"receiving evap %".format(msg[1]).postln;
    ~currentData[\td][\evap] = msg[1];
},
    '/evap'
);



