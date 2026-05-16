extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $"../.."
@onready var root  = $".."
@onready var background = $background
#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------

#Selector Setup
func _ready() -> void:
	var count: float = 0
	for player in mainRoot.players.keys():
		var buttonPerPerson: Button = Button.new()
		buttonPerPerson.text = player
		buttonPerPerson.anchor_top = 0.2
		buttonPerPerson.anchor_bottom = 0.9
		buttonPerPerson.anchor_left = count * 1/mainRoot.numOfPlayers - 0.1
		buttonPerPerson.anchor_right = buttonPerPerson.anchor_left + 0.2
		if mainRoot.players[player].get("dead", false):
			buttonPerPerson.disabled = true
			buttonPerPerson.text = player + " (Dead)"
		background.add_child(buttonPerPerson)
		buttonPerPerson.connect("button_down", (func(): root._selection_complete(count)))
		count += 1
