extends CanvasLayer
 
# One text box for every scene. Instance Scenes/text_box.tscn, then:
#   await $TextBox.say("Dev", "line")                   waits for the player to advance
#   var i = await $TextBox.ask("You", "line", ["A","B"]) waits for a button, returns its index (int)
#   var s = await $TextBox.ask("You", "line")            waits for typed text + Submit, returns a String
#   $TextBox.prompt("You", "line")                       shows a line and locks advancing,
#                                                        for when the scene has its own buttons
 
signal advanced
signal chosen(value)
 
const CHARS_PER_SECOND = 55.0
const MAX_INPUT_LENGTH = 30
 
var typing = false
var locked = false
var shown = 0.0
var input_field: LineEdit = null
 
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
 
# options empty -> text input + submit button, returns the String
# options filled -> buttons, returns the int index
func ask(who: String, line: String, options: Array = []):
	show_line(who, line)
	locked = true
	if options.is_empty():
		_build_text_input()
	else:
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
 
func _build_text_input() -> void:
	var row = HBoxContainer.new()
	input_field = LineEdit.new()
	input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_field.placeholder_text = "Type your answer..."
	input_field.max_length = MAX_INPUT_LENGTH
	var submit = Button.new()
	submit.text = "Submit"
	submit.focus_mode = Control.FOCUS_NONE
	# Enter key and the Submit button both go through the same path
	input_field.text_submitted.connect(func(_t): _submit_text())
	submit.pressed.connect(_submit_text)
	row.add_child(input_field)
	row.add_child(submit)
	choices.add_child(row)
 
func _submit_text() -> void:
	if not locked or input_field == null:
		return
	var value = input_field.text.strip_edges()
	if value == "":
		return
	locked = false
	_clear_choices()
	chosen.emit(value)
 
func _on_choice_pressed(index: int) -> void:
	if not locked:
		return
	locked = false
	_clear_choices()
	chosen.emit(index)
 
func _clear_choices() -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
	choices.visible = false
	input_field = null
 
func show_line(who: String, line: String) -> void:
	_clear_choices()
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
		if input_field:
			input_field.grab_focus()
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
 
