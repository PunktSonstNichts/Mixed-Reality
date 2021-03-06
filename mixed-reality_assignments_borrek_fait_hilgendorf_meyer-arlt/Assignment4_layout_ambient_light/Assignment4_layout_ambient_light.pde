/*By Heiderose Borrek, Celine Hilgendorf, Till Meyer-Arlt, Catherine Fait*/
/*With the big round, white Button you can switch the light on. If you did this you can change 
the color, saturation and brightness of the ligtht. You can activate special programs like "sunrise" as well.*/
color c_bg = color(60, 71, 72); // background color of the application
color c_highlight = color(83, 93, 96); // highlight color to highlight important UI elements
color c_cursor = color(33, 33, 33); //color of the cursor
color c_sunrise = color(255, 202, 112);
color c_underwater = color(35, 198, 193);
color c_off = color(255, 255, 255);
color c_on = color(223, 223, 223);
color c_offStroke = color(0, 0, 0);
boolean lightOn = false;

Position pos_preview;
Button b_preview;
Position pos_sunrise;
Button b_sunrise;
Position pos_sunrise_color_field;
Button b_sun_color_field;
Position pos_underwater;
Button b_underwater;
Position pos_water_color_field;
Button b_water_color_field;

void setup() {
  size(700, 800);
  background(c_bg);

  strokeWeight(10);
  stroke(c_cursor);
  pos_preview = new Position(30, 30);
  b_preview = new Button(c_highlight, pos_preview, 640, 60); //preview box

  strokeWeight(1);
  pos_sunrise = new Position(50., 580.);
  b_sunrise = new Button(c_highlight, pos_sunrise, 600., 80.); //first suggestion "Sunrise"
  PFont font = loadFont("SitkaDisplay-Italic-36.vlw");
  fill(c_sunrise);
  textFont(font);
  text("Sunrise", 70, 630);
  pos_sunrise_color_field = new Position(350, 590);
  b_sun_color_field = new Button(c_sunrise, pos_sunrise_color_field, 290, 60);

  pos_underwater = new Position(50, 690);
  b_underwater = new Button(c_highlight, pos_underwater, 600, 80); //second suggestion "under water world"
  fill(c_underwater);
  textFont(font);
  text("Underwater World", 70, 740);
  pos_water_color_field = new Position(350, 700);
  b_water_color_field = new Button(c_underwater, pos_water_color_field, 290, 60);

  //ColorWheel
  smooth();
  pushMatrix();
  translate (width/4.65, height/6.65);
  setUpColorWheel(0, 0, 350, 350);

  //ON OFF Button
  colorMode(RGB);
  fill(c_off);
  stroke(c_off);
  ellipse(width/2, height/2.5, 250, 250);
  stroke(c_offStroke);
  strokeWeight(8);
  ellipse(width/2, height/2.5, 50, 50);
  line(width/2, height/2.5-5, width/2, height/2.5 - 35);
  
  //Text B, S
  fill(c_highlight);
  addBrightnessSlider();
  addSaturationSlider();
}

