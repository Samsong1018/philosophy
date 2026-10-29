extends Node2D

func _ready() -> void:
	var friction = player.state["friction"]
	var startLine = ""
	if friction >= 2:
		startLine = "Something in that room changed. Not the door. The room. \nBefore I tell you what: who are you?"
	else:
		startLine = "No one looked at you in there. That is what it looks like when it works. \nWho are you?"
	
	var reply = await $TextBox.ask("??", startLine, [])
	player.state["accounts"].append(reply)
	
	if reply != "":
		await $TextBox.say("??", "Those are the words you have. Who gave them to you?")
		await $TextBox.say("??", "You will be asked again. Not by me.")
	else:
		await $TextBox.say("??", "Silence is also an answer. I heard it.")

	# the world made these unintelligible until now
	player.unlock()
	scene_manager.change_scene("res://Scenes/scene_four.tscn")
