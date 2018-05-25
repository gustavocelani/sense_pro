
/* **********************************************************************************************
 *
 * Tittle: Status_Commands_Desktop_v3.pde
 *
 * Description:  Monitoring States of Sensors and Command SensePro Graphcaly
 *
 * Version:      3
 * Date:         25/09/2016  11:17:32
 * Author:       Gustavo Celani
 * Organization: CDTTA - Centro de Desenvolvimento e Transferência de Tencologia Assistiva
 *
 * *********************************************************************************************/

import processing.serial.*;
import cc.arduino.*;

final boolean FALSE = false;
final boolean TRUE = true;

/* Images */
private PImage Background;
private PImage OpenHand;
private PImage ClosedHand;
private PImage Rock;
private PImage Peace;
private PImage CompleteHand;
private PImage Cellphone;

/* Colors */
final color BLUE         = color(90, 109, 238);
final color YELLOW       = color(255, 140, 0);
final color LIGHT_YELLOW = color(255, 255, 0);
final color WHITE        = color(255);
final color BLACK        = color(0);
final color RED          = color(255, 0, 0);
final color LIGHT_RED    = color(255, 60, 60);
final color GREEN        = color(0, 255, 0);

final color CLOSED_COLOR = RED;    //Color that Indicate Closed Finger
final color OPENED_COLOR = GREEN;  //Color that Indicate Opened Finger

/* Servo PWM Pins */
final int SERVO_POLEGAR_PIN   = 9;
final int SERVO_INDICADOR_PIN = 11;
final int SERVO_MEDIO_PIN     = 10;
final int SERVO_ANELAR_PIN    = 6;
final int SERVO_MINIMO_PIN    = 5;

/* Sensor Analog Pins */
final unsigned int SENSOR_POLEGAR_PIN   = 0;
final unsigned int SENSOR_INDICADOR_PIN = 1;
final unsigned int SENSOR_MEDIO_PIN     = 2;
final unsigned int SENSOR_ANELAR_PIN    = 3;
final unsigned int SENSOR_MINIMO_PIN    = 4;

/* Sensor Read Variables */
unsigned int POLEGAR_SENSOR   = 0;
unsigned int INDICADOR_SENSOR = 0;
unsigned int MEDIO_SENSOR     = 0;
unsigned int ANELAR_SENSOR    = 0;
unsigned int MINIMO_SENSOR    = 0;

/* Proportional Sensors Values beetween 0 - 100 */
unsigned int PROP_POLEGAR   = 0;
unsigned int PROP_INDICADOR = 0;
unsigned int PROP_MEDIO     = 0;
unsigned int PROP_MEDIO     = 0;
unsigned int PROP_MINIMO    = 0;

/* Control Vairables */
final unsigned int OPEN = 180; //Open Finger Angulation
final unsigned int CLOSE = 5;  //Close Finger Angulation
final unsigned int STEP = 5;   //Angulatino Step
unsigned int STATE = 0; // 0 => OPENED
                        // 1 => CLOSED
                        // 2 => ROCK
                        // 3 => PEACE
                        // 4 => SENSOR CLOSE

unsigned int max = 0;             //Maximum Value Readed by Sensors
final unsigned int MARGIN = 4;    //Sensor's Thereshold
final unsigned int PRESSURE = 60; //Pressure Level 0 - 100
boolean PRESSURE_REACHED = false; //TRUE => Reached //FALSE => Not Yet

/* Current Finger Positions */
int CURRENT_POLEGAR   = OPEN;
int CURRENT_INDICADOR = OPEN;
int CURRENT_MEDIO     = OPEN;
int CURRENT_ANELAR    = OPEN;
int CURRENT_MINIMO    = OPEN;

/* Desired Finger Positions */
int DESIRED_POLEGAR   = OPEN;
int DESIRED_INDICADOR = OPEN;
int DESIRED_MEDIO     = OPEN;
int DESIRED_ANELAR    = OPEN;
int DESIRED_MINIMO    = OPEN;

Arduino arduino; //Arduino Global Object

