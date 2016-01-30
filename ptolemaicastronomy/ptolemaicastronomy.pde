int w = 900, h =700, fr = 200;
boolean pause = false, showTrail = true, trailLines = false;
float orbitScalar = 1, angleSlice = 5,
trailMargin = .25;
int[] defaultStroke = {0,0,0,255};
int[] defaultFill = {0,0,0,255};
int trailLen = 1000;
P earth, moon, merc, venus, sun, mars, jptr, strn;
P merc2, merc3, merc4, merc5, merc6, merc7, merc8, merc9, merc10;

Cycle mercCy, mercCy2, mercCy3, mercCy4, 
mercCy5, mercCy6, mercCy7, mercCy8, mercCy9, mercCy10;

//Ptolemy ratio details
//Moon orbit - 48*earth-radii, merc - 115, Venus, 622.5, 
//Sun, 1210, Mar, 5040, Jupiter, 11,504, Saturn 17026,
//fixed stars, 20000

void setup(){
  size(w,h);
  frameRate(fr);
  earth = new P(w/2, h/2);
  
  float size = 200;
  
  //trying to reconstruct a square wave
  //NOTE: children collect rotation from parents
  // (can be removed with a negative);
  merc = new P(earth);merc.translate(size*orbitScalar, 0);
  mercCy = new Cycle(earth, merc);mercCy.setAngle(1);
  
  merc2 = new P(merc);merc2.translate(size/3.0*orbitScalar, 0);
  mercCy2 = new Cycle(merc, merc2);mercCy2.setAngle(3);

  merc3 = new P(merc2);merc3.translate(size/5.0*orbitScalar, 0);
  mercCy3 = new Cycle(merc2, merc3);mercCy3.setAngle(5);
  
  merc4 = new P(merc3);merc4.translate(size/7.0*orbitScalar, 0);
  mercCy4 = new Cycle(merc3, merc4);mercCy4.setAngle(7);
  
  merc5 = new P(merc4);merc5.translate(size/9.0*orbitScalar, 0);
  mercCy5 = new Cycle(merc4, merc5);mercCy5.setAngle(9);
  
  merc6 = new P(merc5);merc6.translate(size/11.0*orbitScalar, 0);
  mercCy6 = new Cycle(merc5, merc6);mercCy6.setAngle(11);
  
  merc7 = new P(merc6);merc7.translate(size/13.0*orbitScalar, 0);
  mercCy7 = new Cycle(merc6, merc7);mercCy7.setAngle(13);
  
  merc8 = new P(merc7);merc8.translate(size/15.0*orbitScalar, 0);
  mercCy8 = new Cycle(merc7, merc8);mercCy8.setAngle(15);
  
  merc9 = new P(merc8);merc9.translate(size/17.0*orbitScalar, 0);
  mercCy9 = new Cycle(merc8, merc9);mercCy9.setAngle(17);
  
  merc10 = new P(merc9);merc10.translate(size/19.0*orbitScalar, 0);
  mercCy10 = new Cycle(merc9, merc10);mercCy10.setAngle(19);
  mercCy10.setPlanet();
  
  mercCy10.dfrnt.setSize(2);
  mercCy9.addEpi(mercCy10);
  mercCy8.addEpi(mercCy9);
  mercCy7.addEpi(mercCy8);
  mercCy6.addEpi(mercCy7);
  mercCy5.addEpi(mercCy6);
  mercCy4.addEpi(mercCy5);
  mercCy3.addEpi(mercCy4);
  mercCy2.addEpi(mercCy3);
  mercCy.addEpi(mercCy2);
  
  background(235);
}

void draw(){
  if(!pause){
    background(235);
    earth.draw();
    mercCy.draw();
    mercCy.update();
  }
}

void keyPressed(){
  if(key == 'p'){
    pause = !pause;
  } 
  if(key == 't'){
    if(!showTrail && !trailLines)
      showTrail = true; 
    else if(showTrail && !trailLines)
      trailLines = true;
    else{
      showTrail = false;
      trailLines = false;
    }
  }
}

private void defStroke(){
  stroke(defaultStroke[0], defaultStroke[1], defaultStroke[2], defaultStroke[3]);
}

private void defFill(){
  fill(defaultFill[0], defaultFill[1], defaultFill[2], defaultFill[3]);
}

class Cycle{
 private P ctr, eqnt, dfrnt; //center, equant, (pnt defining) deferent
 private float rad;
 private int ctrS;
 private float angle, prevAngle; //part of the circle that is moved every increment (max 360)
 private float angleSum;
 private ArrayList epis, trail;
 private boolean isPlanet;
 private int curPlanet;

 Cycle(P c, P e, P d){
   ctr = new P(c);
   eqnt = new P(e);
   dfrnt = new P(d);
   rad = dist(c.getX(), c.getY(), d.getX(), d.getY());
   ctrS = 8;
   angle = 1;
   curPlanet = 0;
   trail = new ArrayList();
   epis = new ArrayList();
 }
 Cycle(P c, P d){
   this(c, c, d); 
 }
 public P getCtr(){
   return ctr;
 }
 public P getEqnt(){
   return eqnt;
 }
  public P getDfrnt(){
   return dfrnt;
 }
 public float getRad(){
    return rad;
 } 
 public void setCtr(P c){
   ctr = c;
 }
 public void setEqnt(P e){
   eqnt = e;
 }
 public void setDfrnt(P d){
   dfrnt = d; 
 }
 public void setAngle(float a){
   angle = a; 
 }
 public float getAngle(){
   return angle; 
 }
 public void addEpi(Cycle c){
   epis.add(c);
 }
 public void setPlanet(){
   isPlanet = !isPlanet; 
 }
 public boolean isPlanet(){
   return isPlanet; 
 }
  private void addPlanet(P p){
   if(trail.size() > trailLen)
     trail.remove(0);
   trail.add(new P(p));
 }
 
