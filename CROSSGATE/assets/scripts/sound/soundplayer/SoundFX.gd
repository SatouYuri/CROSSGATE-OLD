extends AudioStreamPlayer2D

#Variáveis de Estado
var audioPath : String
var repeat : bool = false

func _on_SoundFX_finished():
	if !repeat:
		queue_free()
	else:
		play()
