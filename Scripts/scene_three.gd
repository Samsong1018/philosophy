extends Node2D

var phase = 1
var patha = 2

func next():
	if phase != 1:
		phase += 1
		if phase == 5 && patha == 1:
			$TextBox/Speaker.text = "Other Student"
			if player.state.reads.gender <= -1:
				$TextBox/Text.text = "(To another student) Hey is she in your chem class?"
			else:
				$TextBox/Text.text = "(To another student) Hey is he in your chem class?"
		elif phase == 5 && patha == 0:
			get_tree().change_scene_to_file("res://Scenes/god_one.tscn")
		if phase >= 7:
			get_tree().change_scene_to_file("res://Scenes/god_one.tscn")

func _ready() -> void:
	if player.state.reads.gender >= 2:
		$Background.texture = load("res://Assets/bg_bathroom_hall_open_boys.svg")
		$studentBoy.visible = true
	elif player.state.reads.gender <= -2:
		$Background.texture = load("res://Assets/bg_bathroom_hall_open_girls.svg")
		$studentGirl.visible = true

func _on_girls_pressed() -> void:
	if player.state["reads"]["gender"] >= 1:
		$TextBox/Speaker.text = "Student"
		$TextBox/Text.text = "Uh. Wrong one?"
		# opposite read
		patha = 0
		player.state["reads"]["gender"] -= 2
		player.state["reads"]["belong"] -= 1
		player.state["friction"] += 2
		if "boy" in player.tags or "girl" in player.tags:
			player.tags.pop()
			player.tags.append("??")
	elif player.state["reads"]["gender"] <= -1:
		# leading read
		player.state["reads"]["gender"] -= 1
		player.state["reads"]["belong"] += 1
		$TextBox/Speaker.text = "Narrator"
		$TextBox/Text.text = "Nothing happens. That is how you know it went right"
		patha = 1
		if not "girl" in player.tags:
			player.state.tags.append("girl")
	phase += 2
	next()

func _on_boys_pressed() -> void:
	if player.state["reads"]["gender"] <= -1:
		$TextBox/Speaker.text = "Student"
		$TextBox/Text.text = "Uh. Wrong one?"
		# opposite read
		patha = 0
		player.state["reads"]["gender"] += 2
		player.state["reads"]["belong"] -= 1
		player.state["friction"] += 2
		if "boy" in player.tags or "girl" in player.tags:
			player.tags.pop()
			player.tags.append("??")
	elif player.state["reads"]["gender"] >= 1:
		# leading read
		player.state["reads"]["gender"] += 1
		player.state["reads"]["belong"] += 1
		$TextBox/Speaker.text = "Narrator"
		$TextBox/Text.text = "Nothing happens. That is how you know it went right"
		patha = 1
		if not "boy" in player.state["tags"]:
			player.state.tags.append("boy")
	phase += 2
	next()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		next()