/*---------------------------------------------------------------------------------------------*/
/*                                        Initial Setup                                        */
/*---------------------------------------------------------------------------------------------*/
void setup() {

  arduino = new Arduino(this, Arduino.list()[0]);

  size(1200, 650);

  /* Images */
  Background = loadImage("Background.png");
  OpenHand = loadImage("OpenHand.png");
  ClosedHand = loadImage("ClosedHand.png");
  Rock = loadImage("Rock.png");
  Peace = loadImage("Peace.png");
  CompleteHand = loadImage("CompleteHand.gif");
  Cellphone = loadImage("Cellphone.jpg");

  /* Servo Motors */
  arduino.pinMode(SERVO_POLEGAR_PIN, Arduino.SERVO);
  arduino.pinMode(SERVO_INDICADOR_PIN, Arduino.SERVO);
  arduino.pinMode(SERVO_MEDIO_PIN, Arduino.SERVO);
  arduino.pinMode(SERVO_ANELAR_PIN, Arduino.SERVO);
  arduino.pinMode(SERVO_MINIMO_PIN, Arduino.SERVO);

  /* Sensors */
  arduino.pinMode(SENSOR_POLEGAR_PIN, Arduino.INPUT);
  arduino.pinMode(SENSOR_INDICADOR_PIN, Arduino.INPUT);
  arduino.pinMode(SENSOR_MEDIO_PIN, Arduino.INPUT);
  arduino.pinMode(SENSOR_ANELAR_PIN, Arduino.INPUT);
  arduino.pinMode(SENSOR_MINIMO_PIN, Arduino.INPUT);

  /* Opening Hand */
  arduino.servoWrite(SERVO_POLEGAR_PIN, OPEN);
  arduino.servoWrite(SERVO_INDICADOR_PIN, OPEN);
  arduino.servoWrite(SERVO_ANELAR_PIN, OPEN);
  arduino.servoWrite(SERVO_MEDIO_PIN, OPEN);
  arduino.servoWrite(SERVO_MINIMO_PIN, OPEN);

  //3 Seconds Delay
  sensors_calibration();
}

