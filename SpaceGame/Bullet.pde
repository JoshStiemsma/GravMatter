class Bullet{
 
  
  public Bullet(PVector pos, PVector velocity, String state){
    this.state = state;
    this.velocity=velocity;
    position = pos;
    birthTime=millis();
  }
  
  float mass = 10;
  
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
  void setup(){
    
    birthTime=millis();
    
  }
  
  void draw(){
  
  pushStyle();
 
  switch(state) {
    case "PlayerBullet":
    fill(255,0,0);
    break;
    case " EnemyBullet":
    fill(0,0,255);
    break;
  }
   ellipse(position.x,position.y,mass,mass);  
  popStyle();
  
  
  }
  
  void update(){
   
    force.div(mass);
    acceleration.add(force);
    velocity.add(force);
    position.add(velocity);
    
    bulletCheckingPlayer = false;
    bulletCheckingStars = false;
    bulletCheckingEnemy = false;
    colliding = false;
    aabb.resetColliding();
    aabb.recalc(position, mass/8);///////////MAS/8  idk yet
    
    
    
    
    
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
      //println("bullet checking with enemy");
      //if (e.enemyCheckingBullets==true) continue;
      if (checkEnemyCollision(e)) {
        println("bullet hit en");
        switch(state){
         case "EnemyBullet":
         
         break;
         case "PlayerBullet":
         collideWithEnemy(e);
         break;
        }
        colliding=true;
        e.colliding = true;
        
        
        
      }
    }
    bulletCheckingEnemy =true;
    
    if(checkPlayerCollision()){
      
    }
    bulletCheckingPlayer=true;
  }
  
  
    /*
  *
   *Check Collision with star
   */
  boolean checkStarCollision(Star star) {
    PVector v = new PVector(this.position.x - star.position.x, this.position.y - star.position.y);
    if ( mag(v.x, v.y) <= (this.mass/2) + (star.size/2) ) {
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
      for (PVector n : e.normals) {
        //PVector dist = new PVector(position.x-e.position.x,position.y-e.position.y);//Find distance vector

        e.mm = e.mm.projectEnemyAlongAxis(n, e);
        this.mm = this.mm.projectSphereAlongAxis( n,position, mass);
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
      for (PVector n : player.normals) {
        player.mm = player.mm.projectPlayerAlongAxis(n, player);
        this.mm = this.mm.projectSphereAlongAxis(n, this.position, this.mass);
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
  void collideWithPlayer(){
    player.health-=10;
    bulletsToKill.add(this);
  }
   void collideWithEnemy(Enemy e){
     enemiesToKill.add(e);
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