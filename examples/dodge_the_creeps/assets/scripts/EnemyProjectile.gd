extends RigidBody2D
class_name EnemyProjectile

@export var ExplosionEffect: PackedScene
@export var intensity_curve: Curve
@export var intensity_curve_scale = 2
var random_curve_offset: int

var destroyed = false

func _ready():
	$Fire_2.play()
	random_curve_offset = randi_range(0, 1000)
	fade_in(0.5, Callable())
	
func _process(delta):
	var time = Time.get_ticks_msec()
	var t = (((int(time * intensity_curve_scale) + random_curve_offset) % 1000) / 1000.0)
	$FireballBottom.self_modulate = $FireballBottom.self_modulate * (1.0 + intensity_curve.sample(t))

func _on_VisibilityNotifier2D_screen_exited():
	if not destroyed: #deletion handled by script
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
	#$CollisionShape2D.disabled = !value
	$CollisionShape2D.disabled = true

func explosion_effect():
	var exp_inst = ExplosionEffect.instantiate()
	get_tree().root.get_node("Main").add_child(exp_inst)
	exp_inst.set_new_color($FireballBottom.self_modulate)
	exp_inst.position = self.position

func handle_object_destroy():
	destroyed = true
	self.linear_velocity = Vector2.ZERO
	#idk why collider is still active
	$CollisionShape2D.position = Vector2(10000, 10000)
	
func destroy_self():
	enable_collider(false)
	$FireballBottom/Trail.emitting = false
	explosion_effect()
	handle_object_destroy()
	fade_out(0.1, 0.6, Callable(self, "queue_free"))
