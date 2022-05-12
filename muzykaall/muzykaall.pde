
import processing.sound.*;
SoundFile file;
FFT fft;
int bands = 32;
float a=0.05;
int cols, rows;
int scl = 20;
int w = 2900;
int h = 2500;
PGraphics img ;
float flying = 0;
float przesun=0;
float[][] terrain;
float liczb=0;
float wsp=-13;
PImage[] obrazy;
PImage tlo;
int ilobr=5;
int t;
int o;
float red=0;
float green=0;
float blue=0;
float srodek;
float dzwiek[];
float smoothingFactor = 0.0001;
float smcl=0.0001;
float smobrot=0.000001;
float obrot;
float pr;


void setup() {
  size(1920, 1080, P3D);
  cols = w / scl;
  rows = h/ scl;
  srodek=cols/2;
  tlo=loadImage("tlo.png");
  println(cols);
  dzwiek=new float[bands];
  terrain = new float[cols][rows];
  img= createGraphics(1200, 900, P2D);
  file = new SoundFile(this, "sample.mp3");
  file.play();
  fft = new FFT(this, 128);
  fft.input(file);

  obrazy=new PImage[ilobr];
  for (int i=0; i<ilobr; i++) {
    obrazy[i]= loadImage("obrazek"+(i+1)+".jpg");
    img.beginDraw();
    img.background(0);
    img.image(obrazy[0], 0, 0);

    img.endDraw();
    t=0;
    o=0;
  }
  for (int i=0; i<bands; i++) {
    dzwiek[i]=0;
  }
  obrot=0;
  pr=0;
}









void updateimg() {
  img.beginDraw();
  img.tint(70+(4*red/smcl),70+(2*red/smcl),70+(2*red/smcl));
  img.image(obrazy[o], 0, t);
  if (o+1>ilobr-1) {
    img.image(obrazy[0], 0, t-obrazy[o].height);
  } else
  {
    img.image(obrazy[o+1], 0, t-obrazy[o].height);
  }
  t+=2+pr*50;
  if (t>obrazy[o].height) {
    t=0; 
    o++; 
    if (o>(ilobr-1)) {
      o=0;
    }
  }
   img.tint(1.05*red/smcl,0.6*red/smcl,0.5*red/smcl);
  img.image(tlo, 0, 0, img.width, img.height/2);
  img.tint(255);
  img.endDraw();
}







float popraw(float lczb, int in) {
  float w=10000;
  float bnd=0.3*bands;
  if (in>bnd) {
    return (w*lczb)*1/(in-bnd);
  } else {
    return w*lczb;
  }
  

}
void draw() {
// directionalLight(15*red/smcl, 15*green/smcl,15*blue/smcl,1, 1,-1);
  red=(red+popraw(dzwiek[8], 8))*smcl;
  green=(green+popraw(dzwiek[2], 2))*smcl;
  
  blue=(blue+popraw(dzwiek[0], 0))*smcl;
  
  fft.analyze();
  flying -= (a+pr);
  updateimg();
  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    int k=0;
    int b=0;
    for (int x = 0; x < cols; x++) {
      k=int(map(x, 0, (srodek), 0, (bands-1)));
      if (x>srodek) {
        k=(bands-1)-int(map(x, srodek, (cols-1), 0, (bands-1)));
      }
      dzwiek[k]+=(fft.spectrum[abs(k-bands+1)] - dzwiek[k]) * smoothingFactor; 
      // println(x+"   "+k);
      //println(k+"            "+popraw(dzwiek[k],k));
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, -popraw(dzwiek[k], k)*3, popraw(dzwiek[k], k)*3);
      xoff += 0.1;
    }
    yoff += 0.1;
  }


  liczb+=PI/360;



  background(red/smcl,0.6*red/smcl,0.5*red/smcl);
  //stroke(0);
  noFill();
  noStroke();
pushMatrix();
  translate(width/2, height/2+50);
 float sila=1*(sin(map(obrot,0,40,0,2*PI)-PI/2)+1)+0.2;

//obrot=obrot+((red*0.02/smcl)-1)*sila;
obrot+=(red/smcl*0.2-obrot)*0.05;
pr=obrot*0.005;
if (obrot<0){obrot=0;}else if(obrot>17){obrot=17;} 
   //*smobrot; 
  rotateX(PI/4+PI/360*obrot*3);
  println(obrot);
  println(sila);
  translate(-w/2, -h/2);
  for (int y = 0; y < rows-1; y++) {
   // tint(y*4);
   // if (y*4>255) {
     // tint(255);
   // }
    beginShape(TRIANGLE_STRIP);
    texture(img);

    for (int x = 0; x < cols; x++) {

      float xobraz=img.width/cols*x;
      float yobraz=img.width/cols*y;
      float yobraz1=img.width/cols*(y+1);
      vertex(x*scl, y*scl, terrain[x][y], xobraz, yobraz);
      vertex(x*scl, (y+1)*scl, terrain[x][y+1], xobraz, yobraz1);
      //println(x," ",y);
      //rect(x*scl, y*scl, scl, scl);
    }
    endShape();
  }
  popMatrix();
   //translate(width/2, (height/2+50));

}