void draw() {

  //switch light on or off
  if (mousePressed == true) {
    if (get(mouseX, mouseY) == c_off && lightOn == false) {
      lightOn = true;
      colorMode(RGB);
      fill(c_on);
      strokeWeight(3);
      stroke(c_bg);
      ellipse(width/2, height/2.5, 250, 250);
      stroke(c_offStroke);
      strokeWeight(8);
      ellipse(width/2, height/2.5, 50, 50);
      line(width/2, height/2.5-5, width/2, height/2.5 - 35);
    } else if (get(mouseX, mouseY) == c_on && lightOn == true) {
      lightOn = false;
      colorMode(RGB);
      fill(c_off);
      strokeWeight(3);
      stroke(c_off);
      ellipse(width/2, height/2.5, 250, 250);
      stroke(c_offStroke);
      strokeWeight(8);
      ellipse(width/2, height/2.5, 50, 50);
      line(width/2, height/2.5-5, width/2, height/2.5 - 35);

      b_preview.changeColor(c_highlight);
    }
  }
  noFill();
  strokeWeight(1);

  if (lightOn == true) {
    //Change the cusor shape in front of a button
    if ((mouseX >= pos_sunrise.x && mouseX <= pos_sunrise.x + b_sunrise.getWidth() && mouseY >= pos_sunrise.y && mouseY <= pos_sunrise.y + b_sunrise.getHeight()) || (mouseX >= pos_underwater.x && mouseX <= pos_underwater.x + b_underwater.getWidth() && mouseY >= pos_underwater.y && mouseY <= pos_underwater.y + b_underwater.getHeight())) {
      cursor(HAND);
    } else if (get(mouseX, mouseY) == c_on || get(mouseX, mouseY) == c_off || get(mouseX, mouseY) == c_offStroke || get(mouseX, mouseY) == c_offStroke) {
      cursor(HAND);
    } else if (mouseX > (width-width/7.5)-5 && mouseX < 5 + (width - width/7.5) && (mouseY > height/4 && mouseY < height/1.8)) {
      cursor(HAND);
    } else if (mouseX > width/7.5-5 && mouseX < width/7.5+5 && (mouseY > height/4 && mouseY < height/1.8)) {
      cursor(HAND);
    } else if (get(mouseX, mouseY) != c_bg && (mouseX > (width/2)-180 && mouseX < (width/2)+180 && mouseY > (height/2)-260 && mouseY < (height/2)+100) && get(mouseX, mouseY) != c_offStroke) {
      cursor(CROSS);
    } else {
      cursor(ARROW);
    }

    //Change the color of the preview box if a button is pressed
    if (mousePressed == true) {
      if (mouseX >= pos_sunrise.x && mouseX <= pos_sunrise.x + b_sunrise.getWidth() && mouseY >= pos_sunrise.y && mouseY <= pos_sunrise.y + b_sunrise.getHeight()) {
        b_preview.changeColor(c_sunrise);
      } else if (mouseX >= pos_underwater.x && mouseX <= pos_underwater.x + b_underwater.getWidth() && mouseY >= pos_underwater.y && mouseY <= pos_underwater.y + b_underwater.getHeight()) {
        b_preview.changeColor(c_underwater);
      } else if ((mouseX > (width/2)-180 && mouseX < (width/2)+180 && mouseY > (height/2)-260 && mouseY < (height/2)+100) && get(mouseX, mouseY) != c_bg && get(mouseX, mouseY) != c_cursor && get(mouseX, mouseY) != c_off && get(mouseX, mouseY) != c_on && get(mouseX, mouseY) != c_offStroke) {
        b_preview.changeColor(get(mouseX, mouseY));
      }
    }

    //alter brightness
    if (mousePressed == true) {
      if (mouseX > width/7.5-5 && mouseX < width/7.5+5 && (mouseY > height/4 && mouseY < height/1.8)) {
        b_preview.setBrightness(100 - 100*(float)((mouseY-(height/4))/((height/1.8)-(height/4))));
      }
    }

    //alter saturation
    if (mousePressed == true) {
      if (mouseX > (width-width/7.5)-5 && mouseX < 5 + (width - width/7.5) && (mouseY > height/4 && mouseY < height/1.8)) {
        b_preview.setSaturation(100 - 100*(float)((mouseY-(height/4))/((height/1.8)-(height/4))));
      }
    }
  } else {
    if (get(mouseX, mouseY) == c_offStroke || get(mouseX, mouseY) == c_on || get(mouseX, mouseY) == c_off || get(mouseX, mouseY) == c_offStroke && !(mouseX > pos_preview.x && mouseY > pos_preview.y && mouseX < pos_preview.x+b_preview.getWidth() && mouseY < pos_preview.y+b_preview.getHeight())) {
      cursor(HAND);
    } else {
      cursor(ARROW);
    }
  }
}

void setUpColorWheel(float w, float h, float a, float b) {
  ellipseMode(CENTER);
  colorMode(HSB, 100);
  for (float x=0; x<width; x++) {
    for (float y=0; y<height; y++) {
      if (dist(200, 200, x, y)<=a/2) {
        stroke(map(atan2(x-200, y-200), -PI, PI, 0, 100), map(dist(200, 200, x, y), 0, 190, 0, 100), 100);
        point(x, y);
      }
    }
  }
  noFill();
  stroke(c_bg);
  popMatrix();
  ellipse(width/2, height/2.5, a, b);
}

class Position {
  float x;
  float y;
  Position(float x_new, float y_new) {
    x = x_new;
    y = y_new;
  }
}
class Button {
  color c;
  Position pos;
  float width; 
  float height;

  Button(color c_new, Position pos_new, float width_new, float height_new) {
    c = c_new;
    pos = pos_new;
    width = width_new; 
    height = height_new;

    fill (c);
    rect(pos.x, pos.y, width, height);
  }

  float getWidth() {
    return width;
  }

  float getHeight() {
    return height;
  }

  void updatePreview() {
    fill(c);
    strokeWeight(10);
    stroke(c_cursor);
    rect(pos.x, pos.y, width, height);
  }

  void setBrightness(float percent) {
    colorMode(HSB, 100);
    changeColor(color(hue(c), saturation(c), percent));
  }

  void setSaturation(float percent) {
    colorMode(HSB, 100);
    changeColor(color(hue(c), percent, brightness(c)));
  }
  
  void changeColor(color c_new) {
    c = c_new;
    updatePreview();
  }
}

void addBrightnessSlider() {
  stroke(c_cursor);
  strokeWeight(10);
  line(width/7.5, height/4, width/7.5, height/1.8);
  PFont font = loadFont("SitkaDisplay-Italic-36.vlw");
  textFont(font);
  text("B", (width/7.5) - 8, height/4-10);
}


void addSaturationSlider() {
  stroke(c_cursor);
  strokeWeight(10);
  line(width - width/7.5, height/4, width - width/7.5, height/1.8);
  PFont font = loadFont("SitkaDisplay-Italic-36.vlw");
  textFont(font);
  text("S", (width - width/7.5) - 8, height/4-10);
}