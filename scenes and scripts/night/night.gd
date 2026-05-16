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
	roleTitle.text = "You Are: " + playerRole["name"]
	if playerRole.has("night") and playerRole["night"]["target"] == "selection":
		playerSelectorObject = playerSelector.instantiate()
		add_child(playerSelectorObject)

#Action Logic
func _selection_complete(botNumber) -> void:
	mainRoot._perform_action("night", playerRole, "Bot" + str(botNumber))
	self.remove_child(playerSelectorObject)

#End Night Sequence
func _on_finish_button_pressed() -> void:
	mainRoot.voteColecter = {}
	mainRoot._start_vote()
