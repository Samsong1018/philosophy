extends Node2D

func _ready() -> void:
	await $TextBox.say("Narrator", "You arrived at school...")

	# dev asks about your side of the school
	$dev.visible = true
	var question = "Oh, I can't tell. Weird."
	if player.state["reads"]["gender"] >= 1:
		question = "You're on the guys' side, yeah?"
	elif player.state["reads"]["gender"] <= -1:
		question = "Oh, you're sitting with girls at lunch, right?"
	var reply = await $TextBox.ask("Dev", question, ["> Yeah.", "> Why does it matter?", "> Depends who's asking."])
	if reply == 0:
		# confirm
		player.state["reads"]["belong"] += 1
		if player.state["reads"]["gender"] == 1:
			player.state["reads"]["gender"] += 1
		elif player.state["reads"]["gender"] == -1:
			player.state["reads"]["gender"] -= 1
		await $TextBox.say("Dev", "Cool.")
	elif reply == 1:
		# deny
		player.state["reads"]["belong"] -= 1
		player.state["reads"]["conduct"] -= 1
		player.state["friction"] += 1
		await $TextBox.say("Dev", "*Shrugs* It doesn't. I was just asking.")
		await $TextBox.say("Dev", "Okay, whatever you say.")
	else:
		# deflect
		await $TextBox.say("Dev", "Okay.")
		await $TextBox.say("Dev", "Okay, whatever you say.")
	$dev.visible = false

	var pickup = await $TextBox.ask("You", "You notice a phone lying on the ground. Do you pick it up?", ["Yes", "No"])
	if pickup == 0:
		player.state["phone"] = true
		player.state["actions"].append("Picked up a phone.")
		$Phone.visible = false
	else:
		player.state["phone"] = false

	# a read this strong becomes a tag
	if abs(player.state["reads"]["gender"]) >= 2:
		var tag = "boy"
		if player.state["reads"]["gender"] <= -2:
			tag = "girl"
		await player.offer_tag($TextBox, tag, "Dev, hallway")

	scene_manager.change_scene("res://Scenes/scene_three.tscn")
