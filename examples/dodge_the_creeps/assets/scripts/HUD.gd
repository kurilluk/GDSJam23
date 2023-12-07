extends CanvasLayer
class_name HUD
signal start_game

@export var HealthBar: TextureProgressBar
@export var UnderlyingHealthBar: TextureProgressBar
@export var ManaBar: TextureProgressBar
@export var UnderlyingManaBar: TextureProgressBar
@export var HudFrame: Sprite2D
@export var PotionsScene: Node2D
@export var ColorFadeRect: ColorRect

@export var bar_tween_first_dur = 0.15
@export var bar_tween_second_dur = 0.15
@export var bar_tween_third_dur = 0.5

var health_tween: Tween
var mana_tween: Tween

@export var potion_name_colors = {
	"Potion_1" : Color.DARK_RED,
	"Potion_2" : Color.WEB_GREEN,
	"Potion_3" : Color.ORANGE,
	"Potion_4" : Color.MEDIUM_BLUE
}

func _ready():
	hud_bars_hidden()
	
func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

func change_hud_bar_colors(heal_potion, mana_potion):
	HealthBar.tint_progress = potion_name_colors[heal_potion]
	UnderlyingHealthBar.tint_progress = potion_name_colors[heal_potion]
	UnderlyingHealthBar.tint_progress.a = 0.75
	
	ManaBar.tint_progress = potion_name_colors[mana_potion]
	UnderlyingManaBar.tint_progress = potion_name_colors[mana_potion]
	UnderlyingManaBar.tint_progress.a = 0.75

func show_hud_bars():
	var bars = [HealthBar, UnderlyingHealthBar, ManaBar, UnderlyingManaBar]  #, HudFrame, PotionsScene
	var show_tween = create_tween()
	show_tween.set_parallel(true)
	for bar in bars:
		bar.modulate = Color.TRANSPARENT
		show_tween.tween_property(bar, "modulate", Color.WHITE, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)	

func hide_hud_bars():
	var bars = [HealthBar, UnderlyingHealthBar, ManaBar, UnderlyingManaBar] #, HudFrame, PotionsScene
	var hide_tween = create_tween()
	hide_tween.set_parallel(true)
	for bar in bars:
		bar.modulate = Color.WHITE
		hide_tween.tween_property(bar, "modulate", Color.TRANSPARENT, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func set_hud_bars():
	var bars = [HealthBar, UnderlyingHealthBar, ManaBar, UnderlyingManaBar]
	for bar in bars:
		bar.max_value = 100
		bar.value = 100

func hud_bars_hidden():
	var bars = [HealthBar, UnderlyingHealthBar, ManaBar, UnderlyingManaBar] #, HudFrame, PotionsScene
	for bar in bars:
		bar.modulate = Color.TRANSPARENT

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
		#bar.value = old_value
		#underlying_bar.value = old_value
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

func get_potion_ready(name):
	return $Potions.is_potion_ready(name)

func use_potion(name):
	$Potions.use_potion(name)

func set_potion_cooldown(value):
	$Potions.potion_cooldown = value

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = ""
	$MessageLabel.show()
	await get_tree().create_timer(1).timeout
	$StartButton.show()

func scene_fade_in():
	pass

func fade_layer_switch(callback: Callable):
	ColorFadeRect.color = Color.WHITE
	ColorFadeRect.modulate = Color.TRANSPARENT
	var layer_fade_tween = create_tween()
	
	layer_fade_tween.tween_property(ColorFadeRect, "modulate", Color.WHITE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	layer_fade_tween.tween_callback(callback)
	layer_fade_tween.tween_property(ColorFadeRect, "modulate", Color.TRANSPARENT, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	

func update_score(score):
	$ScoreLabel.text = str(score)


func _on_StartButton_pressed():
	$StartButton.hide()
	$Play.play()
	start_game.emit()
	set_hud_bars()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()
