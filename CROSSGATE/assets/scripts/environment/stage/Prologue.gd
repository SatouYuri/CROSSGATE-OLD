extends Node2D

#Constantes
const SCRIPT_TYPE = "Stage"
var loopInterval = range(2,8) #(Range retorna uma lista) Vagões com wagonIndex pertencentes a esse intervalo (a <= wagonIndex < b) entrarão em loop (se looping==true) assim que o jogador adentrá-lo (quando o último vagão fora do intervalo for desinstanciado).

#Variáveis de Estado
var looping : bool
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

#Código Incial
func _ready():
	looping = false
	loopTriggerReady = false
	getGlobal().stageMap = [[1, 1, 2, 2, 2, 3, 2, 3], #Tipo de vagão
						    [1, 0, 0, 0, 0, 0, 0, 0]] #Estado de renderização (0: Não renderizado; 1: Renderizado)
	get_node("Wagon1").wagonIndex = 0 #O estado de renderização do índice do vagão inicial em stageMap[1][wagonIndexOrigem] deve começar como 1.
	originalStageMap = getGlobal().stageMap[0]

#Código Principal
func _physics_process(delta):
	if !looping:
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
			looping = true
	else:
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
		#NOTA / WIP: Depois, implementar o comportamento ao desligar o loop (looping==false)...