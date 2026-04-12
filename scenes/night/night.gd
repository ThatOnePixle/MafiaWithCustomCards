extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $".."
@onready var roleTitle = $roleTitle
var playerSelector: PackedScene = preload("res://scenes/night/player_selector.tscn")
var playerSelectorObject = playerSelector.instantiate()
@onready var playerRole = mainRoot.players["Bot0"]
@onready var actionComplete = playerRole == "Villager"

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

func _ready() -> void:
	roleTitle.text = "You Are: " + playerRole
	if playerRole == "Mafia":
		self.add_child(playerSelectorObject)

func _selection_complete() -> void:
	actionComplete = true
	self.remove_child(playerSelectorObject)

func _on_finish_button_pressed() -> void:
	if actionComplete == true:
		mainRoot._start_vote()
