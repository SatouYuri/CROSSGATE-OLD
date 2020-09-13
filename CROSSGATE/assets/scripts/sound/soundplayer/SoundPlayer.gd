extends Node2D

#Constantes
const Soundtrack = preload("res://assets/scenes/sound/soundplayer/Soundtrack.tscn")
const SoundFX = preload("res://assets/scenes/sound/soundplayer/SoundFX.tscn")

#Variáveis de Estado
var playing : bool
var curSoundPath : String
var toBeFreeList = []

#Código Inicial
func _ready():
	playing = false

#Funções
func play(soundPath : String, isSoundtrack : bool): #NOTA / WIP: Adicionar parâmetros para fadeIn e fadeOut depois...
	if Directory.new().file_exists(soundPath):
		var soundNodeAlreadyExists = false
		for sNode in get_children():
			if soundPath == sNode.audioPath:
				soundNodeAlreadyExists = true
				sNode.play()
				break
			
		if !soundNodeAlreadyExists:
			if isSoundtrack:
				var newSoundtrackNode = Soundtrack.instance()
				newSoundtrackNode.name = "SoundtrackNode_Id_" + str(get_children().size()) + "_" + soundPath
				newSoundtrackNode.stream = load(soundPath)
				newSoundtrackNode.audioPath = soundPath
				add_child(newSoundtrackNode)
				newSoundtrackNode.play()
			else:
				var newSoundFxNode = Soundtrack.instance()
				newSoundFxNode.name = "SoundFxNode_Id_" + str(get_children().size()) + "_" + soundPath
				newSoundFxNode.stream = load(soundPath)
				newSoundFxNode.audioPath = soundPath
				newSoundFxNode.volume_db = -10.0
				add_child(newSoundFxNode)
				newSoundFxNode.play()
			
		playing = true
	else:
		push_error("SoundPlayer: O arquivo de som cujo caminho especificado é '" + soundPath + "' é inválido ou não pôde ser aberto.")

func pause():
	pass

func stop():
	pass

func fadeOut():
	pass

func fadeIn():
	pass

