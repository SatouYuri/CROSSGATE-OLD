extends KinematicBody2D

#Constantes
const SCRIPT_TYPE = "Player"
const DEAD = 0
const STANDBY = 1
const AIMING = 2
const ATTACKING = 3
const SLIDING = 4
const MOVESPEED = 160
const GRAVITY = 20
const JUMP_HEIGHT = -450
const FLOOR = Vector2(0, -1)
const GATE = preload("res://assets/scenes/environment/object/dynamic/gate/Gate.tscn") #NOTA / WIP: Depois, generalizar para qualquer Gate. #Carregar o Gate na memória

#Variáveis de Estado
var velocity = Vector2()
var actionState = STANDBY
var stopped = false
var maxLifepoints = 200
var lifepoints = 100
var maxEtherpoints = 200
var etherpoints = 100
var globalMousePosition
var crossingGates = false
var timeStopInterval = 3

#Funções
func die():
	actionState = DEAD #NOTA / WIP: Depois, ajustar a função de morte.

func takeDamage(damage):
	lifepoints -= damage
	$hud.updateLifepoints()
	if lifepoints <= 0:
		lifepoints = 0
		die()

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

func getSide(): #Retorna o lado atual (-1: esquerda; 1: direita)
	if !$UBODY.flip_h:
		return 1
	else: 
		return -1

func weaponSpriteAdjust(): #Ajusta a arma atualmente selecionada à mão do personagem.
	if !actionState in [AIMING, ATTACKING]:
		return
	var s = getSide()
	if velocity.x == 0:
		if actionState == ATTACKING:
			if $LARM.get_frame() == 0:
				$Weapons/Ranger.position = Vector2(s*14, -5)
			elif $LARM.get_frame() == 1:
				$Weapons/Ranger.position = Vector2(s*12, -6)
			elif $LARM.get_frame() == 2:
				$Weapons/Ranger.position = Vector2(s*12, -5)
			return
		if actionState == AIMING:
			if $LARM.get_frame() in [0, 2]:
				$Weapons/Ranger.position = Vector2(s*14, -4)
			elif $LARM.get_frame() == 1:
				$Weapons/Ranger.position = Vector2(s*14, -3)
			elif $LARM.get_frame() == 3:
				$Weapons/Ranger.position = Vector2(s*14, -5)
			return
	else:
		if actionState == ATTACKING:
			if $LARM.get_frame() == 0:
				$Weapons/Ranger.position = Vector2(s*13,2)
			elif $LARM.get_frame() == 1:
				$Weapons/Ranger.position = Vector2(s*11,-4)
			elif $LARM.get_frame() == 2:
				$Weapons/Ranger.position = Vector2(s*13,-2)
			return
		if actionState == AIMING:
			if $LARM.get_frame() in [0, 1, 5, 6, 7, 11]:
				$Weapons/Ranger.position = Vector2(s*13, 2)
			elif $LARM.get_frame() in [2, 4, 8, 10]:
				$Weapons/Ranger.position = Vector2(s*13, 1)
			elif $LARM.get_frame() in [3, 9]:
				$Weapons/Ranger.position = Vector2(s*13, 0)
			return

func mirror(side): #Espelha os sprites de todas as partes do corpo a favor do lado inserido (false: direita; true: esquerda)
	$UBODY.flip_h = side
	$DBODY.flip_h = side
	$LARM.flip_h  = side
	$RARM.flip_h  = side
	$Weapons/Ranger.mirror(side)
	$Weapons/Ranger.position.x = abs($Weapons/Ranger.position.x)*getSide()
	$UNDERSLIDING_DETECTOR.cast_to.x = abs($UNDERSLIDING_DETECTOR.cast_to.x)*getSide()

func collisionState(actionState): #Atualiza a caixa de colisão para o caso de deslizamento.
	if actionState == SLIDING: #Se está deslizando...
		$STANDING.disabled = true
		$SLIDING.disabled = false
	else: #Se não está deslizando...
		$STANDING.disabled = false
		$SLIDING.disabled = true

func isUnderslidingPossible(): #Retorna true se for possível executar um deslizamento por baixo; retorna false, caso contrário.
	if !$UNDERSLIDING_DETECTOR.is_colliding(): 
		return true
	else:
		return false

