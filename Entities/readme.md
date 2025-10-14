# Entities
This is probably the most important directory, it contains all interactable 
things in the game.

For items an "Items" subdirectory should be created. It contains the Superclass
of any items in the game in the "item.gd" script.

Any type of items now are put in subdirectories of the Items directory and
inherit from the item-superclass.

An example of the directory structure when trying to implement e.g. the items
sword and bow, could look like this:

|> Entities
	|> Enemies
	|> Player
	|> Items
		|> Weapons
			|> Sword
				|> SwordWeaponItem.gd
			|> Bow
				|> BowWeaponItem.gd
			|> WeaponItem.gd
		|> Item.gd

Another example for enemies:

|> Entities
	|> Enemies
		|> Slimes
			|> RedSlime
				|> RedSlime.gd
			|> BlueSlime
				|> BlueSlime.gd
			|> Slime.gd
		|> Goblins
			|> SwordGoblin
				|> SwordGoblin.gd
			|> BowGoblin
				|> BowGoblin.gd
			|> Goblin.gd
		|> Enemy.gd
	|> Player
	|> Items
