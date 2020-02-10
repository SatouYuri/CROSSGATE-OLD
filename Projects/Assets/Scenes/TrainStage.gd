extends Node2D

var BGSPEED = -5
var gateList = []

func _ready():
	$Soundtrack.playost("Fading_Soul")
	
func playerPos():
	return $Player.position

func _physics_process(delta):
	$Background/Sky.translate(Vector2(BGSPEED*0.2, 0))
	if $Background/Sky.position.x - $Player.position.x <= -2048:
		$Background/Sky.position.x = $Player.position.x
	
	$Background/Clouds.translate(Vector2(BGSPEED*0.1, 0))
	if $Background/Clouds.position.x - $Player.position.x <= -2048:
		$Background/Clouds.position.x = $Player.position.x
	
	$Background/Dunes.translate(Vector2(BGSPEED*0.3, 0))
	if $Background/Dunes.position.x - $Player.position.x <= -2048:
		$Background/Dunes.position.x = $Player.position.x
		
	$Background/Sand.translate(Vector2(BGSPEED*1, 0))
	if $Background/Sand.position.x - $Player.position.x <= -2048:
		$Background/Sand.position.x = $Player.position.x

func _on_DeathByTheRail_body_entered(body):
	if "Player" in body.name:
		body.dead()
