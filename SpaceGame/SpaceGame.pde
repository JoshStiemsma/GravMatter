/*
GravMAtter 
 By Josh Stiemsma
 */


/*
*ArrayList stars holds all the actie stars in the game.
 *
 *ArrayList toCreate is list of Star's with additional info attached like mass, position, and a boolean specifying how it 
 ***** was creat(Explosioon/dropped by player);
 *
 *ArrayList toKill is an list of active stars to be deleted at the beginning of the frame so they dont get calculated into
 ***** anything within the frame.
 */
ArrayList<Star> stars = new ArrayList<Star>();
ArrayList<Star> toCreate = new ArrayList<Star>();
ArrayList<Star> toKill = new ArrayList<Star>();


ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Enemy> enemiesToCreate = new ArrayList<Enemy>();
ArrayList<Enemy> enemiesToKill = new ArrayList<Enemy>();

ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Bullet> bulletsToCreate = new ArrayList<Bullet>();
ArrayList<Bullet> bulletsToKill = new ArrayList<Bullet>();

ArrayList<Bomb> bombs = new ArrayList<Bomb>();
ArrayList<Bomb> bombsToCreate = new ArrayList<Bomb>();
ArrayList<Bomb> bombsToKill = new ArrayList<Bomb>();

ArrayList<PickUp> pickUps = new ArrayList<PickUp>();
ArrayList<PickUp> pickUpsToCreate = new ArrayList<PickUp>();
ArrayList<PickUp> pickUpsToKill = new ArrayList<PickUp>();



/*
*The float G represents gravity and the size of its force
/*/
float G = .1;
/*
* maxForce is a float or the maxForce gravity can have on an object
 */
float maxForce = 1;
/*
*boundaries is a boolean to toggle the boundaries that bounce the player and stars back into the field at width*4 and height*$
 */
boolean boundaries =true;
/*
*Scale is a float used for the scaling of the matrix used for the players view(encompassing everything really),
 * previously used for zooming in and out of view
 */
float scale=1;

/*
*starDropped is a boolean used with the players input of dropping stars into the field
 * it stopped the function from continuously dropping and required the key to be released before being activated again
 */
boolean starDropped = false;
boolean starStarted=false;
boolean antiMatStarted = false;
/*
* scaled is a Boolean used when scaling the view to send input confirmation only once untill the key was released
 */
boolean scaled=false;
/*
* scaleOffset is a PVector that stores the amount of offset needed when scaling in or out to keep the viewport centered,
 * otherwise when zoooming in or out the view, including the player, was rooted in the top left corner of the screen.
 * With this offset when zooming the player stays right in the center.
 */
PVector scaleOffset = new PVector();

PVector offset = new PVector();
/*
* This installs a new Player class named player
 */
Player player; 


/*
* This newStar of the Star class is used during the creation of a start via the player and is then passed to toCreate
 */
Star newStar;

/*
*Landscape handles the stars and other objecsts in the field
*/
Landscape landscape;

/*
* This installs a new Controls class named class
 */

Controls control;

String weapon = "Matter";

/*
* totalMass is a float used to store the sum of all the stars mass in the system
 */
float totalMass = 0;
/*
* counter is and int used to count each frame
 */
int counter;


Gravity gravity;

/*
* setup 
 */
void setup() {
  size(900, 600);
  cursor(HAND);
  //player is set to the output of the makePlayer() function which is a collection fo points in a shape.
  player = makePlayer();
  // control is set to a new class object 
  control = new Controls();
 gravity = new Gravity();
 landscape = new Landscape();
}

