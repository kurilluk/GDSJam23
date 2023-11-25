extends Camera2D

@export var shake_duration := 0.5
@export var shake_times := 10
@export var shake_scale := 2

func camera_shake(dmg_scale):
	var tween = create_tween()
	for i in range(shake_times):
		var target_location = Vector2(
			randf_range(-shake_scale * dmg_scale, shake_scale * dmg_scale),
			randf_range(-shake_scale * dmg_scale, shake_scale * dmg_scale)
		)
		tween.tween_property(self, "offset", target_location, shake_duration / shake_times) 
	tween.tween_property(self, "offset", Vector2.ZERO, shake_duration / shake_times)
