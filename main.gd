extends Control

enum GameState { LOBBY, NIGHT, VOTING, END }
var roles: Array = []
var numOfPlayers: int = clamp(1,0,20)
var currentgameState: GameState 	= GameState.LOBBY

@onready var numOfPlayersText = $mainMenu/numOfPlayers
@onready var rolesText = $mainMenu/roles

@onready var addBotButton = $mainMenu/AddBotButton
@onready var removeBotButton = $mainMenu/RemoveBotButton

@onready var removeMafiaRoleButton = $mainMenu/addRoleButton/RemoveMafia
@onready var removeVillagerRoleButton = $mainMenu/addRoleButton/RemoveVillager
@onready var removeDetectiveRoleButton = $mainMenu/addRoleButton/RemoveDetective


func _ready() -> void:
	removeBotButton.disabled = true
	$mainMenu/addRoleButton/AddVillager.set_meta("role", "Villager")
	removeVillagerRoleButton.set_meta("role", "Villager")
	$mainMenu/addRoleButton/AddMafia.set_meta("role", "Mafia")
	removeMafiaRoleButton.set_meta("role", "Mafia")
	$mainMenu/addRoleButton/AddDetective.set_meta("role", "Detective")
	removeDetectiveRoleButton.set_meta("role", "Detective")

func _on_add_bot_button_pressed() -> void:
	numOfPlayers += 1
	if numOfPlayers >= 20:
		addBotButton.disabled = true
	removeBotButton.disabled = false
	numOfPlayersText.text = "Number of Players: " + str(numOfPlayers)

func _on_remove_bot_pressed() -> void:
	numOfPlayers -= 1
	if numOfPlayers <= 1:
		removeBotButton.disabled = true
	addBotButton.disabled = false
	numOfPlayersText.text = "Number of Players: " + str(numOfPlayers)

func _on_button_pressed(button) -> void:
	var role = button.get_meta("role")
	roles.append(role)
	rolesText.text = "Roles: " + str(roles)
	