func isStandingPossible(): #Retorna true se for possível ficar em pé (indo do estado SLIDING para qualquer outro estado que exija estar em pé); retorna false, caso contrário.
	if !$UNDERSLIDING_CEILING_DETECTOR.is_colliding(): 
		return true
	else:
		return false

func isUndersliding(): #Retorna true se estiver deslizando e não for possível ficar em pé; retorna false, caso contrário.
	if !isStandingPossible() and actionState == SLIDING:
		return true
	else:
		return false

func theWorld(): #Paraliza o mundo. Essa função deve ser chamada ao ativar o CROSSGATE.
	get_parent().theWorld()

func timeStop(): #Paraliza/Desparaliza essa cena. Essa função deve ser chamada pelo nó pai "World.tscn".
	if !stopped:
		stopped = true
		for t in $Timers.get_children():
			t.paused = true
		$UBODY.stop()
		$LARM.stop()
		$RARM.stop()
		$DBODY.stop()
		$Weapons/Ranger/AnimatedSprite.stop()
	else:
		stopped = false
		for t in $Timers.get_children():
			t.paused = false
		$UBODY.play()
		$LARM.play()
		$RARM.play()
		$DBODY.play()
		$Weapons/Ranger/AnimatedSprite.play()

#Código Inicial
func _ready():
	#Configurando máscara TIMESTOP_MASK (Se a resolução for atualizada, reinicialize estes valores)
	$TIMESTOP_MASK.margin_top = -(get_viewport().size.y/2)*1.2
	$TIMESTOP_MASK.margin_right = +(get_viewport().size.x/2)*1.2
	$TIMESTOP_MASK.margin_bottom = +(get_viewport().size.y/2)*1.2
	$TIMESTOP_MASK.margin_left = -(get_viewport().size.x/2)*1.2
	#Atualizando o HUD
	$hud.update()

#Código Principal
func _input(event):
	if stopped and event is InputEventMouseButton:
		if event.is_action_pressed("CG_L_CLICK"): #Inicializar um Gate e adicioná-lo ao mundo, no nó "Background".
			if get_parent().gateList.size() < 2:
				var gate = GATE.instance()
				get_parent().gateList.append(gate)
				get_parent().get_node("Background").add_child(gate)
				gate.position = get_global_mouse_position()
		elif event.is_action_pressed("CG_R_CLICK") and get_parent().gateList.size() > 0: #Excluir e desinstanciar os Gates.
			for g in get_parent().gateList:
				g.queue_free()
			get_parent().gateList = []

