~dataPath = PathName(~projectRoot).parentPath ++ "data";
~imagePath = PathName(~projectRoot).parentPath ++ "data/img";
~dataFileName = "zku_OpenHausData_noTime.csv";
~recordingPath = PathName(~projectRoot).parentPath ++ "recordings";
~samplesPath = PathName(~projectRoot).parentPath ++ "samples";
~buffers = Dictionary.new;
~liveBuffer = Buffer.alloc(s, 4 * s.sampleRate, 1);
~grainBuffer = Buffer.alloc(s, 4 * s.sampleRate, 1);
~userSound = Buffer.alloc(s, 4 * s.sampleRate, 1);
~currentSample = Dictionary.new;
~dataImages = ();
~posX = 14; //position of the cursor in ~dataView, manipulated by ~moveCursor

~activeSynths = ();
~data = ();
~currentData = Dictionary.new;

~dataGroups = (
	\freq: [// suitable for frequency values
		\solar,
		\yearly,
		\relative,
		\relative_low,
		\relative_high,
		\absolute,
	],
	\factors: //suitable for multiplying values
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

	\steady: [ //slowly changing values between 20 - 80
		\temperature,
		\temperature_1,
		\temperature_low,
		\temperature_high,
		\temperature_high_1,
		\humidity,
		\soilmoisture,
		\soilmoisture_1
	],

	\volatile: [ //rapidly changing values
		\event,
		\weekly,
		\monthly,
		\wind_direction
	],
	\static: [ // static values between 1-0 -2.0
		\temperature_sensor_ch1,
		\soilmoisture_sensor_ch1,
		\soilmoisture_sensor_ch2,
	],
	\low: [// values 0.0 -5.0
		\wind_speed,
		\haptic_array3,
		\hourly,
		\haptic_array4,
	],
	\med_low: [//values 0-20
		\uvi,
		\wind_gust,
		\rain_rate,
		\event,
	],
	\medium:[// 0.0 - 85
		\temperature,
		\temperature_low,
		\temperature_low_1,
		\temperature_high,
		\temperature_high_1,
		\temperature_1,
		\monthly,
	],
	\med_high: [//0-900
		\solar,
		\yearly,
		\wind_direction,
	],
	\high: [ // around 1000
		\relative,
		\relative_high,
		\relative_low,
		\absolute
	]
);
