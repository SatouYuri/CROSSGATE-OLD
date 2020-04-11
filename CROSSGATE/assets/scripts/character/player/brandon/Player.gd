extends KinematicBody2D

#Constantes
const MOVESPEED = 160
const GRAVITY = 20
const JUMP_HEIGHT = -450
const FLOOR = Vector2(0, -1)

#Variáveis de Estado
var velocity = Vector2()

#Funções
func playAnim(anim): #Inicia, para todas as partes do corpo, a animação inserida.
	$UBODY.play(anim)
	$DBODY.play(anim)
	$LARM.play(anim)
	$RARM.play(anim)

func mirror(side): #Espelha os sprites de todas as partes do corpo a favor do lado inserido (false: direita; true: esquerda)
	$UBODY.flip_h = side
	$DBODY.flip_h = side
	$LARM.flip_h  = side
	$RARM.flip_h  = side

#Código Principal
func _ready():
	playAnim("idle")

func _physics_process(delta):
	#Movimentação: Eixo X
	if Input.is_action_pressed("CG_RIGHT"):
		mirror(false)
		velocity.x = MOVESPEED
	elif Input.is_action_pressed("CG_LEFT"):
		mirror(true)
		velocity.x = -MOVESPEED
	else:
		if is_on_floor():
			velocity.x = 0

	#Movimentação: Eixo Y
	if Input.is_action_pressed("CG_UP") and is_on_floor():
		velocity.y = JUMP_HEIGHT
	
	velocity.y = velocity.y + GRAVITY #Força da gravidade

	#Comandos finais do frame
	velocity = move_and_slide(velocity, FLOOR)