extends CanvasLayer

# One text box for every scene. Instance Scenes/text_box.tscn, then:
#   await $TextBox.say("Dev", "line")             waits for the player to advance
#   var i = await $TextBox.ask("You", "line", [])  waits for a button, returns its index
#   $TextBox.prompt("You", "line")                 shows a line and locks advancing,
#                                                  for when the scene has its own buttons

signal advanced
signal chosen(index)

const CHARS_PER_SECOND = 55.0

var typing = false
var locked = false
var shown = 0.0

@onready var name_plate = $Root/NamePlate
@onready var speaker = $Root/NamePlate/Speaker
@onready var text = $Root/Box/VBox/Text
@onready var choices = $Root/Box/VBox/Choices
@onready var mark = $Root/ContinueMark

func _ready() -> void:
	# little pulse on the continue arrow
	var pulse = create_tween().set_loops()
	pulse.tween_property(mark, "modulate:a", 0.25, 0.6)
	pulse.tween_property(mark, "modulate:a", 1.0, 0.6)

func say(who: String, line: String) -> void:
	show_line(who, line)
	await advanced

func ask(who: String, line: String, options: Array) -> int:
	show_line(who, line)
	locked = true
	for i in options.size():
		var button = Button.new()
		button.text = options[i]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_choice_pressed.bind(i))
		choices.add_child(button)
	return await chosen

func prompt(who: String, line: String) -> void:
	show_line(who, line)
	locked = true

func show_line(who: String, line: String) -> void:
	for button in choices.get_children():
		button.queue_free()
	choices.visible = false
	locked = false
	name_plate.visible = who != ""
	speaker.text = who
	text.text = line
	text.visible_characters = 0
	mark.visible = false
	shown = 0.0
	typing = true

func _process(delta: float) -> void:
	if not typing:
		return
	shown += CHARS_PER_SECOND * delta
	text.visible_characters = int(shown)
	if shown >= text.get_total_character_count():
		finish_typing()

func finish_typing() -> void:
	typing = false
	text.visible_characters = -1
	if locked:
		choices.visible = choices.get_child_count() > 0
	else:
		mark.visible = true

func advance() -> void:
	if typing:
		finish_typing()
	elif not locked:
		advanced.emit()

func _unhandled_input(event: InputEvent) -> void:
	var clicked = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if clicked or event.is_action_pressed("ui_accept"):
		advance()

func _on_choice_pressed(index: int) -> void:
	if not locked:
		return
	locked = false
	for button in choices.get_children():
		button.queue_free()
	choices.visible = false
	chosen.emit(index)
