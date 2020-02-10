extends Area2D

const SPEED = 500
const SOUNDFX = preload("res://Assets/Scenes/SoundFX.tscn")

var velocity = Vector2()
var direction = 1
var damage = 0
var shooter = "DEFAULT"
var is_crossing_gates = false

func set_bullet_direction(dir):
	direction = dir
	if dir == -1:
		$AnimatedSprite.flip_h = true

func _ready():
	#Inicializando Timer (duração da existência da bala)
	$Timer.start()
	
	#Ajustando o efeito sonoro a ser reproduzido
	var SoundFX = SOUNDFX.instance()
	get_parent().get_node(shooter).add_child(SoundFX)
	SoundFX.playfx("Shot")

	#Ajustando nomes
	if "Player" in shooter:
		shooter = "Player"
	elif "Enemy" in shooter:
		shooter = "Enemy"

func _physics_process(delta):
	velocity.x = SPEED * direction * delta
	translate(velocity)
	$AnimatedSprite.play("Shoot")
		
func _on_Bullet_body_entered(body):
	if ("Player" in body.name) and !(shooter in body.name):
		body.lifepoints -= damage
		
		#Som de feedback de acerto
		var SoundFX = SOUNDFX.instance()
		body.add_child(SoundFX)
		SoundFX.playfx("Pain")
		
		if body.lifepoints <= 0:
			body.lifepoints = 0
			body.dead()
		queue_free()
	
	if ("Enemy" in body.name) and !(shooter in body.name):
		body.lifepoints -= damage
		
		#Som de feedback de acerto
		var SoundFX = SOUNDFX.instance()
		body.add_child(SoundFX)
		SoundFX.playfx("Pain")
		
		if body.lifepoints <= 0:
			body.lifepoints = 0
			body.dead()
		queue_free()
		
	queue_free()

#Checagem de sinais
func _on_Timer_timeout():
	queue_free()
