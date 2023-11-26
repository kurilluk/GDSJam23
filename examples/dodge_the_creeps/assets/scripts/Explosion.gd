extends Node2D

@export var tween_scale_duration = 0.2
@export var tween_invis_duration = 0.3

# Called when the node enters the scene tree for the first time.
func _ready():
	$ExplosionBottom.rotation = randf_range(0.0, 2 * PI)
	$ExplosionBottom.scale = Vector2.ZERO
	var scale_tween = create_tween()
	scale_tween.tween_property($ExplosionBottom, "scale", Vector2(2,2), tween_scale_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	scale_tween.tween_property($ExplosionBottom, "scale", Vector2.ZERO, tween_invis_duration - tween_scale_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	var invis_tween = create_tween()
	invis_tween.tween_property($ExplosionBottom, "modulate", Color.WHITE, tween_invis_duration/2)
	invis_tween.tween_property($ExplosionBottom, "modulate", Color.TRANSPARENT, tween_invis_duration/2)
	invis_tween.tween_callback(Callable(self, "queue_free"))

func set_new_color(new_color):
	$ExplosionBottom.self_modulate = new_color

