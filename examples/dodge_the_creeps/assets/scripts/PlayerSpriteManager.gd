extends Sprite2D
class_name PlayerSpriteManager

enum Facing {
	LEFT,
	RIGHT
}

var fx_facing_mp = {
	Facing.LEFT : -1,
	Facing.RIGHT : 1
}

var current_facing : Facing

@export var parts: Array[Sprite2D]
@export var magic_fx_parts: Array[Sprite2D]
@export var move_dragging_parts: Array[Sprite2D]

var magic_fx_default_clr: Color = Color.WHITE
var magic_fx_casting_clr: Color = Color.WHITE
@export var magic_fx_cast_dur = 0.1
@export var magic_fx_cast_hold_dur = 0.1
@export var magic_fx_fade_dur = 0.2

@export var movement_base_lean_angle = 7
@export var movement_base_max_lean_dur = 0.25
@export var movement_base_stop_lean_dur = 0.35
var current_lean_angle: float

var magic_fx_tween: Tween = null
var base_move_fx_tween: Tween = null
var dragging_parts_move_fx_tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready():
	current_facing = Facing.RIGHT
	set_facing(current_facing)
	
func set_magic_fx_color(new_color):
	magic_fx_casting_clr = new_color
	
func set_facing(facing: Facing):
	if facing == current_facing:
		return
	else:
		current_facing = facing
		for part in parts:
			if current_facing == Facing.LEFT:
				part.flip_h = true
			else:
				part.flip_h = false
		# side flip fx
		movement_facing_flip()
		
func magic_casting_fx():
	if magic_fx_tween == null or magic_fx_tween.is_running():
		for part in magic_fx_parts:
			part.modulate = magic_fx_default_clr
			
	magic_fx_tween = create_tween()
	var sprite = magic_fx_parts[0]
	magic_fx_tween.tween_property(sprite, "modulate", magic_fx_casting_clr, magic_fx_cast_dur)
	magic_fx_tween.tween_property(sprite, "modulate", magic_fx_casting_clr, magic_fx_cast_hold_dur)
	magic_fx_tween.tween_property(sprite, "modulate", magic_fx_default_clr, magic_fx_fade_dur)
	
	# there probably wont be more parts that have this effect apart from the wand orb so no need for this generic construct
	#for i in range(len(magic_fx_parts)):
	#	var part: Sprite2D = magic_fx_parts[i]
	#	if i == 0:
	#		magic_fx_tween.tween_property(part, "modulate", magic_fx_casting_clr, magic_fx_cast_dur)
	#	else:
	#		magic_fx_tween.parallel().tween_property(part, "modulate", magic_fx_casting_clr, magic_fx_cast_dur)
		
func movement_started():
	if base_move_fx_tween != null and base_move_fx_tween.is_running():
		base_move_fx_tween.stop()
	
	base_move_fx_tween = create_tween()
	var final_val = deg_to_rad(movement_base_lean_angle * fx_facing_mp[current_facing])
	base_move_fx_tween.tween_property(self, "rotation", final_val, movement_base_max_lean_dur) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	pass
func movement_ended():
	if base_move_fx_tween != null and base_move_fx_tween.is_running():
		base_move_fx_tween.stop()
	
	base_move_fx_tween = create_tween()
	base_move_fx_tween.tween_property(self, "rotation", 0, movement_base_stop_lean_dur) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	pass
func movement_facing_flip():
	movement_started()
