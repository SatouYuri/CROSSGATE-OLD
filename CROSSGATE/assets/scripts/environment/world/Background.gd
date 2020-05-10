extends Node2D

#Constantes
const SCRIPT_TYPE = "World_BG_Root"

#Variáveis de Estado
var background #O background atualmente selecionado

#Funções
func loadBackground(backgroundName): #Carrega e instancia o background alvo.
	if "Sunlight" == backgroundName:
		background = preload("res://assets/scenes/environment/background/sunlight/SunlightBackground.tscn").instance()
	#/*Adicione mais Backgrounds...*/#
	add_child(background)

func timeStop(): #Paraliza/Desparaliza o background atual.
	for node in get_children():
		node.timeStop()