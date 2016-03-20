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
* This installs a new Controls class named class
 */

Controls control;

String weapon = "AntiMatter";

/*
* totalMass is a float used to store the sum of all the stars mass in the system
 */
float totalMass = 0;
/*
* counter is and int used to count each frame
 */
int counter;
/*
* setup 
 */
void setup() {
  size(1200, 700);
  cursor(HAND);
  //player is set to the output of the makePlayer() function which is a collection fo points in a shape.
  player = makePlayer();
  // control is set to a new class object 
  control = new Controls();
  //Run the function SetStars which plots stars into the system ending just outside the players starting view
  SetStars();
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
 // println(millis()/1000);

  control.update(); //Update controls
  //This is the key function for calculating all the forces of attraction between stars in the system as well as the player and soon enemies
  CalculateGravity(); 
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



  //Check for user Input
  checkInput();
  //reset total mass so its not constantly growing
  totalMass=0;
  //calculate total mass by adding each strs mass to the now emtpy totalMass float
  for (Star s : stars) totalMass = totalMass+s.mass;
  //  println(totalMass);
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
}


/*
*
 *Calculate and apply  the forces of gravities upon all stars 
 *
 */
void CalculateGravity() {
  //Reset the value of each star
  for (Star s : stars) s.resetValues(); 
  for (Star s1 : stars) {
    for (Star s2 : stars) {
      //dont check with your slot in the arraylist else checkig with self, as well as if that star is set to done, dont check it
      if (s1 == s2 || s2.done ) continue;
      // F = G*M1*M2/(R*R)
      // Collect the vector spereating first star from second star
      PVector V = PVector.sub(s2.position, s1.position);
      // The magnitude of that vector between each star is set to magSq
      float magSq = V.x * V.x + V.y * V.y; 
      // The equal force of gravity between the two stars is the constant for gravity(G) * the first stars mass * the 2nd stars mass devided by their magSq
      float M = G * s1.mass * s2.mass / magSq;
      //If this force is greater than our allowed maxForce, stop it at that maxForce
      if (M > maxForce) M = maxForce;
      // set float A to the arcTanSq of the found subtracted vector V
      float A = atan2(V.y, V.x);
      // The force of pull in the direction of x is the force M * cos of A
      float Fx = M * cos(A);
      // The force of pull in the direction of y is the force M * sin of A
      float Fy = M * sin(A);
      if (s1.state=="AntiMatter"||s2.state=="AntiMatter") {
        // call the function addForce within the first star and pass it the force of x and the force of y
        s1.addForce(new PVector(-Fx, -Fy));
        // call the func addForce within the 2nd star and pass it the same force but negative to equal force in the opposite direction
        s2.addForce(new PVector(Fx, Fy));
      } else {
        // call the function addForce within the first star and pass it the force of x and the force of y
        s1.addForce(new PVector(Fx, Fy));
        // call the func addForce within the 2nd star and pass it the same force but negative to equal force in the opposite direction
        s2.addForce(new PVector(-Fx, -Fy));
      }
      // mark this star as done checking itself with other stars
      s1.done = true;
    }
  }
  // This for loop is used to check each stars force via mass and apply it onto the player, But not the other way
  for (Star s1 : stars) {
    // find vector between objects
    PVector V = PVector.sub(player.position, s1.position);
    // find their magnitude squared
    float magSq = V.x * V.x + V.y * V.y;
    // find the amount of force between them
    float M = G * s1.mass * player.mass /magSq;
    // if that force is too big cap it
    if (M > maxForce) M = maxForce;
    // angle of force equales arcTanSquared of the vector V
    float A = atan2(V.y, V.x);
    // force in Dir X is force M * cos of A
    float Fx = M * cos(A);
    // force in Dir y is force M * sin of A
    float Fy = M * sin(A);
    // apply this force to the player by calling the players addForce() and passig it the force x,y but reversed represent a push and not pull,
    // also devided by 8 right now to make the ship more resistant to forces.
    if (s1.state=="AntiMatter") {
      player.addForce(new PVector(Fx, Fy));
    } else {
      player.addForce(new PVector(-Fx, -Fy));
    }
  }

  // This for loop is used to check each stars force via mass and apply it onto the enemies, But not the other way
  for (Star s1 : stars) {
    for (Enemy e : enemies) {
      // find vector between objects
      PVector V = PVector.sub(e.position, s1.position);
      // find their magnitude squared
      float magSq = V.x * V.x + V.y * V.y;
      // find the amount of force between them
      float M = G * s1.mass * player.mass /magSq;
      // if that force is too big cap it
      if (M > maxForce) M = maxForce;
      // angle of force equales arcTanSquared of the vector V
      float A = atan2(V.y, V.x);
      // force in Dir X is force M * cos of A
      float Fx = 100 * M * cos(A);
      // force in Dir y is force M * sin of A
      float Fy = 100 * M * sin(A);
      // apply this force to the player by calling the players addForce() and passig it the force x,y but reversed represent a push and not pull,
      // also devided by 8 right now to make the ship more resistant to forces.
      if (s1.state=="AntiMatter") {
        e.addForce((new PVector(Fx, Fy)));
      } else {
        e.addForce(new PVector(-Fx, -Fy));
      }
    }
  }
  ///////////////////////Star Gravity With Bullets///////////////////////
  // This for loop is used to check each stars force via mass and apply it onto the bullets, But not the other way
  for (Star s1 : stars) {
    for (Bullet b : bullets) {
      // find vector between objects
      PVector V = PVector.sub(b.position, s1.position);
      // find their magnitude squared
      float magSq = V.x * V.x + V.y * V.y;
      // find the amount of force between them
      float M = G * s1.mass * player.mass /magSq;
      // if that force is too big cap it
      if (M > maxForce) M = maxForce;
      // angle of force equales arcTanSquared of the vector V
      float A = atan2(V.y, V.x);
      // force in Dir X is force M * cos of A
      float Fx = 100 * M * cos(A);
      // force in Dir y is force M * sin of A
      float Fy = 100 * M * sin(A);
      // apply this force to the player by calling the players addForce() and passig it the force x,y but reversed represent a push and not pull,
      // also devided by 8 right now to make the ship more resistant to forces.
      if (s1.state=="AntiMatter") {
        b.addForce((new PVector(Fx, Fy)));
      } else {
        b.addForce(new PVector(-Fx, -Fy));
      }
    }
  }
  
  
}

