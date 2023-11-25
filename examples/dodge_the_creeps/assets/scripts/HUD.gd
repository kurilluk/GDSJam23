extends CanvasLayer
class_name HUD
signal start_game

@export var HealthBar: ProgressBar
@export var ManaBar: ProgressBar

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

func set_hud_bars():
	HealthBar.max_value = 100
	HealthBar.value = 100
	ManaBar.max_value = 100
	ManaBar.value = 100
	
func update_health(old_value, new_value):
	HealthBar.value = new_value
	
func update_mana(old_value, new_value):
	ManaBar.value = new_value

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = "Dodge the\nCreeps"
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
