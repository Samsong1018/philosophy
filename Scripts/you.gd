extends Node

signal tags_changed

var state = {
	"name": "",
	"reads": {
		"gender": 0,
		"conduct": 0,
		"belong": 0
	},
	"phone": false,
	"clothes": -1,
	"friction": 0,
	"tags": [],
	"tag_sources": {},
	"tag_origins": {},
	"tag_relations": {},
	"unlocked": false,
	"silent": false,
	"accounts": [],
	"actions": [],
	"record": [],
	"reflex_state": 0
}

const SAVE_PATH = "user://save.cfg"

# new run: wipe the day, keep only what the first run unlocked
func reset() -> void:
	var unlocked = state["unlocked"]
	state["name"] = ""
	state["reads"] = {"gender": 0, "conduct": 0, "belong": 0}
	state["phone"] = false
	state["clothes"] = -1
	state["friction"] = 0
	state["tags"] = []
	state["tag_sources"] = {}
	state["tag_origins"] = {}
	state["tag_relations"] = {}
	state["unlocked"] = unlocked
	state["silent"] = false
	state["accounts"] = []
	state["actions"] = []
	state["record"] = []
	state["reflex_state"] = randi_range(0, 1)
	tags_changed.emit()

# reads live in -10..10
func clamp_reads() -> void:
	for read in state["reads"]:
		state["reads"][read] = clampi(state["reads"][read], -10, 10)

func _ready() -> void:
	state["reflex_state"] = randi_range(0, 1)
	# a replay keeps what the first run unlocked
	var save = ConfigFile.new()
	if save.load(SAVE_PATH) == OK:
		state["unlocked"] = save.get_value("flags", "unlocked", false)

# after the god first asks, options that were not on screen before appear
func unlock() -> void:
	state["unlocked"] = true
	var save = ConfigFile.new()
	save.set_value("flags", "unlocked", true)
	save.save(SAVE_PATH)

# what NPCs repeat back: only the first clause survives, the qualifiers are dropped
func first_clause(text: String) -> String:
	var clause = text
	for cut in [",", ";", ".", " but ", " because ", " though "]:
		var at = clause.find(cut)
		if at > 0:
			clause = clause.substr(0, at)
	return clause.strip_edges()

# "Student claims ..." version of something the player said (goes in record)
func retell(text: String) -> String:
	var clause = first_clause(text)
	if clause == "":
		return "Student claims nothing."
	return "Student claims " + clause + "."

# a tag forms and the player picks a relation to it: accept, rework or refuse.
# the relation changes how the tag behaves, never the read itself (refusing costs belong)
func offer_tag(box, tag: String, source: String) -> void:
	var word = tag
	var relation = await box.ask("???", "You just received a new tag: " + tag + "\n(" + source + ")", ["Accept", "Rework", "Refuse"])
	if relation == 1:
		var typed = await box.ask("You", "What would you call it instead? (3 words max)")
		var words = typed.split(" ", false)
		if words.size() > 0:
			word = " ".join(words.slice(0, 3))
	elif relation == 2:
		state["reads"]["belong"] -= 1
	add_tag(word, source, ["accept", "rework", "refuse"][relation], tag)

# store a tag, origin is the word the world gave before any rework
func add_tag(word: String, source: String, relation: String = "accept", origin: String = "") -> void:
	state["tags"].append(word)
	state["tag_sources"][word] = source
	state["tag_origins"][word] = origin if origin != "" else word
	state["tag_relations"][word] = relation
	tags_changed.emit()

func remove_tag(word: String) -> void:
	state["tags"].erase(word)
	state["tag_sources"].erase(word)
	state["tag_origins"].erase(word)
	state["tag_relations"].erase(word)
	tags_changed.emit()

# the word currently standing in for boy/girl (even if reworked or refused), "" if none
func gender_tag() -> String:
	for word in state["tags"]:
		if state["tag_origins"].get(word, word) in ["boy", "girl"]:
			return word
	return ""

# how NPCs say a tag: a reworked word gets bent a little
func tag_as_heard(word: String) -> String:
	if state["tag_relations"].get(word, "") == "rework":
		return "sort of " + word
	return word

func has_origin(word: String) -> bool:
	return word in state["tag_origins"].values()

# conduct and belong become tags once they get strong enough (gender is handled in scene 2)
func check_read_tags(box) -> void:
	var words = {
		"conduct": [["trouble", "good kid"], "Ms. Alvarez, class"],
		"belong": [["loner", "in"], "your classmates"]
	}
	for read in words:
		var value = state["reads"][read]
		if abs(value) >= 3:
			var word = words[read][0][0 if value < 0 else 1]
			if not has_origin(word):
				await offer_tag(box, word, words[read][1])

# a small plate: the tag word with who gave it underneath
func make_plate(word: String, source: String) -> PanelContainer:
	var plate = PanelContainer.new()
	plate.theme_type_variation = &"NamePlate"
	var box = VBoxContainer.new()
	var title = Label.new()
	title.theme_type_variation = &"NamePlateLabel"
	title.text = word
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var small = Label.new()
	small.theme_type_variation = &"NamePlateLabel"
	small.add_theme_font_size_override("font_size", 12)
	small.text = source
	small.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	box.add_child(small)
	plate.add_child(box)
	return plate
