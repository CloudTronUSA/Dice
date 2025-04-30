/*
 * Acknowledgement:
 *
 * Made with Processing Java Framework
 * Processing Core library is licensed under GNU LGPL v2.1.
 * Other parts (Processing Framework, Processing IDE) are licensed under GNU GPL v2.
 * Official website: https://processing.org/
 *
 */

/* File: Main.pde */
// array of dice objects on the screen
Dice[] dices = new Dice[6];

// run once at start
void setup() {
  size(800, 600, P3D);
  frameRate(60);
  smooth(8);

  // setup all the dices
  int index = 0;
  for (int y=-100; y<=100; y+=200) {
    for (int x=-200; x<=200; x+=200) {
      dices[index++] = new Dice(x, y, 0, 100);
    }
  }
}

// run once every frame
void draw() {
  background(200);
  lights();
  
  // move the cam
  translate(width/2, height/2, 100);
  
  // update all dices
  for (Dice d : dices) {
    d.update();
  }

  // display the sum of all dices
  displaySum(dices);
}

// listen to mouse pressed event
// when mouse is pressed, attempt to spin the dices
void mousePressed() {
  // check if any are spining
  boolean anySpinning = false;
  for(Dice d : dices) {
    if(d.isSpinning()) {
      anySpinning = true;
      break;
    }
  }

  // if none are spinning, start spinning
  if(!anySpinning) {
    for(Dice d : dices) {
      d.spin();
    }
  }
}

// calculate & display sum of all dices
void displaySum(Dice[] allDice) {
  // sum up all the numbers
  int total = 0;
  for (Dice d : allDice) {
    if (!d.isSpinning()) {
      total += d.number();
    } else {
      return; // if any dice is spinning, don't show the number yet
    }
  }
  
  // show num
  // DEPTH_TEST MUST be disabled before drawing text
  // otherwise the text will be hidden behind the dice
  hint(DISABLE_DEPTH_TEST);
  text("Total Number: " + total, -45, 0);
  hint(ENABLE_DEPTH_TEST);
  println("Rolled Total Number: " + total);
}

/* File: Dice.pde */
// dice class
class Dice {
  // basic transformation
  float x, y, z;
  float size;
  float rotX, rotY, rotZ;
  
  // expected final rotation
  float targetRotX, targetRotY, targetRotZ;
  
  // velocity
  float velX, velY, velZ;
  
  int spinCount;
  int totalSpinFrames = 30;  // finish spining in x frames
  boolean spinning;
  int finalNumber;
  
  // constructor
  Dice(float initX, float initY, float initZ, float initSize) {
    x = initX;
    y = initY;
    z = initZ;
    size = initSize;
    rotX = 0;
    rotY = 0;
    rotZ = 0;
    spinning = false;
    finalNumber = 1;
  }
  
  // spin the dice
  // setup the parameters, will do calc and render accordingly in update
  public void spin() {
    rotX += random(TWO_PI);  // start spining at random angle
    rotY += random(TWO_PI);
    
    int targetFace = (int)random(1,7);  // target face
    numToRot(targetFace); // map num to target rotation
    
    int extraSpins = 2;
    // calc total change of rotation X, Y needed to get to target
    float changeX = shortestAngle(targetRotX - rotX) + extraSpins * TWO_PI;
    float changeY = shortestAngle(targetRotY - rotY) + extraSpins * TWO_PI;
    
    // calc the velocity to reach the target in x frames
    velX = changeX / totalSpinFrames;
    velY = changeY / totalSpinFrames;
    
    spinCount = totalSpinFrames;
    spinning = true;
  }
  
  // update the dice, do calc and render
  // this should be called every frame
  public void update() {
    pushMatrix();
    translate(x, y, z);
    
    // check if we are spinning
    if(spinning) {
      // calc the new rotation
      rotX += velX;
      rotY += velY;
      rotZ += velZ;
      
      // check if we are done spinning
      spinCount--;
      if(spinCount <= 0) {
        spinning = false;
        finalNumber = rotToNum();
      }
    }
    
    // rotate the dice to the calculated rotation
    rotateX(rotX);
    rotateY(rotY);
    rotateZ(rotZ);
    
    // draw the dice
    drawDice();
    
    popMatrix();
  }
  
