class Bomb {
  float life;
  String mode = "Ticking";
  PVector position;
  float birthTime;
  float size= 100;
  float smallradius=-66;
  float radius=-33;
  float bigradius=0;

  color c=  color(255, 0, 0);
  float lastColorSwap=0;
  float g=0;
  float direction = 1;

  AABB aabb = new AABB();
  MinMax mm =new MinMax(0, 0);

  Bomb(PVector position, String mode) {
    this.position=position;

    birthTime=millis()/1000;
    lastColorSwap=birthTime;
    
    this.mode=mode;
    switch(mode){
     case "Exploding":
     birthTime+=5;
     break;
    }
  }



  void update() {
    aabb.resetColliding();
    aabb.recalc(position, size);
    if (millis()/1000-birthTime>=5) mode="Exploding";
    if (millis()/1000-birthTime>=10) mode="DoneExploding";
    if (millis()/1000-birthTime>=12) bombsToKill.add(this);
  }


  void draw() {
    update(); 

    pushStyle();
    noStroke();
    switch(mode) {
    case "Ticking":
      UpdateColor();
      fill(c);
      ellipse(position.x, position.y, 5, 5);
      break;
    case "Exploding":
      CheckCollisions();
      noFill();
      radius=radius+2;
      smallradius=smallradius+2;
      bigradius=bigradius+2;

      if (radius>=size)radius=0;      
      if (smallradius>=size)smallradius=0;      
      if (bigradius>=size)bigradius=0;
      strokeWeight(5);
      stroke(255, 0, 0);
      arc(position.x, position.y, radius, radius, 0, TWO_PI);
      stroke(255, 255, 0);
      arc(position.x, position.y, smallradius, smallradius, 0, TWO_PI);
      stroke(255, 255, 240);
      arc(position.x, position.y, bigradius, bigradius, 0, TWO_PI);
      break;
    case "DoneExploding":
      noFill();
      radius=radius-2;
      smallradius=smallradius-2;
      bigradius=bigradius-2;
      strokeWeight(5);
      if (radius>0) {
        stroke(255, 0, 0);
        arc(position.x, position.y, radius, radius, 0, TWO_PI);
      }
      if (smallradius>0) {
        stroke(255, 255, 0);
        arc(position.x, position.y, smallradius, smallradius, 0, TWO_PI);
      }
      if (bigradius>0) {
        stroke(255, 255, 240);
        arc(position.x, position.y, bigradius, bigradius, 0, TWO_PI);
      }
      break;
    }
    popStyle();
  }



  void CheckCollisions() {
    for (Star s : stars) {
     if (checkStarCollision(s)) {
       if (s.mass<400)toKill.add(s);
     }
    }   

    for (Enemy e : enemies) {
     if (checkEnemyCollision(e)) {
       enemiesToKill.add(e);
     }
    }
    
    if(checkPlayerCollision()){

  }
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
    ///Wide range collision
    if (aabb.checkCollision(e.aabb)) {
      ///////////Find the distance vector of the NEAREST POINT and test that vectors normal////
      PVector shortestDist = new PVector();
      int pos = 0;
      for (int i=0; i < e.points.size(); i++) {
        PVector p = e.points.get(i);
        PVector dist = PVector.sub(p, this.position);
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
      ///Next test the enemies normals 
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

     PVector shortestDist = new PVector();
      int pos = 0;
      for (int i=0; i < player.points.size(); i++) {
        PVector p = player.points.get(i);
        PVector dist= PVector.sub(p, this.position);
        if (dist.mag()<shortestDist.mag()||shortestDist.mag()==0) {
          shortestDist=dist;
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


  void UpdateColor() {
    if (millis()/1000-lastColorSwap>.2) {
      direction *=-1;
      lastColorSwap=millis()/1000;
    }
    g+=(25*direction);
    c= color(255, g, 0);
  }
}