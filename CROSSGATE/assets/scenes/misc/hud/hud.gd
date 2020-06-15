#Esta cena deve ser nó de "Player" para funcionar.
extends CanvasLayer

#Constantes
const SCRIPT_TYPE = "HUD"

#Variáveis de Estado
var weaponSwitching = 0 #-1 se estiver girando no sentido anti-horário; 0 se não estiver girando; +1 se estiver girando no sentido horário.
var weaponSwitchFading = false #false caso esteja sumindo ou já tenha sumido; true caso esteja aparecendo.
var weaponNameFading = false #false caso esteja sumindo ou já tenha sumido; true caso esteja aparecendo.

func update():
	updateLifepoints()
	updateEtherpoints()

func updateLifepoints():
	$StatusBars/HP/TextureProgress.value = (float(get_parent().lifepoints)/float(get_parent().maxLifepoints))*100

func updateEtherpoints():
	$StatusBars/EP/TextureProgress.value = (float(get_parent().etherpoints)/float(get_parent().maxEtherpoints))*100

func switchWeapon(nextOrPrev): #nextOrPrev: +1 para selecionar próxima arma; -1 para selecionar arma anterior.
	if nextOrPrev != 0:
		weaponSwitching = nextOrPrev
		weaponSwitchFading = true
		weaponNameFading = true
		if nextOrPrev > 0:
			get_parent().selectNextWeapon()
		else:
			get_parent().selectPrevWeapon()
		$Timers/FADING_COUNTDOWN.start()
		$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite.play("switch")
		$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite/Text.visible = false
		$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite/Text/Name.text = get_parent().get_node("Weapons").get_node("currentWeapon").WEAPON_NAME
		$WeaponSelect/WeaponDisplay/BaseBlock/Text/AmmoType/AmmoType.text =  get_parent().get_node("Weapons").get_node("currentWeapon").WEAPON_AMMO_TYPE

#Código Inicial
func _ready():
	#Ajustes iniciais no WeaponSelect
	$WeaponSelect/WeaponSwitch.modulate.a = 0
	$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite.modulate.a = 0

#Código Principal
func _physics_process(delta):
	#Barra de HP
	if $StatusBars/DELAY/TextureProgress.value > $StatusBars/HP/TextureProgress.value and $Timers/DELAY_SPEED.is_stopped():
		$Timers/DELAY_SPEED.start()
	elif $StatusBars/DELAY/TextureProgress.value <= $StatusBars/HP/TextureProgress.value:
		$Timers/DELAY_SPEED.stop()
	
	#Troca de Armas
	if get_parent().get_node("Weapons").has_node("currentWeapon"):
		$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite/Text/Name.text = get_parent().get_node("Weapons").get_node("currentWeapon").WEAPON_NAME
		$WeaponSelect/WeaponDisplay/BaseBlock/Text/AmmoType/AmmoType.text =  get_parent().get_node("Weapons").get_node("currentWeapon").WEAPON_AMMO_TYPE
	
	if weaponSwitchFading:
		if $WeaponSelect/WeaponSwitch.modulate.a < 0.6:
			$WeaponSelect/WeaponSwitch.modulate.a += 0.1
	else:
		if $WeaponSelect/WeaponSwitch.modulate.a > 0 :
			$WeaponSelect/WeaponSwitch.modulate.a -= 0.1
	
	if weaponNameFading:
		if $WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite.modulate.a < 1:
			$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite.modulate.a += 0.1
	else:
		if $WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite.modulate.a > 0:
			$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite.modulate.a -= 0.1
	
	if weaponSwitching != 0:
		if abs($WeaponSelect/WeaponSwitch.rotation_degrees) < 180:
			$WeaponSelect/WeaponSwitch.rotate(0.25*weaponSwitching)
		else:
			weaponSwitching = 0
			$WeaponSelect/WeaponSwitch.rotation_degrees = 0
	elif weaponSwitching == 0:
		if Input.is_action_just_pressed("CG_SWITCH_NEXT"):
			switchWeapon(+1)
		elif Input.is_action_just_pressed("CG_SWITCH_PREV"):
			switchWeapon(-1)

func _on_DELAY_SPEED_timeout():
	$StatusBars/DELAY/TextureProgress.value -= 1

func _on_FADING_COUNTDOWN_timeout():
	weaponSwitchFading = false
	weaponNameFading = false

func _on_AnimatedSprite_animation_finished():
	if $WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite.animation == "switch":
		$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite.play("idle")
		$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite/Text.visible = true
