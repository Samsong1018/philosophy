# Philosophy (working title: Asked)

Godot 4.7 visual novel. Script is in `Script.pdf`. This README only covers how to build the remaining scenes with what's already here.

## What's left (per the script)

| Scene | File to make | Status |
|---|---|---|
| God (after bathroom) | `god_one.tscn` | empty placeholder, `scene_three.gd` already sends you here |
| 4: Class (Ms. Alvarez) | `scene_four.tscn` + `scene_four.gd` | not started |
| 5: Lunch (Kai) | `scene_five.tscn` + `scene_five.gd` | not started |
| 6: Ending (columns, Rowan) | `scene_six.tscn` + `scene_six.gd` | not started |

Art already exists for all of them in `Assets/` (see Assets below).

## Making a new scene

The pattern every scene follows (look at `scene_two` for the fullest example):

1. In Godot: new scene, root `Node2D`, name it `scene_four`. Save in `Scenes/`.
2. Add a `Sprite2D` for the background and set its position to `(576, 324)` (screen center; the window is 1152x648).
3. Drag `Scenes/text_box.tscn` into the scene and name the node `TextBox`.
4. Attach a new script in `Scripts/`. Start it like this:

```gdscript
extends Node2D

func _ready() -> void:
	await $TextBox.say("Narrator", "First period.")
	# ...the rest of the scene...
	scene_manager.change_scene("res://Scenes/scene_five.tscn")
```

5. Link it in: the previous scene's last line is `scene_manager.change_scene(...)`. Point it at your new scene. (Right now `scene_three.gd` ends by going to `god_one.tscn`, and `god_one` needs to go on to `scene_four`.)

Scenes are plain code, top to bottom. `await` pauses until the player clicks, so a scene reads like the script.

## The text box

One reusable scene, `Scenes/text_box.tscn`, script `Scripts/text_box.gd`. Three functions:

```gdscript
# Show a line, wait for a click.
await $TextBox.say("Ms. Alvarez", "A phone was taken in the hallway this morning.")

# Show a line with buttons, get back the index of the one pressed (0, 1, 2...).
var pick = await $TextBox.ask("Ms. Alvarez", "Was it you?", ["> No.", "> Why are you asking me?"])
if pick == 0:
	...

# Show a line and lock clicking, for when the SCENE has its own buttons (like the bathroom doors).
$TextBox.prompt("You", "I kind of need to use the bathroom...")
var side = await picked   # your own signal, emitted by your own button
```

- Empty speaker (`""`) hides the name plate. Use it for the god's text and narration with no name.
- Text types out at 55 chars/sec. Click skips to the end of the line, click again advances.
- Choice buttons are made from the strings you pass. Conditional options are just conditional array building:

```gdscript
var options = ["> No.", "> Why are you asking me?"]
if player.state["phone"]:
	options.insert(0, "> I picked it up to give it back.")
```

Careful, though: the returned index is into the array you built, so if an option can be missing, match on the text instead of the number (`options[pick]`).

### What the text box does NOT do yet

The script needs these and they don't exist, so you'll have to build them:

- **Free-text input.** The god's "Who are you?", Alvarez's "Say it in your own words", Kai's "Not exactly...", Rowan, and the "rework" tag option all need a typed answer. Easiest route: add a `LineEdit` plus submit button to `text_box.tscn` and a `type_in(who, line) -> String` function next to `ask()`, following the same pattern (build UI, `locked = true`, `return await` a signal).
- **Dimmed god screen.** Nothing for this exists. Simplest: a black `ColorRect` in `god_one.tscn` and call `say("", "...")` with the empty speaker.
- **Tag panel, rewind button, record/retell, redacted lines.** None built.

## Game state: `player.state`

`Scripts/you.gd` is an autoload called `player`. It holds everything in one dictionary and survives scene changes.

```gdscript
player.state["reads"]["gender"] += 1     # reads: gender, conduct, belong
player.state["friction"] += 1
player.state["phone"] = true
player.state["tags"].append("boy")
player.state["accounts"].append(typed_text)   # what the player SAID
player.state["actions"].append("picked up a phone")  # what the player DID
player.state["reflex_state"]             # 0 or 1, rolled once at startup
```

