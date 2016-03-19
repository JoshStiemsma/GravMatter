 class MinMax{
 float min, max;
 MinMax(float min, float max){
  this.min = min;
  this.max= max; 
 }
 
 
 MinMax projectSphereAlongAxis(PVector axis, PVector pos, float mass) {
      float min = 0, max = 0;
      float v = pos.dot(axis);
      if (v - (mass/2) < min) min = v - (mass/2);
      if (v + (mass/2) > max) max = v + (mass/2);
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