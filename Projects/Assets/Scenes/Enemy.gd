extends KinematicBody2D

const GRAVITY = 15
const FLOOR = Vector2(0, -1)
const BULLET = preload("res://Assets/Scenes/Bullet.tscn") #Carregar a bullet na memória

var MOVESPEED = 50
var velocity = Vector2()
var direction = 1
var is_dead = false
var is_attacking = false
var is_chasing = false
var is_watching = false
var damage = 20
var lifepoints = 40
var lifepoints_changing = 0 #Em relação à barra de vida, 1 se estiver ganhando HP, -1 se estiver perdendo e 0 caso contrário.
var chaseTarget
var timer_is_counting = false
var is_running = false

func dead(): #Inicia o processo de morte do personagem. É concluído apenas na fase de checagem, após o término da animação.
	is_dead = true
	is_chasing = false
	is_attacking = false
	is_watching = false
	velocity = Vector2(0, 0)
	$AnimatedSprite.play("Dead")
	
func attack(): #Executa um disparo
	var L_Bullet = BULLET.instance()
	var R_Bullet = BULLET.instance()
	L_Bullet.damage = damage
	R_Bullet.damage = damage
	L_Bullet.shooter = name
	R_Bullet.shooter = name
	if direction == -1:
		L_Bullet.set_bullet_direction(-1)
		R_Bullet.set_bullet_direction(-1)
	get_parent().add_child(L_Bullet) #Adicionando a bullet esquerda como nó filho de TrainStage
	get_parent().add_child(R_Bullet) #Adicionando a bullet direita como nó filho de TrainStage
	L_Bullet.position = $LGUN_Position2D.global_position
	R_Bullet.position = $RGUN_Position2D.global_position
	
func switchDirection(dir): #Espelha o personagem para a direção oposta. Use dir = 1 para olhar para direita e, para esquerda, use dir = -1.
	if dir == 1:
		direction = dir
		$AnimatedSprite.flip_h = false
		$DETECT_PLAYER_FRONTVIEW/CollisionShape2D.position.x = abs($DETECT_PLAYER_FRONTVIEW/CollisionShape2D.position.x)
		$DETECT_PLAYER_BACKVIEW/CollisionShape2D.position.x = -abs($DETECT_PLAYER_BACKVIEW/CollisionShape2D.position.x)
		$PREVENT_FALL_RayCast2D.position.x = abs($PREVENT_FALL_RayCast2D.position.x)
		$LGUN_Position2D.position.x = abs($LGUN_Position2D.position.x)
		$RGUN_Position2D.position.x = abs($RGUN_Position2D.position.x) 
		$HealthBar.position.x = abs($HealthBar.position.x)
	elif dir == -1:
		direction = dir
		$AnimatedSprite.flip_h = true
		$DETECT_PLAYER_FRONTVIEW/CollisionShape2D.position.x = -abs($DETECT_PLAYER_FRONTVIEW/CollisionShape2D.position.x)
		$DETECT_PLAYER_BACKVIEW/CollisionShape2D.position.x = abs($DETECT_PLAYER_BACKVIEW/CollisionShape2D.position.x)
		$PREVENT_FALL_RayCast2D.position.x = -abs($PREVENT_FALL_RayCast2D.position.x)
		$LGUN_Position2D.position.x = -abs($LGUN_Position2D.position.x) 
		$RGUN_Position2D.position.x = -abs($RGUN_Position2D.position.x)
		$HealthBar.position.x = -abs($HealthBar.position.x)

func _ready():
	$HealthBar/TextureProgress.max_value = lifepoints

