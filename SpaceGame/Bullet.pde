class Bullet {


  public Bullet(PVector pos, PVector velocity, String state) {
    this.state = state;
    this.velocity=velocity;
    position = pos;
    birthTime=millis();
    if(state=="PlayerBullet"){
      lifeSpan=player.bulletRange;
    }
  }
  float size=2;
  float mass = 100;

  String state;//EnemyBullet PlayerBullet etc.
  PVector velocity = new PVector();
  public PVector position = new PVector();
  PVector acceleration = new PVector();
  PVector force = new PVector();

  AABB aabb = new AABB();
  MinMax mm =new MinMax(0, 0);
  boolean done = false;
  public boolean colliding = false;
  public boolean destroyed = false;

  boolean bulletCheckingEnemy = false;
  boolean bulletCheckingStars = false;
  boolean bulletCheckingPlayer = false;

  float birthTime;
  float lifeSpan = 1000;
  void setup() {

    birthTime=millis();
  }

  void draw() {

    pushStyle();

    switch(state) {
    case "PlayerBullet":
      fill(255, 0, 0);
      break;
    case " EnemyBullet":
      fill(0, 0, 255);
      break;
    }
    ellipse(position.x, position.y, size, size);  
    PVector middle = new PVector(position.x-velocity.x*1.3,position.y-velocity.y*1.3);
    ellipse(middle.x,middle.y,size/1.3,size/1.3);
    PVector tail = new PVector(position.x-velocity.x*1.7,position.y-velocity.y*1.7);
    ellipse(tail.x,tail.y,size/2,size/2);
    
    
    popStyle();
  }

  void update() {

    force.div(mass);
    acceleration.add(force);
    velocity.add(force);
    position.add(velocity);

    bulletCheckingPlayer = false;
    bulletCheckingStars = false;
    bulletCheckingEnemy = false;
    colliding = false;
    aabb.resetColliding();
    aabb.recalc(position, size);

    //Destroy bullet after lifespan
    if ( millis()-birthTime>=lifeSpan) {
      bulletsToKill.add(this);
    } 
    draw();
  }

  //////////////////////////////////////Check Collisions//////////////
  public void checkCollision() {
    for (Star s : stars) {
      // if (s.starCheckingStars==true) continue;
      if (checkStarCollision(s)) {
        colliding=true;
        s.colliding = true;
      }
      bulletCheckingStars =true; //ake seperate for each item
    }   

    for (Enemy e : enemies) {
      if (checkEnemyCollision(e)) {
        switch(state) {
        case "EnemyBullet":
          break;
        case "PlayerBullet":
          collideWithEnemy(e);
          break;
        }
      }
    }
    bulletCheckingEnemy =true;

    if (checkPlayerCollision()) {
      switch(state) {
      case "EnemyBullet":
        player.health-=mass/10;
        break;
      case "PlayerBullet":
        break;
      }
    }
    bulletCheckingPlayer=true;
  }


  /*
  *
   *Check Collision with star
   */
  boolean checkStarCollision(Star star) {
    PVector v = new PVector(this.position.x - star.position.x, this.position.y - star.position.y);
    if ( mag(v.x, v.y) <= (this.size/2) + (star.size/2) ) {
      return true;
    } else {
      return false;
    }
  }

  /*
  *
   *Check Collision with star
   */
  boolean checkEnemyCollision(Enemy e) {
    //check star with enemy
    if (aabb.checkCollision(e.aabb)) {
      PVector dist = new PVector();
      int pos = 0;
      for (int i=0; i < e.points.size(); i++) {
        PVector p = e.points.get(i);
        if (PVector.sub(p, this.position).mag()<dist.mag()||dist.mag()==0) {
          dist=PVector.sub(p, this.position);
          pos =i;
        }
      }
      //dist is the vector u need to check the normal of
      //but this is the long and sure way of getting the distance normal
      PVector Distnormal = new PVector(this.position.y - e.points.get(pos).y, e.points.get(pos).x - this.position.x);
      e.mm = e.mm.projectEnemyAlongAxis(Distnormal, e);
      this.mm = this.mm.projectSphereAlongAxis( Distnormal, position, this.size);
      if (e.mm.min>this.mm.max) return false;
      if (this.mm.min>e.mm.max) return false;





      for (PVector n : e.normals) {

        e.mm = e.mm.projectEnemyAlongAxis(n, e);
        this.mm = this.mm.projectSphereAlongAxis( n, position, size);
        if (e.mm.min>this.mm.max) return false;
        if (this.mm.min>e.mm.max) return false;
        return true;
      }
      return false;
    }
    return false;
  }

  /*
  *
   *Check Collision with star
   */
  boolean checkPlayerCollision() {
    if (aabb.checkCollision(player.aabb)) {
      PVector dist = new PVector();
      int pos = 0;
      for (int i=0; i < player.points.size(); i++) {
        PVector p = player.points.get(i);
        if (PVector.sub(p, this.position).mag()<dist.mag()||dist.mag()==0) {
          dist=PVector.sub(p, this.position);
          pos =i;
        }
      }
      //dist is the vector u need to check the normal of
      //but this is the long and sure way of getting the distance normal
      PVector Distnormal = new PVector(this.position.y - player.points.get(pos).y, player.points.get(pos).x - this.position.x);
      player.mm = player.mm.projectPlayerAlongAxis(Distnormal, player);
      this.mm = this.mm.projectSphereAlongAxis( Distnormal, position, size);
      if (player.mm.min>this.mm.max) return false;
      if (this.mm.min>player.mm.max) return false;

      for (PVector n : player.normals) {
        player.mm = player.mm.projectPlayerAlongAxis(n, player);
        this.mm = this.mm.projectSphereAlongAxis(n, this.position, this.size);
        if (this.mm.min>player.mm.max) return false;
        if (player.mm.min>this.mm.max) return false;
        return true;
      }
      return false;
    }
    return false;
  }







  ///////////////////////////////////////////Handle Coliision/////////

  /*
   *This function handles the deletion of the bullet if cucked into a star
   */
  void collideWithStar(Star star) {

    bulletsToKill.add(this);
  }
  void collideWithPlayer() {
    player.health-=10;
    bulletsToKill.add(this);
  }
  void collideWithEnemy(Enemy e) {
    e.health-=mass/2;
    //enemiesToKill.add(e);
    bulletsToKill.add(this);
  }



  //////////Modular Stuff
  /*
   *This function adds force to this bullet
   */
  public void addForce(PVector f) {
    force.add(f);
  }
  /*
  *
   *This function resets the values of this stars accelration and force which is needed every update to be reset
   *
   */
  public void resetValues() {
    done = false;
    acceleration.mult(0);
    force.mult(0);
  }
}///Close class 