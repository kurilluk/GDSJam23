extends CanvasLayer
class_name HUD
signal start_game

@export var HealthBar: TextureProgressBar
@export var UnderlyingHealthBar: TextureProgressBar
@export var ManaBar: TextureProgressBar
@export var UnderlyingManaBar: TextureProgressBar

@export var bar_tween_first_dur = 0.15
@export var bar_tween_second_dur = 0.15
@export var bar_tween_third_dur = 0.5

var health_tween: Tween
var mana_tween: Tween

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

func set_hud_bars():
	HealthBar.max_value = 100
	HealthBar.value = 100
	ManaBar.max_value = 100
	ManaBar.value = 100

func update_bar(old_value, new_value, type):
	var tweener: Tween
	var bar: TextureProgressBar
	var underlying_bar: TextureProgressBar
	match type:
		"Health":
			tweener = health_tween
			bar = HealthBar
			underlying_bar = UnderlyingHealthBar
		"Mana":
			tweener = mana_tween
			bar = ManaBar
			underlying_bar = UnderlyingManaBar
	
	if tweener != null and tweener.is_running():
		tweener.stop()
		bar.value = old_value
		underlying_bar.value = old_value
	tweener = create_tween()
	
	if new_value > old_value: #healing
		tweener.tween_property(underlying_bar, "value", new_value, bar_tween_first_dur)
		tweener.tween_property(underlying_bar, "value", new_value, bar_tween_second_dur)
		tweener.tween_property(bar, "value", new_value, bar_tween_third_dur)
	else: #damage
		tweener.tween_property(bar, "value", new_value, bar_tween_first_dur)
		tweener.tween_property(bar, "value", new_value, bar_tween_second_dur)
		tweener.tween_property(underlying_bar, "value", new_value, bar_tween_third_dur)

func update_health(old_value, new_value):
	update_bar(old_value, new_value, "Health")
	
func update_mana(old_value, new_value):
	update_bar(old_value, new_value, "Mana")

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = ""
	$MessageLabel.show()
	await get_tree().create_timer(1).timeout
	$StartButton.show()


func update_score(score):
	$ScoreLabel.text = str(score)


func _on_StartButton_pressed():
	$StartButton.hide()
	start_game.emit()
	set_hud_bars()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()
