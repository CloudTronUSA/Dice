Dice[] dices = new Dice[6];

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

void draw() {
  background(200);
  lights();
  
  // move the cam
  translate(width/2, height/2, 100);
  
  boolean readyToDisplayNum = true;
  for(Dice d : dices) {
    d.update();
    if (d.isSpinning()) {
      readyToDisplayNum = false;
      break;
    }
  }
  
  int totalNum = 0;
  if (readyToDisplayNum) {
    for (Dice d : dices)
      totalNum += d.finalNumber;
    
    // show num
    hint(DISABLE_DEPTH_TEST);
    text("Total Number: " + totalNum, -45, 0);
    hint(ENABLE_DEPTH_TEST);
    println(totalNum);
  }
}

void mousePressed() {
  // check if already spining
  boolean anySpinning = false;
  for(Dice d : dices) {
    if(d.isSpinning()) {
      anySpinning = true;
      break;
    }
  }

  if(!anySpinning) {
    for(Dice d : dices) {
      d.spin();
    }
  }
}

// dice
class Dice {
  float x, y, z;
  float size;
  
  float rotX, rotY, rotZ;
  
  // expected rotation
  float targetRotX, targetRotY, targetRotZ;
  
  // vel
  float velX, velY, velZ;
  
  int spinCount;
  int totalSpinFrames = 30;  // finish spining in x frames
  boolean spinning;
  int finalNumber;
  
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
  
  void spin() {
    rotX += random(TWO_PI);  // start spining at rand rot
    rotY += random(TWO_PI);
    
    int targetFace = (int)random(1,7);  // target face
    numToRot(targetFace);
    
    int extraSpins = 2;
    float changeX = shortestAngle(targetRotX - rotX) + extraSpins * TWO_PI;
    float changeY = shortestAngle(targetRotY - rotY) + extraSpins * TWO_PI;
    
    velX = changeX / totalSpinFrames;
    velY = changeY / totalSpinFrames;
    
    spinCount = totalSpinFrames;
    spinning = true;
  }
  
  void update() {
    pushMatrix();
    translate(x, y, z);
    
    if(spinning) {
      // spin
      rotX += velX;
      rotY += velY;
      rotZ += velZ;
      
      spinCount--;
      if(spinCount <= 0) {
        spinning = false;
        finalNumber = rotToNum();
      }
    }
    
    rotateX(rotX);
    rotateY(rotY);
    rotateZ(rotZ);
    
    drawDice();
    
    popMatrix();
  }
  
  // getters
  boolean isSpinning() {
    return spinning;
  }
  
  int number() {
    return finalNumber;
  }
  
  // change of rot to get to an angle
  float shortestAngle(float angle) {
    angle = angle % TWO_PI;
    if (angle > PI)
        angle -= TWO_PI;
    return angle;
  }
  
  // map num to rotation
  void numToRot(int num) {
    switch(num) {
      case 1: // front
        targetRotX = 0;
        targetRotY = 0;
        targetRotZ = 0;
        break;
      case 2: // top
        targetRotX = -HALF_PI;
        targetRotY = 0;
        targetRotZ = 0;
        break;
      case 3: // right
        targetRotX = 0;
        targetRotY = -HALF_PI;
        targetRotZ = 0;
        break;
      case 4: // back
        targetRotX = 0;
        targetRotY = HALF_PI;
        targetRotZ = 0;
        break;
      case 5: // bottom
        targetRotX = HALF_PI;
        targetRotY = 0;
        targetRotZ = 0;
        break;
      case 6: // back
        targetRotX = 0;
        targetRotY = PI;
        targetRotZ = 0;
        break;
    }
  }
  
  // map rot to num
  int rotToNum() {
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
  
  void drawDice() {
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
  
  void drawDots(int num) {
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
