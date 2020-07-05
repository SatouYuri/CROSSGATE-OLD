#Esta cena deve ser nó de "Player" para funcionar.
extends CanvasLayer

#Constantes
const SCRIPT_TYPE = "HUD"

#Sinais
signal dialogBoxReady

#Variáveis de Estado
var fxName = "" #Nome do efeito de tela atual
var weaponSwitching = 0 #-1 se estiver girando no sentido anti-horário; 0 se não estiver girando; +1 se estiver girando no sentido horário.
var weaponSwitchFading = false #false caso esteja sumindo ou já tenha sumido; true caso esteja aparecendo.
var weaponNameFading = false #false caso esteja sumindo ou já tenha sumido; true caso esteja aparecendo.
var dialogBoxFading = false
var dialogBoxOpen = false
var dialogWriting = false
var dialogWritingSpeed = 0.5

var dialogTitle : String = ""
var dialogText : String = ""
var dialogExpression : String
var dialogConversation : Array
var dialogCurrentIndex : int = 0

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

func dialogBox():
	if dialogBoxFading:
		if !dialogBoxOpen: #Se a caixa de diálogo está fechando
			if $DialogBox/AnimatedSprite.modulate.a > 0.2:
				$DialogBox/AnimatedSprite.modulate.a -= 0.2
				$PartnerCall/Sprite.modulate.a += 0.2
				$WeaponSelect.modulate.a += 0.2
				$StatusBars.modulate.a += 0.2
				$Under.modulate.a += 0.2
				$Face.modulate.a += 0.2
			else:
				dialogBoxFading = false
		else: #Se a caixa de diálogo está abrindo
			if $DialogBox/AnimatedSprite.modulate.a < 1:
				$DialogBox/AnimatedSprite.modulate.a += 0.2
				$PartnerCall/Sprite.modulate.a -= 0.2
				$WeaponSelect.modulate.a -= 0.2
				$StatusBars.modulate.a -= 0.2
				$Under.modulate.a -= 0.2
				$Face.modulate.a -= 0.2
			else:
				dialogBoxFading = false
				emit_signal("dialogBoxReady") #Depois que a caixa de diálogo estiver pronta, emitir esse sinal chamará updateDialog().
	elif dialogWriting:
		if $DialogBox/AnimatedSprite/DialogLabel.percent_visible >= 1.00:
			dialogWriting = false
		else:
			if $DialogBox/AnimatedSprite/DialogLabel.get_total_character_count() > 0:
				$DialogBox/AnimatedSprite/DialogLabel.percent_visible += (dialogWritingSpeed/($DialogBox/AnimatedSprite/DialogLabel.get_total_character_count()))

func openDialogBox(isDialog):
	if isDialog:
		$DialogBox/AnimatedSprite.play("dialog")
	else:
		$DialogBox/AnimatedSprite.play("text")
	dialogBoxFading = true
	dialogBoxOpen = true

func closeDialogBox():
	dialogBoxFading = true
	dialogBoxOpen = false

func isDialogRunning():
	if dialogBoxOpen == false:
		return false
	else:
		return true

func loadDialog(dialogFilePath) -> Dictionary:
	var file = File.new()
	assert file.file_exists(dialogFilePath)
	file.open(dialogFilePath, file.READ)
	var dialog = parse_json(file.get_as_text())
	assert dialog.size() > 0
	return dialog

func startDialog(dialogFilePath, isDialog):
	openDialogBox(isDialog)
	if isDialog:
		$DialogBox/AnimatedSprite/DialogLabel.margin_left = -58
		$DialogBox/AnimatedSprite/DialogLabel.margin_right = 550
	else:
		$DialogBox/AnimatedSprite/DialogLabel.margin_left = -92
		$DialogBox/AnimatedSprite/DialogLabel.margin_right = 654
	var dialog : Dictionary = loadDialog(dialogFilePath)
	dialogConversation = dialog.values()
	dialogCurrentIndex = 0

