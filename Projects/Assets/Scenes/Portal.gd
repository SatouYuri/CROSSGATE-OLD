extends KinematicBody2D

const GRAVITY = 20
const IMPULSE = -450
const FLOOR = Vector2(0, -1)

var is_open = false
var sphere_mode = false #thrownable_mode, true se a esfera for afetada pela gravidade, false, caso contrário.
var velocity = Vector2()
var initialImpulse = Vector2()
var free = false
var is_flashing = false
var timer_is_triggered = true
var obj_altername = "DarkBall"
var static_darkball = false

func safe_queue_free(): #Remove da gateList do mundo do jogo primeiro, antes de executar queue_free
	for i in get_parent().gateList:
		if i.name == name:
			get_parent().gateList.remove(0)
	queue_free()

func throwImpulse(direction):
	velocity = direction
	initialImpulse = direction
	#Se a DarkBall não se abrir como um portal em 5 segundos, ela será excluída.
	if timer_is_triggered:
		timer_is_triggered = false
		$QueueFreeTimer.wait_time = 3
		$QueueFreeTimer.start()

func ballInitialize(thrownable, impulse): #Chame esta função sempre que uma DarkBall for instanciada.
	#Quando for uma DarkBall, o Z Index muda (à frente do jogador, para aparecer na mão dele)	
	sphere_mode = thrownable
	if sphere_mode:
		initialImpulse = impulse
		throwImpulse(initialImpulse)

func openGate():
	$QuickSoundFX.playfx("GateOpen")
	sphere_mode = false
	$SpriteSetClosed.z_index = 0
	$SpriteSetClosed/PortalBack1.play("Opening")
	$SpriteSetClosed/PortalBack2.play("Opening")
	$SpriteSetClosed/PortalBack3.play("Opening")
	$SpriteSetClosed/PortalBack4.play("Opening")
	$SpriteSetClosed/PortalBack5.play("Opening")

func openGateWithTimer(seconds):
	$QuickSoundFX.playfx("GateOpen")
	sphere_mode = false
	$SpriteSetClosed.z_index = 0
	$SpriteSetClosed/PortalBack1.play("Opening")
	$SpriteSetClosed/PortalBack2.play("Opening")
	$SpriteSetClosed/PortalBack3.play("Opening")
	$SpriteSetClosed/PortalBack4.play("Opening")
	$SpriteSetClosed/PortalBack5.play("Opening")
	$QueueFreeTimer.wait_time = seconds
	$QueueFreeTimer.start()

func closeGate(free_gate):
	$QuickSoundFX.playfx("GateClose")
	free = free_gate
	$SpriteSetOpen/PortalFront.visible = false
	$SpriteSetOpen/PortalBack1.visible = false
	$SpriteSetOpen/PortalBack2.visible = false
	$SpriteSetOpen/PortalBack3.visible = false
	$SpriteSetClosed/PortalBack1.visible = true
	$SpriteSetClosed/PortalBack2.visible = true
	$SpriteSetClosed/PortalBack3.visible = true
	$SpriteSetClosed/PortalBack4.visible = true
	$SpriteSetClosed/PortalBack5.visible = true
	$SpriteSetClosed/PortalBack1.play("Closing")
	$SpriteSetClosed/PortalBack2.play("Closing")
	$SpriteSetClosed/PortalBack3.play("Closing")
	$SpriteSetClosed/PortalBack4.play("Closing")
	$SpriteSetClosed/PortalBack5.play("Closing")
	$SpriteSetClosed.z_index = 3
	
func _ready():
	$SoundFX.playfx("PortalIdle")
	$SpriteSetClosed/PortalBack1.play("Locked")
	$SpriteSetClosed/PortalBack2.play("Locked")
	$SpriteSetClosed/PortalBack3.play("Locked")
	$SpriteSetClosed/PortalBack4.play("Locked")
	$SpriteSetClosed/PortalBack5.play("Locked")
	$MaxLifeTimeTimer.start() #Uma DarkBall tem, no máximo, 60 seg de vida útil (exceto se static_darkball for verdadeiro).

