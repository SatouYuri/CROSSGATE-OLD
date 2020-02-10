extends KinematicBody2D

const MOVESPEED = 160
const GRAVITY = 20
const JUMP_HEIGHT = -450
const FLOOR = Vector2(0, -1)
const FADEFACTOR = 0.1
const BULLET = preload("res://Assets/Scenes/Bullet.tscn") #Carregar a bullet na memória
const DARKBALL = preload("res://Assets/Scenes/Portal.tscn") #Carregar a darkball na memória
const SOUNDFX = preload("res://Assets/Scenes/SoundFX.tscn")
const SMASH_DAMAGE = 400

var velocity = Vector2()
var on_ground = false
var is_attacking = false
var is_dashing = false
var is_aiming = false
var aimarrow_visible = false
var is_crossing_gates = false
var darkball_generated = false
var darkball_thrown = false
var just_landed_check = false
var hand_busy = false
var total_lifepoints = 200
var lifepoints = total_lifepoints
var lifepoints_changing = 0 #Em relação à barra de vida, 1 se estiver ganhando HP, -1 se estiver perdendo e 0 caso contrário.
var damage = 10
var is_dead = false
var DarkBall = null
var throwFactor = 1
var superthrow_active = false
var gateLifeTime = 10
var dashReady = true
var dashCooldownTime = 1
var smashTargetDetected = false

func dead():
	is_dead = true
	velocity = Vector2(0, 0)
	$UPBODY_AnimatedSprite.play("Dead")
	$DOWNBODY_AnimatedSprite.play("Static")
	$RIGHTHAND_AnimatedSprite.play("Static")
	
func getSpriteSide(): #Retorna false se o personagem estiver olhando para direita; true, caso contrário.
	return $UPBODY_AnimatedSprite.flip_h
	
func aimArrowThrowFeedbackReset():
	superthrow_active = false
	$AIMARROW/AIMARROW_BACKMETER_Sprite.modulate.r = 0
	$AIMARROW/AIMARROW_BACKMETER_Sprite.modulate.b = 0
	$AIMARROW/AIMARROW_SUPERTHROW_Timer.stop()
	$SoundFX/EnergyFlow.stop()
	throwFactor = 1
	gateLifeTime = 10
	
func setAimAngle(angle):
	$AIMARROW.rotation_degrees = angle
	
func getAimAngle():
	return $AIMARROW.rotation_degrees
	
func dash(dashtime): #dashtime é o tempo do dash em segundos
	if getSpriteSide() == false:
		velocity = Vector2(3*MOVESPEED, 0)
	else:
		velocity = Vector2(-3*MOVESPEED, 0)
		
	$UPBODY_AnimatedSprite.play("Smash")
	$DOWNBODY_AnimatedSprite.play("Smash")
	$RIGHTHAND_AnimatedSprite.play("Smash")
		
	$DASH_Timer.wait_time = dashtime
	$DASH_Timer.start()
	
func _ready():
	$Interface/HUD/HP.max_value = lifepoints
	$Interface/HUD/HP.value = lifepoints
	$Interface/HUD/HP_STEPDAMAGE.max_value = lifepoints
	$Interface/HUD/HP_STEPDAMAGE.value = lifepoints

