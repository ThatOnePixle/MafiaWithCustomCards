extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

var roleOptions: Array[String] = ["Mafia", "Villager", "Detective"]
var roles: Array[String] = []
var players: Array[String] = []
var numOfPlayers: int = 1

var lobbyScene: PackedScene = preload("res://scenes/lobby/lobby.tscn")
var lobbySceneObject: Node = lobbyScene.instantiate()
var nightScene: PackedScene = preload("res://scenes/night/night.tscn")
var nightSceneObject: Node = nightScene.instantiate()

#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------

func _ready() -> void:
	self.add_child(lobbySceneObject)

func _start() -> void:
	self.remove_child(lobbySceneObject)
	for i in range(numOfPlayers):                                             #Assigns Roles
		var roleToBeAssigned: String = roles[randi_range(0,len(roles)-1)]
		players.append(roleToBeAssigned)
		roles.erase(roleToBeAssigned)
	self.add_child(nightSceneObject)
