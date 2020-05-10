extends Node2D

#Constantes
const SCRIPT_TYPE = "World_ENV_Root"

#Variáveis de Estado
var stage #O estágio atualmente selecionado

#Funções
func loadStage(stageName): #Carrega e instancia o estágio alvo.
	if "TestStage" == stageName:
		stage = preload("res://assets/scenes/environment/stages/TestStage.tscn").instance()
		get_parent().get_node("Background").loadBackground("Sunlight") #Todo estágio tem um background inicial associado. No caso de "TestStage", esse Background é "Sunlight".
	#/*Adicione mais Stages...*/#
	add_child(stage)

func timeStop(): #Paraliza/Desparaliza todos os nós dentro do estágio atual.
	for node in get_children():
		node.timeStop()

#Código Inicial
func _ready():
	loadStage("TestStage") #NOTA / WIP: O estágio atual deve ser buscado de algum arquivo de save do jogo.