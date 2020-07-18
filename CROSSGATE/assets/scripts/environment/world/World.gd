extends Node2D

#Constantes
const SCRIPT_TYPE = "World_Root"

#Variáveis de Estado
var globalMousePosition
var gateList = []
var stopped = false
var curStopType = ""

#Funções
func setStopConfig(stopType):
	if !stopped:
		stopped = true
		curStopType = stopType
	elif curStopType == stopType:
		stopped = false
		curStopType = stopType

func theWorld(stopType): #Paraliza os nós dentro do mundo de acordo com a configuração de parada inserida.
	if stopType == "SKILL":
		setStopConfig(stopType)
		for node in get_children():
			node.timeStop()
	elif stopType == "DIALOG":
		setStopConfig(stopType)
		for node in get_children():
			if node.name != "Background": 
				node.timeStop()