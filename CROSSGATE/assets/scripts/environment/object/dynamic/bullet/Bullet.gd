extends Area2D

#Constantes
const SCRIPT_TYPE = "DynamicObject"
const SPEED = 500

#Variáveis de Estado
var velocity = Vector2()
var direction = 1
var damage = 0
var shooter = "DEFAULT"
var stopped = false
var crossingGates = false

#Funções
func set_direction(side): #Espelha o sprite a favor do lado inserido (false: direita; true: esquerda)
	$AnimatedSprite.flip_h = side
	if !side:
		direction = 1
	else:
		direction = -1

func timeStop():
	if !stopped:
		stopped = true
	else:
		stopped = false
	$BULLET_DISTANCE.paused = stopped

#Código Inicial
func _ready():
	#Inicializando Timer (duração da existência da bala)
	$BULLET_DISTANCE.start()
	$AnimatedSprite.play("shoot")

#Código Principal
func _physics_process(delta):
	if !stopped:
		velocity.x = SPEED * direction * delta
		translate(velocity)

func _on_BULLET_DISTANCE_timeout():
	queue_free()

func _on_Bullet_body_entered(body):
	if (body.SCRIPT_TYPE == "Enemy") or (body.SCRIPT_TYPE == "Player" and shooter != "Player"):
		body.takeDamage(damage)
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	#queue_free()
	pass
