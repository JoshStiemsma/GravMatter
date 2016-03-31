class Landscape {


  void update() {
    UpdateStars();
    UpdateDrops();
  }
  void UpdateDrops(){
     //if player is moving right
    if (player.velocity.x>0) {
      float rand = random(0, 100);
      if (rand*10<=player.velocity.x) {
        //Drop pickup on right side of screen
        PVector newPos = new PVector(player.position.x+width/2, random(player.position.y-height/2, player.position.y+height/2));
        pickUpsToCreate.add(new PickUp(newPos));
      }
    }
    //if player is moving left
    if (player.velocity.x<0) {
      float rand = random(0, 100);
      if (rand*10<=abs(player.velocity.x)) {
        //Drop pickup on left side of screen
        PVector newPos =new PVector(player.position.x-width/2, random(player.position.y-height/2, player.position.y+height/2));
        pickUpsToCreate.add(new PickUp( newPos));
      }
    }
    //if player is moving up
    if (player.velocity.y<0) {
      float rand = random(0, 100);
      if (rand*10<=abs(player.velocity.y)) {
        //Drop pickup on left side of screen
        PVector newPos =new PVector( random(player.position.x-width/2, player.position.x+width/2), player.position.y-height/2);
        pickUpsToCreate.add(new PickUp(newPos));
      }
    }
    //if player is moving up
    if (player.velocity.y>0) {
      float rand = random(0, 100);
      if (rand*10<=abs(player.velocity.y)) {
        //Drop pickup on left side of screen
        PVector newPos = new PVector( random(player.position.x-width/2, player.position.x+width/2), player.position.y+height/2);
        pickUpsToCreate.add(new PickUp(newPos));
      }
    }
  }
  
  
  
  void UpdateStars() {
    //if player is moving right
    if (player.velocity.x>0) {
      float rand = random(0, 100);
      if (rand<=player.velocity.x) {
        //Drop stras on right side of screen
       PVector newPos = new PVector(player.position.x+width/2, random(player.position.y-height/2, player.position.y+height/2));
        toCreate.add(new Star(random(10, 100), newPos, "Dropped"));
      }
    }
    //if player is moving left
    if (player.velocity.x<0) {
      float rand = random(0, 100);
      if (rand<=abs(player.velocity.x)) {
        //Drop stras on left side of screen
         PVector newPos =new PVector(player.position.x-width/2, random(player.position.y-height/2, player.position.y+height/2));
        toCreate.add(new Star(random(10, 100), newPos, "Dropped"));
      }
    }
    //if player is moving up
    if (player.velocity.y<0) {
      float rand = random(0, 100);
      if (rand<=abs(player.velocity.y)) {
        //Drop stras on left side of screen
        PVector newPos =new PVector( random(player.position.x-width/2, player.position.x+width/2), player.position.y-height/2);
        toCreate.add(new Star(random(10, 100), newPos, "Dropped"));
      }
    }
    //if player is moving up
    if (player.velocity.y>0) {
      float rand = random(0, 100);
      if (rand<=abs(player.velocity.y)) {
        //Drop stras on left side of screen
        PVector newPos = new PVector( random(player.position.x-width/2, player.position.x+width/2), player.position.y+height/2);
        toCreate.add(new Star(random(10, 100), newPos, "Dropped"));
      }
    }
  }
}