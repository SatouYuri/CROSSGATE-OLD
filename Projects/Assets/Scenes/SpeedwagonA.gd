extends Node2D

#Esse script é utilizado por SpeedwagonA.tscn, SpeedwagonB.tscn, SpeedwagonC.tscn, 

const FADEFACTOR = 0.01

var fadeMode = 0 # -1 para fadeOut e 1 para fadeIn

func _physics_process(delta):
	pass

func _on_OPACITY_REDUCE_Area2D_body_entered(body):
	if "Player" in body.name:
		fadeMode = -1
		$Timer.start()

func _on_OPACITY_REDUCE_Area2D_body_exited(body):
	if "Player" in body.name:
		fadeMode = 1
		$Timer.start()

func _on_Timer_timeout():
	if fadeMode == -1:
		if modulate.a > 0.65:
			modulate.a -= FADEFACTOR
	elif fadeMode == 1:
		if modulate.a != 1:
			modulate.a += FADEFACTOR