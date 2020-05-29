extends Node2D

var PLAYERSCENE = preload("res://Scenes/Player.tscn")

func _init():
	randomize()

func _ready():
	$CurrentPlayer/Player.connect("Died", self, "PlayerDied")
	Global.Slimes = 1

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _process(delta):
	$Camera2D.set_position($CurrentPlayer/Player.get_position())

func PlayerDied():
	var deadPlayersNode = $DeadPlayers
	var player = $CurrentPlayer/Player
	$CurrentPlayer.remove_child(player)
	deadPlayersNode.add_child(player)
	player.set_owner(deadPlayersNode)
	
	var newPlayer = PLAYERSCENE.instance()
	newPlayer.set_position(Global.RespawnPosition)
	newPlayer.connect("Died", self, "PlayerDied")
	$CurrentPlayer.add_child(newPlayer)
	
	Global.Slimes += 1

func _on_Exit_body_entered(body):
	$CanvasLayer/ColorRect/Tween.interpolate_property($CanvasLayer/ColorRect, "color", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CanvasLayer/ColorRect/Tween.start()

func _on_Tween_tween_all_completed():
	get_tree().change_scene("res://Scenes/End.tscn")
