extends Node2D

var cur_cont_fx

func stop_continuous_fx():
	cur_cont_fx.stop()

func playfx(sound_name):
	
	#Efeitos Não Contínuos (Executam o som e em seguida, esta instância de SoundFX é destruída e, portanto, removida da árvore)
	if sound_name == "Shot":
		var shot_sound = randi()%3
		if shot_sound == 0:
			$Shot1.play(0)
		elif shot_sound == 1:
			$Shot2.play(0)
		elif shot_sound == 2:
			$Shot3.play(0)
			
	if sound_name == "Pain":
		var pain_sound = randi()%3
		if pain_sound == 0:
			$Pain1.play(0)
		elif pain_sound == 1:
			$Pain2.play(0)
		elif pain_sound == 2:
			$Pain3.play(0)
		
	if sound_name == "GateOpen":
		$GateOpen.play(0)
		
	if sound_name == "GateClose":
		$GateClose.play(0)
		
	if sound_name == "GateInteract":
		$GateInteract.play(0)
		
	#Efeitos Contínuos (Executam o som continuamente, até que seja chamada a função stop_continuous_fx(). Não destrói a instância de SoundFX)		
	if sound_name == "PortalIdle":
		cur_cont_fx = $PortalIdle
		$PortalIdle.play()
	
	if sound_name == "EnergyFlow":
		cur_cont_fx = $EnergyFlow
		$EnergyFlow.play()
			
func _physics_process(delta):
	pass

func _on_Shot1_finished(): #Serve para os sons Shot1, 2 e 3 e Pain1, 2 e 3.
	queue_free()
