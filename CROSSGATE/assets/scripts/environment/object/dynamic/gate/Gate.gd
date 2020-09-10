extends Node2D
#Gates sempre devem ser instanciados no nó "Background".

#Constantes
const SCRIPT_TYPE = "DynamicObject"

#Variáveis de Estado
var open
var flashing
var stopped #Se o tempo está ou não parado (não afeta o funcionamento do Gate)
var lifetime = 10 #Tempo de vida do Gate (ajustável)

#Funções
func timeStop(): #Gates não são afetados pela parada do tempo
	if !stopped:
		stopped = true
	else:
		stopped = false
		gateOpenWithLifetime(lifetime)

func gateOpen():
	open = true
	for node in get_node("SpriteSetClosed").get_children():
		node.play("opening")

func gateOpenWithLifetime(lifetime):
	open = true
	for node in get_node("SpriteSetClosed").get_children():
		node.play("opening")
	$LIFETIME.wait_time = lifetime
	$LIFETIME.start()

func gateClose():
	$SpriteSetOpen.visible = false
	$SpriteSetClosed.visible = true
	for node in get_node("SpriteSetClosed").get_children():
		node.play("closing")

func getWorld():
	return get_parent().get_parent()

func getPlayer():
	return getWorld().get_node("Player")

#Código Inicial
func _ready():
	open = false
	flashing = false
	stopped = true
	$SpriteSetClosed/Closed1.play("locked")
	$SpriteSetClosed/Closed2.play("locked")
	$SpriteSetClosed/Closed3.play("locked")
	$SpriteSetClosed/Closed4.play("locked")
	$SpriteSetClosed/Closed5.play("locked")

#Código Principal
func _physics_process(delta):
	if open:
		$SpriteSetOpen/OpenFront.rotate(-3.1415/180)
		$SpriteSetOpen/Open1.rotate(-3.1415/360)
		$SpriteSetOpen/Open2.rotate(-3.1415/720)
		$SpriteSetOpen/Open3.rotate(-3.1415/800)
		if flashing:
			$SpriteSetOpen/OpenFront.modulate.a = 3
		else:
			$SpriteSetOpen/OpenFront.modulate.a = 1
	else:
		$SpriteSetClosed/Closed1.rotate(-3.1415/360)
		$SpriteSetClosed/Closed2.rotate(-3.1415/720)
		$SpriteSetClosed/Closed3.rotate(-3.1415/800)
		$SpriteSetClosed/Closed4.rotate(-3.1415/360)
		$SpriteSetClosed/Closed5.rotate(-3.1415/720)

func _on_Closed1_animation_finished():
	if $SpriteSetClosed/Closed1.animation == "opening":
		$SpriteSetOpen.visible = true
		$SpriteSetClosed.visible = false
	elif $SpriteSetClosed/Closed1.animation == "closing":
		open = false
		#for node in get_node("SpriteSetClosed").get_children(): #NOTA / WIP : Isso seria usado em um Gate fixo no mapa. Não é o caso.
		#	node.play("locked")
		getWorld().gateList.erase(self)
		queue_free()

func _on_Interact_body_entered(body):
	if open and getWorld().gateList.size() >= 2:
		if "Player" in body.name:
			flashing = true
			if !body.crossingGates:
				body.crossingGates = true
				for i in range(getWorld().gateList.size()):
					if getWorld().gateList[i].name == name:
						if i == (getWorld().gateList.size() - 1):
							body.position = getWorld().gateList[0].position
						else:
							body.position = getWorld().gateList[i + 1].position

func _on_Interact_body_exited(body):
	if open: #Se o portal está aberto...
		if "Player" in body.name:
			flashing = false
			body.crossingGates = false

func _on_Interact_area_entered(area):
	if open and getWorld().gateList.size() >= 2:
		if "Bullet" in area.name:
			flashing = true
			if !area.crossingGates:
				area.crossingGates = true
				for i in range(getWorld().gateList.size()):
					if getWorld().gateList[i].name == name:
						if i == (getWorld().gateList.size() - 1):
							area.position = getWorld().gateList[0].position
						else:
							area.position = getWorld().gateList[i + 1].position

func _on_Interact_area_exited(area):
	if open: #Se o portal está aberto...
		if "Bullet" in area.name:
			flashing = false
			area.crossingGates = false

func _on_LIFETIME_timeout(): #Timeout por Lifetime atingido (fechando o portal)...
	gateClose()
