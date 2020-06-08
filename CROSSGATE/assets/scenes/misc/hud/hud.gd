#Esta cena deve ser nó de "Player" para funcionar.
extends CanvasLayer

#Constantes
const SCRIPT_TYPE = "HUD"

#Funções
func update():
	updateLifepoints()
	updateEtherpoints()

func updateLifepoints():
	$StatusBars/HP/TextureProgress.value = (float(get_parent().lifepoints)/float(get_parent().maxLifepoints))*100

func updateEtherpoints():
	$StatusBars/EP/TextureProgress.value = (float(get_parent().etherpoints)/float(get_parent().maxEtherpoints))*100

#Código Principal
func _physics_process(delta):
	if $StatusBars/DELAY/TextureProgress.value > $StatusBars/HP/TextureProgress.value and $Timers/DELAY_SPEED.is_stopped():
		$Timers/DELAY_SPEED.start()
	elif $StatusBars/DELAY/TextureProgress.value <= $StatusBars/HP/TextureProgress.value:
		$Timers/DELAY_SPEED.stop()

func _on_DELAY_SPEED_timeout():
	$StatusBars/DELAY/TextureProgress.value -= 1
