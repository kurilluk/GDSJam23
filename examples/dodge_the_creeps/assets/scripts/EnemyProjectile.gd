extends RigidBody2D
class_name EnemyProjectile

func _ready():
	$Fire_2.play()
	fade_in(0.5, Callable())

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func set_color(new_color):
	$FireballBottom.self_modulate = new_color
	
func set_new_rotation(new_rot):
	$FireballBottom.rotation = new_rot
	
func fade_in(duration, callback: Callable):
	$FireballBottom.modulate = Color.TRANSPARENT
	var fade_tweener = create_tween()
	fade_tweener.tween_property($FireballBottom, "modulate", Color.WHITE, duration). \
		set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	fade_tweener.tween_callback(callback)
	
func fade_out(fade_dur, duration_to_callback, callback: Callable):
	enable_collider(false)
	$FireballBottom/Trail.emitting = false
	var fade_tweener = create_tween()
	fade_tweener.tween_property($FireballBottom, "self_modulate", Color.TRANSPARENT, fade_dur). \
		set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	fade_tweener.parallel().tween_property($FireballBottom/FireballTop, "self_modulate", Color.TRANSPARENT, fade_dur). \
		set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	fade_tweener.tween_property($FireballBottom, "self_modulate", Color.TRANSPARENT, duration_to_callback - fade_dur)
	fade_tweener.tween_callback(callback)
	
func enable_collider(value):
	$CollisionShape2D.disabled = !value

func destroy_self():
	enable_collider(false)
	$FireballBottom/Trail.emitting = false
	fade_out(0.1, 1.0, Callable(self, "queue_free"))
