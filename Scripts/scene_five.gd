extends Node2D

func _ready() -> void:
	
	await $TextBox.say("Narrator", "You get in line for lunch. Everyone seems to be sitting by gender.")
	$kai.visible = true
	var who = await $TextBox.ask("Kai", "(Kai moves his bag from next to him.)\nI'm not asking which table you're from. Who are you?", [])
	player.state["accounts"].append(who)
	await $TextBox.say("Narrator", "Nothing on your silhouette changes. This time, no one was keeping count.")
	
	var response = 0
	var record = player.state["record"]
	var heard = record[-1] if record.size() > 0 else "Student was in the hallway this morning."
	var question = "Dev told me something.\n\"" + heard + "\"\nI only know what I heard. Tell me the rest."
	var options = ["Not exactly...", "Yeah.", "Ask Dev"]
	if player.state["unlocked"]:
		options.append("Stay silent.")
	response = await $TextBox.ask("Kai", question, options)
	
	if response == 0:
		var retelling = await $TextBox.ask("You", "What actually happened... ", [])
		player.state["accounts"].append(retelling)
		var repeated = player.retell(retelling)
		player.state["record"].append(repeated)
		await $TextBox.say("Kai", "Ok, so: " + repeated)
	elif response == 1:
		await $TextBox.say("Kai", "Okay.")
	elif response == 2:
		await $TextBox.say("Kai", "*laughs*")
	elif response == 3:
		# silence is read as a boundary, not as guilt
		player.state["silent"] = true
		await $TextBox.say("Kai", "You don't have to.")
	
	# Kai's word sticks as a tag, no accept/rework/refuse for this one
	var word = "brave"
	var line = "You seem braver than you look."
	if player.state["silent"]:
		word = "hard to read"
		line = "You're hard to read. In a good way."
	elif player.state["reads"]["conduct"] <= -2:
		word = "stubborn"
		line = "You're stubborn. I mean it nicely."
	elif player.state["reads"]["conduct"] >= 2:
		word = "careful"
		line = "You're careful. Like you check twice."
	# the tag lands on the silhouette as Kai says it
	player.add_tag(word, "Kai, lunch")
	await $TextBox.say("Kai", line)

	scene_manager.change_scene("res://Scenes/ending.tscn")
