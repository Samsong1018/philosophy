extends Node2D

func _ready() -> void:
	if player.state["clothes"] == 1:
		$player/clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	elif player.state["clothes"] == 0:
		$player/clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")
	
	await $TextBox.say("Narrator", "You arrived at first period...")
	await $TextBox.say("Ms. Alvarez", "A phone was taken in the hallway this morning. I'd like to settle this quietly")
	var response = 0
	if player.state["phone"] == true:
		response = await $TextBox.ask("Ms. Alvarez", "(she looks at you) Was it you?", ["I picked it up to give it back.", "No.", "Why are you asking me?"])
	elif player.state["phone"] == false and player.state["reads"]["conduct"] <= -1:
		response = await $TextBox.ask("Ms. Alvarez", "(she looks at you) Was it you?", ["I picked it up to give it back.", "No.", "Why are you asking me?"])
	else:
		response = await $Textbox.ask("Ms. Alvarez", "Did anyone see anything?", ["I picked it up to give it back.", "No.", "Why are you asking me?"])
	
	if response == 0:
		player.state["reads"]["conduct"] += 1
		player.state["accounts"].append("Student admits to taking the phone")
	elif response == 1 and player.state["phone"] == true:
		await $TextBox.say("Narrator", "That is not the whole story, and you both know it")
		player.state["reads"]["conduct"] -= 1
		player.state["accounts"].append("Student denies involvement, Did not elaborate")
	elif response == 1 and player.state["phone"] == false:
		player.state["reads"]["conduct"] -= 1
		await $TextBox.say("Ms. Alvarez", "We'll see")
		player.state["accounts"].append("Student became defensive")
	elif response == 2:
		player.state["reads"]["conduct"] -= 1
		player.state["reads"]["belong"] += 1
		player.state["friction"] += 1
	
	if player.state["reads"]["conduct"] <= -3:
		player.state["record"].append("Detention Slip")
	
	scene_manager.change_scene("res://Scenes/scene_five.tscn")
