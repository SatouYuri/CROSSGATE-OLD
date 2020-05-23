extends Node2D

#Constantes
const SCRIPT_TYPE = "World_Root"

#Variáveis de Estado
var globalMousePosition
var gateList = []

#Funções
func theWorld(time): #Paraliza todos os nós dentro do mundo pelo período de tempo inserido.
	for node in get_children():
		node.timeStop()