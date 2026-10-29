extends Node2D

signal picked(side)

func _ready() -> void:
	if player.state["reads"]["gender"] >= 2:
		$Background.texture = load("res://Assets/bg_bathroom_hall_open_boys.svg")
		$studentBoy.visible = true
	elif player.state["reads"]["gender"] <= -2:
		$Background.texture = load("res://Assets/bg_bathroom_hall_open_girls.svg")
		$studentGirl.visible = true

	# the single stall only exists once the god has asked
	if player.state["unlocked"]:
		var stall = Button.new()
		stall.text = "Single stall (by the nurse's office)"
		stall.position = Vector2(400, 20)
		stall.pressed.connect(func(): picked.emit(0))
		$Options.add_child(stall)

	$TextBox.prompt("You", "I kind of need to use the bathroom... ")
	var side = await picked
	# doors are done, hide them so they can't be clicked again
	$Options.visible = false

	if side == 0:
		player.state["actions"].append("Used the single stall.")
		scene_manager.change_scene("res://Scenes/god_one.tscn")
		return

	# open the door that was picked, a student is always at the sink inside
	$Background.texture = load("res://Assets/bg_bathroom_hall_open_girls.svg") if side == -1 else load("res://Assets/bg_bathroom_hall_open_boys.svg")
	$studentGirl.visible = side == -1
	$studentBoy.visible = side == 1

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
		# the world can't read you, the student's face draws as a blank oval
		$studentGirl.texture = load("res://Assets/char_student_sink_blank.svg")
		$studentBoy.texture = load("res://Assets/char_student_sink_boy_blank.svg")
		# the tag no longer fits, swap it for ??
		player.remove_tag(player.gender_tag())
		await $TextBox.say("Student", "Uh. Wrong one?")
		await player.offer_tag($TextBox, "??", "the sink")
	elif gender * side > 0:
		# leading read
		player.state["reads"]["gender"] += side
		player.state["reads"]["belong"] += 1
		await $TextBox.say("Narrator", "Nothing happens. That is how you know it went right.")
		var pronoun = "she" if side == -1 else "he"
		await $TextBox.say("Other Student", "(To another student) Hey is " + pronoun + " in your chem class?")
		# nobody asked you, the label forms anyway (unless you already have one)
		if player.gender_tag() == "":
			await player.offer_tag($TextBox, tag, "the sink, Room 114")

	scene_manager.change_scene("res://Scenes/god_one.tscn")

func _on_girls_pressed() -> void:
	picked.emit(-1)

func _on_boys_pressed() -> void:
	picked.emit(1)
