extends Node

var state = {
	"name": "",
	"reads": {
		"gender": 0,
		"conduct": 0,
		"belong": 0
	},
	"phone": false,
	"clothes": 0,
	"friction": 0,
	"tags": [],
	"tag_sources": {},
	"accounts": [],
	"actions": [],
	"record": [],
	"reflex_state": 0
}

func _ready() -> void:
	state["reflex_state"] = randi_range(0, 1)

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
