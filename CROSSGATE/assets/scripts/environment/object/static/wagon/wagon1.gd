extends StaticBody2D

#Constantes
const SCRIPT_TYPE = "StaticObject"
const pConst = preload("res://assets/util/PROJECT_CONSTANTS.gd")

#Variáveis de Estado
var stopped = false
var wagonIndex = -1 #Esse índice deve ser ajustado antes de instanciar o vagão

#Código Inicial
func _ready():
	#Ajustando o z-index
	$Exterior.z_index = pConst.WAGON_Z_INDEX
	$Interior.z_index = pConst.WAGON_INTERIOR_Z_INDEX

#Funções
func timeStop(): #Paraliza/Desparaliza este objeto.
	if !stopped:
		stopped = true
	else:
		stopped = false

func renderWagon(wagonType, wagonIndex, nextOrPrev): #Renderiza o próximo/anterior vagão do tipo especificado no índice alvo. (nextOrPrev==+1: próximo; nextOrPrev==-1: anterior)
	var newWagon
	if wagonType in [1, 2, 3, 4]:
		newWagon = load("res://assets/scenes/environment/object/static/wagon/Wagon" + str(wagonType) + ".tscn").instance()
	newWagon.wagonIndex = wagonIndex
	newWagon.position.y = position.y
	newWagon.position.x = position.x + nextOrPrev*432
	#Adicione mais vagões...
	get_parent().add_child(newWagon)
	getGlobal().stageMap[1][wagonIndex] = 1

func watchRenderingTrigger():
	if wagonIndex >= 0 and (position.x - 250) <= getPlayer().position.x and getPlayer().position.x <= (position.x + 250):
		#Renderizando vagões adjacentes.
		if wagonIndex < getGlobal().stageMap[0].size() - 1 and wagonIndex >= 0: #Se este vagão tem próximo...
			if getGlobal().stageMap[1][wagonIndex + 1] == 0: #Se o próximo não está renderizado
				renderWagon(getGlobal().stageMap[0][wagonIndex + 1], wagonIndex + 1, +1)
		if wagonIndex > 0 and wagonIndex <= getGlobal().stageMap[0].size() - 1: #Se este vagão tem anterior...
			if getGlobal().stageMap[1][wagonIndex - 1] == 0: #Se o anterior não está renderizado
				renderWagon(getGlobal().stageMap[0][wagonIndex - 1], wagonIndex - 1, -1)
	elif abs(getPlayer().position.x - position.x) > 800:
		getGlobal().stageMap[1][wagonIndex] = 0
		queue_free() #NOTA / WIP: E os inimigos que estavam nesse vagão? O que acontece com eles se o vagão for desrenderizado?

func getPlayer():
	return get_parent().get_node("Player")#return get_parent().get_parent().get_parent().get_node("Player")

func getGlobal():
	return get_tree().get_root().get_node("Global")

#Código Principal
func _physics_process(delta):
	#Mostrar o interior do vagão.
	if getPlayer() in $InteractionArea.get_overlapping_bodies():
		if $Exterior.modulate.a >= 0:
			$Exterior.modulate.a -= 0.05
		else:
			$Exterior.modulate.a = 0.0
	else:
		if $Exterior.modulate.a <= 1.0:
			$Exterior.modulate.a += 0.05
		else:
			$Exterior.modulate.a = 1.0

	watchRenderingTrigger()