func _physics_process(delta):
	if is_dead == false:
		#VIGILÂNCIA
		if is_watching == true:
			velocity.x = 0
			$AnimatedSprite.play("Idle")
			
		#PERSEGUIÇÃO
		if is_chasing == true:
			if chaseTarget.position.x - position.x >= 0: #Se o alvo da perseguição está à direita
				switchDirection(1)
			elif chaseTarget.position.x - position.x < 0: #Se o alvo da perseguição está à esquerda
				switchDirection(-1)
		
		#PATRULHA
		if is_attacking == false and is_watching == false:
			#Mantendo a patrulha
			velocity.x = MOVESPEED * direction
			if direction == 1:
				switchDirection(1)
				$AnimatedSprite.play("Walk")
				
			elif direction == -1:
				switchDirection(-1)
				$AnimatedSprite.play("Walk")
		#ATAQUE
		elif is_attacking == true:
			velocity = Vector2(0, 0)
			$AnimatedSprite.play("Shooting")
			
		velocity.y += GRAVITY
		
		velocity = move_and_slide(velocity, FLOOR)
		
	elif is_dead == true:
		$CollisionShape2D.disabled = true
	
	#Patrulha
	if is_on_wall() or $PREVENT_FALL_RayCast2D.is_colliding() == false:
		$PREVENT_FALL_RayCast2D.position.x *= -1
		direction = -direction
		
	#Atualizando status na barra de vida
	if $HealthBar/TextureProgress.value > lifepoints:
		lifepoints_changing = -1
		$FadeTimer.start()
	elif $HealthBar/TextureProgress.value < lifepoints:
		lifepoints_changing = +1
		$FadeTimer.start()
	else:
		lifepoints_changing = 0
		
	#Checagem do Timer
	if $Timer.get_time_left() <= 4 and $Timer.get_time_left() > 2 and timer_is_counting == true:
		is_attacking = false
		is_chasing = true
		is_watching = true
		
	elif $Timer.get_time_left() <= 2 and $Timer.get_time_left() > 0 and timer_is_counting == true:
		is_attacking = false
		is_chasing = false
		is_watching = true
		
func _on_Timer_timeout():
	if timer_is_counting == true:
		is_attacking = false
		is_chasing = false
		is_watching = false

#Checagem de sinais
func _on_DETECT_PLAYER_BACKVIEW_area_entered(area): #Projétil detectado no campo de visão traseiro
	if is_dead == false:
		if "Bullet" in area.name:
			if "Player" in area.shooter:
				switchDirection(-direction)
				if is_running == false:
					MOVESPEED *= 2.5 #O personagem fica mais rápido por T segundos (onde T é o tempo definido em RunTimer)
					is_running = true
					$RunTimer.start()
	
func _on_DETECT_PLAYER_FRONTVIEW_area_entered(area): #Projétil detectado no campo de visão frontal
	if is_dead == false:
		if "Bullet" in area.name:
			if "Player" in area.shooter:
				if is_running == false:
					MOVESPEED *= 2.5 #O personagem fica mais rápido por T segundos (onde T é o tempo definido em RunTimer)
					is_running = true
					$RunTimer.start()

func _on_DETECT_PLAYER_BACKVIEW_body_entered(body): #Jogador detectado no campo de visão traseiro
	if is_dead == false:
		if "Player" in body.name:
			switchDirection(-direction)

func _on_DETECT_PLAYER_FRONTVIEW_body_entered(body): #Jogador detectado no campo de visão frontal
	if is_dead == false:
		if "Player" in body.name:
			is_watching = false
			is_attacking = true
			is_chasing = true
			chaseTarget = body
			timer_is_counting = false
		
func _on_DETECT_PLAYER_FRONTVIEW_body_exited(body):
	if is_dead == false:
		if "Player" in body.name:
			timer_is_counting = true
			$Timer.start()
			
func _on_RunTimer_timeout():
	MOVESPEED /= 2.5
	is_running = false
	$RunTimer.stop()
	
func _on_AnimatedSprite_animation_finished(): #Animação de morte encerrada: elimine a instância deste personagem.
	if is_dead == false:	
		if is_attacking:
			attack()
	elif is_dead == true:
		queue_free()

func _on_FadeTimer_timeout():
	if lifepoints_changing == -1:
		$HealthBar/TextureProgress.value -= 1
	elif lifepoints_changing == +1:
		$HealthBar/TextureProgress.value += 1
