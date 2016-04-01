class Missile {
  float life;
  String type;
  String mode = "Ticking";
  PVector position;
  float birthTime;

  color c=  color(255, 0, 0);
  // points is the collected points that make up the shape of the player
  private ArrayList<PVector> points = new ArrayList<PVector>();
  // pointsTransformed is an arraylist containing PVector points from the player that have been changed this frame 
  private PVector[] pointsTransformed;
  // normals is an arraylist of PVectors that represent the normals of the ships sides
  private PVector[] normals;
  // dirty is a boolean to indicae whether the players ship and points have been changed this frame
  private boolean dirty = true;
  //float direction is used to toggle scales fluxuation
  private float direction=1;
  // rotation is a float htat holds the players angle of rotation around its center axis
  private float rotation = 0;
  // PVector velocity containts the players veloctiy which is recalculated and applied to the player every scene
  public PVector velocity = new PVector();
  // PVector acceleration holds the players acceleration based off of velocity each frame
  PVector acceleration = new PVector();
  // PVector force holds a vector the represents the amount of force for applying to the player
  PVector force = new PVector();
  // players inital mass is 100 used for calculating gravity and forces with other things
  float mass = 50;
  AABB aabb = new AABB();
  MinMax mm =new MinMax(0, 0);

  Enemy target;


  Missile(PVector position, String type) {
    this.position = position;
    this.type=type;
    CreateShape();

    if (type=="Player") {
      Retarget();
    }
    birthTime = millis()/1000;
  }



  void update() {


    MoveAtTarget();

    force.div(mass);
    acceleration.add(force);
    velocity.add(acceleration);
    if (rotation>TWO_PI) rotation=0;
    setPosition(position.add(velocity));
    println(birthTime+"    " + millis()/1000);
    if (millis()/1000-birthTime>3) {
      println("EXP");
      Explode();
      missilesToKill.add(this);
    };
    resetValues();
    aabb.resetColliding();
    recalc();
  }


  void draw() {
    update();
    pushStyle();
    noStroke();
    fill(c);
    textSize(10);
    beginShape();
    for (int i = 0; i < pointsTransformed.length; i++) {
      vertex(pointsTransformed[i].x, pointsTransformed[i].y);
    }      
    endShape();
    popStyle();
  }

  void Explode() {
    bombsToCreate.add(new Bomb(this.position, "Exploding"));
  }

  void Retarget() {



    for (Enemy e : enemies) {
      println("TEST");
      PVector distV = PVector.sub(this.position, e.position);
      if (target==null)target=e;
      if (distV.mag()<PVector.sub(position, target.position).mag())  this.target=e;
      e.targeted=true;
    }
  }


  void MoveAtTarget() {
    switch(type) {
    case "Player":
      PVector V = PVector.sub(this.position, target.position);
      float A = atan2(V.y, V.x);
      float towardsTarget = A-HALF_PI;
      if (rotation<towardsTarget) rotation += .05;
      if (rotation>towardsTarget) rotation-= .05;
      //rotation = towardsTarget;
      float Fx = 2 * cos(rotation+HALF_PI);
      float Fy = 2 * sin(rotation+HALF_PI);
      addForce(new PVector(-Fx,-Fy));
      break;
    case "Enemy":
      PVector distV = PVector.sub(this.position, target.position);
      float playerA = atan2(distV.y, distV.x);
      float towardsPlayer = playerA-HALF_PI;
      rotation = towardsPlayer;
      break;
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

    matrix.scale(scale);
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






  void CheckCollisions() {
    for (Enemy e : enemies) {
      if (checkEnemyCollision(e)&&type=="PlayerMissle") {
        enemiesToKill.add(e);
        println("Missle hit enemy");
        missilesToKill.add(this);
      }
    }
    if (checkPlayerCollision()&&type=="EnemyMissle") {
      println("missle hit player");
    }
  }

  /////////////////////////Run Collision check with each class item

  boolean checkPlayerCollision() {
    if (aabb.checkCollision(player.aabb)) {
      for (PVector n : normals) {
        this.mm = this.mm.projectMissleAlongAxis(n, this);
        player.mm = player.mm.projectPlayerAlongAxis(n, player);
        if (this.mm.min>player.mm.max) return false;
        if (player.mm.min>this.mm.max) return false;
        return true;
      }
      for (PVector n : player.normals) {
        this.mm = this.mm.projectMissleAlongAxis(n, this);
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
    if (aabb.checkCollision(e.aabb)) {
      for (PVector n : normals) {
        this.mm = this.mm.projectMissleAlongAxis(n, this);
        e.mm = e.mm.projectEnemyAlongAxis(n, e);
        if (this.mm.min>e.mm.max) return false;
        if (e.mm.min>this.mm.max) return false;
        return true;
      }
      for (PVector n : e.normals) {
        this.mm = this.mm.projectMissleAlongAxis(n, this);
        e.mm = e.mm.projectEnemyAlongAxis(n, e);
        if (this.mm.min>e.mm.max) return false;
        if (e.mm.min>this.mm.max) return false;
        return true;
      }
      return false;
    }
    return false;
  }

  void CreateShape() {
    addPoint(0, -10);
    addPoint(2, -6);
    addPoint(2, -1);
    addPoint(3, 0);
    addPoint(-3, 0);
    addPoint(-2, -1);
    addPoint(-2, -6);
  }
}