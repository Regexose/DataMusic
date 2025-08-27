/*
Hier werden die Oscdefs zur Kommunikation mit Touchdesigner geladen
*/


OSCdef(\TDOnKeyhold, {|msg, time, addr, recvPort|
    var key, buf, syn,  rout, funcDict;
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


OSCdef(\sm1, {|msg, time, addr, recvPort|
    //"receiving sm1 %".format(msg[1]).postln;
    ~currentData[\td][\sm1] = msg[1].asInteger;
},
    '/sm1'
);

OSCdef(\fade, {|msg, time, addr, recvPort|
    var key, val;
   //msg.postln;
    key = msg[1];
    val = msg[2];
    [key, val].postln;
    ~currentData[\fade][key.asSymbol] = val.asFloat;

},
    '/fade'
);
OSCdef(\trock02, {|msg, time, addr, recvPort|
    //msg[1].postln;
    ~currentData[\td][\trock02] = msg[1].asInteger;
},
    '/trock02'
);

OSCdef(\temp1, {|msg, time, addr, recvPort|
    //msg[1].postln;
    ~currentData[\td][\temp_winter] = msg[1].asFloat;
},
    '/temp_winter'
);

OSCdef(\drone, {|msg, time, addr, recvPort|
     //"receiving drone %".format(msg[1]).postln;
    ~currentData[\td][\drone] = msg[1];
},
    '/drone'
);



