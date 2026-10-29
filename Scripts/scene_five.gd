extends Node2D

func _ready() -> void:
	if player.state["clothes"] == 1:
		$player/clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	elif player.state["clothes"] == 0:
		$player/clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")
	
	await $TextBox.say("Narrator", "You get in line for lunch. Everyone seems to be sitting by gender.")
	$kai.visible = true
	var who = await $TextBox.ask("Kai", "(Kai moves his bag from next to him.)\nI'm not asking which table you're from. Who are you?", [])
	player.state["accounts"].append(who)
	await $TextBox.say("Narrator", "Nothing on your silhouette changes. This time, no one was keeping count.")
	
	var response = 0
	var record = player.state["record"]
	var heard = record[-1] if record.size() > 0 else "Student was in the hallway this morning."
	var question = "Dev told me something.\n\"" + heard + "\"\nI only know what I heard. Tell me the rest."
	response = await $TextBox.ask("Kai", question, ["Not exactly...", "Yeah.", "Ask Dev"])
	
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
	
	# Kai's word sticks as a tag, no accept/rework/refuse for this one
	var word = "brave"
	if player.state["reads"]["conduct"] <= -2:
		word = "stubborn"
		await $TextBox.say("Kai", "You're stubborn. I mean it nicely")
	elif player.state["reads"]["conduct"] >= 2:
		word = "careful"
		await $TextBox.say("Kai", "You're careful. Like you check twice.")
	else:
		await $TextBox.say("Kai", "You seem braver than you look.")
	player.state["tags"].append(word)
	player.state["tag_sources"][word] = "Kai, lunch"
	
	scene_manager.change_scene("res://Scenes/ending.tscn")
