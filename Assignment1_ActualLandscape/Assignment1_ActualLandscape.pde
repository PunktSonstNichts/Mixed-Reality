int cols, rows;
int scale = 20;
int w = 1200;
int h = 1000;

void setup() {
  size(600, 600, P3D);

  cols = w/scale;
  rows = h/scale;

  drawLandscape();
}

void draw() {
}

void drawLandscape() {
  background(0);
  stroke(255);
  noFill();

  translate(width/2, height/2);
  rotateX(PI/3);
  translate(-w/2, -h/2);
  //PImage img = loadImage("ice-texture.jpg");

  float offsetY = 0;
  for (int y = 0; y < rows; y ++) {
    beginShape(TRIANGLE_STRIP);
    //texture(img);
    float offsetX = 0;
    for (int x=0; x< cols; x++) {
      vertex(x*scale, y*scale, map(noise(offsetX, offsetY), 0, 1, -50, 50));
      vertex(x*scale, (y+1)*scale, map(noise(offsetX, offsetY), 0, 1, -50, 50));

      offsetX += 0.2;

      //rect(x*scale, y*scale, scale, scale);
    }
    offsetY += 0.2;

    endShape();
  }
}