extends Node2D

#Constantes
const SCRIPT_TYPE = "Stage"
const DEFAULT_AMPLITUDE = 0.25
const DEFAULT_FREQUENCY = 20

#Funções
func timeStop(): #Paraliza/Desparaliza todos os nós dentro deste estágio.
	for node in get_children():
		node.timeStop()