/*---------------------------------------------------------------------------------------------*/
/*                                            Looping                                          */
/*---------------------------------------------------------------------------------------------*/
void draw() {

  background(Background);

  fill(BLUE);
  noStroke();
  rect(760, 0, 20, height);      //Screen Split
  rect(1180, 0, 20, height);     //Right Split
  rect(0, 0, 20, height);        //Left Split
  rect(0, height-20, width, 20); //Bottom Split
  rect(0, 450, 760, 20);         //Control Split
  rect(0, -30, width, 70);       //Header

  textSize(31);
  fill(BLACK);
  text("Controle Prótese", 240, 30); //Left Text
  text("Sensores", 910, 30);         //Right Text

  /* Image Positions */
  image(CompleteHand, 50, 100);
  image(OpenHand, 30, 490);
  image(ClosedHand, 180, 530);
  image(Rock, 320, 490);
  image(Peace, 500, 480);
  image(Cellphone, 640, 470);

  /*    Control    */

  textSize(38);

  if(open_finger_verify(CURRENT_POLEGAR)) {
    fill(OPENED_COLOR);
    text("Polegar: Aberto", 375, 120);
  }  else {
    fill(CLOSED_COLOR);
    text("Polegar: Fechado", 375, 120);
  }
  ellipse(310, 190, 40, 40);


  if(open_finger_verify(CURRENT_INDICADOR)) {
    fill(OPENED_COLOR);
    text("Indicador: Aberto", 375, 190);
  } else {
    fill(CLOSED_COLOR);
    text("Indicador: Fechado", 375, 190);
  }
  ellipse(260, 90, 40, 40);


  if(open_finger_verify(CURRENT_MEDIO)) {
    fill(OPENED_COLOR);
    text("Médio: Aberto", 375, 260);
  } else {
    fill(CLOSED_COLOR);
    text("Médio: Fechado", 375, 260);
  }
  ellipse(185, 80, 40, 40);


  if(open_finger_verify(CURRENT_ANELAR)) {
    fill(OPENED_COLOR);
    text("Anelar: Aberto", 375, 330);
  } else {
    fill(CLOSED_COLOR);
    text("Anelar: Fechado", 375, 330);
  }
  ellipse(120, 90, 40, 40);


  if(open_finger_verify(CURRENT_MINIMO)) {
    fill(OPENED_COLOR);
    text("Mínimo: Aberto", 375, 400);
  } else {
    fill(CLOSED_COLOR);
    text("Mínimo: Fechado", 375, 400);
  }
  ellipse(60, 150, 40, 40);

  /*    SENSORING    */

  POLEGAR_SENSOR = arduino.analogRead(SENSOR_POLEGAR_PIN);
  INDICADOR_SENSOR = arduino.analogRead(SENSOR_INDICADOR_PIN);
  MEDIO_SENSOR = arduino.analogRead(SENSOR_MEDIO_PIN);
  ANELAR_SENSOR = arduino.analogRead(SENSOR_ANELAR_PIN);
  MINIMO_SENSOR = arduino.analogRead(SENSOR_MINIMO_PIN);

  POLEGAR_SENSOR = (int) map(POLEGAR_SENSOR, 0, 1023, 0, 100);
  INDICADOR_SENSOR = (int) map(INDICADOR_SENSOR, 0, 1023, 0, 100);
  MEDIO_SENSOR = (int) map(MEDIO_SENSOR, 0, 1023, 0, 100);
  ANELAR_SENSOR = (int) map(ANELAR_SENSOR, 0, 1023, 0, 100);
  MINIMO_SENSOR = (int) map(MINIMO_SENSOR, 0, 1023, 0, 100);

  POLEGAR_SENSOR = (int) map(POLEGAR_SENSOR, PROP_POLEGAR, 100, 0, 100);
  INDICADOR_SENSOR = (int) map(INDICADOR_SENSOR, PROP_INDICADOR, 100, 0, 100);
  MEDIO_SENSOR = (int) map(MEDIO_SENSOR, PROP_MEDIO, 100, 0, 100);
  ANELAR_SENSOR = (int) map(ANELAR_SENSOR, PROP_MEDIO, 100, 0, 100);
  MINIMO_SENSOR = (int) map(MINIMO_SENSOR, PROP_MINIMO, 100, 0, 100);

  int[] current_reads_vet = {POLEGAR_SENSOR, INDICADOR_SENSOR, MEDIO_SENSOR, ANELAR_SENSOR, MINIMO_SENSOR};
  max = (int) max(current_reads_vet);

  textSize(46);
  if(max <= MARGIN) { fill(GREEN); text("Sem Carga", 840, 125); }
  else if(max > MARGIN && max <= 30) { fill(LIGHT_YELLOW); text("Carga Baixa", 830, 125); }
  else if(max > 30 && max <= 70) { fill(YELLOW); text("Carga Média", 830, 125); }
  else if(max > 70 && max <= 96) { fill(LIGHT_RED); text("Carga Alta", 840, 125); }
  else if(max > 96) { fill(RED); text("Carga Máxima", 820, 125); }

  if(POLEGAR_SENSOR <= 0 || POLEGAR_SENSOR <= MARGIN) POLEGAR_SENSOR = 0;
  if(INDICADOR_SENSOR <= 0 || INDICADOR_SENSOR <= MARGIN) INDICADOR_SENSOR = 0;
  if(MEDIO_SENSOR <= 0 || MEDIO_SENSOR <= MARGIN) MEDIO_SENSOR = 0;
  if(ANELAR_SENSOR <= 0 || ANELAR_SENSOR <= MARGIN) ANELAR_SENSOR = 0;
  if(MINIMO_SENSOR <= 0 || MINIMO_SENSOR <= MARGIN) MINIMO_SENSOR = 0;

  fill(BLACK);
  textSize(32);

  text("Polegar:", 820, 200);
  text(POLEGAR_SENSOR, 950, 200);

  text("Indicador:", 820, 290);
  text(INDICADOR_SENSOR, 980, 290);

  text("Médio:", 820, 380);
  text(MEDIO_SENSOR, 930, 380);

  text("Anelar:", 820, 470);
  text(ANELAR_SENSOR, 935, 470);

  text("Mínimo:", 820, 560);
  text(MINIMO_SENSOR, 950, 560);

  /* Gradient Conversion */
  POLEGAR_SENSOR = (int) map(POLEGAR_SENSOR, 0, 100, 0, 225);
  INDICADOR_SENSOR = (int) map(INDICADOR_SENSOR, 0, 100, 0, 225);
  MEDIO_SENSOR = (int) map(MEDIO_SENSOR, 0, 100, 0, 225);
  ANELAR_SENSOR = (int) map(ANELAR_SENSOR, 0, 100, 0, 225);
  MINIMO_SENSOR = (int) map(MINIMO_SENSOR, 0, 100, 0, 225);

  /* Gradient Progres Bars */
  fill(255, 225-POLEGAR_SENSOR, 225-POLEGAR_SENSOR);
  POLEGAR_SENSOR = (int) map(POLEGAR_SENSOR, 0, 225, 0, 370);
  rect(800, 210, POLEGAR_SENSOR, 30, 20);

  fill(255, 225-INDICADOR_SENSOR, 225-INDICADOR_SENSOR);
  INDICADOR_SENSOR = (int) map(INDICADOR_SENSOR, 0, 225, 0, 370);
  rect(800, 300, INDICADOR_SENSOR, 30, 20);

  fill(255, 225-MEDIO_SENSOR, 225-MEDIO_SENSOR);
  MEDIO_SENSOR = (int) map(MEDIO_SENSOR, 0, 225, 0, 370);
  rect(800, 390, MEDIO_SENSOR, 30, 20);

  fill(255, 225-ANELAR_SENSOR, 225-ANELAR_SENSOR);
  ANELAR_SENSOR = (int) map(ANELAR_SENSOR, 0, 225, 0, 370);
  rect(800, 480, ANELAR_SENSOR, 30, 20);

  fill(255, 225-MINIMO_SENSOR, 225-MINIMO_SENSOR);
  MINIMO_SENSOR = (int) map(MINIMO_SENSOR, 0, 225, 0, 370);
  rect(800, 570, MINIMO_SENSOR, 30, 20);
}

