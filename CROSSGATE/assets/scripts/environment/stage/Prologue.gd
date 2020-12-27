extends Node2D

#Constantes
const SCRIPT_TYPE = "Stage"
var loopInterval = range(25,33) #(Range retorna uma lista) Vagões com wagonIndex pertencentes a esse intervalo (a <= wagonIndex < b) entrarão em loop (se looping==true) assim que o jogador adentrá-lo (quando o último vagão fora do intervalo for desinstanciado).

#Variáveis de Estado
var looping : int # 1: loop ativo; 0: loop inativo; -1: loop já foi quebrado;
var loopTriggerReady : bool
var originalStageMap

#Funções
func timeStop(): #Paraliza/Desparaliza todos os nós dentro deste estágio.
	for node in get_children():
		node.timeStop()

func getGlobal():
	return get_tree().get_root().get_node("Global")

func getPlayer():
	return get_node("Player")#return get_parent().get_parent().get_node("Player")

func breakLoop(): #Quebra o loop. O loop só pode ser quebrado se o jogador estiver dentro do conjunto de vagões em loop (loopInterval).
	#IMPORTANTE: Essa função só pode ser chamada se o jogador estiver dentro do conjunto de vagões em loop E os vagões atualmente renderizados, na precisa ordem em que estiverem, DEVEM EXISTIR LINEARMENTE NO LOOP. (Exemplo: Dado um loop [4, 1, 2, 4, 2, 3, 2, 3], temos: Quebrar o loop em [1, 2, 4, 2, 3, 2, 3, 4] é válido, pois o fragmento "3, 2, 3" existe linearmente no loop. Já quebrar o loop em [1, 2, 4, 2, 3, 2, 3, 4] é inválido, já que "2, 3, 4" não existe linearmente no loop (há uma quebra entre "3" e "4"), portanto, breakLoop() não deve ser chamada nesse estado.
	#                                                                                                                                                                                                                                                                                           [0, 0, 0, 0, 1, 1, 1, 0]                                                                                       [0, 0, 0, 0, 0, 1, 1, 1] 
	if looping == 1:
		looping = -1
		var auxStageMap = originalStageMap
		var originalLoopSection = []
		for n in auxStageMap[1]:
			if n == 1:
				n = 0
				break
		for k in loopInterval:
			originalLoopSection.append(originalStageMap[0][k])
		var rightSlidesCount = 0
		while getGlobal().stageMap[0] != originalLoopSection:
			var auxType = getGlobal().stageMap[0][getGlobal().stageMap[0].size() - 1]
			var auxRender = getGlobal().stageMap[1][getGlobal().stageMap[1].size() - 1]
			for l in range(getGlobal().stageMap[0].size() - 1, 0, -1):
				getGlobal().stageMap[0][l] = getGlobal().stageMap[0][l - 1]
				getGlobal().stageMap[1][l] = getGlobal().stageMap[1][l - 1]
			getGlobal().stageMap[0][0] = auxType
			getGlobal().stageMap[1][0] = auxRender
			rightSlidesCount += 1
		for i in range(getGlobal().stageMap[1].size()):
			auxStageMap[1][i + loopInterval[0]] = getGlobal().stageMap[1][i]
		for w in get_children():
			if "Wagon" in w.name:
				#Ajustando o wagonIndex de cada vagão atualmente renderizado
				if w.wagonIndex + rightSlidesCount > originalLoopSection.size() - 1:
					w.wagonIndex = w.wagonIndex + rightSlidesCount - originalLoopSection.size()
				else:
					w.wagonIndex = w.wagonIndex + rightSlidesCount
				w.wagonIndex += loopInterval[0]
		getGlobal().stageMap = auxStageMap
		print(getGlobal().stageMap)
		for node in get_children():
			if "Wagon" in node.name:
				print("X - " + node.name + ": " + "Index = " + str(node.wagonIndex) + "\n")

#Código Incial
func _ready():
	looping = 0
	loopTriggerReady = false
	getGlobal().stageMap = [[1, 2, 1, 1, 2, 3, 4, 3, 2, 1, 1, 1, 2, 2, 3, 3, 1, 4, 2, 1, 1, 2, 4, 3, 1, 4, 1, 2, 4, 2, 3, 2, 3], #Tipo de vagão
						    [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] #Estado de renderização (0: Não renderizado; 1: Renderizado)
	get_node("Wagon1").wagonIndex = 2 #O estado de renderização do índice do vagão inicial em stageMap[1][wagonIndexOrigem] deve começar como 1.
	originalStageMap = getGlobal().stageMap

#Código Principal
func _physics_process(delta):
	if Input.is_action_just_pressed("CG_INTERACT"):
		breakLoop()
	if Input.is_action_just_pressed("CG_UP"):
		print(getGlobal().stageMap[0])
		print(getGlobal().stageMap[1],'\n')
		print(looping)
	if Input.is_action_just_pressed("CG_SHOOT"):
		for node in get_children():
			if "Wagon" in node.name:
				print(node.name + ": " + "Index = " + str(node.wagonIndex) + "\n")
	if looping == 0:
		#Se os únicos vagões atualmente renderizados estão contidos no intervalo de loop, o loop precisa começar.
		for i in range(getGlobal().stageMap[0].size()):
			if !(i in loopInterval):
				if getGlobal().stageMap[1][i] == 1:
					loopTriggerReady = false
					break
			else:
				if getGlobal().stageMap[1][i] == 1:
					loopTriggerReady = true
		if loopTriggerReady:
			var auxList = [[], []]
			var auxIndex = null
			for i in range(getGlobal().stageMap[0].size()):
				if i in loopInterval:
					if auxIndex == null:
						auxIndex = i
					auxList[0].append(getGlobal().stageMap[0][i])
					auxList[1].append(getGlobal().stageMap[1][i])
			getGlobal().stageMap = auxList
			for node in get_children():
				if "Wagon" in node.name:
					node.wagonIndex -= auxIndex
			looping = 1
	elif looping == 1:
		#Se o jogador está a uma certa distância das "pontas" do array, remonte o array com o último/primeiro elemento sendo o primeiro/último (lembre-se de ajustar os wagonIndexes dos vagões ao fazer isso).
		for node in get_children():
			if "Wagon" in node.name:
				#Ponta direita do loop
				if node.wagonIndex == loopInterval.size() - 1 and abs(getPlayer().position.x - node.position.x) <= 210:
					getGlobal().stageMap[0].append(getGlobal().stageMap[0][0])
					getGlobal().stageMap[0].remove(0)
					getGlobal().stageMap[1].append(0)
					getGlobal().stageMap[1].remove(0)
					for node in get_children():
						if "Wagon" in node.name:
							node.wagonIndex -= 1
				#Ponta esquerda do loop
				if node.wagonIndex == 0 and abs(getPlayer().position.x - node.position.x) <= 210:
					getGlobal().stageMap[0].insert(0, getGlobal().stageMap[0][loopInterval.size() - 1])
					getGlobal().stageMap[0].remove(loopInterval.size())
					getGlobal().stageMap[1].insert(0, 0)
					getGlobal().stageMap[1].remove(loopInterval.size())
					for node in get_children():
						if "Wagon" in node.name:
							node.wagonIndex += 1