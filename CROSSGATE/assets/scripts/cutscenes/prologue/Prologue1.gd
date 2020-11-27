extends Node2D

#Constantes
const SoundPlayer = preload("res://assets/scenes/sound/soundplayer/SoundPlayer.tscn")

#Variáveis de Estado
var step : int
var quoteFadeOut : bool

#Código Inicial
func _ready():
	var newSoundPlayer = SoundPlayer.instance()
	newSoundPlayer.name = "SoundPlayer"
	add_child(newSoundPlayer)
	$TextLabel/TextLabel1.percent_visible = 0
	step = 1
	quoteFadeOut = false
	$Timers/PRECUTSCENE_DELAY.start()

#Código Principal
func _physics_process(delta):
	if step == 1:
		if $Timers/PRECUTSCENE_DELAY.is_stopped() and $Timers/AFTER_QUOTE_DELAY.is_stopped() and !quoteFadeOut:
			if $TextLabel/TextLabel1.percent_visible < 1:
				$TextLabel/TextLabel1.percent_visible += 0.0025
			else:
				$TextLabel/TextLabel1.percent_visible = 1
				$Timers/AFTER_QUOTE_DELAY.start()
		elif quoteFadeOut:
			if $TextLabel/TextLabel1.modulate.a > 0:
				$TextLabel/TextLabel1.modulate.a -= 0.01
			else:
				step = 2
	#elif step == 2:
			

func _on_AFTER_QUOTE_DELAY_timeout():
	quoteFadeOut = true
	get_node("SoundPlayer").play("res://assets/sounds/soundtrack/OdysseyOfTheGateHero.ogg", true)
