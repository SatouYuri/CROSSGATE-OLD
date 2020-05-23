extends StaticBody2D

#Constantes
const SCRIPT_TYPE = "StaticObject"

#Variáveis de Estado
var stopped = false

#Funções
func timeStop(): #Paraliza/Desparaliza este objeto.
	if !stopped:
		stopped = true
	else:
		stopped = false
