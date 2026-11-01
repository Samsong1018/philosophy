extends Control

func _on_start_pressed() -> void:
	player.reset()
	scene_manager.change_scene("res://Scenes/scene_one.tscn")
