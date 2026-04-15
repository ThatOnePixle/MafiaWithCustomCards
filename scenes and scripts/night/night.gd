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

func _ready() -> void:
	roleTitle.text = "You Are: " + playerRole["name"]
	if playerRole["night"]["target"] == "selection":
		self.add_child(playerSelectorObject)

func _selection_complete(botNumber) -> void:
	_perform_action("Bot" + str(botNumber))
	self.remove_child(playerSelectorObject)

func _perform_action(target: String) -> void:
	print(target)
	match playerRole["night"]["action"]:
		"kill":
			if "protected" in mainRoot.players[target]:
				if !mainRoot.players[target]["protected"]:
					mainRoot.players[target]["dead"] = true
			else:
				mainRoot.players[target]["dead"] = true
		"protect":
			mainRoot.players[target]["protected"] = true
		"investigate":
			outputText = mainRoot.players[target]["name"]
	

func _on_finish_button_pressed() -> void:
		mainRoot._start_vote()
