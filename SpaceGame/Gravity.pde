class Gravity {
  /*
*
   *Calculate and apply  the forces of gravities upon all stars 
   *
   */
  void CalculateGravity() {
    StarOnStar();
    StarsOnPlayer();
    StarsOnEnemies();
    StarsOnBullets();
  }
  
  
  
  void StarOnStar() {
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
  }


  void StarsOnPlayer() {
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
  }

  void StarsOnBullets() {
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
  void StarsOnEnemies() {
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
  }
}