func _physics_process(delta):
	if !stopped: #Se o tempo não estiver parado...
		#Ajustando a máscara TIMESTOP_MASK (tempo voltando a correr)...
		if $TIMESTOP_MASK.modulate.a > 0:
			$TIMESTOP_MASK.modulate.a -= 0.1
		#Ajustando o círculo do éter CROSSGATE (tempo voltando a correr)...
		if $AetherCircle.modulate.a > 0:
			$AetherCircle.modulate.a -= 0.05
		if $AetherCircle.scale.x > 0:
			$AetherCircle.scale.x -= 0.01
		if $AetherCircle.scale.y > 0:
			$AetherCircle.scale.y -= 0.01
		
		#Movimentação: Eixo X
		if Input.is_action_pressed("CG_RIGHT") and !isUndersliding():
			mirror(false)
			if actionState == SLIDING:
				velocity.x = MOVESPEED*2
			else:
				velocity.x = MOVESPEED
		elif Input.is_action_pressed("CG_LEFT") and !isUndersliding():
			mirror(true)
			if actionState == SLIDING:
				velocity.x = -MOVESPEED*2
			else:
				velocity.x = -MOVESPEED
		elif actionState != SLIDING:# and is_on_floor():
			velocity.x = 0
	
		#Movimentação: Eixo Y
		if Input.is_action_pressed("CG_UP") and is_on_floor() and !isUndersliding():
			velocity.y = JUMP_HEIGHT
			if actionState == SLIDING:
				actionState = STANDBY
				$Timers/SLIDING_COOLDOWN.start()
			
		velocity.y = velocity.y + GRAVITY #Força da gravidade
		
	else: #Se o tempo estiver parado...
		#Ajustando a máscara TIMESTOP_MASK (tempo parando)...
		if $TIMESTOP_MASK.modulate.a < 1:
			$TIMESTOP_MASK.modulate.a += 0.1
		#Ajustando o círculo do éter CROSSGATE (tempo parando)...
		if $AetherCircle.modulate.a < 1:
			$AetherCircle.modulate.a += 0.1
		if $AetherCircle.scale.x < 0.5:
			$AetherCircle.scale.x += 0.1
		if $AetherCircle.scale.y < 0.5:
			$AetherCircle.scale.y += 0.1

	#Animações
	if actionState != SLIDING: #Se não está deslizando...
		weaponSpriteAdjust()
		if !stopped:
			if actionState == STANDBY:
				$Weapons/Ranger.visible = false
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
			if Input.is_action_pressed("CG_SHOOT") and $Timers/SHOT_COOLDOWN.time_left == 0: #Disparo
				$Weapons/Ranger.visible = true
				$Timers/SHOT_COOLDOWN.start()
				if actionState != ATTACKING:
					if velocity.x == 0:
						specifiedPlayAnim("idle_shoot", "LARM") #ASSINCRONIA: Resolução em _on_LARM_animation_finished()
					else:
						specifiedPlayAnim("run_shoot", "LARM") #ASSINCRONIA: Resolução em _on_LARM_animation_finished()
					$Weapons/Ranger/AnimatedSprite.play("shoot") #NOTA / WIP: Depois, generalizar para qualquer arma...
					actionState = ATTACKING
					$Weapons/Ranger.shoot("Player")
			
			if Input.is_action_pressed("CG_DOWN") and $Timers/SLIDING_COOLDOWN.time_left == 0 and isUnderslidingPossible() and is_on_floor(): #Slide Start
				if actionState != SLIDING:
					if velocity.x != 0:
						$Weapons/Ranger.visible = false
						playAnim("slide")
						actionState = SLIDING
						$Timers/SLIDING.start()
		
	else: #Se está deslizando...
		if !stopped:
			if is_on_wall(): #Se está colidindo com uma parede...
				$Timers/SLIDING.stop()
				actionState = STANDBY
			else: #Se não está colidindo com uma parede...
				if !isStandingPossible():
					$Timers/SLIDING.stop()
				else:
					if $Timers/SLIDING.is_stopped():
						actionState = STANDBY
						$Timers/SLIDING_COOLDOWN.start()
	
	#CROSSGATE
	if Input.is_action_just_pressed("CG_GATE"): #NOTA / WIP: Ajustar para parar o tudo que for pertinente...
		if !stopped: 
			if get_parent().gateList.size() > 0:
				for g in get_parent().gateList:
					g.gateClose()
			else:
				theWorld()
				$TIMESTOP_COUNTDOWN.wait_time = timeStopInterval # NOTA / WIP : O intervalo de tempo depende do tipo de Gate
				$TIMESTOP_COUNTDOWN.start()
		else:
			theWorld()
			$TIMESTOP_COUNTDOWN.stop()
		
	#Comandos finais do frame
	collisionState(actionState)
	if !stopped:
		velocity = move_and_slide(velocity, FLOOR)

func _on_LARM_animation_finished():
	if '_shoot' in $LARM.animation and !'_aiming' in $LARM.animation: #Se a animação de ataque acabou...
		$Weapons/Ranger/AnimatedSprite.play("aiming") #NOTA: Depois, generalizar para qualquer arma...
		actionState = AIMING
		$Timers/AIMING.start() #COUNTDOWN: Resolução em _on_AIMING_timeout()

func _on_AIMING_timeout():
	if isStandingPossible():
		actionState = STANDBY

func _on_SLIDING_timeout():
	if isStandingPossible():
		$Timers/SLIDING.stop()
		actionState = STANDBY
		$Timers/SLIDING_COOLDOWN.start()

func _on_TIMESTOP_COUNTDOWN_timeout(): #Tempo voltando a correr (timeout da pausa no tempo atingido)...
	if stopped:
		theWorld()
