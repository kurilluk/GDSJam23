extends RigidBody2D
class_name Mob

func _ready():
	$AnimatedSprite2D.play()
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func set_color(new_color):
	$ColorRect.color = new_color
	
func die():
	queue_free()
