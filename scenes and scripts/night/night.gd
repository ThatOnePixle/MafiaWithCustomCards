extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $".."
@onready var roleTitle = $roleTitle
@onready var outputText = $outputText
var playerSelector: PackedScene = preload("res://scenes and scripts/night/player_selector.tscn")
var playerSelectorObject = playerSelector.instantiate()
@onready var playerRole = mainRoot.players["Bot0"]

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

#Night Setup
func _ready() -> void:
	playerSelectorObject = playerSelector.instantiate()
	roleTitle.text = "You Are: " + playerRole["name"]
	if playerRole.has("night") and playerRole["night"]["target"] == "selection":
		self.add_child(playerSelectorObject)

#Action Logic
func _selection_complete(botNumber) -> void:
	_perform_action("Bot" + str(botNumber))
	self.remove_child(playerSelectorObject)
func _perform_action(target: String) -> void:
	match playerRole["night"]["action"]:
		"kill":
			if !mainRoot.players[target].get("protected", false):
				mainRoot.players[target]["dead"] = true
		"protect":
			mainRoot.players[target]["protected"] = true
		"investigate":
			outputText.text = mainRoot.players[target]["name"]
	
#End Night Sequence
func _on_finish_button_pressed() -> void:
		mainRoot._start_vote()