func nextDialog():
	if $DialogBox/AnimatedSprite/DialogLabel.percent_visible >= 1.00:
		dialogWritingSpeed = 0.5
		dialogCurrentIndex += 1
		if dialogCurrentIndex < dialogConversation.size():
			updateDialog()
		elif dialogCurrentIndex == dialogConversation.size():
			endDialog()
	else:
		dialogWritingSpeed = 3.0

func endDialog():
	closeDialogBox()
	$DialogBox/AnimatedSprite/DialogLabel.bbcode_text = ""
	$DialogBox/AnimatedSprite/DialogLabel.percent_visible = 0

func updateDialog():
	$DialogBox/AnimatedSprite/DialogLabel.percent_visible = 0
	dialogWriting = true
	dialogText = dialogConversation[dialogCurrentIndex].text
	dialogTitle = dialogConversation[dialogCurrentIndex].name
	dialogExpression = dialogConversation[dialogCurrentIndex].expression
	$DialogBox/AnimatedSprite/DialogLabel.bbcode_text = "[fill]" + dialogText + "[/fill]"

#Código Inicial
func _ready():
	#Ajustes iniciais no WeaponSelect
	$WeaponSelect/WeaponSwitch.modulate.a = 0
	$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite.modulate.a = 0
	
	#Ajustes inicias na DialogBox
	$DialogBox/AnimatedSprite.modulate.a = 0

#Código Principal
func _physics_process(delta):
	#Barra de HP
	if $StatusBars/DELAY/TextureProgress.value > $StatusBars/HP/TextureProgress.value and $Timers/DELAY_SPEED.is_stopped():
		$Timers/DELAY_SPEED.start()
	elif $StatusBars/DELAY/TextureProgress.value <= $StatusBars/HP/TextureProgress.value:
		$Timers/DELAY_SPEED.stop()
	
	#Caixa de Diálogo
	dialogBox()
	if Input.is_action_just_pressed("CG_TEST"):
		if !dialogBoxOpen:
			startDialog("res://assets/dialogues/TestStage_dazuva.json", true) #NOTA / WIP: Dialogue Test
			#startDialog("res://assets/dialogues/TestStage_dazuva.json", false) #NOTA / WIP: Text Test
		else:
			nextDialog()
	
	#Troca de Armas
	if get_parent().get_node("Weapons").has_node("currentWeapon"):
		$WeaponSelect/WeaponDisplay/NameBlock/AnimatedSprite/Text/Name.text = get_parent().get_node("Weapons").get_node("currentWeapon").WEAPON_NAME
		$WeaponSelect/WeaponDisplay/BaseBlock/Text/AmmoType/AmmoType.text =  get_parent().get_node("Weapons").get_node("currentWeapon").WEAPON_AMMO_TYPE
		$WeaponSelect/WeaponDisplay/BaseBlock/Text/Ammo/Ammo.text = str(get_parent().ammunition[get_parent().get_node("Weapons").get_node("currentWeapon").WEAPON_AMMO_TYPE_INDEX])
		if($WeaponSelect/WeaponDisplay/BaseBlock/Text/Ammo/Ammo.text == "0"): #Se não houver munição, o contador de munição fica vermelho
			$WeaponSelect/WeaponDisplay/BaseBlock/Text/Ammo/Ammo.modulate.g = 0
			$WeaponSelect/WeaponDisplay/BaseBlock/Text/Ammo/Ammo.modulate.b = 0
		else:
			$WeaponSelect/WeaponDisplay/BaseBlock/Text/Ammo/Ammo.modulate.g = 1
			$WeaponSelect/WeaponDisplay/BaseBlock/Text/Ammo/Ammo.modulate.b = 1
		
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
			for icon in $WeaponSelect/WeaponDisplay/IconBlock.get_children():
				if get_parent().get_node("Weapons").has_node("currentWeapon") and icon.name == get_parent().get_node("Weapons").get_node("currentWeapon").WEAPON_SHORT_NAME:
					icon.visible = true
				else:
					icon.visible = false
	else:
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

func _on_hud_dialogBoxReady():
	updateDialog()
