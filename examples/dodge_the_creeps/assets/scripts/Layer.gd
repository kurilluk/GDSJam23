extends Node
class_name Layer

@export var background_color: Color
@export var enemy_main_color: Color
@export var enemy_off_color: Color
@export var player_fireball_color: Color
@export var player_accent_color: Color

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
	"Potion_3": 3,
	"Potion_4": 2
}

func shuffle_potion_effects() -> Array:
	var vals_permutation = potion_effects_modification.values()
	vals_permutation.shuffle()	
	var i = 0
	for key in potion_effects_modification.keys():
		potion_effects_modification[key] = vals_permutation[i]
		i += 1
	return potion_effects_modification.values()

func get_input_modification():
	return input_modification
	
func get_potion_modifications():
	return potion_effects_modification

func get_layer_heal_potion():
	return get_layer_potion(0)
	
func get_layer_mana_potion():
	return get_layer_potion(2)
	
func get_layer_potion(effect_id):
	var vals = potion_effects_modification.values()
	var id = vals.find(effect_id, 0)
	return potion_effects_modification.keys()[id]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
