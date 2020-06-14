#Esta cena deve ser nó de "Player" para funcionar.
extends CanvasLayer

#Constantes
const SCRIPT_TYPE = "HUD"

#Variáveis de Estado
var weaponSwitching = 0 #-1 se estiver girando no sentido anti-horário; 0 se não estiver girando; +1 se estiver girando no sentido horário.
var weaponSwitchFading = false #false caso esteja sumindo ou já tenha sumido; true caso esteja aparecendo.

func update():
	updateLifepoints()
	updateEtherpoints()

func updateLifepoints():
	$StatusBars/HP/TextureProgress.value = (float(get_parent().lifepoints)/float(get_parent().maxLifepoints))*100

func updateEtherpoints():
	$StatusBars/EP/TextureProgress.value = (float(get_parent().etherpoints)/float(get_parent().maxEtherpoints))*100

#Código Inicial
func _ready():
	$WeaponSelect/WeaponSwitch.modulate.a = 0

#Código Principal
func _physics_process(delta):
	#Barra de HP
	if $StatusBars/DELAY/TextureProgress.value > $StatusBars/HP/TextureProgress.value and $Timers/DELAY_SPEED.is_stopped():
		$Timers/DELAY_SPEED.start()
	elif $StatusBars/DELAY/TextureProgress.value <= $StatusBars/HP/TextureProgress.value:
		$Timers/DELAY_SPEED.stop()
	
	#Troca de Armas
	if weaponSwitchFading:
		if $WeaponSelect/WeaponSwitch.modulate.a < 0.6:
			$WeaponSelect/WeaponSwitch.modulate.a += 0.1
	else:
		if $WeaponSelect/WeaponSwitch.modulate.a > 0 :
			$WeaponSelect/WeaponSwitch.modulate.a -= 0.1
	
	if weaponSwitching != 0:
		if abs($WeaponSelect/WeaponSwitch.rotation_degrees) < 180:
			$WeaponSelect/WeaponSwitch.rotate(0.25*weaponSwitching)
		else:
			weaponSwitching = 0
			$WeaponSelect/WeaponSwitch.rotation_degrees = 0
	elif weaponSwitching == 0:
		if Input.is_action_just_pressed("CG_SWITCH_NEXT"):
			weaponSwitching = 1
			weaponSwitchFading = true
			get_parent().selectNextWeapon()
			$Timers/FADING_COUNTDOWN.start()
		elif Input.is_action_just_pressed("CG_SWITCH_PREV"):
			weaponSwitching = -1
			weaponSwitchFading = true
			get_parent().selectPrevWeapon()
			$Timers/FADING_COUNTDOWN.start()

func _on_DELAY_SPEED_timeout():
	$StatusBars/DELAY/TextureProgress.value -= 1

func _on_FADING_COUNTDOWN_timeout():
	weaponSwitchFading = false