void draw() {
  background(0);
  //DrawHud() draws the star count and totalMass onto the scree OUTSIDE of the main systems Matrix
  drawHud();
  //enter the matrix neo
  pushMatrix();

  //translate the matrix 
  //-First by the offset needed to counter the offset created by scaling(otherwise everything is TopLeft rooted)
  //-Secondly by the players position and this keeps the player centered to the screen while it also allows
  ////our player to be an object of velocity with forces, compared to player is center of screen and world moves around that
  offset = new PVector(-player.position.x+width/2, -player.position.y+height/2);
  // translate(-scaleOffset.x,-scaleOffset.y);
  translate(-player.position.x, -player.position.y);
  translate(width/2, height/2);


  //scaling the matrix by the scale float, the scale float is tied to an input for zooming capability
  //scale(scale);
  //Run update with currently update
  //-StarDeaths FIRST
  //-Star Births After Deaths
  //-Calculate Physics and Gravity
  //-Player.update
  //-Star.update
  //-star.Collision.update
  update();

  //Draw the players ship
  player.draw();
  //This draw the boundary boxes, there are no game objects that continue past this, they all bounce back
  stroke(255);
  line(-width*4, -height*4, width*4, -height*4);
  line(-width*4, -height*4, -width*4, height*4);
  line(width*4, -height*4, width*4, height*4);
  line(-width*4, height*4, width*4, height*4);

  //For each star draw urself
  for (Star s : stars) s.draw();

  for ( Enemy e : enemies) e.draw();
  //Leave the matrix neo
  popMatrix();
}


/*
* Update function called at start of draw to update all things that need it right now
 */
void update() {
  //call handle deaths function FIRST FIRST FIRST, in handledeaths all stars references in the list are removed from the
  ////stars array which destroys them there and after each star is destroyed this list get reset completely wiping them cleanly
  HandleDeaths();
  //call handle births function right AFTER DEATHS, in handle births all the stars from the previouse frame that are waiting to be created,
  //// get created and added to the stars array in order but as well done to specifications that go along with them which is
  //// Mass, position and what created them boolean. 
  HandleBirths();

  control.update(); //Update controls
  //This is the key function for calculating all the forces of attraction between stars in the system as well as the player and soon enemies
  gravity.CalculateGravity(); 
  //update the player including the input given from the player 
  player.update();
  //update each star 
  for ( Star s : stars)  s.update();
  //For each star check your collision with every star in the ArrayList stars
  for ( Star s : stars)  s.CheckCollision();  

  for (Enemy e : enemies) e.update();
  for (Enemy e : enemies) e.checkCollision(); 

  player.checkEnemyCollisions(enemies);
  player.checkStarCollisions(stars);

  if (newStar!=null) newStar.update();
  if (newStar!=null) newStar.draw();

  for (Bullet b : bullets) b.update();
  for (Bullet b : bullets) b.checkCollision(); 

  //For bombs, Update is at start of draw() and CheckCollisions is inside dependent on mode
  for (Bomb b : bombs) b.draw();

  //For pickups, Update is at start of draw()
  for (PickUp p : pickUps) p.draw();
  for (PickUp p : pickUps) p.checkCollision();


 //Update the landscape to see if new stars or [ickups should be added relative to the players movement
  landscape.update();
  
  
  //Check for user Input
  checkInput();
  //reset total mass so its not constantly growing
  totalMass=0;
  //calculate total mass by adding each strs mass to the now emtpy totalMass float
  for (Star s : stars) totalMass = totalMass+s.mass;
  // add one to the fram counter
  counter++;
  //This if is for randomly adding stars into the field around thte player, currently off
  if (counter>60) {
    // toCreate.add(new Star(10+random(5), player.position, false));   
    enemiesToCreate.add(new Enemy("SmallAlien", new PVector(-20, -20)));
    counter=0;
  }
}
/*
* drawHud() draws to the window the star count and total Mass in the playing field
 *  drawHud is one of the only things outside of the games Matrix
 */
