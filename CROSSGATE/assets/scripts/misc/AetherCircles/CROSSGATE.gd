extends Node2D

#Código Principal
func _physics_process(delta):
	if modulate.a > 0:
		$Core.rotate(-0.1)
		$Main.rotate(-0.05)
		$External1.rotate(0.05)
		$External2.rotate(0.1)