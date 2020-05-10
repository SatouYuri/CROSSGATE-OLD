extends KinematicBody2D

#Constantes
const SCRIPT_TYPE = "Enemy"
const DEAD = 0
const ALIVE = 1
const GRAVITY = 20
const JUMP_HEIGHT = -450
const FLOOR = Vector2(0, -1)

#Variáveis de Estado
var velocity = Vector2()
var actionState = ALIVE
var stopped = false
var lifepoints = 100

#Funções
func die():
	queue_free()

func timeStop(): #Paraliza/Desparaliza este inimigo.
	if !stopped:
		stopped = true
	else:
		stopped = false

#Código Principal
func _physics_process(delta):
	if !stopped:
		if is_on_floor():
			velocity.y = JUMP_HEIGHT #Quicar
		
		velocity.y = velocity.y + GRAVITY #Força da gravidade
		
		velocity = move_and_slide(velocity, FLOOR)