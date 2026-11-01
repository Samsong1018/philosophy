extends CanvasLayer

# Autoload. scene_manager.change_scene("res://Scenes/x.tscn") fades out, swaps, fades in.
# Don't await it from a scene, the scene gets freed during the swap.

const FADE_TIME = 0.4

var busy = false
var fade = ColorRect.new()

func _ready() -> void:
	layer = 100
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fade)

func change_scene(path: String) -> void:
	if busy:
		return
	busy = true
	player.clamp_reads()
	# block clicks while the screen is fading
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, FADE_TIME)
	await tween.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, FADE_TIME)
	await tween.finished
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false
