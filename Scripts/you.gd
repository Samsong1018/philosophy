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
	"accounts": [],
	"actions": [],
	"reflex_state": 0
}

func _ready() -> void:
	state["reflex_state"] = randi_range(0, 1)
