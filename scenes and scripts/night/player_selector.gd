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

func _ready() -> void:
	for i in range(1,mainRoot.numOfPlayers):
		var buttonPerPerson: Button = Button.new()
		buttonPerPerson.text = "Bot " + str(i)
		buttonPerPerson.anchor_top = 0.2
		buttonPerPerson.anchor_bottom = 0.9
		buttonPerPerson.anchor_left = float(i) * 1/mainRoot.numOfPlayers - 0.1
		buttonPerPerson.anchor_right = buttonPerPerson.anchor_left + 0.2
		if "dead" in mainRoot.players["Bot" + str(i)]:
			if mainRoot.players["Bot" + str(i)]["dead"]:
				buttonPerPerson.disabled = true
				buttonPerPerson.text = "Bot " + str(i) + " (Dead)"
		background.add_child(buttonPerPerson)
		buttonPerPerson.connect("button_down", (func(): root._selection_complete(i)))
