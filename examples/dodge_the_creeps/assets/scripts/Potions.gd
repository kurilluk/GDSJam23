extends Node2D

@export var PotionBars: Array[TextureProgressBar]

var potion_cooldown = 0.1

var potion_use_empty_dur = 0.05
var potion_use_scale_down_val = 0.8
var potion_use_scale_down_dur = 0.15
var potion_use_scale_up_dur = 0.4

var potions_name_index_map = {
	"Potion_1": 0,
	"Potion_2": 1,
	"Potion_3": 2,
	"Potion_4": 3
}

var potions_ready_status = [true, true, true, true]

func _ready():
	pass

func use_potion(name):
	var potion_index = potions_name_index_map[name]
	potions_ready_status[potion_index] = false
		
	var potion_progress_bar = PotionBars[potion_index]
	var value_tween = create_tween()
	value_tween.tween_property(potion_progress_bar, "value", 25, potion_use_empty_dur) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	value_tween.tween_property(potion_progress_bar, "value", 100, potion_cooldown - potion_use_empty_dur) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	value_tween.tween_callback(Callable(self, "set_potion_ready").bind(potion_index))
	
	var scale_tween = create_tween()
	scale_tween.tween_property(potion_progress_bar, "scale", Vector2(potion_use_scale_down_val, potion_use_scale_down_val), potion_use_scale_down_dur) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	scale_tween.parallel().tween_property(potion_progress_bar, "position", potion_progress_bar.position + (potion_progress_bar.size * (1 - potion_use_scale_down_val)/2.0), potion_use_scale_down_dur). \
		set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	scale_tween.tween_property(potion_progress_bar, "scale", Vector2.ONE, potion_use_scale_up_dur). \
		set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	scale_tween.parallel().tween_property(potion_progress_bar, "position", potion_progress_bar.position, potion_use_scale_up_dur). \
		set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

func set_potion_ready(index):
	potions_ready_status[index] = true
	
func is_potion_ready(name):
	var potion_index = potions_name_index_map[name]
	return potions_ready_status[potion_index]