/*---------------------------------------------------------------------------------------------*/
/*                                         Mouse Event                                         */
/*---------------------------------------------------------------------------------------------*/
void mouseClicked() {

  if((mouseX >= 30 && mouseX <= 130) && (mouseY >= 490 && mouseY <= 610)) {
    println("Mao Aberta"); //Debug
    STATE = 0;

    DESIRED_POLEGAR = OPEN;
    DESIRED_INDICADOR = OPEN;
    DESIRED_MEDIO = OPEN;
    DESIRED_ANELAR = OPEN;
    DESIRED_MINIMO = OPEN;

    movement();
  }

  if((mouseX >= 180 && mouseX <= 270) && (mouseY >= 530 && mouseY <= 620)) {
    println("Mao Fechada"); //Debug
    STATE = 1;

    DESIRED_POLEGAR = CLOSE;
    DESIRED_INDICADOR = CLOSE;
    DESIRED_MEDIO = CLOSE;
    DESIRED_ANELAR = CLOSE;
    DESIRED_MINIMO = CLOSE;

    movement();
  }

  if((mouseX >= 320 && mouseX <= 440) && (mouseY >= 490 && mouseY <= 620)) {
    println("Mao Rock"); //Debug

    STATE = 2;

    DESIRED_POLEGAR = OPEN;
    DESIRED_INDICADOR = OPEN;
    DESIRED_MEDIO = CLOSE;
    DESIRED_ANELAR = CLOSE;
    DESIRED_MINIMO = OPEN;

    movement();
  }

  if((mouseX >= 500 && mouseX <= 578) && (mouseY >= 480 && mouseY <= 628)) {
    println("Mao Peace"); //Debug

    STATE = 3;

    DESIRED_POLEGAR = CLOSE;
    DESIRED_INDICADOR = OPEN;
    DESIRED_MEDIO = OPEN;
    DESIRED_ANELAR = CLOSE;
    DESIRED_MINIMO = CLOSE;

   movement();
  }

  if((mouseX >= 640 && mouseX <= 740) && (mouseY >= 470 && mouseY <= 620)) {
    println("Cellphone"); //Debug

    STATE = 4;

    DESIRED_POLEGAR = OPEN;
    DESIRED_INDICADOR = CLOSE;
    DESIRED_MEDIO = CLOSE;
    DESIRED_ANELAR = CLOSE;
    DESIRED_MINIMO = OPEN;

    movement();
  }
}

//TRUE  => Opened Finger
//FALSE => Closed Finger
boolean open_finger_verify(int FINGER_POS) {
  if(FINGER_POS == CLOSE) return false;
  else return true;
}

