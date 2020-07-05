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
var isPlayerInsideDialogArea = false

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

func triggerDialog(): #Exemplo de diálogo (os diálogos por interação devem funcionar desta maneira, esperando que o jogador aperte a tecla de interação); triggerDialog() é uma função chamada a cada frame.
	if Input.is_action_just_pressed("CG_INTERACT"):
		if isPlayerInsideDialogArea and !getPlayerHud().isDialogRunning():
			getPlayerHud().startDialog("res://assets/dialogues/TestStage_dazuva.json", true)
		elif getPlayerHud().isDialogRunning():
			getPlayerHud().nextDialog()

func getWorld():
	return get_parent().get_parent().get_parent()

func getPlayerHud():
	return get_parent().get_parent().get_parent().get_node("Player").get_node("hud")

#Código Principal
func _physics_process(delta):
	if !stopped:
		if is_on_floor():
			#velocity.y = JUMP_HEIGHT #Quicar
			pass
		
		velocity.y = velocity.y + GRAVITY #Força da gravidade
		
		velocity = move_and_slide(velocity, FLOOR)
		
		#Teste de diálogo
		triggerDialog()

func _on_SHOOT_COOLDOWN_timeout():
	if !stopped:
		$Weapons/Ranger.shoot(SCRIPT_TYPE)
		$SHOOT_COOLDOWN.wait_time = (randi()%10 + 1)/10.0
		pass

func _on_DialogArea_body_entered(body):
	if "Player" in body.name:
		isPlayerInsideDialogArea = true

func _on_DialogArea_body_exited(body):
	if "Player" in body.name:
		isPlayerInsideDialogArea = false
