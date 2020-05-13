extends Node2D

#Constantes
const SCRIPT_TYPE = "Background"

#Variáveis de Estado
var scrollSpeed = 0.25
var distBetweenRegionCenters
var curRegionConfig
var curOrigin
var stopped = false
var time = 0

#Funções
func timeStop(): #Paraliza/Desparaliza o background.
	if !stopped:
		stopped = true
	else:
		stopped = false
	updateShaders("stopped", stopped)

func executeRealoc(side): #Atualiza a posição/arranjo das regiões conforme a configuração de regiões atual (curRegionConfig). Deve ser chamada apenas pela função updateRegionConfig().
	if !side: #Se for uma realocação de região para a direita...
		if curRegionConfig[1] == 0:
			curOrigin = $Sand/Region0.position
			for node in get_children():
				node.get_node("Region1").position.x = node.get_node("Region0").position.x + distBetweenRegionCenters
		elif curRegionConfig[1] == 1:
			curOrigin = $Sand/Region1.position
			for node in get_children():
				node.get_node("Region2").position.x = node.get_node("Region1").position.x + distBetweenRegionCenters
		elif curRegionConfig[1] == 2:
			curOrigin = $Sand/Region2.position
			for node in get_children():
				node.get_node("Region0").position.x = node.get_node("Region2").position.x + distBetweenRegionCenters
	else: #Se for uma realocação de região para a esquerda...
		if curRegionConfig[1] == 0:
			curOrigin = $Sand/Region0.position
			for node in get_children():
				node.get_node("Region2").position.x = node.get_node("Region0").position.x - distBetweenRegionCenters
		elif curRegionConfig[1] == 1:
			curOrigin = $Sand/Region1.position
			for node in get_children():
				node.get_node("Region0").position.x = node.get_node("Region1").position.x - distBetweenRegionCenters
		elif curRegionConfig[1] == 2:
			curOrigin = $Sand/Region2.position
			for node in get_children():
				node.get_node("Region1").position.x = node.get_node("Region2").position.x - distBetweenRegionCenters

func updateRegionConfig(side): #Atualiza o vetor de configuação atual das regiões 0, 1 e 2 deste background. Use side = false se for uma realocação de região para direita e side = true caso seja para a esquerda.
	if !side: #Se for uma realocação de região para a direita...
		var realocTarget = curRegionConfig[0]
		curRegionConfig[0] = curRegionConfig[1]
		curRegionConfig[1] = curRegionConfig[2]
		curRegionConfig[2] = realocTarget
	else: #Se for uma realocação de região para a esquerda...
		var realocTarget = curRegionConfig[2]
		curRegionConfig[2] = curRegionConfig[1]
		curRegionConfig[1] = curRegionConfig[0]
		curRegionConfig[0] = realocTarget
	executeRealoc(side)

func updateShaders(shaderParamName, shaderParamValue):
	for node in $Sand.get_children():
		node.get_node("TextureRect").material.set_shader_param(shaderParamName, shaderParamValue)
	for node in $Dunes.get_children():
		node.get_node("TextureRect").material.set_shader_param(shaderParamName, shaderParamValue)
	for node in $Sky.get_children():
		node.get_node("TextureRect").material.set_shader_param(shaderParamName, shaderParamValue)

#Código Inicial
func _ready():
	for node in $Sand.get_children():
		node.get_node("TextureRect").material.set_shader_param("scrollSpeed", scrollSpeed)
	for node in $Dunes.get_children():
		node.get_node("TextureRect").material.set_shader_param("scrollSpeed", scrollSpeed * 0.6)
	for node in $Sky.get_children():
		node.get_node("TextureRect").material.set_shader_param("scrollSpeed", scrollSpeed * 0.3)
	position = Vector2(get_parent().get_parent().get_node("Player").position.x, 0)
	curOrigin = position
	curRegionConfig = [0, 1, 2]
	distBetweenRegionCenters = abs($Sand/Region2.position.x - $Sand/Region1.position.x)

#Código Principal
func _physics_process(delta):
	#Atualizando o contador de tempo...
	if !stopped:
		time += delta
	else:
		time += delta * 0.025
	
	#Executando realocação de região, caso necessário...
	if abs(get_parent().get_parent().get_node("Player").position.x - curOrigin.x) > distBetweenRegionCenters/2:
		if get_parent().get_parent().get_node("Player").position.x > curOrigin.x:
			updateRegionConfig(false)
		elif get_parent().get_parent().get_node("Player").position.x < curOrigin.x:
			updateRegionConfig(true)
	
	#Atualizando o estado de imagem de cada região com base no contador de tempo (parâmetro passado ao shader de cada TextureRect, a cada frame, para controlar a velocidade do background)...
	updateShaders("time", time)