Keys the script uses that **aren't in `you.gd` yet**, so add them there before using them:

- `"record"`: `[]`, what NPCs repeat (Alvarez's notebook, Kai's retelling, detention slip)
- `"unlocked"`: `false`, set to `true` in the god scene; gates the silence / ask back options in scenes 4, 5 and the single-stall door
- `"silent"`: `false`, if you want Kai's "hard to read" line (stayed silent in scene 4 or 5)

Only write to state through `player.state[...]`. Don't keep story data in a scene's own variables, since the scene is freed when you leave.

## Changing scenes

```gdscript
scene_manager.change_scene("res://Scenes/scene_four.tscn")
```

Fades to black, swaps, fades back in. Two rules:

- Call it as the **last line** of a scene. Don't `await` it, the scene gets freed during the swap.
- Calls made while a fade is running are ignored, so double-calls are safe.

## Characters and sprites

All characters and backgrounds are SVGs in `Assets/`. Everything is 200x420 for characters and 960x540 for backgrounds.

| Need | Asset |
|---|---|
| Classroom | `bg_classroom.svg` |
| Cafeteria | `bg_cafeteria.svg` |
| Hallway (ending) | `bg_hallway.svg` |
| God scene | `bg_god.svg` |
| Alvarez / Kai / Rowan | `char_alvarez.svg`, `char_kai.svg`, `char_rowan.svg` |
| Same, faceless | `char_*_blank.svg` (for the "can't read you" blank-oval faces after the wrong door) |
| Detention slip | `ui_detention_slip.svg` |
| Tag label | `ui_tag.svg` |
| Player | `char_player_base.svg` + outfit overlay |

Placing a character, copying what `scene_two.tscn` does:

- Character: `Node2D` with a `Sprite2D` child, **scale 0.615**, y around 450, x around 181 (left) or 908 (right).
- Player: a `Node2D` named `player` with a `body` sprite (`char_player_base.svg`) and an empty `clothes` sprite on top.
- Put the character under a `Node2D` and toggle the **parent's** `visible` to show or hide them.
- Background: `Sprite2D` at `(576, 324)`.

Putting the player's outfit on in a later scene (copy from `scene_two.gd`):

```gdscript
if player.state["clothes"] == 1:
	$player/clothes.texture = load("res://Assets/char_player_outfit_jeans_tshirt.svg")
else:
	$player/clothes.texture = load("res://Assets/char_player_outfit_skirt_tshirt.svg")
```

Watch the node-name casing: scene_one uses `$Player/Clothes`, scene_two uses `$player/clothes`. Use whatever you named the node in the scene.

## Scene's own buttons (like the bathroom doors)

The text box's `ask()` is for dialogue choices. If the scene needs buttons on the picture, put them in the scene, emit a signal, and `await` it. `scene_three` is the pattern to copy:

```gdscript
signal picked(side)

func _on_girls_pressed() -> void:
	picked.emit(-1)
```

Connect the button's `pressed` signal to that function in the editor (Node tab, Signals). The `DoorButton` theme variation (invisible until hover) is set on the button via `theme_type_variation`, useful for the single-stall door.

## Theme

`Resources/vn_theme.tres` is the project-wide theme (set in `project.godot`), so new Buttons, Labels and text get the look automatically. Don't style per-node. If you need a new variant, add it to the theme and set `theme_type_variation` on the node. Existing ones: `DoorButton`, `NamePlate`, `NamePlateLabel`, `TextBoxPanel`.

## Running

Open the folder in Godot 4.7 and press F5 (starts at the main menu). To test a later scene without playing through, open it and press F6 (run current scene). `player.state` will have defaults, so set what you need at the top of `_ready()` temporarily, e.g. `player.state["reads"]["conduct"] = -3`.

## Known TODOs in code

- `scene_two.gd`: tag "Rework" and "Refuse" are placeholders (both halve the read). Script wants typed replacement word / hide tag and belong -1.
- `god_one.tscn` is empty.
- Script says Scene 2's phone choice has the player step over it silently; currently it's an explicit yes/no question.
