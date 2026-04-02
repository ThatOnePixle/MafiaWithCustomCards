extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

#Global
enum GameState { LOBBY, NIGHT, VOTING, END }
var currentgameState: GameState = GameState.LOBBY
var role_options: Array[String] = ["Mafia", "Villager", "Detective"]
var roles: Array[String] = []

#Lobby
var numOfPlayers: int = 1

@onready var numOfPlayersText = $mainMenu/numOfPlayers
@onready var rolesText = $mainMenu/roles
@onready var addBotButton = $mainMenu/AddBotButton
@onready var removeBotButton = $"mainMenu/role buttons"
@onready var role_button_parent = $"mainMenu/role buttons"
var add_and_remove_role_button: PackedScene = preload("res://scenes/lobby/add_and_remove_role_button.tscn")
#----------------------------------------------------------------------------------------------------
#Functions
#--------------------------------------------	--------------------------------------------------------

#Lobby
func _ready() -> void:
	for item in role_options:
		var add_and_remove_role_button_object = add_and_remove_role_button.instantiate()
		add_and_remove_role_button_object.name_of_role = item
		add_and_remove_role_button_object.position = Vector2(role_options.find(item) * 1800/len(role_options), 350)
		role_button_parent.add_child(add_and_remove_role_button_object)

func _on_add_bot_button_pressed() -> void:
	_change_players(1)
func _on_remove_bot_pressed() -> void:
	_change_players(-1)
func _change_players(amount: int) -> void:
	numOfPlayers += amount
	numOfPlayers = clamp(numOfPlayers, 1, 20)
	addBotButton.disabled = numOfPlayers >= 20
	removeBotButton.disabled = numOfPlayers <= 1
	numOfPlayersText.text = "Number of Players: " + str(numOfPlayers)
