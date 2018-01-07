import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

// Reads, processes, and displays motion capture BVH files (.bvh)
//
// Assumes there's only one hierarchy per file.
// Assumes channels: root: 3 positions (in that order: X,Y,Z) + 3 rotations (XYZ in any order),
//                   joints: 3 rotations (XYZ in any order),
//                   end sites: none.
// ** Joint translations are not supported! **
//
// A collection of BVH's can be found at http://www.cgspeed.com/ or http://www.motioncapturedata.com
//      (any version, MotionBuilder-, Max-, or Daz-friendly, will work;
//       notice that the latter seems to have a different scale).
//
// Based on mocapBVH from stefanG (with some simplifications): http://www.openprocessing.org/sketch/78767
// Display and overall program structure taken (with slight modifications)
//       from roxstomp's mocap1: http://www.openprocessing.org/sketch/1964
// Some inspiration (joint's transformation matrix) drawn from Bruce Hahne's BVHplay:
//       https://sites.google.com/a/cgspeed.com/cgspeed/bvhplay
//
// In a nut-shell:
// - a Joint has a set of positions;
// - a Mocap is a set of joints;
// - a MocapInstance draws a Mocap, and specifies how.
//
// Computing of positions:
// Except for the root, joints' positions are not directly given in a BVH file.
// Instead, a transformation specified by a joint's CHANNELS are applied to all 
// its descendants. This can be a composition of translation and rotation, though
// in this program only rotations are supported.
// The transfomations are applied to the joints' offsets, so as to produce the
// desired pose at each frame.
// Example: a linear hierarchy with four joints: j1 (root), j2, j3, j4 (end site);
//          each has an offset (zero-pose): 3-vectors off1, off2, off3, off4;
//          the root has a position channel: 3-vector posR;
//          all except the end site have rotation channels: for each joint, 3 angles
//                define a rotation R (which can be represented as a 3x3 matrix);
//          the joints' positions are then:
//                pos1 = off1 + posR;
//                pos2 = R1.off2 + pos1
//                pos3 = R1.R2.off2 + pos2
//                pos4 = R1.R2.R3.off2 + pos3
//          (The root position posR and the angles defining R1, R2, and R3, form the data
//                given at each frame.)

PeasyCam cam;

MocapInstance mocapinst;
PShape floor;
PVector origin;
ParticleSystem particlesys0, particlesys1;
float zCoord = ((height/2) / tan(PI*30.0 / 180.0)*3);
PImage floor_img;

void setup () {
  //--- Display --- 
  // size(1280, 960, OPENGL);
  size(800, 600, P3D);
  frameRate(75); 
  sphereDetail(20);
  //camera(0.0, 100.0, -320.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0);

  //--- Camera ---
  cam = new PeasyCam(this, 0, -100, 0, 450);

  //--- Mootion captures ---
  Mocap mocap1 = new Mocap("Avatar-006#My MVN System.bvh");// found at http://www.motioncapturedata.com

  //--- To draw mocaps, specify:
  //which mocap; the time offset (starting frame); the space offset (translation); the scale; the color; the stroke weight. 
  mocapinst = new MocapInstance(mocap1, 0, new float[] {0., -20, -100.}, 1., color(0), 3);


  origin = new PVector(width/2, height/2, 0); // sets the origin to the center 
  particlesys0 = new ParticleSystem();
  particlesys1 = new ParticleSystem();

  floor_img = loadImage("img/wiese.jpg");
}

void draw() {
  background(100, 100, 100);
  lights();
  rotateX(PI);
  rotateY(PI/6);

  drawGroundPlane(300);

  //antig is now inside the particle
  PVector antig = new PVector(random(-0.02, 0.02), 0.01, random(-0.02, 0.02));
  // JUST TEMP FOR TESTING THE PARTICLE BEHAVIOR
  particlesys0.addForce(antig); // spheres
  particlesys1.addForce(antig); // cubes 
  
  particlesys0.addParticle(random(3, 8));
  particlesys1.addParticle(random(3, 8));

  if (keyPressed) {
    
    particlesys0.addParticleCube(random(3, 8));
    PVector wind = new PVector(random(-0.2, 0.2), random(0, 0.01), random(-0.2, 0.2));
    particlesys0.addForce(wind); // spheres
    particlesys1.addForce(wind); // cubes
  }

  
  particlesys0.startSys();
  particlesys1.startSys();  

  mocapinst.drawMocap();



  cam.beginHUD();
  displayTime();
  cam.endHUD();

  /*
  pushMatrix();
   translate(width/5-80, height/5-80);
   //rotateX(-PI/6);
   rotateY(-radians(frameCount)/2);
   noFill();
   box(50);
   popMatrix();
   
   pushMatrix();
   translate((width/5)*2-100, height/5-100);
   //rotateX(-PI/6);
   rotateY(radians(frameCount+45));
   box(50, 40, 100);
   popMatrix();*/
}




