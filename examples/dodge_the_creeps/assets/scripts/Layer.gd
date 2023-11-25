extends Node

@export var background_color: Color

@export var input_modification = {
	"Left": Vector2.LEFT,
	"Right": Vector2.RIGHT,
	"Up": Vector2.UP,
	"Down": Vector2.DOWN
}

# 0 - heal
# 1 - lose health
# 2 - gain mana
# 3 - lose mana
@export var potion_effects_modification = {
	"Potion_1": 0,
	"Potion_2": 1,
	"Potion_3": 2,
	"Potion_4": 3
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
