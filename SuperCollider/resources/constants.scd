~dataPath = PathName(~projectRoot).parentPath ++ "data";
~fileName = "zku_3007-0508_noTime.csv";
~samplesPath = PathName(~projectRoot).parentPath ++ "samples";
~buffers = Dictionary.new;
~liveBuffer = Buffer.alloc(s, 10 * s.sampleRate, 1);
~data = ();
~dataGroups = (
	\freq: [
		\solar,
		\yearly,
		\relative,
		\relative_low,
		\relative_high,
		\absolute,
	],
	\factors:
	[	\uvi,
		\daily,
		\hourly,
		\wind_speed,
		\wind_gust,
		\rain_rate,
		\haptic_array1,
		\haptic_array2,
		\haptic_array3,
		\haptic_array4,

	],

	\steady: [
		\temperature,
		\temperature_1,
		\temperature_low,
		\temperature_high,
		\temperature_high_1,
		\humidity,
		\soilmoisture,
		\soilmoisture_1
	],
	\volatile: [
		\event,
		\weekly,
		\monthly,
		\wind_direction
	],
	\static: [
		\temperature_sensor_ch1,
		\soilmoisture_sensor_ch1,
		\soilmoisture_sensor_ch2,
	]
);
