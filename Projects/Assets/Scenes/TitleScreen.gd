extends Node

func _ready():
	$MarginContainer/VBoxContainer/VBoxContainer/TextureButton.grab_focus()
	$Soundtrack.playost("An_Endless_Railroad")

func _physics_process(delta):
	if $MarginContainer/VBoxContainer/VBoxContainer/TextureButton.is_hovered() == true:
		$MarginContainer/VBoxContainer/VBoxContainer/TextureButton.grab_focus()

func _on_TextureButton_pressed():
	$Soundtrack.stop()
	get_tree().change_scene("res://Assets/Scenes/TrainStage.tscn")
