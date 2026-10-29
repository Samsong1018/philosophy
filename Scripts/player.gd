extends Node2D

# The silhouette every scene instances: body, clothes, and a plate for each tag.

func _ready() -> void:
	dress()
	refresh_tags()
	player.tags_changed.connect(refresh_tags)

func dress() -> void:
	if player.state["clothes"] == 1:
		$clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
	elif player.state["clothes"] == 0:
		$clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")
	else:
		$clothes.texture = null

# one plate per tag beside the head, stacked downward, the source (who said it) in small text.
# refused tags stay hidden
func refresh_tags() -> void:
	for old in $tags.get_children():
		$tags.remove_child(old)
		old.queue_free()
	# the scene scales the player down, keep the plates a normal size
	$tags.scale = Vector2.ONE / scale
	$tags.position = Vector2(130, -420)

	var plates = []
	for tag in player.state["tags"]:
		if player.state["tag_relations"].get(tag, "") == "refuse":
			continue
		var plate = player.make_plate(tag, player.state["tag_sources"].get(tag, ""))
		$tags.add_child(plate)
		plates.append(plate)

	for i in plates.size():
		plates[i].position = Vector2(0, i * 64)
