extends Node2D # v3.2.4


const BUS_NAME  = "Pitch"
const BUS_INDEX = 1
const EFF_INDEX = 0

export var pitch = 2.0

# Replace with yours.
onready var sfx : AudioStreamPlayer = $AudioStreamPlayer



func _ready() -> void:

	var shift = AudioEffectPitchShift.new()

	shift.pitch_scale = 1.0 / pitch

	AudioServer.add_bus(BUS_INDEX)
	AudioServer.set_bus_name(BUS_INDEX, BUS_NAME)
	AudioServer.add_bus_effect(BUS_INDEX, shift, EFF_INDEX)

	sfx.bus = BUS_NAME


func _input(event: InputEvent) -> void:

	if(event.is_pressed()):

		sfx.play()
		sfx.pitch_scale = pitch

		var shift = AudioServer.get_bus_effect(BUS_INDEX, EFF_INDEX)

		shift.pitch_scale = 1.0 / pitch

		sfx.connect("finished", self, "ts", [], CONNECT_ONESHOT)
		ts = OS.get_ticks_usec()


var ts : float

func ts():
	print("SFX finished in: ", (OS.get_ticks_usec() - ts) / 1000000.0)
