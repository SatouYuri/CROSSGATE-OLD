extends Node2D

#Constantes
const SoundPlayer = preload("res://assets/scenes/sound/soundplayer/SoundPlayer.tscn")

#Variáveis de Estado
var step : int
var puncDelayActive : bool
var tagTriggerList

#Código Inicial
func _ready():
	var newSoundPlayer = SoundPlayer.instance()
	newSoundPlayer.name = "SoundPlayer"
	add_child(newSoundPlayer)
	$TextLabel1.percent_visible = 0
	step = 1
	tagTriggerList = getTagTriggers($TextLabel1.text)
	$GLITCH_MASK.modulate.a = 0
	$GLITCH_MASK.visible = true
	$Flash.modulate.a = 0
	$Flash.visible = true
	$Town.modulate.a = 0
	$Town.visible = true
	$Brandon.modulate.a = 0
	$Brandon.visible = true
	$Capture.modulate.a = 0
	$Capture.visible = true
	$GLITCH_MASK2.modulate.a = 0
	$GLITCH_MASK2.visible = true
	$Flash2.modulate.a = 0
	$Flash2.visible = true
	$Black2.modulate.a = 0
	$Black2.visible = true
	$Timers/PRECUTSCENE_DELAY.start()

#Funções
func getTagTriggers(targetString : String):
	var removingTag = false
	var auxString = ""
	var auxList = []
	var regex = RegEx.new()
	while '{' in targetString:
		for i in range(targetString.length()):
			if targetString[i] == '}':
				auxString += targetString[i]
				#PROBLEMA: E se o texto começar com '{'?
				auxList.append([i-auxString.length(), auxString]) #Cada elemento: [Índice da tag no texto sem tags o qual deve disparar o timer de delay, Tag]
				regex.compile(auxString)
				targetString = regex.sub(targetString, "")
				auxString = ""
				removingTag = false
				break
			elif targetString[i] == '{' or removingTag:
				auxString += targetString[i]
				removingTag = true
	removeAllTags(targetString)
	return auxList

func removeAllTags(targetString : String):
	if step == 1:
		$TextLabel1.text = targetString
	elif step == 4:
		$TextLabel9.text = targetString

