extends Node2D

#onready var arrCards = $cards.get_children();
#onready var arrRestZones = $dropZones.get_children();

func _ready():
	initScene();


func initScene():
	setAllCardsInRestZones();


func setAllCardsInRestZones():
	var nearestZone = null;
	var minimalDistance = 100000;
	var distanceToZone = null;
	
	var arrCards = $cards.get_children();
	var arrRestZones = $dropZones.get_children();
	
	for card in arrCards:
		minimalDistance = 100000;
		nearestZone = null;
		for restZone in arrRestZones:
			distanceToZone = restZone.global_position.distance_to(card.global_position);
			if distanceToZone < minimalDistance:
				minimalDistance = distanceToZone;
				nearestZone = restZone;
		if nearestZone:
			nearestZone.setCardRestInZone(card);
			card.setRestZone(nearestZone);
			card._initialize_RETURN_TO();

	
	#for restZone in arrRestZones:
	#	minimalDistance = 100000;
	#	nearestCard = null;
	#	for card in arrCards:
	#		distanceToCard = restZone.global_position.distance_to(card.global_position);
	#		if distanceToCard < minimalDistance:
	#			minimalDistance = distanceToCard;
	#			nearestCard = card;
	#
	#	if nearestCard:
	#		restZone.setCardRestInZone(nearestCard);
	#		nearestCard.setRestZone(restZone);
	#		nearestCard._initialize_RETURN_TO();
	#		nearestCard = null;

