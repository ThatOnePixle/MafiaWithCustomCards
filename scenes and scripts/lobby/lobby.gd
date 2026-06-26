extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $".."

@onready var numOfPlayersText = $numOfPlayers
@onready var rolesText = $roles

@onready var startButton = $StartButton
@onready var roleButtonParent = $roleButtonParent

var roleSettings: PackedScene = preload("res://scenes and scripts/lobby/add_and_remove_role_button.tscn")

var numOfPlayers: int = 0

#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------

#Lobby Setup
func _ready() -> void:
	#Set up a selector for each role
	for item in mainRoot.roleOptions.values():
		var roleSettingsObject = roleSettings.instantiate()
		roleSettingsObject.get_node("name of role").text = item["name"]
		roleButtonParent.add_child(roleSettingsObject)

#Add/Remove Players
func _change_players(amount: int) -> void:
	numOfPlayers += amount
	numOfPlayersText.text = "Number of Players: " + str(numOfPlayers)
	#Check amount of ppl to see if game can start
	startButton.disabled = false if numOfPlayers > 2 and numOfPlayers == len(mainRoot.roles) else true

#Start Button
func _on_start_button_pressed() -> void:
	mainRoot.lobbyNode.visible = false
	_assign_roles()
	mainRoot._check_win_cons(mainRoot._get_win_con(), "night")

#Assign Roles
func _assign_roles() -> void:
	mainRoot.players.clear()
	for id in mainRoot.nonBotPlayers.keys():
		var tempRoles: Array[String] = mainRoot.roles.duplicate(true)
		#Check if enough roles
		if tempRoles.is_empty():
			push_error("Not enough roles")
			return
		#Set up role
		var randomRole: String = tempRoles[randi_range(0,len(tempRoles)-1)]
		mainRoot.players[id]["roles"] = mainRoot.roleOptions[randomRole].duplicate(true)
		mainRoot.players[id]["id"] = id
		mainRoot.players[id]["conditions"] = {}
		tempRoles.erase(randomRole)
