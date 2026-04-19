extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------
#Roles
var roleOptions: Array = _load_roles_data()
var roles: Array[String] = []
var teams: Array = _load_team_data()

#Players
var players: Dictionary[String, Dictionary] = {}
var numOfPlayers: int = 1

#Scenes
var lobbyScene: PackedScene = preload("res://scenes and scripts/lobby/lobby.tscn")
var nightScene: PackedScene = preload("res://scenes and scripts/night/night.tscn")
var voteingScene: PackedScene = preload("res://scenes and scripts/voteing/voteing.tscn")
var lobbySceneObject: Node = lobbyScene.instantiate()
var nightSceneObject: Node = nightScene.instantiate()
var voteingSceneObject: Node = voteingScene.instantiate()	

#Comparisons
var comparisons = {
	"==": func(a, b): return a == b,
	"!=": func(a, b): return a != b,
	">=": func(a, b): return a >= b,
	"<=": func(a, b): return a <= b,
	">":  func(a, b): return a > b,
	"<":  func(a, b): return a < b
}

#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------

#Misc Functions
func _get_player_count(condition: String, valueToCompare: String, countDead: bool):
	var memberCount = 0
	for player in players.values():
		if player.get(condition, "") == valueToCompare and (countDead or !player.get("dead", false)):
			memberCount += 1
	return memberCount

#Setup Custom Data
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
func _load_team_data():
	var teamData = []
	var dir = DirAccess.open("res://teams")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file = FileAccess.open("res://teams/" + file_name, FileAccess.READ)
			var data = JSON.parse_string(file.get_as_text())
			teamData.append(data)
		file_name = dir.get_next()
	return teamData
func _create_json_var(varStructure: Dictionary):
	var returnVar = 0
	match varStructure["type"]:
		"players":
			returnVar = _get_player_count("","",false)
			match varStructure["condition"]:
				"is team":
					returnVar = _get_player_count("team",varStructure["team"], false)
			if varStructure.get("inverted", false):
				returnVar = _get_player_count("","",false) - returnVar
		"constant":
			returnVar = int(varStructure["number"])
	return returnVar

#Check Win-Cons
func _get_win_con():
	var teamsThatHaveWon = []
	for team in teams:
		match team["win con"]["type"]:
			"compare":
				var var1 = _create_json_var(team["win con"]["var1"])
				var var2 = _create_json_var(team["win con"]["var2"])
				var comp = team["win con"]["comparison"]
				print(str(var1) + str(comp) + str(var2))
				print(str(_create_json_var(team["win con"]["var2"])))
				if comparisons.has(comp) and comparisons[comp].call(var1, var2):
					teamsThatHaveWon.append(team["name"])
	return teamsThatHaveWon
func _check_win_cons(team_win, sceneToTransitionTo):
	if team_win == []:
		_instantiate_scenes()
		self.add_child(sceneToTransitionTo)
	else:
		print(str(team_win) + " has won!")

#Assign Roles
func _assign_roles() -> void:
	for i in range(numOfPlayers):
		var roleToBeAssigned: String = roles[randi_range(0,len(roles)-1)]
		players["Bot" + str(i)] = _return_role_data_matching_name(roleToBeAssigned).duplicate(true)
		roles.erase(roleToBeAssigned)

#Swapping Scenes
func _ready() -> void:
	self.add_child(lobbySceneObject)
func _instantiate_scenes() -> void:
	lobbySceneObject = lobbyScene.instantiate()
	nightSceneObject = nightScene.instantiate()
	voteingSceneObject = voteingScene.instantiate()
	print(players)
func _start() -> void:
	self.remove_child(lobbySceneObject)
	_assign_roles()
	_check_win_cons(_get_win_con(), nightSceneObject)
func _start_vote() -> void:
	self.remove_child(nightSceneObject)
	_check_win_cons(_get_win_con(), voteingSceneObject)
func _end_vote() -> void:
	self.remove_child(voteingSceneObject)
	_check_win_cons(_get_win_con(),nightSceneObject)
