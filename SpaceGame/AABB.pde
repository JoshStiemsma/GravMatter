class  AABB {
  private boolean colliding = false;

  private float xmin, xmax, ymin, ymax;



  public void resetColliding() {
    colliding = false;
  }

  public void recalc(PVector[] points) {
    for (int i=0; i < points.length; i++) {
      PVector p = points[i];
      if (i==0 || p.x < xmin) xmin = p.x;
      if (i==0 || p.x > xmax) xmax = p.x;
      if (i==0 || p.y < ymin) ymin = p.y;
      if (i==0 || p.y > ymax) ymax = p.y;
    }
  }
  
  
  /*
  finds aabb for sphere wwith a mass for size
  @param PVector pos The position of the sphere
  @param mass the size of the sphere
  
  */
  public void recalc(PVector pos, float mass) {
   
      if (pos.x - (mass/2) < xmin) xmin = pos.x - (mass/2);
      if (pos.x + (mass/2) > xmax) xmax = pos.x + (mass/2);
      if (pos.y - (mass/2) < ymin) ymin = pos.y - (mass/2);
      if (pos.y + (mass/2) > ymax) ymax = pos.y + (mass/2);
    
  }

  public boolean checkCollision(AABB aabb) {
    if (xmax < aabb.xmin) return false;
    if (xmin > aabb.xmax) return false;
    if (ymax < aabb.ymin) return false;
    if (ymin > aabb.ymax) return false;
    colliding = true;
    aabb.colliding = true;
    return true;
  }
}