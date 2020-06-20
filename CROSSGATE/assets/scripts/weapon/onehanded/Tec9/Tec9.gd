#Certifique-se de que a animação do disparo é mais rápida do que a animação de recuo do atirador.
extends Node2D

#Constantes
const SCRIPT_TYPE = "Attachment"
const WEAPON_NAME = "CROSSDYNAMIC TEC-9"
const WEAPON_SHORT_NAME = "Tec9"
const WEAPON_AMMO_TYPE = "9mm"
const WEAPON_AMMO_TYPE_INDEX = 0
const BULLET = preload("res://assets/scenes/environment/object/dynamic/bullet/Bullet.tscn") #Carregar a bullet na memória

#Funções
func mirror(side):
	$AnimatedSprite.flip_h = side
	$Hands/Brandon.flip_h = side
	if !side:
		$Position2D.position.x = abs($Position2D.position.x)
	else:
		$Position2D.position.x = -abs($Position2D.position.x)

func readyToShoot():
	if $SHOOT_COOLDOWN.is_stopped():
		return true
	else:
		return false

func adjustSpeed():
	get_parent().get_parent().get_node("LARM").frames.set_animation_speed("idle_shoot", 30) #FPS da animação de recoil do atirador (idle).
	get_parent().get_parent().get_node("LARM").frames.set_animation_speed("run_shoot", 30) #FPS da animação de recoil do atirador (run).
	$AnimatedSprite.frames.set_animation_speed("shoot", 60) #FPS da animação de tiro desta arma.

func setRateOfFire(timeBetweenShots): #Taxa de tiro padrão: timeBetweenShots = 0.25
	$SHOOT_COOLDOWN.wait_time = timeBetweenShots

func shoot(shooterName):
	$SHOOT_COOLDOWN.start()
	var bullet = BULLET.instance() #Instanciando a bullet
	bullet.damage = 20 #Definindo o dano da bullet
	bullet.shooter = shooterName #Definindo o atirador da bullet
	bullet.set_direction($AnimatedSprite.flip_h) #Definindo a direção da bullet
	get_parent().get_parent().get_parent().add_child(bullet) #Primeiro parent: O nó Weapons de Player.tscn; Segundo parent: O próprio Player.tscn; Terceiro parent: O mundo.
	bullet.position = $Position2D.global_position #Definindo posição inicial da bullet
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	bullet.velocity.y -= (rng.randf_range(-0.5, 0.5))