void drawHud() {
  textSize(32);
  fill(255);
  text("Stars: " + stars.size(), 20, 30); 
  text("Total Mass: " + totalMass, 20, 60);
  text(weapon, 20, height-20);

  fill(map(player.health, 100, 0, 0, 255), map(player.health, 100, 0, 255, 0), 0);
  rect(width-20, height-20, -20, -player.health);
  
   fill(255);
  rect(width-50, height-20, -20, -player.matterAmmo/2);


  fill(map(player.antiMatterAmmo, 0, 100, 0, 255), 0, map(player.antiMatterAmmo, 0, 100, 0, 255));
  rect(width-80, height-20, -20, -player.antiMatterAmmo);

  fill(map(player.beamGunAmmo, 0, 100, 0, 255), 0, 0);
  rect(width-110, height-20, -20, -player.beamGunAmmo);

  fill(255, 0, 0);
  for (int i=0; i<player.bombs; i++) {   
    ellipse(width-20, 10*(i+1), 5, 5);
  }

  fill(255, 255, 0);
  for (int i=0; i<player.missiles; i++) { 
    float offset = (10*(i+1));
    triangle(width-23, 30+offset, width-18, 30+offset, width-20.5, 35+offset);
  }
}




 
 

/*
* Explosion is called whena star reached critical mass and cant contain its mass anymore, The star, along with
 * the star that joined it to reach critMass, are removed from the game and from thier position many stars are
 * ejected into the field despersing the original stars mass back out into the system.
 * @param Star s, pass into this function the star that reached critical mass
 * @param PVector pos is the position where the original star was, and now where the new stars will emerge from
 */
void Explosion(Star s, PVector pos) {
  // How many stars to emerge
  for ( int i = 0; i<20; i++) {
    // add a new star to the ArrayList toCreate and it will add the star to the system at the start of the next frame, 
    // new Star(float mass, PVector position, boolean exploded) exploded tell the constructor to ake an outward veloctiy
    toCreate.add(new Star(25, pos, "Explosion"));
  }
  // Add the giant star to the toKill list so that it can be removed from the game
  toKill.add(s);
}


void DropStar() {
  toCreate.add(new Star(10, new PVector(mouseX, mouseY), "Dropped"));
}

/*
* HandleDeaths take each star in the toKill Array and properly removes it from the stars array 
 * after all stars from toKill are removed from the list stars, toKill is wiped effectivly removing the stars
 */
void HandleDeaths() {
  for (Star s : toKill) stars.remove(s);
  toKill = new ArrayList<Star>();

  for (Enemy e : enemiesToKill) enemies.remove(e);
  enemiesToKill = new ArrayList<Enemy>();

  for (Bullet b : bulletsToKill) bullets.remove(b);
  bulletsToKill = new ArrayList<Bullet>();

  for (Bomb b : bombsToKill) bombs.remove(b);
  bombsToKill = new ArrayList<Bomb>();

  for (PickUp p : pickUpsToKill) pickUps.remove(p);
  pickUpsToKill = new ArrayList<PickUp>();
}
/*
* HandleBirths takes each star from the arraylist toCreate and add it to the arraylist stars with its parameters of
 *  mass, position and boolean of xoming from an explosion or not
 */
void HandleBirths() {
  // for each star in toCreate add it to stars with its param's of mass, pos, exploded
  for (Star s : toCreate) stars.add(new Star(s.mass, s.position, s.state));
  // Once throw the list of all toCreate's wipe the list so next turn its only those from that frame that get added
  toCreate = new ArrayList<Star>();

  for (Enemy e : enemiesToCreate) enemies.add(new Enemy(e.type, e.position));
  enemiesToCreate = new ArrayList<Enemy>();

  for (Bullet b : bulletsToCreate) bullets.add(new Bullet(b.position, b.velocity, b.state ));
  bulletsToCreate = new ArrayList<Bullet>();


  for (Bomb b : bombsToCreate) bombs.add(new Bomb(b.position));
  bombsToCreate = new ArrayList<Bomb>();

  for (PickUp p : pickUpsToCreate) pickUps.add(new PickUp(p.position, p.type));
  pickUpsToCreate = new ArrayList<PickUp>();
}



/*
*Start Star begins the players dropping of chosen star/weopon/mass that is at hand
 *@param String state is the state of the players weopon, ex. "Dropped" for normal star or "AntiMatter" for anttimatter
 */
void StartStar(String type) {
  if (starStarted) {
    if (newStar.mass<=500) {
      newStar.mass+=10;
    }
    newStar.position=new PVector(mouseX-offset.x, mouseY-offset.y);
  } else {
    starStarted=true;
    newStar = new Star(10, new PVector(mouseX, mouseY), type);
  }
}

