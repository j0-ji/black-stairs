# Common
This directory is used for common game logic
It is best to implement base game mechanics in a way
so they can get reused in other games. 

The state machine of the player for example would be such a standalone mechanic. 
Other mechanics/systems that could be implemented as standalone systems are:
	- Loot
	- Projectiles
	- Light
	- Shadows
	- General purpose shaders
	- Resolution Management
	- Loading Screen
	- Weather Management
	- etc. ...

To be more precise those systems have to be implemented in a way, that they 
have no references to or dependencies on any project specific game logic. 

Disclaimer: not all of those systems will be implemented into this game
this list was intended to give the reader a better understanding of the
purpose of this directory.
