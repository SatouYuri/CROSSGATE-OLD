extends Node2D

#Constantes
const NONE_FX = 0
const ACTIVATESKILL_FX = 1

#Variáveis de Estado
var playingFX

#Código Inicial
func _ready():
	playingFX = NONE_FX

#Funções
func FX():
	if playingFX == ACTIVATESKILL_FX:
		if $FX/ActivateSkill.scale.x < 15:
			$FX/ActivateSkill.scale.x += 0.25
			$FX/ActivateSkill.scale.y += 0.25
		else:
			$FX/ActivateSkill.scale.x = 0
			$FX/ActivateSkill.scale.y = 0
			$FX/ActivateSkill.modulate.a = 1
			playFX(NONE_FX)
		
		if $FX/ActivateSkill.modulate.a > 0:
			$FX/ActivateSkill.modulate.a -= 0.02

func playFX(fxConstant):
	playingFX = fxConstant

#Código Principal
func _physics_process(delta):
	FX()
	
	if modulate.a > 0:
		$Core.rotate(-0.1)
		$Main.rotate(-0.05)
		$External1.rotate(0.05)
		$External2.rotate(0.1)