  // getters
  public boolean isSpinning() {return spinning;}
  public int number() {return finalNumber;}
  
  // calc shortest way to get to a specific angle
  private float shortestAngle(float angle) {
    angle = angle % TWO_PI;
    if (angle > PI)
        angle -= TWO_PI;
    return angle;
  }
  
  // map (target) num to rotation
  private void numToRot(int num) {
    switch(num) {
      case 1: // front: number 1
        targetRotX = 0;
        targetRotY = 0;
        targetRotZ = 0;
        break;
      case 2: // top: number 2
        targetRotX = -HALF_PI;
        targetRotY = 0;
        targetRotZ = 0;
        break;
      case 3: // right: number 3
        targetRotX = 0;
        targetRotY = -HALF_PI;
        targetRotZ = 0;
        break;
      case 4: // back: number 4
        targetRotX = 0;
        targetRotY = HALF_PI;
        targetRotZ = 0;
        break;
      case 5: // bottom: number 5
        targetRotX = HALF_PI;
        targetRotY = 0;
        targetRotZ = 0;
        break;
      case 6: // back: number 6
        targetRotX = 0;
        targetRotY = PI;
        targetRotZ = 0;
        break;
    }
  }
  
  // map rot back to num
  private int rotToNum() {
    if(targetRotX == 0 && targetRotY == 0 && targetRotZ == 0) {
      return 1;
    }
    if(targetRotX == -HALF_PI) {
      return 2;
    }
    if(targetRotY == -HALF_PI) {
      return 3;
    }
    if(targetRotY == HALF_PI) {
      return 4;
    }
    if(targetRotX == HALF_PI) {
      return 5;
    }
    if(targetRotY == PI || targetRotY == -PI) {
      return 6;
    }
    return 1;
  }
  
  // draw the dice
  private void drawDice() {
    noStroke();
    fill(255);
    box(size);
    
    // draw dots (gotta add 0.01 or it is inside of the box)
    pushMatrix();
    translate(0, 0, size/2 + 0.01);
    drawDots(1);
    popMatrix();

    pushMatrix();
    translate(0, 0, -size/2 - 0.01);
    rotateY(PI);
    drawDots(6);
    popMatrix();

    pushMatrix();
    translate(size/2 + 0.01, 0, 0);
    rotateY(HALF_PI);
    drawDots(3);
    popMatrix();

    pushMatrix();
    translate(-size/2 - 0.01, 0, 0);
    rotateY(-HALF_PI);
    drawDots(4);
    popMatrix();

    pushMatrix();
    translate(0, -size/2 - 0.01, 0);
    rotateX(-HALF_PI);
    drawDots(2);
    popMatrix();

    pushMatrix();
    translate(0, size/2 + 0.01, 0);
    rotateX(HALF_PI);
    drawDots(5);
    popMatrix();
  }
  
  // draw the dots on the dice
  private void drawDots(int num) {
    fill(0);
    float offset = size / 4;
    float r = size / 10;
    
    switch(num) {
      case 1:
        ellipse(0, 0, r, r);
        break;
      case 2:
        ellipse(-offset, -offset, r, r);
        ellipse(offset, offset, r, r);
        break;
      case 3:
        ellipse(-offset, -offset, r, r);
        ellipse(0, 0, r, r);
        ellipse(offset, offset, r, r);
        break;
      case 4:
        ellipse(-offset, -offset, r, r);
        ellipse(offset, -offset, r, r);
        ellipse(-offset, offset, r, r);
        ellipse(offset, offset, r, r);
        break;
      case 5:
        ellipse(-offset, -offset, r, r);
        ellipse(offset, -offset, r, r);
        ellipse(0, 0, r, r);
        ellipse(-offset, offset, r, r);
        ellipse(offset, offset, r, r);
        break;
      case 6:
        ellipse(-offset, -offset, r, r);
        ellipse(offset, -offset, r, r);
        ellipse(-offset, 0, r, r);
        ellipse(offset, 0, r, r);
        ellipse(-offset, offset, r, r);
        ellipse(offset, offset, r, r);
        break;
    }
  }
}
