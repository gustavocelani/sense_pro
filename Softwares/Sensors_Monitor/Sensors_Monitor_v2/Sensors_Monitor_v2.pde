
/* **********************************************************************************************
 *
 * Tittle: Sensors_Monitor_v2.pde
 *
 * Description:  Monitoring States of Sensors Graphcaly
 *
 * Version:      2
 * Date:         06/02/2016  09:41:02
 * Author:       Gustavo Celani
 * Organization: CDTTA - Centro de Desenvolvimento e Transferência de Tencologia Assistiva
 *
 * *********************************************************************************************/

/* Background Image */
PImage bg;

import processing.serial.*;
import cc.arduino.*;

Arduino arduino;

/* Sensors */
unsigned int s1  = 0;
unsigned int s2  = 1;
unsigned int s3  = 2;
unsigned int s4  = 3;
unsigned int s5  = 4;
unsigned int s6  = 5;
unsigned int s7  = 6;
unsigned int s8  = 7;
unsigned int s9  = 8;
unsigned int s10 = 9;

unsigned int vb1 = 2; //Vibracal Pressure 1
unsigned int vb2 = 3; //Vibracal Pressure 2
unsigned int vb3 = 4; //Vibracal Pressure 3
unsigned int vb4 = 5; //Vibracal Pressure 4

int i1 = 0; //Pressure 1
int i2 = 0; //Pressure 2
int i3 = 0; //Pressure 3
int i4 = 0; //Pressure 4

int sensors_vet[] = new int[10]; //Readed Sensors Values

int thsh = 80;    //Sensors Thereshould
int reach = 1023; //Margin top for Sensors

int radius1 = 90; //Greate Radius
int radius2 = 60; //Small Radius

/* Colors */
color BLUE   = color(90, 109, 238);
color YELLOW = color(255, 204, 0);
color WHITE  = color(255);
color RED    = color(255, 0, 0);
color GREEN  = color(0, 255, 0);

void status1(int w, int  h, color x, int num) {
  if(num >= 10) {
    noFill();
    stroke(x);
    ellipse(w, h, 35, 35);
    fill(x);
    text(num, w, h+10);
  } else {
    noFill();
    stroke(x);
    ellipse(w, h, 30, 30);
    fill(x);
    text(num, w, h+10);
  }
}

void status2(int w, int h, color x, int num, int v) {
  int val_read = v;
  fill(x);
  rect(w, h, 160, 25);
  fill(WHITE);
  textSize(20);
  text("Sensor " + num + ": " + val_read, w+80, h+20);
}

void vibracal(int m) {
  int div = (reach - thsh) /4;

  int x1 = thsh+(1*div);
  int x2 = thsh+(2*div);
  int x3 = thsh+(3*div);
  int x4 = thsh+(4*div);

  if(m >= thsh && m < x1) i1 = 1;
  else i1 = 0;
  if(m >= x1 && m < x2) i2 = 1;
  else i2 = 0;
  if(m >= x2 && m < x3) i3 = 1;
  else i3 = 0;
  if(m >= x3 && m < x4) i4 = 1;
  else i4 = 0;

  arduino.digitalWrite(vb1, i1);
  arduino.digitalWrite(vb2, i2);
  arduino.digitalWrite(vb3, i3);
  arduino.digitalWrite(vb4, i4);
}

void vibracal1(int m) {
  if(m!=0) arduino.digitalWrite(vb1, 1);
}

int maior(int x1, int x2, int x3, int x4, int x5, int x6, int x7, int x8, int x9, int x10) {
  unsigned int maior = 0;

  sensors_vet[0] = x1; sensors_vet[1] = x2; sensors_vet[2] = x3; sensors_vet[3] = x4; sensors_vet[4] = x5;
  sensors_vet[5] = x6; sensors_vet[6] = x7; sensors_vet[7] = x8; sensors_vet[8] = x9; sensors_vet[9] = x10;

  for(int i=0; i<10; i++) if(sensors_vet[i] > maior) maior = sensors_vet[i];

  return maior;
}

