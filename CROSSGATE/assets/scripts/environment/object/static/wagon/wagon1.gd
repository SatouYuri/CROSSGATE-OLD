extends StaticBody2D

#Constantes
const SCRIPT_TYPE = "StaticObject"
const pConst = preload("res://assets/util/PROJECT_CONSTANTS.gd")

#Variáveis de Estado
var stopped = false

#Código Inicial
func _ready():
	#Ajustando o z-index
	$Exterior.z_index = pConst.WAGON_Z_INDEX
	$Interior.z_index = pConst.WAGON_INTERIOR_Z_INDEX

#Funções
func timeStop(): #Paraliza/Desparaliza este objeto.
	if !stopped:
		stopped = true
	else:
		stopped = false

func getPlayer():
	return get_parent().get_parent().get_parent().get_node("Player")

#Código Principal
func _physics_process(delta):
	#Mostrar o interior do vagão.
	if getPlayer() in $InteractionArea.get_overlapping_bodies():
		if $Exterior.modulate.a >= 0:
			$Exterior.modulate.a -= 0.05
		else:
			$Exterior.modulate.a = 0.0
	else:
		if $Exterior.modulate.a <= 1.0:
			$Exterior.modulate.a += 0.05
		else:
			$Exterior.modulate.a = 1.0
