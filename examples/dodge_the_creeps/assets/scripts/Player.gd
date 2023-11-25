extends Area2D

signal hit

@export var SPEED = 600 # How fast the player will move (pixels/sec).
@export var PLAYER_MAX_HEALTH = 100
@export var PLAYER_MAX_MANA = 100
@export var Game_HUD: HUD
var health
var mana
var screen_size # Size of the game window.

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
	0: Callable(self, "potion_heal").bind(10),
	1: Callable(self, "potion_hurt").bind(10),
	2: Callable(self, "potion_gain_mana").bind(10),
	3: Callable(self, "potion_lose_mana").bind(10),
}

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed(&"Right"):
		velocity += player_inputs["Right"]
	if Input.is_action_pressed(&"Left"):
		velocity += player_inputs["Left"]
	if Input.is_action_pressed(&"Down"):
		velocity += player_inputs["Down"]
	if Input.is_action_pressed(&"Up"):
		velocity += player_inputs["Up"]

	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = &"up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
		$Trail.rotation = PI if velocity.y > 0 else 0

func set_player_inputs(new_player_inputs):
	player_inputs = new_player_inputs
	
func set_potion_effects(new_potion_input_effects):
	potion_input_effects = new_potion_input_effects

func start(pos):
	position = pos
	health = PLAYER_MAX_HEALTH
	mana = PLAYER_MAX_MANA
	show()
	$CollisionShape2D.disabled = false

func potion_heal(value):
	var new_health = clamp(health + value, 0, PLAYER_MAX_HEALTH)
	Game_HUD.update_health(health, new_health);
	pass
	
func potion_hurt(value):
	var new_health = clamp(health - value, 0, PLAYER_MAX_HEALTH)
	Game_HUD.update_health(health, new_health);
	pass

func potion_gain_mana(value):
	var new_mana = clamp(mana + value, 0, PLAYER_MAX_MANA)
	Game_HUD.update_mana(mana, new_mana);
	pass
	
func potion_lose_mana(value):
	var new_mana = clamp(mana - value, 0, PLAYER_MAX_MANA)
	Game_HUD.update_mana(mana, new_mana);
	pass


func _on_Player_body_entered(_body):
#	hide() # Player disappears after being hit.
	hit.emit()
	#temp
	health -= 15
	Game_HUD.update_health(health, health - 15)
	
	if health <= 0:
		on_death.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
#	$CollisionShape2D.set_deferred(&"disabled", true)
