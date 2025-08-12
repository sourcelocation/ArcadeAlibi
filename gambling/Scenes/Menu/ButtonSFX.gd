extends MightyButton
class_name ButtonSFX

@export var custom_click: AudioStream

@onready var reg_click = preload("res://Scenes/Menu/click.mp3")

# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_entered.connect(_play_hover)
	pressed.connect(_play_pressed)
	
	_upd_focus()
	visibility_changed.connect(_upd_focus)

func _upd_focus():
	focus_mode = FOCUS_NONE

func _play_hover() -> void:
	if not disabled:
		if $"/root/Menu/AudioStreamPlayer" != null:
			$"/root/Menu/AudioStreamPlayer".play()

func _play_pressed() -> void:
	if $"/root/Menu/AudioStreamPlayer" != null:
		if custom_click:
			if $"/root/Menu/AudioStreamPlayer".stream != custom_click:
				$"/root/Menu/AudioStreamPlayer".stream = custom_click
		else:
			if $"/root/Menu/AudioStreamPlayer".stream != reg_click:
				$"/root/Menu/AudioStreamPlayer".stream = reg_click
		$"/root/Menu/AudioStreamPlayer".play()
		