/*
* SetStars() is a function used to place a lot of stars within the playing field usualy right at setup
 */
void SetStars() {
  for (int i = 0; i<100; i++) {
    // add a new star to the toCreate list with a give MASS, POSITION, and Boolean of whether its from an exploding star or not
    toCreate.add(new Star(10, new PVector(random(-1000, 1000), random(-1000, 1000)), "Dropped"));
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

  for (Enemy e : enemiesToCreate) enemies.add(new Enemy(e.state, e.position));
  enemiesToCreate = new ArrayList<Enemy>();

  for (Bullet b : bulletsToCreate) bullets.add(new Bullet(b.position, b.velocity, b.state ));
  bulletsToCreate = new ArrayList<Bullet>();
}




void StartStar() {
  if (starStarted) {
    if (newStar.mass<=300) {
      newStar.mass+=10;
    }
    newStar.position=new PVector(mouseX-offset.x, mouseY-offset.y);
  } else {
    starStarted=true;
    newStar = new Star(10, new PVector(mouseX, mouseY), "Dropped");
  }
}

void EndStar() {
  toCreate.add(newStar);
  starStarted=false;
  newStar=null;
};

void StartAntiMatter() {
  if (starStarted) {
    if (newStar.mass<=300) {
      newStar.mass+=10;
    }
    newStar.position = new PVector(mouseX-offset.x, mouseY-offset.y);
  } else {
    starStarted=true;
    newStar = new Star(10, new PVector(mouseX, mouseY), "AntiMatter");
  }
}
void EndAntiMatter() {
  toCreate.add(newStar);
  starStarted=false;
  newStar=null;
}
/*
* checkInput checks with Controls class controls to see if any of the Key booleans have been toggles to true, meaning the user
 * has applied input
 */
void MouseDown() {
  switch(weapon) {
  case "Matter":
    StartStar();
    break;
  case "AntiMatter":
    StartAntiMatter();
    break;
  }
}
void MouseUp() {

  if (starStarted) EndStar();
  if (antiMatStarted) EndAntiMatter();
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
  // if Space was pressed 
  if (control.SPACE) {
    // add a star of random mass, at the plaers pos, that did not come from an exploding source to the arraylist toCreate
    if ( millis()-player.timeSinceLastBullet>player.fireRate) {
    bulletsToCreate.add(new Bullet(player.position, new PVector(5*cos(player.rotation+HALF_PI), 5*sin(player.rotation+HALF_PI)), "PlayerBullet"));
      player.timeSinceLastBullet = millis();
    } 
  } 

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