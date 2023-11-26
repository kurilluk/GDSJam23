extends Area2D
class_name Fireball

var speed: int
var direction: Vector2
var on_death_callback: Callable
var ignore_target

func fade_in(duration):
	$FireballBottom.modulate = Color.TRANSPARENT
	var fade_tweener = create_tween()
	fade_tweener.tween_property($FireballBottom, "modulate", Color.WHITE, duration). \
		set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)	
	
func fade_out(duration, callback: Callable):
	var fade_tweener = create_tween()
	fade_tweener.tween_property($FireballBottom, "self_modulate", Color.TRANSPARENT, duration). \
		set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	fade_tweener.parallel().tween_property($FireballBottom, "self_modulate", Color.TRANSPARENT, duration). \
		set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
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
	
func _ready():
	$Fire_1.play()
	fade_in(0.5)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position + (direction * speed * delta)
	#print("process called: " + str(position) + " " + str(speed) + " " + str(direction))
	pass

func _on_screen_exited():
	destroy_self()
	pass # Replace with function body.

func destroy_self():
	on_death_callback.bind(self).call()
	fade_out(0.25, Callable(self, "queue_free"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		pass # Replace with function body.
	if body.is_in_group("mobs"):
		destroy_self()
		body.die()
	

func _on_area_entered(area):
	if area.is_in_group("Player") and ignore_target != "Player":
		destroy_self()
	if area.is_in_group("Projectile"):
		destroy_self()
	pass # Replace with function body.
