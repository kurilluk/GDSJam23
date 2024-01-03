extends Area2D

signal hit

@export var SPEED = 500 # How fast the player will move (pixels/sec).
@export var PLAYER_MAX_HEALTH = 100
@export var PLAYER_MAX_MANA = 100
@export var MAGICKS_MANA_COST = 10
@export var FIREBALL_SPEED = 800
@export var Game_HUD: HUD
@export var POTION_COOLDOWN = 1.0

@export var Fireball: PackedScene

@export var player_sprite_mngr: PlayerSpriteManager = null

var health
var mana
var player_dead = true
var screen_size # Size of the game window.

var tmp_no_movement = true
var velocity
var player_fireball_color: Color
var projectile_append: Callable
var projectile_erase: Callable
signal on_death

var player_inputs = {
	"Left": Vector2.LEFT,
	"Right": Vector2.RIGHT,
	"Up": Vector2.UP,
	"Down": Vector2.DOWN
}

var potion_input_effects = {
	"Potion_1": 0,
	"Potion_2": 1,
	"Potion_3": 2,
	"Potion_4": 3
}

var potion_effects = {
	0: Callable(self, "potion_heal").bind(20),
	1: Callable(self, "potion_hurt").bind(10),
	2: Callable(self, "potion_gain_mana").bind(30),
	3: Callable(self, "potion_loose_mana").bind(10),
}

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	if player_dead:
		return
	handle_movement(delta)
	handle_potion_inputs()
	
func set_fireball_color(new_color):
	self.player_fireball_color = new_color
	set_player_sprite_fx_color(new_color)
	
func set_player_sprite_fx_color(new_color):
	if player_sprite_mngr != null:
		player_sprite_mngr.set_magic_fx_color(new_color)
# right = false ; left = true
func set_player_sprite_facing(side: bool):
	if player_sprite_mngr != null:
		var facing = null
		if side:
			facing = PlayerSpriteManager.Facing.LEFT
		else:
			facing = PlayerSpriteManager.Facing.RIGHT
		player_sprite_mngr.set_facing(facing)
		
func player_sprite_play_magic_fx():
	if player_sprite_mngr != null:
		player_sprite_mngr.magic_casting_fx()
	
func handle_movement(delta):
	velocity = Vector2.ZERO # The player's movement vector.
	for action in player_inputs:
		if Input.is_action_pressed(action):
			velocity += player_inputs[action]

	if velocity.length() > 0:
		if tmp_no_movement:
			player_sprite_mngr.movement_started()
		tmp_no_movement = false
		velocity = velocity.normalized() * SPEED
		$AnimatedSprite2D.play()
	else:
		if not tmp_no_movement:
			player_sprite_mngr.movement_ended()
		tmp_no_movement = true
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x > 0: # moving right
		$Sprite2D.flip_h = false
		set_player_sprite_facing(false)
	elif velocity.x < 0: #moving left
		$Sprite2D.flip_h = true
		set_player_sprite_facing(true)
	#if velocity.x != 0:
	#	$AnimatedSprite2D.animation = &"right"
	#	$AnimatedSprite2D.flip_v = false
	#	$Trail.rotation = 0
	#	$AnimatedSprite2D.flip_h = velocity.x < 0
	#elif velocity.y != 0:
	#	$AnimatedSprite2D.animation = &"up"
	#	$AnimatedSprite2D.flip_v = velocity.y > 0
	#	$Trail.rotation = PI if velocity.y > 0 else 0

func handle_potion_inputs():
	for potion_action in potion_input_effects:
		if Input.is_action_just_pressed(potion_action):
			if Game_HUD.get_potion_ready(potion_action):
				Game_HUD.use_potion(potion_action)
				var potion_func: Callable = potion_effects[potion_input_effects[potion_action]]
				potion_func.call()
				
func player_hurt_effect():
	var tweener = create_tween()
	tweener.tween_property($Sprite2D, "modulate", Color.DARK_RED, 0.15)
	tweener.tween_property($Sprite2D, "modulate", Color.WHITE, 0.15)

func cast_magicks():
	$Fire_1.play()
	player_sprite_play_magic_fx()
	
	var player_dir = velocity.normalized() if velocity.length() != 0 else Vector2.UP
	
	var player_dir_perp = Vector2(-player_dir.y, player_dir.x)
	var projectile_dirs = [player_dir, -1* player_dir, player_dir_perp, -1* player_dir_perp]
	
	for dir in projectile_dirs:
		var fireball = Fireball.instantiate()
		get_tree().root.get_node("Main").add_child(fireball)
		
		var rot = Vector2.UP.angle_to(dir)
		fireball.set_rot(rot)
		fireball.set_pos(position + (dir * 10))
		fireball.set_dir(dir)
		fireball.set_color(player_fireball_color)
		fireball.set_speed(FIREBALL_SPEED)
		fireball.set_ignore_target("Player")
		fireball.on_death_callback = projectile_erase
		
		projectile_append.bind(fireball).call()
	

func set_player_inputs(new_player_inputs):
	player_inputs = new_player_inputs
	
func set_potion_effects(new_potion_input_effects):
	potion_input_effects = new_potion_input_effects

func start(pos):
	position = pos
	health = PLAYER_MAX_HEALTH
	mana = PLAYER_MAX_MANA
	player_dead = false
	show()
	Game_HUD.set_potion_cooldown(POTION_COOLDOWN)
	$CollisionShape2D.disabled = false

func potion_heal(value):
	var new_health = clamp(health + value, 0, PLAYER_MAX_HEALTH)
	Game_HUD.update_health(health, new_health);
	health = new_health
	$S_HealPotion.play()
	pass
	
func potion_hurt(value):
	var new_health = clamp(health - value, 0, PLAYER_MAX_HEALTH)
	Game_HUD.update_health(health, new_health);
	health = new_health
	check_player_health()
	$S_HealPotionDrain.play()
	pass

func potion_gain_mana(value):
	var new_mana = clamp(mana + value, 0, PLAYER_MAX_MANA)
	Game_HUD.update_mana(mana, new_mana);
	mana = new_mana
	$S_ManaPotion.play()
	pass

func potion_loose_mana(value):
	var new_mana = clamp(mana - value, 0, PLAYER_MAX_MANA)
	Game_HUD.update_mana(mana, new_mana);
	mana = new_mana
	$S_ManaPotionDrain.play()
	pass

func check_player_health():
	if health <= 0:
		on_death.emit()
		player_dead = true
		hide()

func _on_Player_body_entered(_body):
#	hide() # Player disappears after being hit.
	if player_dead:
		return
		
	if _body.is_in_group("Projectile") and not _body.destroyed:
		player_hurt_effect()
		_body.destroy_self()
		hit.emit()
		$HitSound.play()
	#temp
		Game_HUD.update_health(health, health - 10)
		health -= 10
		if health == 20:
			$PotionNeeds.play()
		get_viewport().get_camera_2d().camera_shake(5)
		check_player_health()
	# Must be deferred as we can't change physics properties on a physics callback.
#	$CollisionShape2D.set_deferred(&"disabled", true)


func _on_cast_magick_timer_timeout():
	if mana >= MAGICKS_MANA_COST:
		cast_magicks()		
		#spend mana
		var new_mana = clamp(mana - MAGICKS_MANA_COST, 0, PLAYER_MAX_MANA)
		Game_HUD.update_mana(mana, new_mana);
		mana = new_mana
		#
		
