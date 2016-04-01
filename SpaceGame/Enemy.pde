public class Enemy {
  String type = "SmallAlien";
  String mode = "Scanning"; 
  public int health= 100;
  // players inital mass is 100 used for calculating gravity and forces with other things
  float mass = 200;
  public float fireRate = 500;
  public float maxSpeed = 1;


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

  PVector distVect = new PVector();


  // new AABB for testing widre range collision 
  AABB aabb = new AABB();
  // doneChecking is a boolean used to stop loops from checking for collision once they have already checked
  boolean enemyCheckingEnemy = false;
  boolean enemyCheckingStars = false;
  boolean enemyCheckingPlayer = false;
  // colliding is a boolean set to true if the ship hits anything
  public boolean colliding = false;
  // MinMax set to a new class MinMax that hold the min and max values of widths upon a given axis
  MinMax mm =new MinMax(0, 0);
  // boundaries is a boolean that tells the player whether it should react to the previously set boundareis
  boolean boundaries =false;

  public float timeSinceLastBullet = 0;

  public boolean targeted= false;

  /*
  *
   ***********************Constructors
   *
   */

  public Enemy(String type, PVector pos) {
    this.position = pos;
    this.type = type;
    makeEnemy();
    recalc();
  }

  /*
  *
   */
  void update() {
     distVect = PVector.sub(player.position,this.position);

    handleMovement();
    if (health<=0)enemiesToKill.add(this);

    force.div(mass);
    acceleration.add(force);
    velocity.add(acceleration);
    if (rotation>TWO_PI) rotation=0;
    setPosition(position.add(velocity));



    if (mode =="Shooting") {
      if ( millis()-this.timeSinceLastBullet>this.fireRate) {
        println("SPAWN BULLETS");
        bulletsToCreate.add(new Bullet(position, new PVector(5*cos(rotation+HALF_PI), 5*sin(rotation+HALF_PI)), "EnemyBullet"));
        this.timeSinceLastBullet = millis();
      }
    }

    resetValues();
    enemyCheckingPlayer = false;
    enemyCheckingStars = false;
    enemyCheckingEnemy = false;

    colliding = false;
    aabb.resetColliding();
    if (dirty) recalc();
  }


  void draw() {
    update();
    noStroke();
    fill(255, 0, 0);
    textSize(15);
    text(health, position.x-10, position.y+20);
    beginShape();
    for (int i = 0; i < pointsTransformed.length; i++) {
      vertex(pointsTransformed[i].x, pointsTransformed[i].y);
    }
    endShape();
  }









  /*
*******This function updates the movement
   */
  void handleMovement() {
    //PVector V = PVector.sub(player.position, this.position);
    //float magSq = distVect.x * distVect.x + distVect.y * distVect.y;
    float mag = mag(distVect.y, distVect.x);
    float A = atan2(distVect.y, distVect.x);

    //These are normalized forces because A is only the angle of V and no magnitude, 
    float Fx = cos(A);
    // The force of pull in the direction of y is the force M * sin of A
    float Fy = sin(A);

    //float towardsPlayer = atan2(Fy,Fx)-HALF_PI;
    float towardsPlayer = A-HALF_PI;
    //set mode based off of player distance and view
    //if player too far away then set to scanning
    if (mag>400) mode = "Scanning";

    //if player is close enough and enemies rotation is somewhate near player(+ and -
    if (mag<400&&rotation<towardsPlayer+QUARTER_PI&&rotation>towardsPlayer-QUARTER_PI) mode = "Chasing";
    if (mag<125) mode= "Shooting";

    //handle movement based off of mode
    switch(mode) {
    case "Scanning":
      this.addForce(new PVector(random(-.1, .1), random(-.1, .1)));
      rotation = rotation +=radians(random(0, .3));
      break;
    case "Chasing":
      this.addForce(new PVector(Fx, Fy));
      rotation = towardsPlayer;
      break;


    case "Shooting":
      velocity= velocity.mult(.5);
      rotation = towardsPlayer;
      break;
    }






    //if going to fast then slow down
    if (abs(velocity.x)>maxSpeed) velocity.x*=.8;
    if (abs(velocity.y)>maxSpeed) velocity.y*=.8;
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

    matrix.scale(.5);
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

  void HitEnemy(Enemy e) {
    PVector V = PVector.sub(e.position, this.position);
    //float magSq = V.x * V.x + V.y * V.y;
    //float mag = mag(V.y, V.x);
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
  void checkCollision() {
    checkStarCollisions(stars);
    checkEnemyCollisions(enemies);
    checkPlayerCollisions();
  }

  /*
Check collision with stars array list
   
   */
  void checkStarCollisions(ArrayList<Star> stars) {

    for (Star s : stars) {

      if (s.starCheckingEnemy == true) continue;   

      if (checkStarCollision(s)) {
        println("enemy hit star");
        colliding = true;
        s.colliding = true;
        HitStar(s, this);
      }
    }
    enemyCheckingStars = true;
  }
  /*
Check collision with stars array list
   
   */
  void checkEnemyCollisions(ArrayList<Enemy> enemies) {
    for (Enemy e : enemies) {
      if (e.enemyCheckingEnemy == true) continue;
      if (checkEnemyCollision(e)) {
        colliding = true;
        e.colliding = true;
        HitEnemy(e);
      }
    }
    enemyCheckingEnemy = true;
  }
  /*
Check collision with stars array list
   
   */
  void checkPlayerCollisions() {
    if (checkPlayerCollision()) {
      colliding = true;
      player.colliding = true;
      println("enemy HITplayer");
    }
    enemyCheckingPlayer = true;
  }



  boolean checkStarCollision(Star star) {
    if (aabb.checkCollision(star.aabb)) {


      PVector dist = new PVector();
      int pos = 0;
      for (int i=0; i < this.points.size(); i++) {
        PVector p = this.points.get(i);
        if (PVector.sub(p, star.position).mag()<dist.mag()||dist.mag()==0) {
          dist=PVector.sub(p, star.position);
          pos =i;
        }
      }
      //dist is the vector u need to check the normal of
      //but this is the long and sure way of getting the distance normal
      PVector Distnormal = new PVector(star.position.y - this.points.get(pos).y, this.points.get(pos).x - star.position.x);
      this.mm = this.mm.projectEnemyAlongAxis(Distnormal, this);
      star.mm = star.mm.projectSphereAlongAxis( Distnormal, position, star.size);
      if (this.mm.min>star.mm.max) return false;
      if (star.mm.min>this.mm.max) return false;

      for (PVector n : normals) {


        this.mm = this.mm.projectEnemyAlongAxis(n, this);
        star.mm = star.mm.projectSphereAlongAxis( n, star.position, star.size);
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
    if (this==e) return false;
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


  void HitStar(Star s, Enemy e) {

    if (s.mass>mass) {
      //kill e
      enemiesToKill.add(e);
    } else {
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
}