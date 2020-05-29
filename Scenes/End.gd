extends Control

func _ready():
	$Label2.text = """It took you """ + str(Global.Slimes) + """ slimes.
Press R to retry."""
	$ColorRect/Tween.interpolate_property($ColorRect, "color", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$ColorRect/Tween.start()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event.is_action_pressed("respawn"):
		get_tree().change_scene("res://Scenes/Main.tscn")
