class PickUp {
  //////////////////     Constructors   ///////
  PickUp() {
    this.position = new PVector(random(-1000, 1000), random(-1000, 1000));
    type= RandomType();
    CreateShape();
  }
  PickUp(PVector position) {
    this.position = position;
    type= RandomType();
    CreateShape();
  }

  PickUp(PVector position, String type) {
    this.position = position;
    this.type=type;
    CreateShape();
  }

  ///////////////   Variables    /////////

  //type indecates te type of pickup this pickup is
  //options are Bombs, Health, Shield, Invisable, Missiles, Beamgun, AntiMatter
  String type="Health"; 
  String[] types ={ "Bombs", "Health", "Shield", "Invisable", "Missile", "Beamgun", "Antimatter","TriShot","BetterRange"};
  // points is the collected points that make up the shape of the player
  color c = color(255);
  private ArrayList<PVector> points = new ArrayList<PVector>();
  // pointsTransformed is an arraylist containing PVector points from the player that have been changed this frame 
  private PVector[] pointsTransformed;
  // normals is an arraylist of PVectors that represent the normals of the ships sides
  private PVector[] normals;
  // dirty is a boolean to indicae whether the players ship and points have been changed this frame
  private boolean dirty = true;
  //scale
  private float scale = .5;
  //float direction is used to toggle scales fluxuation
  private float direction=1;
  // rotation is a float htat holds the players angle of rotation around its center axis
  private float rotation = 0;
  // position is a PVector that contains the players position, initialy set to the center of the screen
  private PVector position = new PVector(width/2, height/2);
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
  // MinMax set to a new class MinMax that hold the min and max values of widths upon a given axis
  MinMax mm =new MinMax(0, 0);


  /////////// Update ////////////
  void update() {
    force.div(mass);
    acceleration.add(force);
    velocity.add(acceleration);
    rotation = rotation+radians(1);
    if (rotation>TWO_PI) rotation=0;
    setPosition(position.add(velocity));

    resetValues();
    aabb.resetColliding();
    recalc();

    if (scale>=1||scale<=.2) direction*=-1;
    scale = scale+(.005*direction);
  }

  void draw() {
    update();
    pushStyle();
    noStroke();
    fill(c);
    textSize(10);
    text(type, position.x-15, position.y+20);
    beginShape();
 
      for (int i = 0; i < pointsTransformed.length; i++) {
      vertex(pointsTransformed[i].x, pointsTransformed[i].y);
    }
      
    endShape();
    popStyle();
    
    
    
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







  /*
**************************Collision Detection Function***************
   */
  void checkCollision() {
    //checkStarCollisions(stars);
    //checkEnemyCollisions(enemies);
    checkPlayerCollisions();
  }
  /*
Check collision with stars array list
   
   */
  void checkPlayerCollisions() {
    if (checkPlayerCollision()) {
      println("Enemy Grabbed Pickup");
      handleCollision();
      
    }
  }

  boolean checkPlayerCollision() {
    if (aabb.checkCollision(player.aabb)) {
      for (PVector n : normals) {
        this.mm = this.mm.projectPickUpAlongAxis(n, this);
        player.mm = player.mm.projectPlayerAlongAxis(n, player);
        if (this.mm.min>player.mm.max) return false;
        if (player.mm.min>this.mm.max) return false;
        return true;
      }
      for (PVector n : player.normals) {
        this.mm = this.mm.projectPickUpAlongAxis(n, this);
        player.mm = player.mm.projectPlayerAlongAxis(n, player);
        if (this.mm.min>player.mm.max) return false;
        if (player.mm.min>this.mm.max) return false;
        return true;
      }
      return false;
    }
    return false;
  }

  void handleCollision(){
   pickUpsToKill.add(this);
   switch(type){
     case "Bomb":
     player.bombs+=1;
      break;
    case "Health":
    player.health = 100;
      break;
    case "Shield":
    player.shield=true;
      break;
    case "Invisable":
    player.invisable=true;
      break;
    case "Missile":
    player.missiles+=1;
      break;
    case "Beamgun":
    player.beamGunAmmo=+50;
      break;
    case "Antimatter":
    player.antiMatterAmmo+=30;
      break;
      case "TriShot":
    player.triShot=true;
      break;
      case "BetterRange":
    player.bulletRange+=500;
      break;
   }
    
  }


  ///////////////////////  Random Type Function ////////////////////
  String RandomType() {
    int rand = int(random(0, 100));
    println(types.length*4);
    String t="Health";
    if(rand<=20){//4
      t="Antimatter";
    }else if( rand>20&&rand<=40){//8
      t="Health";      
    }else if( rand>40&&rand<=50){//2
      t="Bomb";      
    }else if( rand>50&&rand<=60){//2
      t="TriShot";      
    }else if( rand>60&&rand<=65){//2
      t="Missile";      
    }else if( rand>65&&rand<=70){//2
      t="BeamGun";      
    }else if( rand>70&&rand<=80){//8
      t="Shield";      
    }else if( rand>80&&rand<=90){//4
      t="Invisable";      
    }else if( rand>90&&rand<=100){//2
      t="BetterRang";      
    }else{
     t="Health"; 
    }

    return t;
  }


  void CreateShape() {
    switch(type) {
    case "Bomb":
      MakePent();
      c= color(255,0,0);//red
      break;
    case "Health":
      MakePent();
       c= color(0,255,0);//green
      break;
    case "Shield":
      MakeSquare();
       c= color(0,0,255);//blue
      break;
    case "Invisable":
      MakeTri();
       c= color(255,255,0);//yello
      break;
    case "Missile":
      MakeTri();
       c= color(255,0,0);//red
      break;
    case "Beamgun":
      MakeRect();
       c= color(255,0,0);//red
      break;
    case "Antimatter":
      MakeSquare();
       c= color(255,0,255);//purple
      break;
      case "TriShot":
      MakeTripleTri();
       c= color(255,0,255);//purple
      break;
      case "BetterRange":
      MakeDoubleTri();
       c= color(255,0,255);//purple
      break;
    }
  }

  void MakeTri() {
    addPoint(-10, -10);
    addPoint(10, -10);
    addPoint(0, 20);
  }
  void MakeSquare() {
    addPoint(-10, -10);
    addPoint(10, -10);
    addPoint(10, 10);
    addPoint(-10, 10);
  }
  void MakePent() {
    addPoint(10, 5);
    addPoint(10, -5);
    addPoint(5, -10);
    addPoint(-5, -10);
    addPoint(-10, -5);
    addPoint(-10, 5);
    addPoint(-5, 10);
    addPoint(5, 10);
  }
  void MakeRect() {
    addPoint(-20, -10);
    addPoint(20, -10);
    addPoint(20, 10);
    addPoint(-20, 10);
  }
  void MakeDoubleTri() {
    addPoint(0,25);
    addPoint(10, 10);
    addPoint(3, 10);
    addPoint(10, -5);
    addPoint(-10, -5);
    addPoint(-1, 10);
    addPoint(-10, 10);
  }
  void MakeTripleTri() {
    addPoint(0, 0);
    addPoint(-10, 0);
    addPoint(-5, 10);
    addPoint(0, 20);
    addPoint(5, 10);
    addPoint(-5, 10);
    addPoint(0, 0);
    addPoint(5, 10);
    addPoint(10, 0);
    addPoint(0,0);
  }
}