extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $".."

@onready var numOfPlayersText = $numOfPlayers
@onready var rolesText = $roles

@onready var startButton = $StartButton
@onready var addBotButton = $AddBotButton
@onready var removeBotButton = $RemoveBotButton
@onready var roleButtonParent = $"role buttons"

var addAndRemoveRoleButton: PackedScene = preload("res://scenes/lobby/add_and_remove_role_button.tscn")

#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------

#Lobby Setup
func _ready() -> void:
	for item in mainRoot.roleOptions:
		var addAndRemoveRoleButtonObject = addAndRemoveRoleButton.instantiate()
		addAndRemoveRoleButtonObject.get_node("name of role").text = item
		var leftAnchorPoint: float = float(mainRoot.roleOptions.find(item) + 1) * 1/(1 + len(mainRoot.roleOptions)) - 0.1
		addAndRemoveRoleButtonObject.anchor_left = leftAnchorPoint
		addAndRemoveRoleButtonObject.anchor_right = leftAnchorPoint + 0.2
		roleButtonParent.add_child(addAndRemoveRoleButtonObject)
	for child in roleButtonParent.get_children():
		child.get_node("add role").connect("button_down", (func(): _add_remove_roles("add", child)))
		child.get_node("remove role").connect("button_down", (func(): _add_remove_roles("remove", child)))

#Add/Remove Roles
func _add_remove_roles(action: String, child: Control) -> void:
	if action == "add":
		mainRoot.roles.append(child.get_node("name of role").text)
	elif action == "remove":
		mainRoot.roles.erase(child.get_node("name of role").text)
	rolesText.text = "Roles: " + str(mainRoot.roles)
	_check_can_start()

#Add/Remove Players
func _on_add_bot_button_pressed() -> void:
	_change_players(1)
func _on_remove_bot_button_pressed() -> void:
	_change_players(-1)
func _change_players(amount: int) -> void:
	mainRoot.numOfPlayers += amount
	mainRoot.numOfPlayers = clamp(mainRoot.numOfPlayers, 1, 20)
	addBotButton.disabled = mainRoot.numOfPlayers >= 20
	removeBotButton.disabled = mainRoot.numOfPlayers <= 1
	numOfPlayersText.text = "Number of Players: " + str(mainRoot.numOfPlayers)
	_check_can_start()

#Start Button
func _on_start_button_pressed() -> void:
	mainRoot._start()
func _check_can_start() -> void:
	if mainRoot.numOfPlayers > 2 and mainRoot.numOfPlayers == len(mainRoot.roles):
		startButton.disabled = false
	else:
		startButton.disabled = true
