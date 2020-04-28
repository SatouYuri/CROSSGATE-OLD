extends Area2D

const SPEED = 500

var velocity = Vector2()
var direction = 1
var damage = 0
var shooter = "DEFAULT"

func set_direction(side): #Espelha o sprite a favor do lado inserido (false: direita; true: esquerda)
	$AnimatedSprite.flip_h = side
	if !side:
		direction = 1
	else:
		direction = -1

func _ready():
	#Inicializando Timer (duração da existência da bala)
	$BULLET_DISTANCE.start()
	$AnimatedSprite.play("shoot")

func _physics_process(delta):
	velocity.x = SPEED * direction * delta
	translate(velocity)

func _on_BULLET_DISTANCE_timeout():
	queue_free()

func _on_Bullet_body_entered(body):
	if body.bodyType == "ACTOR":
		body.lifepoints -= damage
		if body.lifepoints <= 0:
			body.lifepoints = 0
			body.die()
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
