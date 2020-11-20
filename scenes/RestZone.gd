extends Node2D

var cardRestHere: Node2D;

func _ready():
	z_index = 20;
	cardRestHere = null;
	setText();


func setText():
	if cardRestHere:
		$Label.text = cardRestHere.name;
	else: 
		$Label.text = "nothing here";

func setCardRestInZone(card):
	cardRestHere = card;
	setText();
	pass

func hasCard():
	if cardRestHere:
		return true
	else:
		return false
