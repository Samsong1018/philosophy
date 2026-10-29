extends Node2D

func _ready() -> void:
	# if the world couldn't read you in the bathroom, she can't either
	if player.has_origin("??"):
		$teacher.texture = load("res://Assets/char_alvarez_blank.svg")

	await $TextBox.say("Narrator", "You arrived at first period...")
	await $TextBox.say("Ms. Alvarez", "A phone was taken in the hallway this morning. I'd like to settle this quietly.")
	# options are built conditionally, so match on the text, not the index
	var options = ["No.", "Why are you asking me?"]
	if player.state["phone"]:
		options.insert(0, "I picked it up to give it back.")
	# the god's question made these unintelligible until now
	if player.state["unlocked"]:
		options.append("Stay silent.")
		options.append("Who is asking, and what happens to my answer?")

	var question = "(she looks at you) Was it you?"
	if not player.state["phone"] and player.state["reads"]["conduct"] > -1:
		# never created friction, so you're a witness, not a suspect
		question = "Did anyone see anything?"

	var said = options[await $TextBox.ask("Ms. Alvarez", question, options)]

	# optional free text for the first three answers, it goes in accounts
	var free = ""
	if not said in ["Stay silent.", "Who is asking, and what happens to my answer?"]:
		free = await $TextBox.ask("You", "Say it in your own words. (optional)")
		if free != "":
			player.state["accounts"].append(free)

	var written = ""
	match said:
		"I picked it up to give it back.":
			player.state["reads"]["conduct"] += 1
			written = "Student admits to taking the phone."
			await $TextBox.say("Ms. Alvarez", "Then give it back.")
		"No.":
			written = "Student denies involvement. Did not elaborate."
			if player.state["phone"]:
				player.state["reads"]["conduct"] -= 1
				await $TextBox.say("Narrator", "That is not the whole story, and you both know it.")
			else:
				await $TextBox.say("Ms. Alvarez", "We'll see.")
		"Why are you asking me?":
			player.state["reads"]["conduct"] -= 1
			player.state["reads"]["belong"] += 1
			player.state["friction"] += 1
			written = "Student became defensive."
		"Stay silent.":
			player.state["reads"]["conduct"] -= 1
			player.state["friction"] += 1
			player.state["silent"] = true
			written = "Student declined to answer."
			await $TextBox.say("Ms. Alvarez", "Silence is not an answer.")
		"Who is asking, and what happens to my answer?":
			player.state["friction"] += 1
			await $TextBox.say("Ms. Alvarez", "I'm asking because a phone is gone.")

	# she writes it down, her version of free text is a retelling
	if free != "":
		written = player.retell(free)
	if written != "":
		player.state["record"].append(written)

	if player.state["reads"]["conduct"] <= -3:
		player.state["record"].append("Detention Slip")

	await player.check_read_tags($TextBox)

	scene_manager.change_scene("res://Scenes/scene_five.tscn")
