extends Node

@export var background: Sprite2D
@export var layers: Array[Layer]
@export var mob_scene: PackedScene

@export var enemy_spawn_amount = 2
var score
var current_layer
var enemies: Array[Mob]
var player_projectiles: Array[Fireball]
var level = 0

func _ready() -> void:
	pass

func game_over():
	$Timers/ScoreTimer.stop()
	$Timers/MobTimer.stop()
	$Timers/CastMagickTimer.stop()
	$Timers/LayerSwitchTimer.stop()
	$HUD.show_game_over()
	$HUD.hide_hud_bars()
	$Music.stop()
	#$DeathSound.play()

func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$Player.projectile_append = Callable(self, "append_projectile")
	$Player.projectile_erase = Callable(self, "erase_projectile")
	$Timers/StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Here they come!")
	$HUD.show_hud_bars()
	set_new_layer(layers[0])

func append_projectile(projectile):
	player_projectiles.append(projectile)
	
func erase_projectile(projectile):
	player_projectiles.erase(projectile)
	#$Music.play()
func set_new_layer(layer: Layer):
	current_layer = layer
	level += 1
	
	background.modulate = layer.background_color
	$Player.set_player_inputs(layer.get_input_modification())
	$Player.set_potion_effects(layer.get_potion_modifications())
	
	set_enemy_colors(layer.enemy_main_color)

func set_enemy_colors(color):
	var remove_last = []
	for i in enemies.size():
		var enemy = enemies[-i-1]
		if enemy == null:
			remove_last.append(-i -1)
			break
		enemy.set_color(color)

	for index in remove_last:
		enemies.remove_at(index)

func _on_MobTimer_timeout():
	for i in enemy_spawn_amount:
	# Create a new instance of the Mob scene.
		var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
		var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
		mob_spawn_location.progress = randi()

	# Set the mob's direction perpendicular to the path direction.
		var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
		mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
		direction += randf_range(-PI / 4, PI / 4)
		mob.rotation = direction

	# Choose the velocity for the mob.
		var velocity = Vector2(randf_range(650.0, 850.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction)
	
		mob.set_color(current_layer.enemy_main_color)
		enemies.append(mob)
	# Spawn the mob by adding it to the Main scene.
		add_child(mob)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$Timers/MobTimer.start()
	$Timers/ScoreTimer.start()
	$Timers/CastMagickTimer.start()
	$Timers/LayerSwitchTimer.start()
	
func _on_layer_switch_timer_timeout():	
	$HUD.fade_layer_switch(Callable(self, "set_new_layer_callback"))
	
func set_new_layer_callback():
	var new_layer = get_rand_layer()
	while new_layer == current_layer:
		new_layer = get_rand_layer()
	set_new_layer(new_layer)
	
func get_rand_layer():
	var rand_layer = layers[randi() % layers.size()]
	return rand_layer


