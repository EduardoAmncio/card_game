extends Node2D


func _ready():
	initScene();


func initScene():
	setAllCardsInRestZones();


func setAllCardsInRestZones():
	var nearestCard = null;
	var minimalDistance = 100000;
	var distanceToCard = null;
	
	var arrCards = $cards.get_children();
	var arrRestZones = $dropZones.get_children();
	
	for restZone in arrRestZones:
		for card in arrCards:
			distanceToCard = restZone.global_position.distance_to(card.global_position);
			if distanceToCard < minimalDistance:
				minimalDistance = distanceToCard;
				nearestCard = card;
	
		
		if nearestCard:
			restZone.setCardRestInZone(nearestCard);
			nearestCard.setRestZone(restZone);
			nearestCard._initialize_RETURN_TO();
			nearestCard = null;

