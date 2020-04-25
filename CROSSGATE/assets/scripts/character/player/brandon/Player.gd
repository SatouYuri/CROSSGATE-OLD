extends KinematicBody2D

#Constantes
const STANDBY = 0
const AIMING = 1
const ATTACKING = 2
const MOVESPEED = 160
const GRAVITY = 15#20
const JUMP_HEIGHT = -450
const FLOOR = Vector2(0, -1)

#Variáveis de Estado
var velocity = Vector2()
var actionState = STANDBY

#Funções
func bodyLayerAdjust(anim): #Configura o valor de z-index em cada parte individual do corpo.
	if('idle' in anim):
		$UBODY.z_index = 3
		$DBODY.z_index = 2
		$LARM.z_index  = 2
		$RARM.z_index  = 2
	elif('run' in anim):
		$UBODY.z_index = 3
		$DBODY.z_index = 2
		$LARM.z_index  = 1
		$RARM.z_index  = 4

func playAnim(anim): #Inicia, para todas as partes do corpo, a animação inserida.
	bodyLayerAdjust(anim) #configura o z-index, dada a animação inserida.
	$UBODY.play(anim)
	$DBODY.play(anim)
	$LARM.play(anim)
	$RARM.play(anim)

func specifiedPlayAnim(anim, target): #[USO APENAS PARA ANIMAÇÕES RÁPIDAS/NÃO-CONTÍNUAS/ASSÍNCRONAS/PRÉ-DESSINCRONIZAÇÃO] Inicia, para a parte do corpo alvo, a animação inserida. Certifique-se de resincronizar a parte do corpo alvo.
	bodyLayerAdjust(anim) #configura o z-index, dada a animação inserida.
	if('LARM' == target):
		$LARM.play(anim)
	elif('RARM' == target):
		$RARM.play(anim)
	elif('UBODY' == target):
		$UBODY.play(anim)
	elif('DBODY' == target):
		$DBODY.play(anim)

func synchronizedPlayAnim(anim, target, synchroFrame): #[USO APENAS PARA ANIMAÇÕES CONTÍNUAS/PÓS-DESSINCRONIZAÇÃO] Inicia, para a parte do corpo alvo, a animação inserida a partir do frame 'synchroFrame'.
	bodyLayerAdjust(anim) #configura o z-index, dada a animação inserida.
	if('LARM' == target):
		$LARM.play(anim)
		$LARM.set_frame(synchroFrame)
	elif('RARM' == target):
		$RARM.play(anim)
		$RARM.set_frame(synchroFrame)
	elif('UBODY' == target):
		$UBODY.play(anim)
		$UBODY.set_frame(synchroFrame)
	elif('DBODY' == target):
		$DBODY.play(anim)
		$DBODY.set_frame(synchroFrame)

func mirror(side): #Espelha os sprites de todas as partes do corpo a favor do lado inserido (false: direita; true: esquerda)
	$UBODY.flip_h = side
	$DBODY.flip_h = side
	$LARM.flip_h  = side
	$RARM.flip_h  = side

#Código Principal
func _physics_process(delta):
	#Movimentação: Eixo X
	if Input.is_action_pressed("CG_RIGHT"):
		mirror(false)
		velocity.x = MOVESPEED
	elif Input.is_action_pressed("CG_LEFT"):
		mirror(true)
		velocity.x = -MOVESPEED
	elif is_on_floor():
		velocity.x = 0

	#Movimentação: Eixo Y
	if Input.is_action_pressed("CG_UP") and is_on_floor():
		velocity.y = JUMP_HEIGHT
	
	velocity.y = velocity.y + GRAVITY #Força da gravidade

	#Animações
	if actionState == STANDBY:
		if is_on_floor():
			if velocity.x == 0:
				playAnim("idle")
			else:
				playAnim("run")
		else:
			if velocity.y < 0: #Se está subindo...
				if velocity.x == 0:
					playAnim("idle_jump")
				else:
					playAnim("run_jump")
			elif velocity.y > 0: #Se está descendo...
				if velocity.x == 0:
					playAnim("idle_fall")
				else:
					playAnim("run_fall")
	elif actionState == AIMING:
		if is_on_floor():
			#Sincronizando os braços com o corpo...
			var synchroFrame = $UBODY.get_frame()
			$DBODY.set_frame(synchroFrame)
			$LARM.set_frame(synchroFrame)
			$RARM.set_frame(synchroFrame)
			if velocity.x == 0:
				playAnim("idle_shoot_aiming")
			else:
				playAnim("run_shoot_aiming")
		else:
			if velocity.y < 0: #Se está subindo...
				if velocity.x == 0:
					playAnim("idle_jump")
					specifiedPlayAnim("idle_air_shoot_aiming", "LARM")
				else:
					playAnim("run_jump")
					specifiedPlayAnim("run_air_shoot_aiming", "LARM")
			elif velocity.y > 0: #Se está descendo...
				if velocity.x == 0:
					playAnim("idle_fall")
					specifiedPlayAnim("idle_air_shoot_aiming", "LARM")
				else:
					playAnim("run_fall")
					specifiedPlayAnim("run_air_shoot_aiming", "LARM")

	#Ações
	if Input.is_action_pressed("CG_SHOOT"):
		if actionState != ATTACKING:
			if velocity.x == 0:
				specifiedPlayAnim("idle_shoot", "LARM") #ASSINCRONIA: Resolução em _on_LARM_animation_finished()
			else:
				specifiedPlayAnim("run_shoot", "LARM") #ASSINCRONIA: Resolução em _on_LARM_animation_finished()
			actionState = ATTACKING
			#shoot()

	#Comandos finais do frame
	velocity = move_and_slide(velocity, FLOOR)

func _on_LARM_animation_finished():
	if '_shoot' in $LARM.animation and !'_aiming' in $LARM.animation: #Se a animação de ataque acabou...
		actionState = AIMING
		$Timers/AIMING.start() #COUNTDOWN: Resolução em _on_AIMING_timeout()

func _on_AIMING_timeout():
	actionState = STANDBY