func _physics_process(delta):
	if is_dead == false:
		#Movimento: Eixo X
		if !is_dashing:
			if Input.is_action_pressed("ui_right"):
				#Checando se o personagem não está mirando
				if is_aiming == false:
					velocity.x = MOVESPEED
					if on_ground == true && is_attacking == false:
						$UPBODY_AnimatedSprite.play("Walk")
						$DOWNBODY_AnimatedSprite.play("Walk")
						if hand_busy == false:
							$RIGHTHAND_AnimatedSprite.play("Walk")
					
					if $UPBODY_AnimatedSprite.flip_h == true && $DOWNBODY_AnimatedSprite.flip_h == true && $RIGHTHAND_AnimatedSprite.flip_h == true:
						$UPBODY_AnimatedSprite.flip_h = false
						$RIGHTHAND_AnimatedSprite.flip_h = false
						$DOWNBODY_AnimatedSprite.flip_h = false
					
					if sign($Position2D.position.x) == -1:
						$Position2D.position.x *= -1
						$DARKBALL_SPOT_Position2D.position.x *= -1
						$OBJECT_DETECTION_Area2D/CollisionShape2D.position.x *= -1
						
				else: #Caso o personagem esteja mirando...
					#Registrando que a AimArrow está visível
					aimarrow_visible = true
				
					#Invertendo Sprites, se necessário...
					if $UPBODY_AnimatedSprite.flip_h && $DOWNBODY_AnimatedSprite.flip_h && $RIGHTHAND_AnimatedSprite.flip_h:
						$UPBODY_AnimatedSprite.flip_h = false
						$RIGHTHAND_AnimatedSprite.flip_h = false
						$DOWNBODY_AnimatedSprite.flip_h = false
					
					if sign($Position2D.position.x) == -1:
						$Position2D.position.x *= -1
						$DARKBALL_SPOT_Position2D.position.x *= -1
						$OBJECT_DETECTION_Area2D/CollisionShape2D.position.x *= -1
						
					#Ajustando a AimArrow
					$AIMARROW.visible = true
					$AIMARROW/AIMARROW_AnimatedSprite.play("EnergyFlow")
					if Input.is_action_pressed("ui_up"): #Caso diagonal 1
						setAimAngle(45)
					elif Input.is_action_pressed("ui_down"): #Caso diagonal 2
						setAimAngle(135)
					elif !Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down"): #Caso retilíneo
						setAimAngle(90)
						
					#Invertendo a posição da DarkBall, se necessário...
					if darkball_generated && $DARKBALL_SPOT_Position2D.position.x < 0:
						if !darkball_thrown:
							DarkBall.position.x = get_parent().get_node("Player").position.x + $DARKBALL_SPOT_Position2D.position.x
				
			elif Input.is_action_pressed("ui_left"):
				#Checando se o personagem não está mirando
				if is_aiming == false:
					velocity.x = -MOVESPEED
					if on_ground == true && is_attacking == false:
						$UPBODY_AnimatedSprite.play("Walk")
						$DOWNBODY_AnimatedSprite.play("Walk")
						if hand_busy == false:
							$RIGHTHAND_AnimatedSprite.play("Walk")
					
					if $UPBODY_AnimatedSprite.flip_h == false && $DOWNBODY_AnimatedSprite.flip_h == false && $RIGHTHAND_AnimatedSprite.flip_h == false:
						$UPBODY_AnimatedSprite.flip_h = true
						$RIGHTHAND_AnimatedSprite.flip_h = true
						$DOWNBODY_AnimatedSprite.flip_h = true
					
					if sign($Position2D.position.x) == 1:
						$Position2D.position.x *= -1
						$DARKBALL_SPOT_Position2D.position.x *= -1
						$OBJECT_DETECTION_Area2D/CollisionShape2D.position.x *= -1
					
				else: #Caso o personagem esteja mirando...
					#Registrando que a AimArrow está visível
					aimarrow_visible = true
					
					#Invertendo Sprites, se necessário...
					if !$UPBODY_AnimatedSprite.flip_h && !$DOWNBODY_AnimatedSprite.flip_h && !$RIGHTHAND_AnimatedSprite.flip_h:
						$UPBODY_AnimatedSprite.flip_h = true
						$RIGHTHAND_AnimatedSprite.flip_h = true
						$DOWNBODY_AnimatedSprite.flip_h = true
					
					if sign($Position2D.position.x) == 1:
						$Position2D.position.x *= -1
						$DARKBALL_SPOT_Position2D.position.x *= -1
						$OBJECT_DETECTION_Area2D/CollisionShape2D.position.x *= -1
						
					#Ajustando a AimArrow
					$AIMARROW.visible = true
					$AIMARROW/AIMARROW_AnimatedSprite.play("EnergyFlow")
					if Input.is_action_pressed("ui_up"): #Caso diagonal 1
						setAimAngle(-45)
					elif Input.is_action_pressed("ui_down"): #Caso diagonal 2
						setAimAngle(-135)
					elif !Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down"): #Caso retilíneo
						setAimAngle(-90)
					
					#Invertendo a posição da DarkBall, se necessário...
					if darkball_generated && $DARKBALL_SPOT_Position2D.position.x > 0:
						if !darkball_thrown:
							DarkBall.position.x = get_parent().get_node("Player").position.x + $DARKBALL_SPOT_Position2D.position.x
			else:
				velocity.x = 0
				if on_ground == true && is_attacking == false:
					$UPBODY_AnimatedSprite.play("Idle")
					$DOWNBODY_AnimatedSprite.play("Idle")
					if hand_busy == false:
						$RIGHTHAND_AnimatedSprite.play("Idle")
		
		#Movimento: Eixo Y
		if Input.is_action_pressed("ui_up"):
			#Checando se o personagem não está mirando
			if is_aiming == false:
				if on_ground == true:
					velocity.y = JUMP_HEIGHT
					on_ground == false
			else: #Caso o personagem esteja mirando...
				#Registrando que a AimArrow está visível
				aimarrow_visible = true
				
				#Ajustando a AimArrow
				$AIMARROW.visible = true
				$AIMARROW/AIMARROW_AnimatedSprite.play("EnergyFlow")
				if Input.is_action_pressed("ui_left") == false && Input.is_action_pressed("ui_right") == false: #Caso retilíneo
					setAimAngle(0)
		
		#Ações
		if Input.is_action_pressed("ui_select") && !is_attacking && !is_aiming && !is_dashing:				
			is_attacking = true
			var Bullet = BULLET.instance()
			Bullet.damage = 10
			Bullet.shooter = "Player"
			if $UPBODY_AnimatedSprite.flip_h == true && $DOWNBODY_AnimatedSprite.flip_h == true && $RIGHTHAND_AnimatedSprite.flip_h == true:
				Bullet.set_bullet_direction(-1)
				
			$UPBODY_AnimatedSprite.play("Shooting")
			if hand_busy == false && on_ground == true:
				$RIGHTHAND_AnimatedSprite.play("Shooting")
			if velocity == Vector2(0, 0):
				$DOWNBODY_AnimatedSprite.play("Static")
			
			get_parent().add_child(Bullet) #Adicionando a bullet como nó filho de TrainStage
			Bullet.position = $Position2D.global_position
		
		if Input.is_action_just_pressed("c_button") && !is_dashing:
			if darkball_thrown:
				aimArrowThrowFeedbackReset()
				
				#Abrindo o portal no mundo
				DarkBall.openGateWithTimer(gateLifeTime)
				
				#Adicionando o portal na gateList do mundo
				get_parent().gateList.append(DarkBall)
				# LINHA ÚTIL: print(get_parent().gateList[get_parent().gateList.find(DarkBall)].position.x)
				
				#Outra DarkBall já pode ser instanciada para arremessar:
				darkball_thrown = false 
				darkball_generated = false
				
			else:
				if is_aiming: #Se está mirando...
					if hand_busy == false:
						hand_busy = true
						$RIGHTHAND_AnimatedSprite.play("Throw")
						#Timer para prevenção contra crashes de animação
						$RIGHTHAND_AnimatedSprite/ANTI_ANIM_CRASH_Timer.start()
						
						darkball_thrown = true
						if getAimAngle() == 135:
							DarkBall.ballInitialize(true, Vector2(throwFactor*500, throwFactor*10))
						elif getAimAngle() == 90:
							DarkBall.ballInitialize(true, Vector2(throwFactor*500, throwFactor*-250))
						elif getAimAngle() == 45:
							DarkBall.ballInitialize(true, Vector2(throwFactor*500, throwFactor*-500))
						elif getAimAngle() == 0:
							DarkBall.ballInitialize(true, Vector2(0, throwFactor*-500))
						elif getAimAngle() == -45:
							DarkBall.ballInitialize(true, Vector2(throwFactor*-500, throwFactor*-500))
						elif getAimAngle() == -90:
							DarkBall.ballInitialize(true, Vector2(throwFactor*-500, throwFactor*-250))
						elif getAimAngle() == -135:
							DarkBall.ballInitialize(true, Vector2(throwFactor*-500, throwFactor*10))
							
				#else: #Se não estiver mirando... (Nota: Usar esse trecho do código para chamar o Tesseract de Zan, na Save Room.)
				#	if hand_busy == false:
				#		hand_busy = true
				#		$RIGHTHAND_AnimatedSprite.play("Throw")
				#		#Timer para prevenção contra crashes de animação
				#		$RIGHTHAND_AnimatedSprite/ANTI_ANIM_CRASH_Timer.start()
						
		if Input.is_action_pressed("shift_button") && !is_dashing:
			is_aiming = true			
			if on_ground == true && is_attacking == false:
				velocity.x = 0
				$UPBODY_AnimatedSprite.play("Idle")
				$DOWNBODY_AnimatedSprite.play("Idle")
				if hand_busy == false:
					$RIGHTHAND_AnimatedSprite.play("Idle")
				
			#Gerando a DARKBALL, se necessário...
			if !darkball_generated: #Se a DarkBall não foi gerada
				DarkBall = DARKBALL.instance()
				DarkBall.ballInitialize(false, 0)	
					
				get_parent().add_child(DarkBall) #Adicionando a DarkBall como nó filho de TrainStage
				if !darkball_thrown:
					DarkBall.position = $DARKBALL_SPOT_Position2D.global_position
				
				darkball_generated = true
				
			else: #Se a DarkBall já foi gerada
				pass
				
			#Atualizando a variável aimarrow_visible, caso left, right ou up não estiverem sendo pressionados
			if !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_up"):
				aimarrow_visible = false
				aimArrowThrowFeedbackReset()
				
		if Input.is_action_just_released("shift_button") && is_aiming == true:
			is_aiming = false
			aimarrow_visible = false
			aimArrowThrowFeedbackReset()
			
			#Desligando a AimArrow
			$AIMARROW.visible = false
			$AIMARROW/AIMARROW_AnimatedSprite.stop()
			
			#Desinstanciando a DarkBall
			if darkball_generated && !darkball_thrown:
				darkball_generated = false
				DarkBall.queue_free()
				DarkBall = null
			
			#Ajustes finais nas variáveis
			darkball_generated = false
			darkball_thrown = false
		
		if Input.is_action_just_pressed("x_button") && !is_dashing && dashReady == true:
			is_dashing = true
			dash(1)
			
			#Desligando outros mecanismos para iniciar o Dash
			hand_busy = false
			is_aiming = false
			aimarrow_visible = false
			aimArrowThrowFeedbackReset()
			
			#Desligando a AimArrow
			$AIMARROW.visible = false
			$AIMARROW/AIMARROW_AnimatedSprite.stop()
			
			#Desinstanciando a DarkBall
			if darkball_generated && !darkball_thrown:
				darkball_generated = false
				DarkBall.queue_free()
				DarkBall = null
			
			#Ajustes finais nas variáveis
			darkball_generated = false
			darkball_thrown = false
	
	if !is_dashing:			
		velocity.y = velocity.y + GRAVITY #GRAVIDADE ATUANDO
		
	#Verificações finais
		#Batida contra um objeto/parede ao usar o Dash
	if is_dashing && is_on_wall():
		$DASH_Timer.wait_time = 0.0001 #Provocando a função timeout do DASH_Timer
		$DASH_Timer.start()
		for i in $OBJECT_DETECTION_Area2D.get_overlapping_bodies():
			if "Enemy" in i.name: #Dano do Smash
				i.lifepoints -= SMASH_DAMAGE
				
				#Som de feedback de acerto
				var SoundFX = SOUNDFX.instance()
				i.add_child(SoundFX)
				SoundFX.playfx("Pain")
				
				if i.lifepoints <= 0:
					i.lifepoints = 0
					i.dead()
	
		#Cria o feedback de arremesso da AimArrow
	if aimarrow_visible:
		if $AIMARROW/AIMARROW_BACKMETER_Sprite.modulate.r < 1:
			$AIMARROW/AIMARROW_BACKMETER_Sprite.modulate.r += 0.01
			$AIMARROW/AIMARROW_BACKMETER_Sprite.modulate.b += 0.01
		else:
			if !superthrow_active:
				superthrow_active = true
				$AIMARROW/AIMARROW_SUPERTHROW_Timer.start()
	
		#Ajusta a DarkBall em translações aéreas
	if darkball_generated && !darkball_thrown:
		DarkBall.position = $DARKBALL_SPOT_Position2D.global_position
					
		#Prevenção contra erros envolvendo desincronia no sprite do jogador
	if $RIGHTHAND_AnimatedSprite.animation == "Idle" && $UPBODY_AnimatedSprite.animation == "Idle" && $DOWNBODY_AnimatedSprite.animation == "Idle":
		if $RIGHTHAND_AnimatedSprite.get_frame() != $UPBODY_AnimatedSprite.get_frame():
			$RIGHTHAND_AnimatedSprite.set_frame($UPBODY_AnimatedSprite.get_frame())
	
		#Modo Standby ao mirar com a DarkBall
	if is_aiming == true && !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_up"):
		$AIMARROW.visible = false
		$AIMARROW/AIMARROW_AnimatedSprite.stop()
	
	if $Interface/HUD/HP.value > lifepoints || $Interface/HUD/HP_STEPDAMAGE.value > lifepoints:
		#Atualizando a barra de vida
		$Interface/HUD/HP.value = lifepoints
		#Atualizando a barra de STEPDAMAGE
		lifepoints_changing = -1
		$Interface/FADE_Timer.start()
	elif $Interface/HUD/HP.value < lifepoints || $Interface/HUD/HP_STEPDAMAGE.value < lifepoints:
		#Atualizando a barra de vida
		$Interface/HUD/HP.value = lifepoints
		#Atualizando a barra de STEPDAMAGE
		lifepoints_changing = +1
		$Interface/FADE_Timer.start()
	elif $Interface/HUD/HP.value == lifepoints && $Interface/HUD/HP_STEPDAMAGE.value == lifepoints:
		lifepoints_changing = 0
		
	#Impedindo que o HP seja inválido
	if lifepoints > total_lifepoints:
		lifepoints = total_lifepoints
	elif lifepoints < 0:
		lifepoints = 0
		
	if is_dead == false:
		if is_on_floor():
			just_landed_check = on_ground
			if on_ground == false: #Evita o bug que faz as animações travarem/freezarem: "Se o personagem ACABOU de encostar no chão, cancele o ataque atual (is_attacking = false) antes de definir que ele agora está no chão."
				is_attacking = false
			on_ground = true
		else:
			on_ground = false
			#if is_attacking == false:
			if !is_dashing:
				if velocity.y < 0:
					$UPBODY_AnimatedSprite.play("Jump")
					$DOWNBODY_AnimatedSprite.play("Jump")
					if hand_busy == false:
						$RIGHTHAND_AnimatedSprite.play("Jump")
				else:
					$UPBODY_AnimatedSprite.play("Fall")
					$DOWNBODY_AnimatedSprite.play("Fall")
					if hand_busy == false:	
						$RIGHTHAND_AnimatedSprite.play("Fall")
	
	velocity = move_and_slide(velocity, FLOOR)

