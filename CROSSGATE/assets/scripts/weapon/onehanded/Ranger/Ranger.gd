extends Node2D

const BULLET = preload("res://assets/scenes/environment/objects/dynamic/bullets/Bullet.tscn") #Carregar a bullet na memória

func mirror(side):
	$AnimatedSprite.flip_h = side
	#$Position2D.position.x = getSide()*$Position2D.position.x
	if !side:
		$Position2D.position.x = abs($Position2D.position.x)
	else:
		$Position2D.position.x = -abs($Position2D.position.x)

func shoot(shooterName):
	var bullet = BULLET.instance() #Instanciando a bullet
	bullet.damage = 20 #Definindo o dano da bullet
	bullet.shooter = shooterName #Definindo o atirador da bullet
	bullet.set_direction($AnimatedSprite.flip_h) #Definindo a direção da bullet
	get_parent().get_parent().get_parent().add_child(bullet) #Primeiro parent: O nó Weapons de Player.tscn; Segundo parent: O próprio Player.tscn; Terceiro parent: O mundo
	bullet.position = $Position2D.global_position #Definindo posição inicial da bullet