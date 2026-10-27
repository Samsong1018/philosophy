extends Node2D

func _ready() -> void:
	await $TextBox.say("You", "You are awake. You don't remember deciding to go to school today. You never remember deciding.")
	var pick = await $TextBox.ask("You", "The closet is already full. Someone stocked it before you had an opinion", ["Jeans/Tshirt", "Skirt/Shirt"])

	if pick == 0:
		player.state["reads"]["gender"] += 1
		player.state["clothes"] = 1
		$Player/Clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	else:
		player.state["reads"]["gender"] -= 1
		player.state["clothes"] = 0
		$Player/Clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")

	# reflex_state 1 = hand goes to the jeans first, 0 = the skirt
	if pick == 1 - player.state["reflex_state"]:
		await $TextBox.say("You", "Your hand went there before you decided.")
	else:
		await $TextBox.say("You", "Your hand went to the other pile first. You moved it.")
		player.state["friction"] += 1

	await $TextBox.say("Mother", "You look nice. Is that what you're wearing today?")
	scene_manager.change_scene("res://Scenes/scene_two.tscn")