func _on_UPBODY_AnimatedSprite_animation_finished():
	is_attacking = false
	if is_dead == true:
		get_parent().get_node("Soundtrack").stop()
		get_tree().change_scene("res://Assets/Scenes/TitleScreen.tscn")
	else:
		if is_dashing:
			$UPBODY_AnimatedSprite.play("Dashing")

func _on_RIGHTHAND_AnimatedSprite_animation_finished():
	hand_busy = false
	$RIGHTHAND_AnimatedSprite/ANTI_ANIM_CRASH_Timer.stop()
	#Evitar desincronização de sprites com a RIGHTHAND
	if $UPBODY_AnimatedSprite.animation == "Idle":
		$UPBODY_AnimatedSprite.set_frame(0)
		
		$RIGHTHAND_AnimatedSprite.play("Idle")
		$RIGHTHAND_AnimatedSprite.set_frame(0)
		
		$DOWNBODY_AnimatedSprite.play("Idle")
		$DOWNBODY_AnimatedSprite.set_frame(0)
		
	elif $UPBODY_AnimatedSprite.animation == "Walk":
		$UPBODY_AnimatedSprite.set_frame(0)
		
		$RIGHTHAND_AnimatedSprite.play("Walk")
		$RIGHTHAND_AnimatedSprite.set_frame(0)
		
		$DOWNBODY_AnimatedSprite.play("Walk")
		$DOWNBODY_AnimatedSprite.set_frame(0)

func _on_AIMARROW_GLOW_Timer_timeout():
	$AIMARROW/AIMARROW_BACKMETER_TextureProgress.value += FADEFACTOR

func _on_FADE_Timer_timeout():
	if lifepoints_changing == -1:
		$Interface/HUD/HP_STEPDAMAGE.value -= 1
	elif lifepoints_changing == +1:
		$Interface/HUD/HP_STEPDAMAGE.value += 1

func _on_ANTI_ANIM_CRASH_Timer_timeout():
	$RIGHTHAND_AnimatedSprite.set_frame(0)
	$RIGHTHAND_AnimatedSprite.play("Throw")

func _on_AIMARROW_SUPERTHROW_Timer_timeout():
	$SoundFX/EnergyFlow.play()
	throwFactor = 2
	gateLifeTime = 20

func _on_DASH_Timer_timeout():
	is_dashing = false
	dashReady = false #Iniciando cooldown do Dash
	$DASH_COOLDOWN_Timer.wait_time = dashCooldownTime
	$DASH_COOLDOWN_Timer.start()
	
func _on_DASH_COOLDOWN_Timer_timeout():
	dashReady = true

func _on_DOWNBODY_AnimatedSprite_animation_finished():
	pass # Replace with function body.