//-------------------------------------
// Classes ----------------------------
//-------------------------------------

class MocapInstance {   
  Mocap mocap;
  int currentFrame, firstFrame, lastFrame;
  float[] translation;
  float scl, strkWgt;
  color clr;

  MocapInstance (Mocap mocap1, int startingFrame, float[] transl, float scl1, color clr1, float strkWgt1) {
    mocap = mocap1;
    currentFrame = startingFrame;
    firstFrame = startingFrame;
    lastFrame = startingFrame-1;   
    translation = transl;
    scl = scl1;
    clr = clr1;
    strkWgt = strkWgt1;
  }

  void drawMocap() {
    pushMatrix();
    stroke(clr);
    strokeWeight(strkWgt);
    translate(translation[0], translation[1], translation[2]);
    scale(scl);
    int countEnds = 0;

    for (Joint itJ : mocap.joints) {
      println(itJ.name + "!");


      if (itJ.name.toString().equals("EndSitenull")) {
        countEnds++;
        println(countEnds);
      }
      
      
      /* 
      
      // IF WE FIX THE BUG (STRG+F for "#bug"), WE FIND THE ENSITE WITH THIS SYNTAX
      
      if (itJ.name.toString().equals("EndSiteHead")) {
        println("Torso");
        fill(255, 0, 0);
      } else if (itJ.name.toString().equals("EndSiteRightWrist")) {
        println("Right arm + head");
        fill(0, 255, 0);
      } else if (itJ.name.toString().equals("EndSiteLeftWrist")) {
        println("Left arm + right hand");
        fill(255, 255, 255);
      } else if (itJ.name.toString().equals("EndSiteRightToe")) {
        println("Right leg");
        fill(0, 255, 255);
      } else if (itJ.name.toString().equals("EndSiteLeftToe")) {
        println("Left leg");
        fill(0, 255, 255);
      }
      
      */
      
      //PVector point = new PVector(midX/2, midY/2, midZ/2);
      PVector point = new PVector(itJ.parent.position.get(currentFrame).x + translation[0], itJ.parent.position.get(currentFrame).y + translation[1], itJ.parent.position.get(currentFrame).z + translation[2]);
      //PVector point = new PVector(150,0,150);
      particlesys0.fleefrombody(point);
      particlesys1.fleefrombody(point);


      
            //if (!(itJ.name.toString().equals("RightToe")||itJ.name.toString().equals("LeftToe") ||itJ.name.toString().equals("EndSitenull"))) {
      // draw bodyparts
      if (countEnds == 0) {
        println("Torso");
        fill(255, 0, 0);
      } else if (countEnds == 1) {
        println("Right arm + head");
        fill(0, 255, 0);
      } else if (countEnds == 2) {
        println("Left arm + right hand");
        fill(255, 255, 255);
      } else if (countEnds == 3) {
        println("Right leg");
        fill(0, 255, 255);
      } else if (countEnds == 4) {
        println("Left leg");
        fill(0, 255, 255);
      } else
        fill(0);
      
      pushMatrix();
      translate(itJ.position.get(currentFrame).x, itJ.position.get(currentFrame).y, itJ.position.get(currentFrame).z);
      float midX = -(itJ.position.get(currentFrame).x - itJ.parent.position.get(currentFrame).x) ;
      float midY = -(itJ.position.get(currentFrame).y - itJ.parent.position.get(currentFrame).y) ;
      float midZ = -(itJ.position.get(currentFrame).z - itJ.parent.position.get(currentFrame).z) ;






      translate(midX/2, midY/2, midZ/2);

      //float a = atan(midY/midX);
      //rotateZ(radians(a));
      //float b = atan(midZ/midY);
      //rotateX(radians(b));
      //float c = atan(midX/midZ);
      //rotateY(radians(c));
      //      println(a,b,c);

      float a = atan2(midY, midX);
      rotateZ(a);
      float b = atan2(midZ, midY);
      rotateX(radians(b));
      float c = atan2(midX, midZ);
      rotateY(radians(c));
      //println(a,b,c);


      strokeWeight(3);
      //noFill();
      //fill(#0000EE);
      box(/*Y*/(midX/cos(a))-4, 10, 10);
      popMatrix();


      // draw joints
      if (!(itJ.name.toString().equals("EndSitenull"))) {//||itJ.name.toString().equals("RightToe")||itJ.name.toString().equals("LeftToe"))) {
        pushMatrix();
        translate(itJ.position.get(currentFrame).x, itJ.position.get(currentFrame).y, itJ.position.get(currentFrame).z);
        strokeWeight(0);
        fill(0);
        sphere(5*sqrt(2)-2);
        //box(7,7,7);
        popMatrix();
      }

      line(itJ.position.get(currentFrame).x, 
        itJ.position.get(currentFrame).y, 
        itJ.position.get(currentFrame).z, 
        itJ.parent.position.get(currentFrame).x, 
        itJ.parent.position.get(currentFrame).y, 
        itJ.parent.position.get(currentFrame).z);
      //}
    }

    popMatrix();
    currentFrame = (currentFrame+1) % (mocap.frameNumber);
    if (currentFrame==lastFrame+1) currentFrame = firstFrame;
  }
}

