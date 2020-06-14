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
var maxLifepoints = 200
var lifepoints = 100

#Funções
func die():
	queue_free()

func takeDamage(damage):
	lifepoints -= damage
	if lifepoints <= 0:
		lifepoints = 0
		die()

func timeStop(): #Paraliza/Desparaliza este inimigo.
	if !stopped:
		stopped = true
	else:
		stopped = false

#Código Principal
func _physics_process(delta):
	if !stopped:
		if is_on_floor():
			#velocity.y = JUMP_HEIGHT #Quicar
			pass
		
		velocity.y = velocity.y + GRAVITY #Força da gravidade
		
		velocity = move_and_slide(velocity, FLOOR)

func _on_SHOOT_COOLDOWN_timeout():
	if !stopped:
		$Weapons/Ranger.shoot(SCRIPT_TYPE)
		$SHOOT_COOLDOWN.wait_time = (randi()%10 + 1)/10.0
