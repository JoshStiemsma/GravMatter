public class Star {
  String state;
  PVector velocity = new PVector();
  public PVector position = new PVector();
  PVector acceleration = new PVector();
  PVector force = new PVector();
  float mass = 0;
  float size = 0;
  float critMass = 1000;
  boolean done = false;

  boolean starCheckingStars = false;
  boolean starCheckingEnemy = false;
  boolean starCheckingPlayer = false;

  AABB aabb = new AABB();
  boolean boundaries =false;
  public boolean colliding = false;
  boolean hit = false;
  public boolean destroyed = false;
  MinMax mm =new MinMax(0, 0);

  public boolean explode = false;
  public PVector origin = new PVector();
  int framecount = 0;

  //public boolean isAntiMatter =false;
  public Star(float mass, PVector pos, String state) {
    this.state=state;
    this.mass = mass;
    this.origin = pos;
    this.position.x = pos.x;
    this.position.y = pos.y;

    switch(state) {
    case "Explosion":
      this.explode = true;
      this.velocity = new PVector(random(-25, 25), random(-25, 25));
      pos.x+=random(-5, 5);
      pos.y+=random(-5, 5);

      break;
    case "Dropped":

      break;
    case "AntiMatter":

      break;
    }
  }

  public void update() {
    if (colliding==true)  hit =true;

    size = mass/8;
    force.div(mass);
    acceleration.add(force);
    velocity.add(force);
    position.add(velocity);
    CheckBoundaries();

    //add sdeleting small ones that are far
    if (mass>200) {   
      // this.boundaries=true;
    }
    if (mass>critMass)  Explosion(this, position);

    starCheckingPlayer = false;
    starCheckingStars = false;
    starCheckingEnemy = false;
    colliding = false;
    aabb.resetColliding();
    aabb.recalc(position, size);
  }



  void CheckBoundaries() {
    if (this.boundaries) {
      if (position.x>width) { 
        position.x=width; 
        ReverseVelocity("x");
      }
      if (position.y>height) { 
        position.y=height; 
        ReverseVelocity("y");
      }
      if (position.x<=0) { 
        position.x = 0; 
        ReverseVelocity("x");
      }
      if (position.y<=0) { 
        position.y = 0; 
        ReverseVelocity("y");
      }
    } else {
      if (position.x>=width*4||position.x<=-width*4) toKill.add(this);
      if (position.y>=height*4||position.y<=-height*4) toKill.add(this);
    }
  }


  void ReverseVelocity(String dir) {
    if (dir=="x")velocity.x=-(velocity.x-(velocity.x/8));
    if (dir=="y")velocity.y=-(velocity.y-(velocity.y/8));
  }
  /*
  *
   *This function is the basic Draw function
   *
   */
  public void draw() {
    noStroke();
    fill(255);

    switch(state) {
    case "Dropped":
      if (hit) fill(0, 0, 255);
      if (mass<=250) fill(225);
      if (mass>250&&mass<=500) fill(0, 0, 255);
      if (mass>500&&mass<=700) fill(0, 255, 0);
      if (mass>700) fill(255, 0, 0);
      if (mass>800) fill(255, 255, 0);
      break;
    case "Explosion":
      if (hit) fill(0, 0, 255);
      if (mass<=250) fill(225);
      if (mass>250&&mass<=500) fill(0, 0, 255);
      if (mass>500&&mass<=700) fill(0, 255, 0);
      if (mass>700) fill(255, 0, 0);
      if (mass>800) fill(255, 255, 0);
      break;
    case "AntiMatter":
      fill(255, 0, 255);
      break;
    }
    ellipse(position.x, position.y, size, size);

    pushStyle();
    fill(255);
    textSize(map(mass/25,2,200,10,50));
    if (mass<200) {
      text(int(mass), position.x-size, position.y-size+5);
    } else {
      text(int(mass), position.x-size/5, position.y+size/7);
    }
    popStyle();

    if (explode&&framecount<=7) {
      framecount++;
      pushStyle();
      stroke(255, 255, 0);
      fill(255);
      line(origin.x, origin.y, position.x, position.y);
      popStyle();
    }
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
  /*
  *
   *This function adds force to this star
   *
   */
  public void addForce(PVector f) {
    force.add(f);
  }
  /*
*
   *This function handles the absorbing of one star into another by adding its velocity(soon relative to mass) 
   *then destroys the star passed in the parameter
   *
   */
  void collideWithStar(Star star) {

    this.addForce(star.velocity);
    this.mass = this.mass + star.mass;
    toKill.add(star);
  }
  void MergeStars (Star s) {
    toKill.add(s);
    toKill.add(this);
    toCreate.add(new Star(s.mass*1.8, s.position, "Dropped"));
  }

  public void CheckCollision() {
    for (Star s : stars) {
      if ( s== this) continue;
      if (s.starCheckingStars==true) continue;
      if (checkStarCollision(s)) {
        colliding=true;
        s.colliding = true;
        if (this.mass>s.mass) collideWithStar(s);
        if (this.mass==s.mass) MergeStars(s);
      }
      starCheckingStars =true; //ake seperate for each item
    }   

    for (Enemy e : enemies) {
      if (e.enemyCheckingStars==true) continue;
      if (checkEnemyCollision(e)) {
        //println("star found collision with enemy");
        colliding=true;
        e.colliding = true;
        e.HitStar(this, e);
      }
    }
    starCheckingEnemy =true;
  }







  /////////////////////////Run Collision check with each class item
  /*
  *
   *Check Collision with star
   */
  boolean checkStarCollision(Star star) {
    PVector v = PVector.sub(star.position, this.position);
    if ( mag(v.x, v.y) <= (this.size/2) + (star.size/2) ) {
      return true;
    } else {
      return false;
    }
  }
  /*
  *
   *Check Collision with enemy
   */
  boolean checkEnemyCollision(Enemy e) {
    //check star with enemy
    if (aabb.checkCollision(e.aabb)) {

      PVector shortestDist = new PVector();
      int pos = 0;
      for (int i=0; i < e.points.size(); i++) {
        PVector p = e.points.get(i);
        PVector dist =  PVector.sub(p, this.position);
        if (dist.mag()<shortestDist.mag()||shortestDist.mag()==0) {
          shortestDist=dist;
          pos =i;
        }
      }
      //dist is the vector u need to check the normal of
      //but this is the long and sure way of getting the distance normal
      PVector Distnormal = new PVector(this.position.y - e.points.get(pos).y, e.points.get(pos).x - this.position.x);
      e.mm = e.mm.projectEnemyAlongAxis(Distnormal, e);
      this.mm = this.mm.projectSphereAlongAxis( Distnormal, position, size);
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
   *Check Collision with player
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
  
  
  
  

  
  
  
}