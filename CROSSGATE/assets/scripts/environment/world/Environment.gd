extends Node2D

#Constantes
const SCRIPT_TYPE = "World_ENV_Root"

#Variáveis de Estado
var stage : Node #O estágio atualmente selecionado
var stageName : String

#Funções
func loadStage(stageName): #Carrega e instancia o estágio alvo.
	if "TestStage" == stageName:
		stage = preload("res://assets/scenes/environment/stage/TestStage.tscn").instance()
		stage.set_name("loadedStage")
		get_parent().get_node("Background").loadBackground("Sunlight") #Todo estágio tem um background inicial associado. No caso de "TestStage", esse Background é "Sunlight".
	elif "WagonTestStage" == stageName:
		stage = preload("res://assets/scenes/environment/stage/WagonTestStage.tscn").instance()
		stage.set_name("loadedStage")
		get_parent().get_node("Background").loadBackground("Sunlight")
	#/*Adicione mais Stages...*/#
	add_child(stage)

func timeStop(): #Paraliza/Desparaliza todos os nós dentro do estágio atual.
	for node in get_children():
		node.timeStop()

func getGlobal():
	return get_tree().get_root().get_node("Global")

#Código Inicial
func _ready():
	loadStage(getGlobal().stageName) #NOTA / WIP: O estágio atual deve ser buscado de algum arquivo de save do jogo.