public class Enemy {
  String state = "SmallAlien";

  PVector position = new PVector();


  // points is the collected points that make up the shape of the player
  private ArrayList<PVector> points = new ArrayList<PVector>();

  // pointsTransformed is an arraylist containing PVector points from the player that have been changed this frame 
  private PVector[] pointsTransformed;
  // normals is an arraylist of PVectors that represent the normals of the ships sides
  private PVector[] normals;

  // dirty is a boolean to indicae whether the players ship and points have been changed this frame
  private boolean dirty = true;
  // rotation is a float htat holds the players angle of rotation around its center axis
  private float rotation = 0;
  // PVector velocity containts the players veloctiy which is recalculated and applied to the player every scene
  public PVector velocity = new PVector();
  // PVector acceleration holds the players acceleration based off of velocity each frame
  PVector acceleration = new PVector();
  // PVector force holds a vector the represents the amount of force for applying to the player
  PVector force = new PVector();
  // players inital mass is 100 used for calculating gravity and forces with other things
  float mass = 100;
  // new AABB for testing widre range collision 
  AABB aabb = new AABB();
  // doneChecking is a boolean used to stop loops from checking for collision once they have already checked
  boolean doneCheckingStars = false;
  boolean doneCheckingEnemies = false;
  boolean doneCheckingPlayer = false;
  // colliding is a boolean set to true if the ship hits anything
  public boolean colliding = false;
  // MinMax set to a new class MinMax that hold the min and max values of widths upon a given axis
  MinMax mm =new MinMax(0, 0);
  // boundaries is a boolean that tells the player whether it should react to the previously set boundareis
  boolean boundaries =false;

  /*
  *
   ***********************Constructors
   *
   */

  public Enemy(String state, PVector pos) {
    this.position = pos;
    this.state = state;
    makeEnemy();
    recalc();
  }

  /*
  *
   */
  void update() {

    handleMovement();


    force.div(mass);
    acceleration.add(force);
    velocity.add(acceleration);
    if (rotation>TWO_PI) rotation=0;
    setPosition(position.add(velocity));
    if(colliding) Destroy();
    
    resetValues();
    doneCheckingPlayer = false;
    doneCheckingStars = false;
    doneCheckingEnemies = false;
    
    colliding = false;
    aabb.resetColliding();
    if (dirty) recalc();
  }


  void draw() {
    update();
    noStroke();
    fill(255, 0, 0);

    beginShape();
    for (int i = 0; i < pointsTransformed.length; i++) {
      vertex(pointsTransformed[i].x, pointsTransformed[i].y);
    }
    endShape();
  }

  void handleMovement() {
    PVector V = PVector.sub(player.position, this.position);
    float magSq = V.x * V.x + V.y * V.y;
    float mag = mag(V.y, V.x);
    float A = atan2(V.y, V.x);
    float Fx = cos(A);
    // The force of pull in the direction of y is the force M * sin of A
    float Fy = sin(A);
    rotation = atan2(Fy,Fx)-HALF_PI;
  
//radians
    if ( mag>=250 && abs(velocity.x)<10&&abs(velocity.y)<10) {
      this.addForce(new PVector(Fx, Fy));
    } else if ( mag<=200 ) {
      velocity= velocity.mult(.9);
    }

  }


  /*
  *recalc is a function called when the players ship has been moved and needs to be recalculated
   */
  void recalc() {
    dirty = false;
    // everything you know neo is wrong, there is a matrix
    PMatrix2D matrix = new PMatrix2D();
    // Now in this matrix neo, we can translate anything, like the players position to to keep the player centered
    matrix.translate(position.x, position.y); //PUT this back for NO FOLLOW CAM
    // matrix.translate(width/2, height/2); //SWITCH THIS FOR FOLLOW CAM
    // rotate the matrix by the palyers rotation to rotate the palyer
    matrix.rotate(rotation);
    // set pointtransformed to a new array the size of points
    pointsTransformed = new PVector[points.size()];
    //for each point in points
    for ( int i = 0; i < points.size(); i++) {
      // get a blank PVectore names p
      PVector p = new PVector();
      //multiply that point by the matrix when u get it from points[]
      matrix.mult(points.get(i), p);
      // put p into pointsTransformed at its spot
      pointsTransformed[i] = p;
    }
    // the arraylis norals is set to a new array the size of points
    normals = new PVector[pointsTransformed.length];
    //for each point in the array
    for (int i = 0; i < pointsTransformed.length; i ++) {
      // int j the point before this one if it exsists
      int j = (i == pointsTransformed.length - 1) ? 0 : i +1;
      // temp PVector p1 is set to pointsTrans of this point
      PVector p1 = pointsTransformed[i];
      // temp PVector p2 is set to points trans of the previous point
      PVector p2 = pointsTransformed[j];
      // set noraml[i] to the noraml of p1 and p2
      normals[i] = new PVector(p1.y - p2.y, p2.x - p1.x);
    }
    // recalculate the aabb's with points transformed
    aabb.recalc(pointsTransformed);
  }

void HitEnemy(Enemy e){
   PVector V = PVector.sub(e.position, this.position);
    float magSq = V.x * V.x + V.y * V.y;
    float mag = mag(V.y, V.x);
    float A = atan2(V.y, V.x);
    float Fx = cos(A);
    // The force of pull in the direction of y is the force M * sin of A
    float Fy = sin(A);
    this.addForce(new PVector(-Fx, -Fy));
    e.addForce(new PVector(Fx, Fy));
}


/*
**************************Collision Detection Function***************
*/
void checkCollision(){
  checkStarCollisions(stars);
  checkEnemyCollisions(enemies);
  checkPlayerCollision();
}

