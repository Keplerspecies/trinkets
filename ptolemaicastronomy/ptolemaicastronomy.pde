int w = 700, h = 500, fr = 3;
boolean pause = false, showTrail = true;
float orbitScalar = 1;
int[] defaultStroke = {0,0,0,255};
int[] defaultFill = {0,0,0,255};
int trailLen = 500;
P earth, moon, merc, venus, sun, mars, jptr, strn;
P merc2;
P merc3;
P mercEqnt;
Cycle mercCy, mercCy2, mercCy3;

//Ptolemy ratio details
//Moon orbit - 48*earth-radii, merc - 115, Venus, 622.5, 
//Sun, 1210, Mar, 5040, Jupiter, 11,504, Saturn 17026,
//fixed stars, 20000

void setup(){
  size(w,h);
  frameRate(fr);
  earth = new P(w/2, h/2);
  merc = new P(earth);
  merc.translate(-115*orbitScalar, 0);
  mercEqnt = new P(earth);
  mercEqnt.translate(0, -60*orbitScalar);
  mercCy = new Cycle(earth, mercEqnt, merc);
  merc2 = new P(merc);
  merc2.translate(0, -60*orbitScalar);
  mercCy2 = new Cycle(merc, merc2);
  mercCy2.setAngle(1);
  mercCy2.getDfrnt().setSize(5);
  merc3 = new P(merc2);
  merc3.translate(0, -10*orbitScalar);
  mercCy3 = new Cycle(merc2, merc3);
  mercCy3.setAngle(1);
  mercCy3.setPlanet();
  mercCy3.getDfrnt().setSize(2);
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
    showTrail = !showTrail; 
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
 
 private void updateEpis(){
   float dcf = angleFromEqnt();
   for(int i = 0; i < epis.size(); i++){
      Cycle c = (Cycle)epis.get(i);
      P cd = c.getDfrnt(); P ce = c.getEqnt(); P cc = c.getCtr();
      cc.rotate(dcf, ctr); ce.rotate(dcf, ctr); cd.rotate(dcf, ctr);
      cd.rotate(c.angleFromEqnt(), cc);
      c.updateEpis();
   }
 }
 
 //TODO: to fix bi-epicyclic, make sure rotation happens for whole recursive brance
 private void drawEpis(){
   for(int i = 0; i < epis.size(); i++){
     
      Cycle c = (Cycle)epis.get(i);
      if(c.isPlanet()){
        c.addPlanet(c.getDfrnt());
        c.drawTrail(); 
      }
      P cd = c.getDfrnt(); P ce = c.getEqnt(); P cc = c.getCtr();
      cc.draw(); ce.draw(); cd.draw();
      noFill();
      ellipse(cc.getX(), cc.getY(), c.getRad()*2, c.getRad()*2);
      defFill();
      c.drawEpis();
   }
 }
 
 private void addPlanet(P p){
   if(trail.size() > trailLen)
     trail.remove(0);
   trail.add(new P(p));
 }
 
 private void drawTrail(){
    for(int i = 0; i < trail.size(); i++){
      P p = (P)trail.get(i);
      p.draw();
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
     addPlanet(dfrnt);
     drawTrail(); 
   }
   //consider incorporating with updateEpis (for trails, etc)
   //should just be a recursive call
   updateEpis();
   float dcf  = angleFromEqnt();
   dfrnt.rotate(dcf, ctr);
 }
 public void draw(){
   //center should(?) already be drawn
   ctr.draw();
   eqnt.draw();
   dfrnt.draw();
   noFill();
   ellipse(ctr.getX(), ctr.getY(), rad*2, rad*2);
   defFill();
   drawEpis();
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
    float sin = sin(radians(angle));
    float cos = cos(radians(angle));
    float nx = cos*x - sin*y;
    float ny = sin*x + cos*y;
    x = nx;
    y = ny;
  }
  
  public void rotate(float angle, P origin){
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
