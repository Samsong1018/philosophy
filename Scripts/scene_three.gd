extends Node2D

signal picked(side)

func _ready() -> void:
	if player.state["reads"]["gender"] >= 2:
		$Background.texture = load("res://Assets/bg_bathroom_hall_open_boys.svg")
		$studentBoy.visible = true
	elif player.state["reads"]["gender"] <= -2:
		$Background.texture = load("res://Assets/bg_bathroom_hall_open_girls.svg")
		$studentGirl.visible = true

	$TextBox.prompt("You", "I kind of need to use the bathroom... ")
	var side = await picked
	# doors are done, hide them so they can't be clicked again
	$Options.visible = false

	# side matches the sign of the gender read, girls = -1, boys = 1
	var gender = player.state["reads"]["gender"]
	var tag = "girl" if side == -1 else "boy"
	player.state["actions"].append("Went through the " + tag + "s' door.")
	if gender * side < 0:
		# opposite read
		player.state["reads"]["gender"] += side * 2
		player.state["reads"]["belong"] -= 1
		player.state["reads"]["conduct"] -= 1
		player.state["friction"] += 2
		# the tag no longer fits, swap it for ??
		for old in ["boy", "girl"]:
			if old in player.state["tags"]:
				player.state["tags"][player.state["tags"].find(old)] = "??"
				player.state["tag_sources"]["??"] = "the sink"
		await $TextBox.say("Student", "Uh. Wrong one?")
	elif gender * side > 0:
		# leading read
		player.state["reads"]["gender"] += side
		player.state["reads"]["belong"] += 1
		if not tag in player.state["tags"]:
			player.state["tags"].append(tag)
			player.state["tag_sources"][tag] = "the sink, Room 114"
		await $TextBox.say("Narrator", "Nothing happens. That is how you know it went right")
		var pronoun = "she" if side == -1 else "he"
		await $TextBox.say("Other Student", "(To another student) Hey is " + pronoun + " in your chem class?")

	scene_manager.change_scene("res://Scenes/god_one.tscn")

func _on_girls_pressed() -> void:
	picked.emit(-1)

func _on_boys_pressed() -> void:
	picked.emit(1)
