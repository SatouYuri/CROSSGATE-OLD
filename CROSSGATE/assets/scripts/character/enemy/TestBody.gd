extends KinematicBody2D

#Constantes
const DEAD = 0
const ALIVE = 1

#Variáveis de Estado
var actionState = ALIVE
var bodyType = "ACTOR"
var lifepoints = 100

func die():
	queue_free()