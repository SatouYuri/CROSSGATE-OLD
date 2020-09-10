extends Node2D

#Constantes
const SCRIPT_TYPE = "Stage"

#Funções
func timeStop(): #Paraliza/Desparaliza todos os nós dentro deste estágio.
	for node in get_children():
		node.timeStop()