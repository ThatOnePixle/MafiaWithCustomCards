extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

var roleOptions: Array = _load_roles_data()
var roles: Array[String] = []

var players: Dictionary[String, Dictionary] = {}
var numOfPlayers: int = 1

var lobbyScene: PackedScene = preload("res://scenes and scripts/lobby/lobby.tscn")
var nightScene: PackedScene = preload("res://scenes and scripts/night/night.tscn")
var voteingScene: PackedScene = preload("res://scenes and scripts/voteing/voteing.tscn")
var lobbySceneObject: Node = lobbyScene.instantiate()
var nightSceneObject: Node = nightScene.instantiate()
var voteingSceneObject: Node = voteingScene.instantiate()	

#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------
func _load_roles_data():
	var rolesData = []
	var dir = DirAccess.open("res://roles")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file = FileAccess.open("res://roles/" + file_name, FileAccess.READ)
			var data = JSON.parse_string(file.get_as_text())
			rolesData.append(data)
		file_name = dir.get_next()
	return rolesData

func _return_role_data_matching_name(nameOfRole):
	for roleData in roleOptions:
		if nameOfRole == roleData["name"]:
			return roleData

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
		players["Bot" + str(i)] = _return_role_data_matching_name(roleToBeAssigned)
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
