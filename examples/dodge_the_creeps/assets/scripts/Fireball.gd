extends Area2D
class_name Fireball

@export var intensity_curve: Curve
@export var intensity_curve_scale = 0.25
var random_curve_offset: int

var speed: int
var direction: Vector2
var on_death_callback: Callable
var ignore_target
	
func _ready():
	#$Fire_1.play()
	random_curve_offset = randi_range(0, 1000)
	fade_in(0.25, Callable(self, "enable_collider").bind(true))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# move projectile
	position = position + (direction * speed * delta)
	# oscillating projectile intensity
	var time = Time.get_ticks_msec()
	var t = (((int(time/intensity_curve_scale) + random_curve_offset) % 1000) / 1000.0)
	$FireballBottom.self_modulate *= 1 + intensity_curve.sample(t)
	pass

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

func set_color(new_color):
	$FireballBottom.self_modulate = new_color

func set_speed(new_speed):
	self.speed = new_speed

func set_ignore_target(target):
	self.ignore_target = target

func set_rot(new_rotation):
	$FireballBottom.rotation = new_rotation
	pass

func set_dir(new_direction):
	self.direction = new_direction
	pass
	
func set_pos(new_position):
	position = new_position
	pass
	
func enable_collider(value):
	$CollisionShape2D.disabled = !value
	
func _on_screen_exited():
	destroy_self()
	pass # Replace with function body.
	
func destroy_self():
	fade_out(0.1, 1.0, Callable(self, "queue_free"))
	on_death_callback.bind(self).call()
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		pass # Replace with function body.
	if body.is_in_group("Projectile"):
		destroy_self()
		body.destroy_self()
	
func _on_area_entered(area):
	if area.is_in_group("Player") and ignore_target != "Player":
		destroy_self()
	if area.is_in_group("Projectile"):
		destroy_self()
	pass # Replace with function body.
	
