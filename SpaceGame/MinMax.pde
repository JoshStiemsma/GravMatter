class MinMax {
  float min, max;
  MinMax(float min, float max) {
    this.min = min;
    this.max= max;
  }


  MinMax projectSphereAlongAxis(PVector axis, PVector pos, float size) {//size is mass/8
    float min = 0, max = 0;
    float radius = size;
float v = pos.dot(axis);
if(v+radius<min||min==0) min = v+radius;
if(v+radius>max||max==0) max = v+radius;
if(v-radius<min||min==0) min = v-radius;
if(v-radius>max||max==0) max = v-radius;
///println(min +"  " + max);
    return new MinMax(min, max);
  }


  MinMax projectPointAlongAxis(PVector dist, PVector axis, float size, PVector starPos) {
    float min = 0; 
    max = 0;
    //find distance vectors magnitue
    //println("distanceV is  " + dist);
    float newMag = mag(dist.x, dist.y)-(size/2);
    // println("oldMag is   " + mag(dist.x,dist.y));
    // println("newMag is   " + newMag);
    //find point with newMag
    float angle = atan2(dist.y, dist.x);
    //So the new point is the magnitude of the distanceVector - radius with the stars pos added back in
    PVector newPoint = new PVector(newMag*sin(angle)+starPos.x, newMag*cos(angle)+starPos.y );
    println("new point  :" + newPoint);
    float v = newPoint.dot(axis);
    min=v;
    max=v;
    return new MinMax(min, max);
  }
  /*
  Project the players polygon along an axis
   
   */
  MinMax projectPlayerAlongAxis(PVector axis, Player player) {
    float min = 0, max = 0;
    int i = 0;
    for (PVector p : player.pointsTransformed) {
      float v = p.dot(axis);
      if ( i == 0 || v < min) min = v;
      if ( i == 0 || v > max) max = v;
      i++;
    }
    return new MinMax(min, max);
  }
  MinMax projectEnemyAlongAxis(PVector axis, Enemy enemy) {
    float min = 0, max = 0;
    int i = 0;
    for (PVector p : enemy.pointsTransformed) {
      float v = p.dot(axis);
      if ( i == 0 || v < min) min = v;
      if ( i == 0 || v > max) max = v;
      i++;
    }
    return new MinMax(min, max);
  }
   MinMax projectPickUpAlongAxis(PVector axis, PickUp pu) {
    float min = 0, max = 0;
    int i = 0;
    for (PVector p : pu.pointsTransformed) {
      float v = p.dot(axis);
      if ( i == 0 || v < min) min = v;
      if ( i == 0 || v > max) max = v;
      i++;
    }
    return new MinMax(min, max);
  }
   MinMax projectMissleAlongAxis(PVector axis, Missile m) {
    float min = 0, max = 0;
    int i = 0;
    for (PVector p : m.pointsTransformed) {
      float v = p.dot(axis);
      if ( i == 0 || v < min) min = v;
      if ( i == 0 || v > max) max = v;
      i++;
    }
    return new MinMax(min, max);
  }
}