void sensors_calibration() {

  delay(3000);

  POLEGAR_SENSOR   = arduino.analogRead(SENSOR_POLEGAR_PIN);
  INDICADOR_SENSOR = arduino.analogRead(SENSOR_INDICADOR_PIN);
  MEDIO_SENSOR     = arduino.analogRead(SENSOR_MEDIO_PIN);
  ANELAR_SENSOR    = arduino.analogRead(SENSOR_ANELAR_PIN);
  MINIMO_SENSOR    = arduino.analogRead(SENSOR_MINIMO_PIN);

  POLEGAR_SENSOR   = (int) map(POLEGAR_SENSOR, 0, 1023, 0, 100);
  INDICADOR_SENSOR = (int) map(INDICADOR_SENSOR, 0, 1023, 0, 100);
  MEDIO_SENSOR     = (int) map(MEDIO_SENSOR, 0, 1023, 0, 100);
  ANELAR_SENSOR    = (int) map(ANELAR_SENSOR, 0, 1023, 0, 100);
  MINIMO_SENSOR    = (int) map(MINIMO_SENSOR, 0, 1023, 0, 100);

  PROP_POLEGAR   = POLEGAR_SENSOR;
  PROP_INDICADOR = INDICADOR_SENSOR;
  PROP_MEDIO     = MEDIO_SENSOR;
  PROP_MEDIO     = ANELAR_SENSOR;
  PROP_MINIMO    = MINIMO_SENSOR;
}

//@Recursive
void finger_coltrolled_movement(int SERVO_PIN, int CURRENT_POSITION, int DESIRED_POSITION) {
  if(CURRENT_POSITION > DESIRED_POSITION) CURRENT_POSITION = CURRENT_POSITION - STEP;
  else if(CURRENT_POSITION < DESIRED_POSITION) CURRENT_POSITION = CURRENT_POSITION + STEP;
  else return;
  arduino.servoWrite(SERVO_PIN, CURRENT_POSITION);

  switch(SERVO_PIN) {
    case SERVO_POLEGAR_PIN:
      CURRENT_POLEGAR = CURRENT_POSITION;
      SERVO_PIN = SERVO_INDICADOR_PIN;
      CURRENT_POSITION = CURRENT_INDICADOR;
      DESIRED_POSITION = DESIRED_INDICADOR;
      break;
    case SERVO_INDICADOR_PIN:
      CURRENT_INDICADOR = CURRENT_POSITION;
      SERVO_PIN = SERVO_MEDIO_PIN;
      CURRENT_POSITION = CURRENT_MEDIO;
      DESIRED_POSITION = DESIRED_MEDIO;
      break;
    case SERVO_MEDIO_PIN:
      CURRENT_MEDIO = CURRENT_POSITION;
      SERVO_PIN = SERVO_ANELAR_PIN;
      CURRENT_POSITION = CURRENT_ANELAR;
      DESIRED_POSITION = DESIRED_ANELAR;
      break;
    case SERVO_ANELAR_PIN:
      CURRENT_ANELAR = CURRENT_POSITION;
      SERVO_PIN = SERVO_MINIMO_PIN;
      CURRENT_POSITION = CURRENT_MINIMO;
      DESIRED_POSITION = DESIRED_MINIMO;
      break;
    case SERVO_MINIMO_PIN:
      CURRENT_MINIMO = CURRENT_POSITION;
      SERVO_PIN = SERVO_POLEGAR_PIN;
      CURRENT_POSITION = CURRENT_POLEGAR;
      DESIRED_POSITION = DESIRED_POLEGAR;
      break;
  }
  finger_coltrolled_movement(SERVO_PIN, CURRENT_POSITION, DESIRED_POSITION);
}

void movement() {
  arduino.servoWrite(SERVO_POLEGAR_PIN, DESIRED_POLEGAR);
  arduino.servoWrite(SERVO_INDICADOR_PIN, DESIRED_INDICADOR);
  arduino.servoWrite(SERVO_MEDIO_PIN, DESIRED_MEDIO);
  arduino.servoWrite(SERVO_ANELAR_PIN, DESIRED_ANELAR);
  arduino.servoWrite(SERVO_MINIMO_PIN, DESIRED_MINIMO);

  CURRENT_POLEGAR = DESIRED_POLEGAR;
  CURRENT_INDICADOR = DESIRED_INDICADOR;
  CURRENT_MEDIO = DESIRED_MEDIO;
  CURRENT_ANELAR = DESIRED_ANELAR;
  CURRENT_MINIMO = DESIRED_MINIMO;
}
