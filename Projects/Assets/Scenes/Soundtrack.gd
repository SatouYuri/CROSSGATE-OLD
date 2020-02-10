extends Node2D

var playing = false
var current_song

func playost(song_name):
	if song_name == "An_Endless_Railroad":
		current_song = $An_Endless_Railroad
		$An_Endless_Railroad.play()
		playing = true
		
	elif song_name == "Time_Dust":
		current_song = $Time_Dust
		$Time_Dust.play()
		playing = true
		
	elif song_name == "The_Ancients_Lost_Hope":
		current_song = $The_Ancients_Lost_Hope
		$The_Ancients_Lost_Hope.play()
		playing = true
		
	elif song_name == "Fading_Soul":
		current_song = $Fading_Soul
		$Fading_Soul.play()
		playing = true

func stop():
	if playing == true:
		playing = false
		current_song.stop()
		
func _physics_process(delta):
	pass