extends Node2D

#Constantes
const SoundPlayer = preload("res://assets/scenes/sound/soundplayer/SoundPlayer.tscn")

#Variáveis de Estado
var cLogoFadeIn : bool
var cLogoFadeOut : bool
var fadeOut : bool
var fadeIn : bool
var glowSignal : int
var glowSpeed : float
var showOptions : bool
var selectedOption : int
var changingScene : bool
var currentMenu : String

#Código Inicial
func _ready():
	currentMenu = "V1" #NOTA / WIP: Podem haver diferentes menus principais depois, com cenas diferentes (V2, V3, etc) e o jogo poderá escolher um deles aleatoriamente
	var newSoundPlayer = SoundPlayer.instance()
	newSoundPlayer.name = "SoundPlayer"
	add_child(newSoundPlayer)
	if currentMenu == "V1":
		newSoundPlayer.play("res://assets/sounds/soundtrack/The Ancients' Lost Hope.ogg", true)
	
	$Black.visible = true
	$GLITCH_MASK.visible = false
	
	cLogoFadeIn = false
	cLogoFadeOut = false
	fadeOut = false
	fadeIn = false
	glowSignal = +1
	glowSpeed = 1.0
	showOptions = false
	selectedOption = 0
	changingScene = false

#Funções
func colorGlow():
	if $Black.modulate.a <= 0.0:
		if $V1/Background.modulate.a <= 0:
			$V1/Background.modulate.a == 0.0
			glowSignal = abs(glowSignal)
		elif $V1/Background.modulate.a >= 1.0:
			$V1/Background.modulate.a == 1.0
			glowSignal = -abs(glowSignal)
			glowSpeed = 1.0
		$V1/Background.modulate.a += 0.001*glowSignal*glowSpeed

func getGlobal():
	return get_tree().get_root().get_node("Global")

#Callbacks
func _input(event):
	if event is InputEventKey and !changingScene:
		var optionList = $V1/Options.get_children()
		if event.pressed and $Black.modulate.a <= 0.0 and !showOptions:
			showOptions = true
			glowSpeed = 200.0
			$V1/PressAnyKey.visible = false
			$Timers/OPTION_BLINK.stop()
			for option in optionList:
				option.visible = true
			get_node("SoundPlayer").play("res://assets/sounds/soundfx/mainmenu/anyKeyPressed.ogg", false)
		elif showOptions:
			if event.is_action_pressed("CG_DOWN") and selectedOption < (optionList.size() - 1):
				selectedOption += 1
				get_node("SoundPlayer").play("res://assets/sounds/soundfx/mainmenu/optionChange.ogg", false)
			elif event.is_action_pressed("CG_UP") and (selectedOption - 1) >= 0:
				selectedOption -= 1
				get_node("SoundPlayer").play("res://assets/sounds/soundfx/mainmenu/optionChange.ogg", false)
			elif event.is_action_pressed("CG_GATE"): 
				if currentMenu == "V1":
					if selectedOption == 0:
						getGlobal().stageName = "TestStage"
						fadeIn = true
						changingScene = true
					elif selectedOption == 1:
						getGlobal().stageName = "WagonTestStage"
						fadeIn = true
						changingScene = true
					get_node("SoundPlayer").play("res://assets/sounds/soundfx/mainmenu/anyKeyPressed.ogg", false)
					$TIMESTOP_MASK.visible = true

#Código Principal
func _process(delta):
	if cLogoFadeIn:
		if $CompanyLogo.modulate.a < 1.0:
			$CompanyLogo.modulate.a += 0.05
		else:
			$CompanyLogo.modulate.a = 1.0
			cLogoFadeIn = false
			$Timers/COMPANY_LOGO_DELAY.start()
	elif cLogoFadeOut:
		if $CompanyLogo.modulate.a > 0:
			$CompanyLogo.modulate.a -= 0.05
		else:
			$CompanyLogo.modulate.a = 0.0
			cLogoFadeOut = false
			$Timers/GAME_LOGO_START_DELAY.start()
	
	if (!$Timers/COMPANY_LOGO_DELAY.is_stopped() or cLogoFadeOut) and Input.is_action_just_pressed("CG_GATE"):
		$Timers/COMPANY_LOGO_DELAY.stop()
		$CompanyLogo.modulate.a = 0.0
		cLogoFadeOut = false
		$Timers/GAME_LOGO_START_DELAY.start()
	
	if fadeOut:
		if $Black.modulate.a > 0:
			$Black.modulate.a -= 0.01
		else:
			$Black.modulate.a = 0.0
			fadeOut = false
	
	if fadeIn:
		if $Black.modulate.a <= 1:
			$Black.modulate.a += 0.01
			if currentMenu == "V1":
				for sNode in get_node("SoundPlayer").get_children(): #NOTA / WIP: Ao invés desse for(), usar uma função de pause com fade out do nó SoundPlayer aqui...
					sNode.volume_db -= 0.5
		else:
			$Black.modulate.a = 1.0
			fadeIn = false
			if currentMenu == "V1":
				if changingScene:
					$Timers/SCENE_CHANCE_DELAY.start()
	
	if $Black.modulate.a <= 0.0:
		if !$GLITCH_MASK.visible and (randi()%100 + 1) <= 1.0:
			$Timers/GLITCH_APPEARANCE.start()
			$GLITCH_MASK.visible = true
		
		if $Timers/OPTION_BLINK.is_stopped() and !showOptions:
			$Timers/OPTION_BLINK.start()
	
	if showOptions:
		colorGlow()
		$V1/Options.get_children()[selectedOption].modulate.a = 1.0
		var index = 0
		var optionList = $V1/Options.get_children()
		for option in optionList:
			if index == selectedOption:
				optionList[index].modulate.a = 1.0
			else:
				optionList[index].modulate.a = 0.5
			index += 1

func _on_GAME_START_DELAY_timeout():
	cLogoFadeIn = true

func _on_COMPANY_LOGO_DELAY_timeout():
	cLogoFadeOut = true

func _on_GAME_LOGO_START_DELAY_timeout():
	fadeOut = true

func _on_GLITCH_APPEARANCE_timeout():
	$GLITCH_MASK.visible = false

func _on_OPTION_BLINK_timeout():
	$V1/PressAnyKey.visible = !$V1/PressAnyKey.visible

func _on_SCENE_CHANCE_DELAY_timeout():
	if currentMenu == "V1":
		get_tree().change_scene("res://assets/scenes/environment/world/World.tscn")
