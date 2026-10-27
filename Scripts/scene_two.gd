extends Node2D

func _ready() -> void:
	if player.state["clothes"] == 1:
		$player/clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	elif player.state["clothes"] == 0:
		$player/clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")

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
		await $TextBox.say("Dev", "*Shrugs* It doesn't. I was just asking")
	else:
		# deflect
		await $TextBox.say("Dev", "Okay")
	$dev.visible = false

	var pickup = await $TextBox.ask("You", "You notice a phone lying on the ground. Do you pick it up?", ["Yes", "No"])
	if pickup == 0:
		player.state["phone"] = true
		$Phone.visible = false
	else:
		player.state["phone"] = false

	# a read this strong becomes a tag
	if abs(player.state["reads"]["gender"]) >= 2:
		var tag = "boy"
		if player.state["reads"]["gender"] <= -2:
			tag = "girl"
		var relation = await $TextBox.ask("???", "You just received a new tag: " + tag + ". Do you choose to accept?", ["Accept", "Rework", "Refuse"])
		if relation == 0:
			player.state["tags"].append(tag)
		else:
			# TODO: rework should let the player type a replacement word (max 3 words),
			# refuse should hide the tag and cost belong -1. Both just halve the read for now
			player.state["reads"]["gender"] /= 2

	scene_manager.change_scene("res://Scenes/scene_three.tscn")
