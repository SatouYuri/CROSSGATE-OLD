extends Node2D

#Constantes
const SCRIPT_TYPE = "World_Root"

#Funções
func theWorld(time): #Paraliza todos os nós dentro do mundo pelo período de tempo inserido.
	for node in get_children():
		node.timeStop()