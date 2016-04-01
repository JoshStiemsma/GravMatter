# GravMatter  by Josh Stiemsma and Devon Duchard
Space flight game playing with gravity and matter


Controls:
W =   Forward

A =   Rotate Left

S =   Rotate Right 

D =   Brake

Space=  Shoot

X = Bomb

C = Missile

1 = Matter

2 = AntiMatter

Click and point to drop Matter



I like the controls and how they are asteroid like by which you can rotate and then apply thrust int he direction you are moving. this alows for frictionless space flight with drifitng as well as instead of having reverse I hae a break. This break works well with the game idea of mass manipulation because i have the break really as a force cancelation thing and it does more than cancle the ships velocity but it also helps cancle the stars gravity pull on the ship so that i can stick itself and hold its ground near larger planets, but not too large. 

So far I have been playing with forces of gravity and matter in space. 

It is fun to fly around the developing and exploding stars in an active solar system, but it is also fun to tamper with it and place bits of matter into the field. 

So far this has come from experiementation and there isn't a universal game aspect to it, so I plan on making it a space craft defender/shooter where a lot of the flying might be automated but you can defend your ship by manipulating the forces of gravity and mass.

I might take out the players ability to completely control the ships movement, so that it follows a track and they can instead focusing on the strategic use of thier weopons and defenses that manipulate forces of gravity and mass. Another option is to have the perspective slowly panning or moveing around the field by track and the player can move freely but has to stay within that boxed view.

Realisticaly most of the weopons being used will shift and change the stars matter and forces causeing enemy ships to be destroyed by crashing or getting sucked in. 

A key factor for the player will be self-preservation and maybe fast paced resource managment because of the hostile environment. a lot of the players weopons are capable of killing the player or killing everyone around if not used properly, and the player will be limited on all supplies but will have the oppertunity to grab floating items from space and use them for specific weopons. Even matter can be a collectable resource because the player will be throwing matter back into the system and will only have so much.


The Ship:
The ship and possibly the background of the game can be based off of high-tec matter manipulation, capable of selectively placing mass into the solar system within range of ships matter displacers. All to defend a ship maybe transporting goods or part of some nation. It will also be capable of using other types of futuristic discoveries like, anti-matter, blackholes, DarkMatter and more mainly because these will be fun to program and fun to use! The players ship can withstand most debri, it can even absorb most mass(white colored mass) and add it to its supply, but if mass gets too big then it will be harmfull to the ships exterior and cause damage to it and the players health.

The ship is also good at deflecting the forces of mass, as if the ship had a huge mass to neglect the stars forces pulling it, but as well a tiny mass as to not pull in large harmfull mass. 


Weopon Ideas:
Anti-MAtter- Like a star but pushes out on all other matter.
BlackHole- Sucks matter in continuously, and the matter dissapears
MatterDesomater- destroys area of matter/stars into nothingness
Enemy Seeking Rockets, StarExplodingRocket,

Defence Ideas:
Matter Repelant
Matter attractor+reflector(matter is more attracted to the ship but as long as its not too big it bounces off)
Delayed bombs/matter/anti-matter

Enemies:
Alien and other army ships
different types for each group that vary in mass, technology, mobility, health , defence, range and maybe more



Stars:
Right now the stars shange color as they grow in size
Once they reach a critical mass they explode sending their mass out into the system.
If two stars touch the biggest one collects the smaller ones mass and velocity 

For programming the death and birth of stars, I created two seperate Arrays for killing and birthing stars I'd drop star class items into. This was so that at the beginning of every frame,and only at the beginning, I could delete all the stars that needed to be deleted at once and then add all the stars that needed to be added in order and this was key for using Array's or ArrayLists in my case. Otherwise the deletion and addition of so many items within a frame messes up order and naming of arrays that is cant handle. 


Major changes:
ill be adding these very soon afer uploading this test version to make it a better representation...
-Point-to-click matter/weopon, compared to now how i have SPACE drops mass behind the player. 
-Enemies and things that are shooting you so I can demo the specific gameplay of mixing enemies and gravity for defence, I believe the key function of the game 
-Less player mobility somehow for easier gameplay and more coherient objective as well as perspective of our space. 
-OPTIMIZATION, things are fine now...till you get to 500 stars, so optimizing the game continuously to save memory on star usage will make the game work tons better.
  (guiding the players general movement, and cleaning stray stars, will allow us to continuously add idol and more stray stars into the players view making the field look more dynamic and balanced at the same time.
