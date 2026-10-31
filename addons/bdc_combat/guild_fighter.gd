class_name GuildFighter
extends Fighter

enum OLD_DOG_SKILLS {
	RALLYING_CRY = (1 << 8),
	POINT_BLANK = (1 << 9),
	CRACKSHOT = (1 << 10),
	FEINT = (1 << 11),
	EXPLORER = (1 << 12),
	ON_TIME = (1 << 13)
	}
@export_flags ("Rallying Cry", "Point Blank Shot",
	"Crackshot", "Feint", "Explorer’s Instincts",
	"Right On Time") var old_dog_skills:int

enum SOLDIER_SKILLS {
	BLACKPOWDER = (1 << 14),
	SHIELD_EXPERT = (1 << 15),
	MARKSMAN = (1 << 16),
	FIGHT_ON = (1 << 17),
	BLESSED = (1 << 18),
	STAND_GROUND = (1 << 19)
	}
@export_flags ("Blackpowder Specialist", "Shield Expert",
	"Marksman", "Fight Till the End", "Blessed by the Saints",
	"Stand Ground") var soldier_skills:int

func has_skill(test:int) -> bool:
	return (skills & test) || (old_dog_skills & test) || (soldier_skills & test)