 private float angleFromEqnt(){
    //c = center, d = deferent, e = equant, f = new location, g = intersection of EF and CD
   //trying to find angle dcf
   float cd = rad; // center to deferent
   //note: cd = cf (both radii on the circle) 
   float ed = dist(eqnt.getX(), eqnt.getY(), dfrnt.getX(), dfrnt.getY());
   float ec = dist(eqnt.getX(), eqnt.getY(), ctr.getX(), ctr.getY());
   float def = angle; //must move equally relatively to equant
   
   float dcf = def; //angle to find
   
   //if equant is not ctr
   if(ec != 0){
     //law of cosines to solve for angle DCE
     float dec = degrees(
       acos((pow(cd,2)-pow(ed,2)-pow(ec,2))/(-2*ed*ec))
     );
     float fec = dec - def;
     //law of sines to solve for angle CFE 
     float cfe = degrees(asin(ec*sin(radians(fec))/rad));
     //law of sines to solve for angle CDE
     float cde = degrees(asin(ec*sin(radians(dec))/rad));
     //find DGE by completion, DGE = FGC by opposition
     float fgc = 180 - cde - def;
     //rare fuzz on fgc to ensure movement
     if(fgc == 180)
       fgc = .1;
     //find DCF by completion
     dcf = 180 - fgc - cfe; 
   }
   //fuzz on NaN (once per cycle)
   if(Float.isNaN(dcf)){
     dcf = prevAngle; 
   }
   else{
     prevAngle = dcf;
   }
   return dcf;
 }
 
 private void rotateCycle(float dcf, P o){
   P dfrntS = new P(dfrnt);
   dfrnt.rotate(dcf, o);
   float x = dfrnt.getX() - dfrntS.getX();
   float y = dfrnt.getY() - dfrntS.getY();
   translateCycle(x, y);
   for(int i = 0; i < epis.size(); i++){
      Cycle c = (Cycle)epis.get(i);
      dcf = c.angleFromEqnt();
      c.rotateCycle(dcf, c.ctr);
   }
 }
 
 private void translateCycle(float x, float y){
   for(int i = 0; i < epis.size(); i++){
     Cycle c = (Cycle)epis.get(i);
     c.ctr.translate(x, y);
     c.eqnt.translate(x, y);
     c.dfrnt.translate(x, y);
     c.translateCycle(x, y); 
   }
 }
 
 public void draw(){
    ctr.draw();
    eqnt.draw();
    dfrnt.draw();
    noFill();
    ellipse(ctr.x, ctr.y, rad*2, rad*2);
    defFill();
    if(isPlanet()){
      addPlanet(dfrnt);
      if(showTrail)
        drawTrail();
    }
    for(int i = 0; i < epis.size(); i++){
      Cycle c = (Cycle)epis.get(i);
      c.draw();
    }
 }
 
 private void drawTrail(){
    for(int i = 0; i < trail.size(); i++){
      P p = (P)trail.get(i);
      //p.setX(i*w*trailMargin/trailLen);
      //p.setY(i/4);
      p.draw();
      if(trailLines && i != trail.size()-1 ){
        P p2 = (P)trail.get(i+1);
        line(p.getX(), p.getY(), p2.getX(), p2.getY());
      }
    }
 }
 
 public void update(P c){
   update(c, eqnt); 
 }
 public void update(P c, P e){
   ctr = c;
   eqnt = e;
   update(); 
 }
 
 public void update(){
   if(isPlanet){
     drawTrail(); 
   }
   //consider incorporating with updateEpis (for trails, etc)
   //should just be a recursive call
   float dcf = angleFromEqnt();
   rotateCycle(dcf, ctr);
 }

}

private class P{
  private float x, y;
  private int r, g, b, a;
  int s;
  P(float xx, float yy){
    x = xx;
    y = yy;
    s = 5;
    r = 0; g = 0; b = 0; a = 255;
  }
  P(P p){
    x = p.getX();
    y = p.getY();
    s = p.size();
    this.setRGBA(p.getRGBA());
  }
  public float getX(){
    return x;
  }
  public float getY(){
    return y;
  }
  public void setX(float xx){
    x = xx;
  }  
  public void setY(float yy){
    y = yy;
  }
  public void setP(float xx, float yy){
    x = xx;
    y = yy;
  }
  public void setSize(int size){
    s = size;
  }
  public int size(){
    return s;
  }
  
  public void translate(float xx, float yy){
    x = x + xx;
    y = y + yy;
  }
  
  public void rotate(float angle){
    //simulate rotation matrix
    //(matrix multiplication for the lazy)
    float sin = sin(radians(angle/angleSlice));
    float cos = cos(radians(angle/angleSlice));
    float nx = cos*x - sin*y;
    float ny = sin*x + cos*y;
    x = nx;
    y = ny;
  }
  
  public void rotate(float angle, P origin){
    if(origin == this){
      origin = new P(origin); 
    }
    translate(-origin.getX(), -origin.getY());
    rotate(angle);
    translate(origin.getX(), origin.getY());
  }
  
  public void setRGBA(int[] rgba){
    r = rgba[0];
    g = rgba[1];
    b = rgba[2];
    a = rgba[3]; 
  }
  
  public void setRGBA(int rr, int gg, int bb, int aa){
    r = rr;
    g = gg;
    b = bb;
    a = aa; 
  }
  
  public int[] getRGBA(){
    return new int[]{r, g, b, a}; 
  }
  
  public void draw(){
    noStroke();
    fill(r, g, b, a);
    ellipse(x, y, s, s);
    defFill();
    defStroke();
  }
}