void EndStar() {
  toCreate.add(newStar);
  starStarted=false;
  newStar=null;
};


/*
* checkInput checks with Controls class controls to see if any of the Key booleans have been toggles to true, meaning the user
 * has applied input
 */
void MouseDown() {
  switch(weapon) {
  case "Matter":
    StartStar("Dropped");
    break;
  case "AntiMatter":
    StartStar("AntiMatter");
    break;
  }
}
void MouseUp() {

  if (starStarted) EndStar();
}


void checkInput() {

  /*
  **************Input from Mouse
   */
  if (control.mouseDown) MouseDown();
  if (control.mouseUp) MouseUp();

  /*
  ********************Input from Numbers
   */
  if (control.KEY_1) weapon = "Matter";
  if (control.KEY_2) weapon = "AntiMatter";
  if (control.KEY_3) weapon = "Matter";

  /*
  **********************Letters from Keyboard input
   */
  // if W was pressed call moveForward within the player of the Player class
  if (control.KEY_W) player.moveForward(); 
  // if A was pressed call moveLEft within the player of the Player class
  if (control.KEY_A) player.moveLeft();
  // if S was pressed call moveBack within the player of the Player class
  if (control.KEY_S) player.moveBack();
  // if D was pressed call moveRight within the player of the Player class
  if (control.KEY_D) player.moveRight();
  if (control.KEY_X) player.DropBomb();
  
  if (control.KEY_Z) {
    if (millis()/1000-player.lastBombTime>2) {
      pickUpsToCreate.add(new PickUp(new PVector(random(player.position.x-50, player.position.x+50), random(player.position.y-50, player.position.y+50)), "TriShot"));
      player.lastBombTime = millis()/1000;
    }
  }

  // if Space was pressed 
  if (control.SPACE) player.ShootGun();
   
  

  // If Q was pressed and we havent scaled this frame 
  if (control.ScaleIn&&scaled==false) {
    // set the scale float to a bit bigger
    scale = scale +.02;
    // add an amount to the scaleOffset PVector
    scaleOffset.x+=(width*.03);
    scaleOffset.y+=(height*.03);
    scaled=true;
  } else {
    scaled=false;
  }
  // If E was pressed and we havent scaled yet this frame
  if (control.ScaleOut&&scaled==false) {
    // set the scale float to a bit smaller
    scale = scale -.02;
    // subtract a bit from the scaleOffset
    scaleOffset.x-=(width*.03);
    scaleOffset.y-=(height*.03);
    scaled=true;
  } else {
    scaled=false;
  }
}


/*
*makePlayer adds points to the player of the Player class by calling its internal function of addPoint and giving it x,y for those points
 * once all the points are added it returns that new Player bag to what called it
 */
Player makePlayer() {
  Player p = new Player();
  p.addPoint(-10, -10);
  p.addPoint(10, -10);
  p.addPoint(0, 20);
  p.addThrusterPoint(-8, -15);
  p.addThrusterPoint(8, -15);
  p.addThrusterPoint(0, -20);
  return p;
}

/*
* keyPressed gets called during any keypress and then calls the function handlekey in control, it also passed te code
 * for what key was pressed and the variable true. within control itll set that keycode to true
 */
void keyPressed() {
  //println(keyCode);
  control.handleKey(keyCode, true);
}
/*
*keyReleased gets called when a key gets released and then calls the func handle key in control with the parameters of
 * the key that got pressed as well as a boolean of false.
 */
void keyReleased() {
  control.handleKey(keyCode, false);
}

void mousePressed() {
  control.handleMouse(new PVector(mouseX, mouseY), new String("pressed"));
}
void mouseReleased() {
  control.handleMouse(new PVector(mouseX, mouseY), new String("released"));
}
void mouseClicked() {
  control.handleMouse(new PVector(mouseX, mouseY), new String("clicked"));
}
void mouseDragged() {
  control.handleMouse(new PVector(mouseX, mouseY), new String("dragged"));
}