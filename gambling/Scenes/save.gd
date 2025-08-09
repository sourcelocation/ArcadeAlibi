extends Node

const CONFIGFILE = "user://CONFIGFILE.save"

var config = {}

func _ready():
	load_data()

func load_data():
	var file = FileAccess.open(CONFIGFILE, FileAccess.READ)
	if FileAccess.file_exists(CONFIGFILE):
		config = file.get_var()
		file.close()
		
	var defaults: Dictionary = {
		# reg
		"window_mode": 0,
		"vsync": 0,
		"motion_blur": 0,
		"resolution_scale": 50.0 if OS.get_name() == "macOS" else 100.0,
		"max_fps": 500,
		"master_volume": 100,
		"music_volume": 100,
		"voice_volume": 100,
		"sensitivity": 1.0,
	}
	
	var added_default = false
	for key in defaults:
		if not config.has(key):
			config[key] = defaults[key]
			added_default = true
	
	if added_default:
		save_data()
		
	for key in config.keys():
		add_user_signal(key + "_changed")
	
func save_data():
	var file = FileAccess.open(CONFIGFILE, FileAccess.WRITE)
	file.store_var(config)
	file.close()

## Stores the value to data and saves the file
func save(key, value):
	config[key] = value
	save_data()
