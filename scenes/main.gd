extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

var roleOptions: Array[String] = ["Mafia", "Villager", "Detective"]
var roles: Array[String] = []
var players: Dictionary[String, String] = {}
var numOfPlayers: int = 1

var lobbyScene: PackedScene = preload("res://scenes/lobby/lobby.tscn")
var nightScene: PackedScene = preload("res://scenes/night/night.tscn")
var voteingScene: PackedScene = preload("res://scenes/voteing/voteing.tscn")
var lobbySceneObject: Node = lobbyScene.instantiate()
var nightSceneObject: Node = nightScene.instantiate()
var voteingSceneObject: Node = voteingScene.instantiate()	

#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------

func _ready() -> void:
	self.add_child(lobbySceneObject)
func _instantiate_scenes() -> void:
	lobbySceneObject = lobbyScene.instantiate()
	nightSceneObject = nightScene.instantiate()
	voteingSceneObject = voteingScene.instantiate()	
func _start() -> void:
	self.remove_child(lobbySceneObject)
	_instantiate_scenes()
	for i in range(numOfPlayers):                                             #Assigns Roles
		var roleToBeAssigned: String = roles[randi_range(0,len(roles)-1)]
		players["Bot" + str(i)] = roleToBeAssigned
		roles.erase(roleToBeAssigned)
	print(players)
	self.add_child(nightSceneObject)
func _start_vote() -> void:
	print(players)
	self.remove_child(nightSceneObject)
	_instantiate_scenes()
	self.add_child(voteingSceneObject)
func _end_vote() -> void:
	print(players)
	self.remove_child(voteingSceneObject)
	_instantiate_scenes()
	self.add_child(nightSceneObject)