class Mocap {
  float frmRate;
  int frameNumber;
  ArrayList<Joint> joints = new ArrayList<Joint>();

  Mocap (String fileName) {
    String[] lines = loadStrings(fileName);
    float frameTime;
    int readMotion = 0;
    int lineMotion = 0;
    Joint currentParent = new Joint();

    for (int i=0; i<lines.length; i++) {

      //--- Read hierarchy --- 
      String[] words = splitTokens(lines[i], " \t");

      //list joints, with parent
      if (words[0].equals("ROOT")||words[0].equals("JOINT")||words[0].equals("End")) {
        Joint joint = new Joint(); 
        joints.add(joint); // #bug THIS LINE IS BAD. We should move it to the bottom of this if-clause, then the EndSiteXXX will work :) 
        if (words[0].equals("End")) {
          joint.name = "EndSite"+((Joint)joints.get(joints.size()-1)).name;
          joint.isEndSite = 1;
        } else joint.name = words[1];
        if (words[0].equals("ROOT")) {
          joint.isRoot = 1;
          currentParent = joint;
        }
        joint.parent = currentParent;
      }

      //find parent
      if (words[0].equals("{")){
        currentParent = (Joint)joints.get(joints.size()-1);
      }
      if (words[0].equals("}")) {
        currentParent = currentParent.parent;
      }

      //offset
      if (words[0].equals("OFFSET")) {
        joints.get(joints.size()-1).offset.x = float(words[1]);
        joints.get(joints.size()-1).offset.y = float(words[2]);
        joints.get(joints.size()-1).offset.z = float(words[3]);
      }

      //order of rotations
      if (words[0].equals("CHANNELS")) {
        joints.get(joints.size()-1).rotationChannels[0] = words[words.length-3];
        joints.get(joints.size()-1).rotationChannels[1] = words[words.length-2];
        joints.get(joints.size()-1).rotationChannels[2] = words[words.length-1];
      }

      if (words[0].equals("MOTION")) {
        readMotion = 1;
        lineMotion = i;
      }

      if (words[0].equals("Frames:"))
        frameNumber = int(words[1]);

      if (words[0].equals("Frame") && words[1].equals("Time:")) {
        frameTime = float(words[2]);
        frmRate = round(1000./frameTime)/1000.;
      }

      //--- Read motion, compute positions ---   
      if (readMotion==1 && i>lineMotion+2) {

        //motion data
        PVector RotRelativPos = new PVector();
        int iMotionData = 3;// number of data points read, skip root position      
        for (Joint itJ : joints) {
          if (itJ.isEndSite==0) {// skip end sites
            float[][] currentTransMat = {{1., 0., 0.}, {0., 1., 0.}, {0., 0., 1.}};
            //The transformation matrix is the (right-)product
            //of transformations specified by CHANNELS
            for (int iC=0; iC<itJ.rotationChannels.length; iC++) {
              currentTransMat = multMat(currentTransMat, 
                makeTransMat(float(words[iMotionData]), 
                itJ.rotationChannels[iC]));
              iMotionData++;
            }
            if (itJ.isRoot==1) {//root has no parent:
              //transformation matrix is read directly
              itJ.transMat = currentTransMat;
            } else {//other joints:
              //transformation matrix is obtained by right-applying
              //the current transformation to the transMat of parent
              itJ.transMat = multMat(itJ.parent.transMat, currentTransMat);
            }
          }

          //positions
          if (itJ.isRoot==1) {//root: position read directly + offset
            RotRelativPos.set(float(words[0]), float(words[1]), float(words[2]));
            RotRelativPos.add(itJ.offset);
          } else {//other joints:
            //apply trasnformation matrix from parent on offset
            RotRelativPos = applyMatPVect(itJ.parent.transMat, itJ.offset);
            //add transformed offset to parent position
            RotRelativPos.add(itJ.parent.position.get(itJ.parent.position.size()-1));
          }
          //store position
          itJ.position.add(RotRelativPos);
        }
      }
    }
  }
}