#Código Principal
func _physics_process(delta):
	if step == 1:
		if $Timers/PRECUTSCENE_DELAY.is_stopped() and $Timers/AFTER_QUOTE_DELAY.is_stopped():
			if $TextLabel1.percent_visible < 1:
				if $Timers/PUNC_DELAY.is_stopped():
					if tagTriggerList.size() > 0 and tagTriggerList[0][0] + 1 == $TextLabel1.get_visible_characters():
						if "{wait=" in tagTriggerList[0][1]:
							$Timers/PUNC_DELAY.wait_time = float(tagTriggerList[0][1].replace("{wait=", "").replace("s}", ""))
							$Timers/PUNC_DELAY.start()
							tagTriggerList.remove(0)
					$TextLabel1.percent_visible += 0.0025
			else:
				$TextLabel1.percent_visible = 1
				$Timers/AFTER_QUOTE_DELAY.start()

		if $GLITCH_MASK.modulate.a < 1:
			$GLITCH_MASK.modulate.a += 0.001
		else:
			$GLITCH_MASK.modulate.a = 1

		if $TextLabel1.percent_visible == 1:
			$Flash.modulate.a += 0.0065
			if $Flash.modulate.a >= 1:
				step = 2
				tagTriggerList = []

	elif step == 2:
		$Town.position.y -= 0.6
		if $Town.position.y < 350:
			step = 3
		if $Town.modulate.a < 1:
			$Town.modulate.a += 0.01
		else:
			$Town.modulate.a = 1
			$Flash.modulate.a = 0
			$GLITCH_MASK.modulate.a = 0
			$TextLabel1.modulate.a = 0

		if $Town/TextLabel2.percent_visible < 1:
			$Town/TextLabel2.percent_visible += 0.0075
		elif $Town/TextLabel2.percent_visible >= 1:
			$Town/TextLabel2.percent_visible = 1
			if $Town/TextLabel3.percent_visible < 1:
				$Town/TextLabel3.percent_visible += 0.0025
			elif $Town/TextLabel3.percent_visible >= 1:
				$Town/TextLabel3.percent_visible = 1
				if $Town/TextLabel4.percent_visible < 1:
					$Town/TextLabel4.percent_visible += 0.005
				elif $Town/TextLabel4.percent_visible >= 1:
					$Town/TextLabel4.percent_visible = 1

	elif step == 3:
		$Town.position.y -= 0.6
		if $Town.modulate.a > 0:
			$Town.modulate.a -= 0.01

		if $Brandon.position.y > 460:
			$Brandon.frame = 1
			if $Brandon/TextLabel6.percent_visible < 1:
				$Brandon/TextLabel6.percent_visible += 0.01
			elif $Brandon/TextLabel6.percent_visible >= 1:
				$Brandon/TextLabel6.percent_visible = 1
				if $Brandon.modulate.a > 0:
					$Brandon.modulate.a -= 0.015
				else:
					$Brandon.modulate.a = 0
					step = 4
		$Brandon.position.y += 1.25
		
		if $Brandon.modulate.a < 1:
			$Brandon.modulate.a += 0.01
		else:
			$Brandon.modulate.a = 1

		if $Brandon/TextLabel5.percent_visible < 1:
			$Brandon/TextLabel5.percent_visible += 0.01
		elif $Brandon/TextLabel5.percent_visible >= 1:
			$Brandon/TextLabel5.percent_visible = 1

	elif step == 4:
		if $Capture.modulate.a < 1:
			$Capture.modulate.a += 0.005
		elif $Capture.modulate.a >= 1:
			$Capture.modulate.a = 1
			if $Capture/Sky2.modulate.a < 1:
				$Capture/Sky2.modulate.a += 0.0025
			elif $Capture/Sky2.modulate.a >= 1:
				$Capture/Sky2.modulate.a = 1

			if $Capture/TextLabel7.percent_visible < 1:
				$Capture/TextLabel7.percent_visible += 0.005
			elif $Capture/TextLabel7.percent_visible >= 1:
				$Capture/TextLabel7.percent_visible = 1
				if $Capture/Gale.modulate.a < 1:
					$Capture/Gale.modulate.a += 0.0025
				elif $Capture/Gale.modulate.a >= 1:
					$Capture/Gale.modulate.a = 1
					$Capture/Wind.modulate.a = 0
		if $Capture.position.y > -144:
			$Capture.position.y -= 0.15
		else:
			if $Capture/TextLabel8.percent_visible < 1:
				$Capture/TextLabel8.percent_visible += 0.003
			elif $Capture/TextLabel8.percent_visible >= 1:
				$Capture/TextLabel8.percent_visible = 1
				if $Flash2.modulate.a < 1:
					$Flash2.modulate.a += 0.005
				elif $Flash2.modulate.a >= 1:
					$Flash2.modulate.a = 1
					$GLITCH_MASK2.modulate.a = 1
					if tagTriggerList.size() == 0:
						tagTriggerList = getTagTriggers($TextLabel9.text)
					if $TextLabel9.percent_visible < 1:
						if $Timers/PUNC_DELAY.is_stopped():
							if tagTriggerList.size() > 0 and tagTriggerList[0][0] + 1 == $TextLabel9.get_visible_characters():
								if "{wait=" in tagTriggerList[0][1]:
									$Timers/PUNC_DELAY.wait_time = float(tagTriggerList[0][1].replace("{wait=", "").replace("s}", ""))
									$Timers/PUNC_DELAY.start()
									tagTriggerList.remove(0)
							$TextLabel9.percent_visible += 0.0025
					else:
						if $Black2.modulate.a < 1:
							$Black2.modulate.a += 0.0025
						elif $Black2.modulate.a >= 1:
							$Black2.modulate.a = 1
							if $Timers/POSCUTSCENE_DELAY.is_stopped():
								$Timers/POSCUTSCENE_DELAY.start()

func _on_AFTER_QUOTE_DELAY_timeout():
	get_node("SoundPlayer").play("res://assets/sounds/soundtrack/OdysseyOfTheGateHero.ogg", true, false)

func _on_PRECUTSCENE_DELAY_timeout():
	get_node("SoundPlayer").play("res://assets/sounds/soundtrack/Courage&Despair.ogg", true, false)

func _on_POSCUTSCENE_DELAY_timeout():
	print("CUTSCENE FINALIZADA. (Implementar troca de cena nessa função de sinal '_on_POSCUTSCENE_DELAY_timeout()'.)")
