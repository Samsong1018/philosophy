extends Node2D

func _ready() -> void:
	if player.state["clothes"] == 1:
		$player/clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	elif player.state["clothes"] == 0:
		$player/clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")

	# what the day kept: three versions of the same life, side by side
	$Columns/Did.text = "WHAT YOU DID\n\n" + "\n".join(player.state["actions"])
	$Columns/Said.text = "WHAT YOU SAID\n\n" + "\n".join(player.state["accounts"])
	$Columns/Wrote.text = "WHAT THEY WROTE\n\n" + "\n".join(player.state["record"])
	var tags = []
	for tag in player.state["tags"]:
		tags.append(tag + " (" + player.state["tag_sources"].get(tag, "unknown") + ")")
	$Columns/Tags.text = "Tags: " + ", ".join(tags)
	$Columns.visible = true
	await $TextBox.say("??", "Here is what the day kept.")
	$Columns.visible = false

	# never shown, never recoverable
	await $TextBox.say("", "Closet stocked by: [unrecoverable]\nWhat your hand knew before you decided: [unrecoverable]\nBefore this morning: [unrecoverable]")

	# the question again, any answer is accepted and none is scored
	var answer = await $TextBox.ask("??", "That is the what. Now: who are you?")
	player.state["accounts"].append(answer)
	await $TextBox.say("??", "That has been given away. You do not get to decide what the next one hears.")

	# role flip: the player's own words come back changed
	$player.visible = true
	$rowan.visible = true
	var said = player.first_clause(answer)
	for lead in ["i am ", "i'm ", "im "]:
		if said.to_lower().begins_with(lead):
			said = said.substr(lead.length())
	if said == "":
		await $TextBox.say("Rowan", "Someone told me you wouldn't say.")
	else:
		await $TextBox.say("Rowan", "Someone told me you're " + said + ".")
	await $TextBox.say("Rowan", "I'm new. They said you'd know where things are.")

	var first = await $TextBox.ask("You", "...", ["What are you? Grade, schedule, anything?", "Who are you?", "I'll show you around."])
	if first == 0:
		await $TextBox.say("Rowan", "Sophomore. Schedule's in my bag.")
		$RowanTags.text = "sophomore"
		await $TextBox.say("Narrator", "You gave them the first question you were given.")
	elif first == 1:
		await $TextBox.say("Rowan", "I'm not sure how to say yet. Ask me tomorrow?")
		await $TextBox.say("Narrator", "You did not need to know who they were to owe them something.")
	else:
		await $TextBox.say("Rowan", "Okay.")
		await $TextBox.say("Narrator", "You offered a place before you asked for an account.")

	# which door
	await $TextBox.ask("Rowan", "Where's the bathroom?", ["GIRLS", "BOYS", "The single-stall by the nurse's office"])
	player.state["actions"].append("Told Rowan which door.")
	await $TextBox.say("Narrator", "You are now one of the people who tells them which door.")

	$Black.visible = true
	$TextBox.visible = false
	$Black/Final.text = "You will never finish giving an account of yourself. Someone is waiting to hear it anyway."
	
	scene_manager.change_scene("res://Scenes/main_screen.tscn")
