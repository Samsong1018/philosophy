extends Node2D

func _ready() -> void:
	if player.state["clothes"] == 1:
		$player/clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	elif player.state["clothes"] == 0:
		$player/clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")
	
	await $TextBox.say("Narrator", "You arrived at first period...")
	await $TextBox.say("Ms. Alvarez", "A phone was taken in the hallway this morning. I'd like to settle this quietly")
	# options are built conditionally, so match on the text, not the index
	var options = ["No.", "Why are you asking me?"]
	if player.state["phone"]:
		options.insert(0, "I picked it up to give it back.")

	var question = "(she looks at you) Was it you?"
	if not player.state["phone"] and player.state["reads"]["conduct"] > -1:
		# never created friction, so you're a witness, not a suspect
		question = "Did anyone see anything?"

	var pick = await $TextBox.ask("Ms. Alvarez", question, options)
	match options[pick]:
		"I picked it up to give it back.":
			player.state["reads"]["conduct"] += 1
			player.state["record"].append("Student admits to taking the phone.")
			await $TextBox.say("Ms. Alvarez", "Then give it back.")
		"No.":
			player.state["record"].append("Student denies involvement. Did not elaborate.")
			if player.state["phone"]:
				player.state["reads"]["conduct"] -= 1
				await $TextBox.say("Narrator", "That is not the whole story, and you both know it.")
			else:
				await $TextBox.say("Ms. Alvarez", "We'll see.")
		"Why are you asking me?":
			player.state["reads"]["conduct"] -= 1
			player.state["reads"]["belong"] += 1
			player.state["friction"] += 1
			player.state["record"].append("Student became defensive.")

	if player.state["reads"]["conduct"] <= -3:
		player.state["record"].append("Detention Slip")
	
	scene_manager.change_scene("res://Scenes/scene_five.tscn")
