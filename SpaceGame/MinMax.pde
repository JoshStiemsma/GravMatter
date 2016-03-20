class MinMax {
  float min, max;
    this.min = min;
    this.max= max;
  }


  MinMax projectSphereAlongAxis(PVector axis, PVector pos, float size) {//size is mass/8
    float min = 0, max = 0;
    float radius = size;

    float angleOfAxis = atan2(axis.x, axis.y);
    
    PVector p1 = new PVector(cos(angleOfAxis)*radius, sin(angleOfAxis)*radius);
    p1= new PVector(p1.x+pos.x, p1.y+pos.y);
    float v1 = p1.dot(axis);
    
    if (v1 < min||min==0) min = v1;
    if (v1 > max||max==0) max = v1;
    
    
    PVector p2 = new PVector(-cos(angleOfAxis)*radius, -sin(angleOfAxis)*radius);
    p2= new PVector(p2.x+pos.x, p2.y+pos.y);   

    //or say that v2 equals v1 minues the size of the circle when projected
    float v2 = p2.dot(axis);


    if (v2 < min||min==0) min = v2;
    if (v2 > max||max==0) max = v2;
    //println(min + "   " + max);
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
}