void setup() {
  size(1000, 650);
  bg = loadImage("background.png");
  ellipseMode(CENTER);

  arduino = new Arduino(this, Arduino.list()[0]);

  arduino.pinMode(s1, Arduino.INPUT);
  arduino.pinMode(s2, Arduino.INPUT);
  arduino.pinMode(s3, Arduino.INPUT);
  arduino.pinMode(s4, Arduino.INPUT);
  arduino.pinMode(s5, Arduino.INPUT);
  arduino.pinMode(s6, Arduino.INPUT);
  arduino.pinMode(s7, Arduino.INPUT);
  arduino.pinMode(s8, Arduino.INPUT);
  arduino.pinMode(s9, Arduino.INPUT);
  arduino.pinMode(s10, Arduino.INPUT);

  arduino.pinMode(vb1, Arduino.OUTPUT);
  arduino.pinMode(vb2, Arduino.OUTPUT);
  arduino.pinMode(vb3, Arduino.OUTPUT);
  arduino.pinMode(vb4, Arduino.OUTPUT);
}

void draw() {

  background(bg);

  textFont(createFont("Arial Bold", 18));
  textAlign(CENTER);

  fill(BLUE);
  rect(0, -40, width, 80);  //Header
  rect(450, 0, 20, height); //Screen Split

  textSize(31);
  fill(WHITE);
  text("Intensidade", 730, 30); //Right Text
  text("Status", 215, 30);      //Left Text

  int v1 = arduino.analogRead(s1);
  int v2 = arduino.analogRead(s2);
  int v3 = arduino.analogRead(s3);
  int v4 = arduino.analogRead(s4);
  int v5 = arduino.analogRead(s5);
  int v6 = arduino.analogRead(s6);
  int v7 = arduino.analogRead(s7);
  int v8 = arduino.analogRead(s8);
  int v9 = arduino.analogRead(s9);
  int v10 = arduino.analogRead(s10);

  v1 = (int) map(v1, 0, 1023, 1023, 0);
  v2 = (int) map(v2, 0, 1023, 1023, 0);
  v3 = (int) map(v3, 0, 1023, 1023, 0);
  v4 = (int) map(v4, 0, 1023, 1023, 0);
  v5 = (int) map(v5, 0, 1023, 1023, 0);
  v6 = (int) map(v6, 0, 1023, 1023, 0);
  v7 = (int) map(v7, 0, 1023, 1023, 0);
  v8 = (int) map(v8, 0, 1023, 1023, 0);
  v9 = (int) map(v9, 0, 1023, 1023, 0);
  v10 = (int) map(v10, 0, 1023, 1023, 0);

  /*  LEFT SIDE  */

  //Sensor 1
  if(v1 <= thsh) {
    v1 = 0;
    status1(107, 169, RED, 1);
    status2(50, 400, RED, 1, v1);
  }
  else {
    status1(107, 169, GREEN, 1);
    status2(50, 400, GREEN, 1, v1);
  }

  //Sensor 2
  if(v2 <= thsh) {
    v2 = 0;
    status1(149, 125, RED, 2);
    status2(50, 445, RED, 2, v2);
  }
  else {
    status1(149, 125, GREEN, 2);
    status2(50, 445, GREEN, 2, v2);
  }

  //Sensor 3
  if(v3 <= thsh) {
    v3 = 0;
    status1(197, 105, RED, 3);
    status2(50, 490, RED, 3, v3);
  }
  else {
    status1(197, 105, GREEN, 3);
    status2(50, 490, GREEN, 3, v3);
  }

  //Sensor 4
  if(v4 <= thsh) {
    v4 = 0;
    status1(259, 131, RED, 4);
    status2(50, 535, RED, 4, v4);
  }
  else {
    status1(259, 131, GREEN, 4);
    status2(50, 535, GREEN, 4, v4);
  }

  //Sensor 5
  if(v5 <= thsh) {
    v5 = 0;
    status1(313, 241, RED, 5);
    status2(50, 580, RED, 5, v5);
  }
  else {
    status1(313, 241, GREEN, 5);
    status2(50, 580, GREEN, 5, v5);
  }

  //Sensor 6
  if(v6 <= thsh) {
    v6 = 0;
    status1(139, 231, RED, 6);
    status2(230, 400, RED, 6, v6);
  }
  else {
    status1(139, 231, GREEN, 6);
    status2(230, 400, GREEN, 6, v6);
  }

  //Sensor 7
  if(v7 <= thsh) {
    v7 = 0;
    status1(167, 211, RED, 7);
    status2(230, 445, RED, 7, v7);
  }
  else {
    status1(167, 211, GREEN, 7);
    status2(230, 445, GREEN, 7, v7);
  }

  //Sensor 8
  if(v8 <= thsh) {
    v8 = 0;
    status1(199, 201, RED, 8);
    status2(230, 490, RED, 8, v8);
  }
  else {
    status1(199, 201, GREEN, 8);
    status2(230, 490, GREEN, 8, v8);
  }

  //Sensor 9
  if(v9 <= thsh) {
    v9 = 0;
    status1(233, 213, RED, 9);
    status2(230, 535, RED, 9, v9);
  }
  else {
    status1(233, 213, GREEN, 9);
    status2(230, 535, GREEN, 9, v9);
  }

  //Sensor 10
  if(v10 <= thsh) {
    v10 = 0;
    status1(267, 285, RED, 10);
    status2(230, 580, RED, 10, v10);
  }
  else {
    status1(267, 285, GREEN, 10);
    status2(230, 580, GREEN, 10, v10);
  }


  /* RIGHT SIDE  */

  fill(YELLOW);
  noStroke();

  float r1 = map(v1, 0, 1023, 0, radius1);
  if(v1<=thsh) v1 = 0;
  ellipse(537, 245, r1, r1); //Sensor 1

  float r2 = map(v2, 0, 1023, 0, radius1);
  if(v2<=thsh) v2 = 0;
  ellipse(612, 150, r2, r2); //Sensor 2

  float r3 = map(v3, 0, 1023, 0, radius1);
  if(v3<=thsh) v3 = 0;
  ellipse(706, 120, r3, r3); //Sensor 3

  float r4 = map(v4, 0, 1023, 0, radius1);
  if(v4<=thsh) v4 = 0;
  ellipse(825, 164, r4, r4); //Sensor 4

  float r5 = map(v5, 0, 1023, 0, radius1);
  if(v5<=thsh) v5 = 0;
  ellipse(924, 373, r5, r5); //Sensor 5

  float r6 = map(v6, 0, 1023, 0, radius2);
  if(v6<=thsh) v6 = 0;
  ellipse(600, 363, r6, r6); //Sensor 6

  float r7 = map(v7, 0, 1023, 0, radius2);
  if(v7<=thsh) v7 = 0;
  ellipse(652, 330, r7, r7); //Sensor 7

  float r8 = map(v8, 0, 1023, 0, radius2);
  if(v8<=thsh) v8 = 0;
  ellipse(711, 317, r8, r8); //Sensor 8

  float r9 = map(v9, 0, 1023, 0, radius2);
  if(v9<=thsh) v9 = 0;
  ellipse(773, 328, r9, r9); //Sensor 9

  float r10 = map(v10, 0, 1023, 0, radius2);
  if(v10<=thsh) v10 = 0;
  ellipse(824, 468, r10, r10); //Sensor 10


  /* VIBRACAL */

  int maior = maior(v1, v2, v3, v4, v5, v6, v7, v8, v9, v10);
  println("Maior = " + maior);

  int div = (reach - thsh) /4;

  int x1 = thsh+(1*div);
  int x2 = thsh+(2*div);
  int x3 = thsh+(3*div);
  int x4 = thsh+(4*div);

  if(maior>thsh) i4 = 1;
  else i4 = 0;

  if(maior >= thsh && maior < x1) i1 = 1;
  else i1 = 0;
  if(maior >= x1 && maior < x2) i2 = 1;
  else i2 = 0;
  if(maior >= x2 && maior < x3) i3 = 1;
  else i3 = 0;
  if(maior >= x3 && maior < x4) i4 = 1;
  else i4 = 0;

  arduino.digitalWrite(vb1, i1);
  arduino.digitalWrite(vb2, i2);
  arduino.digitalWrite(vb3, i3);
  arduino.digitalWrite(vb4, i4);

  if(i1 == 1) delay(200);
  if(i2 == 1) delay(150);
  if(i3 == 1) delay(100);
  if(i4 == 1) delay(50);

  if(i1 == 0 && i2 == 0 && i3 == 0 && i4 == 0) delay(100);
}