func _physics_process(delta):
	#Animação de Movimento Circular
	if is_open == true:
		$SpriteSetOpen/PortalFront.rotate(-3.1415/180)
		$SpriteSetOpen/PortalBack1.rotate(-3.1415/360)
		$SpriteSetOpen/PortalBack2.rotate(-3.1415/720)
		$SpriteSetOpen/PortalBack3.rotate(-3.1415/800)
		if is_flashing:
			$SpriteSetOpen/PortalFront.modulate.a = 2
		else:
			$SpriteSetOpen/PortalFront.modulate.a = 1
			
				
	elif is_open == false:
		$SpriteSetClosed/PortalBack1.rotate(-3.1415/360)
		$SpriteSetClosed/PortalBack2.rotate(-3.1415/720)
		$SpriteSetClosed/PortalBack3.rotate(-3.1415/800)
		$SpriteSetClosed/PortalBack4.rotate(-3.1415/360)
		$SpriteSetClosed/PortalBack5.rotate(-3.1415/720)
		
	#Movimento: Eixo Y
	if sphere_mode: #Se a esfera estiver atualmente sendo afetada pela gravidade...
		$CollisionShape2D.disabled = false
		
		velocity.y = velocity.y + GRAVITY

		#Mecânica para a esfera quicar
		if is_on_floor(): #Se está no chão
			throwImpulse(Vector2(initialImpulse.x*0.75, initialImpulse.y*0.75))
			
		if is_on_wall(): #Se está contra uma parede
			throwImpulse(Vector2(-initialImpulse.x*0.75, initialImpulse.y*0.75))
			
				
		velocity = move_and_slide(velocity, FLOOR)
	
	else: #Se a esfera NÃO estiver atualmente sendo afetada pela gravidade...
		$CollisionShape2D.disabled = true
		#Encerrar os portais sempre que o jogador quiser
		if is_open && Input.is_action_pressed("space_bar"):
			closeGate(true)	
		#elif !is_open && Input.is_action_pressed("space_bar"):
		#	safe_queue_free()
		
#Checagens para sinais emitidos
func _on_PortalBack1_animation_finished():
	if $SpriteSetClosed/PortalBack1.animation == "Opening":
		is_open = true
		
		$SpriteSetOpen/PortalFront.visible = true
		$SpriteSetOpen/PortalBack1.visible = true
		$SpriteSetOpen/PortalBack2.visible = true
		$SpriteSetOpen/PortalBack3.visible = true
		$SpriteSetClosed/PortalBack1.visible = false
		$SpriteSetClosed/PortalBack2.visible = false
		$SpriteSetClosed/PortalBack3.visible = false
		$SpriteSetClosed/PortalBack4.visible = false
		$SpriteSetClosed/PortalBack5.visible = false
		
	elif $SpriteSetClosed/PortalBack1.animation == "Closing":
		is_open = false
		if free:
			safe_queue_free()
		else:
			$SpriteSetClosed/PortalBack1.play("Locked")
			$SpriteSetClosed/PortalBack2.play("Locked")
			$SpriteSetClosed/PortalBack3.play("Locked")
			$SpriteSetClosed/PortalBack4.play("Locked")
			$SpriteSetClosed/PortalBack5.play("Locked")

func _on_INTERACT_Area2D_body_entered(body):
	if is_open: #Se o portal está aberto...
		if get_parent().gateList.size() >= 2:
			if ("Player" in body.name):
				$QuickSoundFX.playfx("GateInteract")
				is_flashing = true
				if body.is_crossing_gates == false:
					body.is_crossing_gates = true #Impede o loop infinito entre 2 portais
					for i in range(get_parent().gateList.size()):
						if get_parent().gateList[i].name == name:
							if(i == (get_parent().gateList.size() - 1)):
								body.position = get_parent().gateList[0].position
							else:
								body.position = get_parent().gateList[i+1].position

func _on_INTERACT_Area2D_body_exited(body):
	if is_open: #Se o portal está aberto...
		if "Player" in body.name:
			is_flashing = false
			body.is_crossing_gates = false

func _on_INTERACT_Area2D_area_entered(area):
	if is_open: #Se o portal está aberto...
		if get_parent().gateList.size() >= 2:
			if ("Bullet" in area.name):
				$QuickSoundFX.playfx("GateInteract")
				is_flashing = true
				if area.is_crossing_gates == false:
					area.is_crossing_gates = true #Impede o loop infinito entre 2 portais
					for i in range(get_parent().gateList.size()):
						if get_parent().gateList[i].name == name:
							if(i == (get_parent().gateList.size() - 1)):
								area.position = get_parent().gateList[0].position
							else:
								area.position = get_parent().gateList[i+1].position

func _on_INTERACT_Area2D_area_exited(area):
	if is_open: #Se o portal está aberto...
		if "Bullet" in area.name:
			is_flashing = false
			area.is_crossing_gates = false

func _on_QueueFreeTimer_timeout():
	if is_open:
		closeGate(true)
	else:
		#Outra DarkBall já pode ser instanciada para arremessar:
		get_parent().get_node("Player").darkball_thrown = false
		get_parent().get_node("Player").darkball_generated = false 
		safe_queue_free()

func _on_MaxLifeTimeTimer_timeout():
	if !static_darkball && !is_open:
		safe_queue_free()