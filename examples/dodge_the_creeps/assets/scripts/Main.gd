extends Node

@export var background: Sprite2D
@export var layers: Array[Layer]
@export var enemy_proj_scene: PackedScene

@export var enemy_spawn_amount = 3
var score
var current_layer
var enemy_projectiles: Array[EnemyProjectile]
var player_projectiles: Array[Fireball]
var level = 0
var pitch = 1
var projectile_multiplier = 1.5

func _ready() -> void:
	randomize_potion_effects()
	pass

func game_over():
	$Timers/ScoreTimer.stop()
	$Timers/MobTimer.stop()
	$Timers/CastMagickTimer.stop()
	$HUD.show_game_over()
	$HUD.hide_hud_bars()
	$Music.stop()
	$Player/CollisionShape2D.disabled = true
	$DeathSound.play()

func new_game():
	get_tree().call_group(&"Projectiles", &"queue_free")
	score = 0
	$Player/CollisionShape2D.disabled = false
	$Player.start($StartPosition.position)
	$Player.projectile_append = Callable(self, "append_projectile")
	$Player.projectile_erase = Callable(self, "erase_projectile")
	$Timers/StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Here they come!")
	$HUD.show_hud_bars()
	level = 1
	pitch = 1
	set_new_layer(layers[0])

func randomize_potion_effects():
	#reshuffle all layers' potion modificators apart from the starting "normal" layer
	for i in range(1, layers.size()):
		var layer = layers[i]
		var permutation = layer.shuffle_potion_effects()
		#check for any duplicate modificators on previous all layers and reshuffle
		while not potion_permutation_unique(i, permutation):
			permutation = layer.shuffle_potion_effects()

func potion_permutation_unique(i, permutation) -> bool:
	for j in range(0, i):
		if permutation == layers[j].potion_effects_modification.values():
			return false
	return true

func append_projectile(projectile):
	player_projectiles.append(projectile)
	
func erase_projectile(projectile):
	player_projectiles.erase(projectile)
	#$Music.play()
func set_new_layer(layer: Layer):
	current_layer = layer
	level += 1
	
	$Music.pitch_scale = pitch
	$Music.play()
	pitch += 0.25
	projectile_multiplier += 0.25
	if pitch >= 3.0:
		pitch = 3.0
	
	background.modulate = layer.background_color
	$Player.set_player_inputs(layer.get_input_modification())
	$Player.set_potion_effects(layer.get_potion_modifications())
	$Player.set_fireball_color(layer.player_fireball_color)
	
	set_enemy_colors(layer.enemy_main_color)
	
func set_player_fireball_colors(color):
	for fireball in player_projectiles:
		fireball.set_color(color)

func set_enemy_colors(color):
	var remove_last = []
	for i in enemy_projectiles.size():
		var enemy = enemy_projectiles[-i-1]
		if enemy == null:
			remove_last.append(-i -1)
			break
		enemy.set_color(color)
		
	for index in remove_last:
		enemy_projectiles.remove_at(index)

func _on_MobTimer_timeout():
	var enmy_projectiles_to_spawn = randi_range(int(pitch), int(projectile_multiplier))
	for i in range(0 , int(pitch)):
	# Create a new instance of the Mob scene.
		var enm_projectile = enemy_proj_scene.instantiate()

	# Choose a random location on Path2D.
		var e_projectile_spawn_location = get_node(^"MobPath/MobSpawnLocation")
		e_projectile_spawn_location.progress = randi()

	# Set the mob's direction perpendicular to the path direction.
		var direction = e_projectile_spawn_location.position.angle_to_point($Player.position)
		enm_projectile.position = e_projectile_spawn_location.position

		var velocity = Vector2(randf_range(550.0, 800.0), 0.0)
		
		# Add some randomness to the direction.
		direction += randf_range(-PI / 16.0, PI / 16.0)
		enm_projectile.linear_velocity = velocity.rotated(direction)
		
		enm_projectile.set_new_rotation(Vector2.UP.angle_to(enm_projectile.linear_velocity.normalized()))	
	
		enm_projectile.set_color(current_layer.enemy_main_color)
		enemy_projectiles.append(enm_projectile)

		add_child(enm_projectile)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$Timers/MobTimer.start()
	$Timers/ScoreTimer.start()
	$Timers/CastMagickTimer.start()
	
func set_new_layer_callback():
	var new_layer = get_rand_layer()
	while new_layer == current_layer:
		new_layer = get_rand_layer()
	set_new_layer(new_layer)
	
func get_rand_layer():
	var rand_layer = layers[randi() % layers.size()]
	return rand_layer

func _on_background_music_finished():
	$HUD.fade_layer_switch(Callable(self, "set_new_layer_callback"))
#	$Transition.play()
	
