extends Node2D

var is_blinking = false
var is_lowlife = false
var lowlife_warning = 0 #-1 se estiver escurecendo o vermelho, +1 se estiver clareando

func rgba(r, g, b, a):
	$HP.tint_progress.r = r
	$HP.tint_progress.g = g
	$HP.tint_progress.b = b
	$HP.tint_progress.a = a
	
func rgb(r, g, b):
	$HP.tint_progress.r = r
	$HP.tint_progress.g = g
	$HP.tint_progress.b = b

func _ready():
	$PlayerPicFrame/BLINK_Timer.start()

func _physics_process(delta):
	#Imagem do Brandon Woodfield
	if is_blinking == false:
		$PlayerPicFrame/PLAYER_PICTURE_AnimatedSprite.play("Idle")
		
	#Barra de HP
	if $HP.value/$HP.max_value >= 0.5:
		is_lowlife = false
		lowlife_warning = 0
		$HP.tint_over.r = 1
		$HP.tint_over.g = 1
		$HP.tint_over.b = 1
		$HP.tint_over.a = 1
		
	elif $HP.value/$HP.max_value < 0.5 && is_lowlife == false:
		is_lowlife = true
		$HP.tint_over.r = 1
		$HP.tint_over.g = 0
		$HP.tint_over.b = 0
		$HP.tint_over.a = 1
		
	#Aviso piscante de pouca vida na texture_over de HP
	if is_lowlife == true:
		if $HP.tint_over.r > 0.95:
			lowlife_warning = -1
			$HP.tint_over.r -= 0.01
			
		elif $HP.tint_over.r < 0.05:
			lowlife_warning = +1
			$HP.tint_over.r += 0.01
			
		else:
			$HP.tint_over.r += 0.01 * lowlife_warning
		
func _on_BLINK_Timer_timeout():
	is_blinking = true
	$PlayerPicFrame/PLAYER_PICTURE_AnimatedSprite.play("Blink")

func _on_PLAYER_PICTURE_AnimatedSprite_animation_finished():
	if is_blinking == true:
		is_blinking = false
		$PlayerPicFrame/BLINK_Timer.wait_time = randf()*11 - 1
		$PlayerPicFrame/BLINK_Timer.start()
			