class Joint {
  String name;
  int isRoot = 0;
  int isEndSite = 0;
  Joint parent;
  PVector offset = new PVector();
  //transformation types (CHANNELS):
  String[] rotationChannels = new String[3];
  //current transformation matrix applied to this joint's children:
  float[][] transMat = {{1., 0., 0.}, {0., 1., 0.}, {0., 0., 1.}};
  //list of PVector, xyz position at each frame:
  ArrayList<PVector> position = new ArrayList<PVector>();
}


//-------------------------------------
// Functions --------------------------
//-------------------------------------

void displayTime() {
  // Calculate time from start of program

  int sec = millis()/1000;
  int min = millis()/60000;
  if (sec >= 60)
    sec -= 60*min;

  // Draw time box and text
  textSize(20);
  pushMatrix();
  translate(width-150, height-50);
  float timeboxX = width/5.5;
  float timeboxY = height/15;
  fill(10);
  rect(0, 0, timeboxX, timeboxY);
  fill(0, 200, 0);
  if (sec < 10)
    text("Time "+min+":0"+sec, timeboxX/9, timeboxY/1.4);
  else
    text("Time "+min+":"+sec, timeboxX/10, timeboxY/1.4);
  popMatrix();
}

void drawGroundPlane( int size ) {
  pushMatrix();
  rotateX(PI / 2);
  noStroke();
  fill(150, 206, 180);
  //noFill();
  floor = createShape(QUAD, -size, -size, size, -size, size, size, -size, size);
  floor.setTexture(floor_img);
  shape(floor);
  popMatrix();
}

float[][] multMat(float[][] A, float[][] B) {//computes the matrix product AB
  int nA = A.length;
  int nB = B.length;
  int mB = B[0].length;
  float[][] AB = new float[nA][mB];
  for (int i=0; i<nA; i++) {
    for (int k=0; k<mB; k++) {
      if (A[i].length!=nB) {
        println("multMat: matrices A and B have wrong dimensions! Exit.");
        exit();
      }
      AB[i][k] = 0.;
      for (int j=0; j<nB; j++) {
        if (B[j].length!=mB) {
          println("multMat: matrices A and B have wrong dimensions! Exit.");
          exit();
        }
        AB[i][k] += A[i][j]*B[j][k];
      }
    }
  }
  return AB;
}

float[][] makeTransMat(float a, String channel) {
  //produces transformation matrix corresponding to channel, with argument a
  float[][] transMat = {{1., 0., 0.}, {0., 1., 0.}, {0., 0., 1.}};
  if (channel.equals("Xrotation")) {
    transMat[1][1] = cos(radians(a));
    transMat[1][2] = - sin(radians(a));
    transMat[2][1] = sin(radians(a));
    transMat[2][2] = cos(radians(a));
  } else if (channel.equals("Yrotation")) {
    transMat[0][0] = cos(radians(a));
    transMat[0][2] = sin(radians(a));
    transMat[2][0] = - sin(radians(a));
    transMat[2][2] = cos(radians(a));
  } else if (channel.equals("Zrotation")) {
    transMat[0][0] = cos(radians(a));
    transMat[0][1] = - sin(radians(a));
    transMat[1][0] = sin(radians(a));
    transMat[1][1] = cos(radians(a));
  } else {
    println("makeTransMat: unknown channel! Exit.");
    exit();
  }
  return transMat;
}

PVector applyMatPVect(float[][] A, PVector v) {
  //apply (square matrix) A to v (both must have dimension 3)
  for (int i=0; i<A.length; i++) {
    if (v.array().length!=3||A.length!=3||A[i].length!=3) {
      println("applyMatPVect: matrix and/or vector not of dimension 3! Exit.");
      exit();
    }
  }
  PVector Av = new PVector();
  Av.x = A[0][0]*v.x + A[0][1]*v.y + A[0][2]*v.z;
  Av.y = A[1][0]*v.x + A[1][1]*v.y + A[1][2]*v.z;
  Av.z = A[2][0]*v.x + A[2][1]*v.y + A[2][2]*v.z;
  return Av;
}