 /*
Check collision with stars array list
   
  */
 void checkStarCollisions(ArrayList<Star> stars) {
  
   for (Star s : stars) {
     if (s.doneCheckingEnemies == true) continue;    
     if (checkStarCollision(s)) {
       colliding = true;
       s.colliding = true;
       HitStar(s);
      println("HIT");
     }
   }
   doneCheckingStars = true;
 }
 /*
Check collision with stars array list
   
  */
 void checkEnemyCollisions(ArrayList<Enemy> enemies) {
   for (Enemy e : enemies) {
     if (e.doneCheckingEnemies == true) continue;
     if (checkEnemyCollision(e)) {
       colliding = true;
       e.colliding = true;
       HitEnemy(e);
       
     }
   }
   doneCheckingEnemies = true;
 }
 /*
Check collision with stars array list
   
  */
 void checkPlayerCollisions() {
     if (checkPlayerCollision()) {
       colliding = true;
      player.colliding = true;
       println("HITplayer");
     }
  doneCheckingPlayer = true;
 }
 boolean checkStarCollision(Star star) {
   if (aabb.checkCollision(star.aabb)) {
     for (PVector n : normals) {
       this.mm = this.mm.projectEnemyAlongAxis(n, this);
       star.mm = star.mm.projectSphereAlongAxis(n, star.position, star.mass);
       if (this.mm.min>star.mm.max) return false;
       if (star.mm.min>this.mm.max) return false;
       return true;
     }
     return false;
   }
   return false;
 }
 boolean checkPlayerCollision() {
   if (aabb.checkCollision(player.aabb)) {
     for (PVector n : normals) {
       this.mm = this.mm.projectEnemyAlongAxis(n, this);
       player.mm = player.mm.projectPlayerAlongAxis(n, player);
       if (this.mm.min>player.mm.max) return false;
       if (player.mm.min>this.mm.max) return false;
       return true;
     }
     for (PVector n : player.normals) {
       this.mm = this.mm.projectEnemyAlongAxis(n, this);
       player.mm = player.mm.projectPlayerAlongAxis(n, player);
       if (this.mm.min>player.mm.max) return false;
       if (player.mm.min>this.mm.max) return false;
       return true;
     }
     return false;
   }
   return false;
 }
boolean checkEnemyCollision(Enemy e) {
   if(this==e) return false;
   if (aabb.checkCollision(e.aabb)) {
     for (PVector n : normals) {
       this.mm = this.mm.projectEnemyAlongAxis(n, this);
       e.mm = e.mm.projectEnemyAlongAxis(n, e);
       if (this.mm.min>e.mm.max) return false;
       if (e.mm.min>this.mm.max) return false;
       return true;
     }
     for (PVector n : e.normals) {
       this.mm = this.mm.projectEnemyAlongAxis(n, this);
       e.mm = e.mm.projectEnemyAlongAxis(n, e);
       if (this.mm.min>e.mm.max) return false;
       if (e.mm.min>this.mm.max) return false;
       return true;
     }
     return false;
   }

   return false;
 }


void HitStar(Star s){
  if(s.mass>mass*3){
    //kill e
    enemiesToKill.add(this);
  }else{
    //kil star
    toKill.add(s);
  }
  
}



  /*
*setRotation sets the rotation oft he players ship and flips dirty to true
   * @param float r is the roatation to set it to
   */
  public void setRotation(float r) { 
    rotation = r; 
    dirty = true;
  }
  /*
*setPosition sets the position oft he players ship and flips dirty to true
   * @param PVector p is the position to set it to
   */
  public void setPosition(PVector p) { 
    position = p.copy(); 
    dirty = true;
  }

  void resetValues() {
    // Reset force and acceleration to zero every update!
    force.mult(0);
    acceleration.mult(0);
  }
  void addForce(PVector f) {
    // Add vector f to force property
    force.add(f);
  }
  void addPoint(PVector p) {
    addPoint(p.x, p.y);
  }

  void addPoint(float x, float y) {
    points.add(new PVector(x, y));
  }


  void makeEnemy() {
    Enemy e = this;
    e.addPoint(-10, -10);
    e.addPoint(10, -10);
    e.addPoint(0, 20);
  }
  
  void Destroy(){
    
  }
}