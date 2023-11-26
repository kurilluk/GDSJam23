extends RigidBody2D
class_name EnemyProjectile

func _ready():
	$AnimatedSprite2D.play()
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$Fire_2.play()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func set_color(new_color):
	$FireballBottom.self_modulate = new_color

func set_new_rotation(new_rot):
	$FireballBottom.rotation = new_rot

func die():
	queue_free()
