~makeWaveTable = {
	|size=4096, external, name|
	var sig, wt, buf ;
	//external = external.wrapExtend(size.asInteger).asArray.normalize;
	r{
		buf = Buffer.alloc(s, size*2);
		s.sync;
		buf.sine3(
			({external.choose} !16).sort,
			({exprand(0.05, 0.9)} !16).sort,
			{rrand(0, 2pi)} !16,
			asWavetable: true
		);
		//buf.plot;
		s.sync;
		~buffers.put(name, buf);
		//~buffers[name].postln;

	}.play(AppClock);
};