extends KinematicBody2D

const MOVESPEED = 150
const GRAVITY = 25
const JUMP_HEIGHT = -450
const FLOOR = Vector2(0, -1)
const BULLET = preload("res://Assets/Scenes/Bullet.tscn") #Carregar a bullet na memória

var velocity = Vector2()
var on_ground = false
var is_attacking = false
var just_landed_check = false
var lifepoints = 110
var damage = 10
var is_dead = false

func dead():
	is_dead = true
	velocity = Vector2(0, 0)
	$AnimatedSprite.play("Dead")

func _physics_process(delta):
	if is_dead == false:
		#Movimento: Eixo X
		if Input.is_action_pressed("ui_right"):
			velocity.x = MOVESPEED
			if on_ground == true && is_attacking == false:
				$AnimatedSprite.play("Walk")
			if $AnimatedSprite.flip_h == true:
				$AnimatedSprite.flip_h = false
			if sign($Position2D.position.x) == -1:
				$Position2D.position.x *= -1
				
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -MOVESPEED
			if on_ground == true && is_attacking == false:
				$AnimatedSprite.play("Walk")
			if $AnimatedSprite.flip_h == false:
				$AnimatedSprite.flip_h = true
			if sign($Position2D.position.x) == 1:
				$Position2D.position.x *= -1
				
		else:
			velocity.x = 0
			if on_ground == true && is_attacking == false:
				$AnimatedSprite.play("Idle")
		
		#Movimento: Eixo Y
		if Input.is_action_pressed("ui_up"):
			if on_ground == true:
				velocity.y = JUMP_HEIGHT
				on_ground == false
		
		#Ações
		if Input.is_action_just_pressed("ui_select") && is_attacking == false:
			is_attacking = true
			var Bullet = BULLET.instance()
			Bullet.damage = 10
			Bullet.shooter = "Player"
			if $AnimatedSprite.flip_h == true:
				Bullet.set_bullet_direction(-1)
			$AnimatedSprite.play("Shooting")
			get_parent().add_child(Bullet) #Adicionando a bullet como nó filho de TrainStage
			Bullet.position = $Position2D.global_position
		
	velocity.y = velocity.y + GRAVITY
		
	#Verificações finais
	if is_dead == false:
		if is_on_floor():
			just_landed_check = on_ground
			if on_ground == false: #Evita o bug que faz as animações travarem/freezarem: "Se o personagem ACABOU de encostar no chão, cancele o ataque atual (is_attacking = false) antes de definir que ele agora está no chão."
				is_attacking = false
			on_ground = true
		else:
			on_ground = false
			if is_attacking == false:
				if velocity.y < 0:
					$AnimatedSprite.play("Jump")
				else:
					$AnimatedSprite.play("Fall")
	
	velocity = move_and_slide(velocity, FLOOR)

func _on_AnimatedSprite_animation_finished():
	is_attacking = false
	if is_dead == true:
		get_tree().change_scene("res://Assets/Scenes/TitleScreen.tscn")
