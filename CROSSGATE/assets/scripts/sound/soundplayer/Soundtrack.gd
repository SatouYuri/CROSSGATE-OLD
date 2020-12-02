extends AudioStreamPlayer

#Variáveis de Estado
var audioPath : String
var repeat : bool = false

func _on_Soundtrack_finished():
	if !repeat:
		queue_free()
	else:
		play()
