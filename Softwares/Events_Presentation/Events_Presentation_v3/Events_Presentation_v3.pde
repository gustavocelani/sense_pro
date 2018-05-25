
/* **********************************************************************************************
 *
 * Tittle: Events_Presentation_v3.pde
 *
 * Description:  SensePro Graphical Presentation to be Used on Events
 *
 * Version:      3
 * Date:         02/08/2016  15:36:11
 * Author:       Gustavo Celani
 * Organization: CDTTA - Centro de Desenvolvimento e Transferência de Tencologia Assistiva
 *
 * *********************************************************************************************/

import processing.serial.*;
import cc.arduino.*;

/* Uploaded Images */
PImage Background;
PImage OpenHand;
PImage ClosedHand;
PImage Rock;
PImage Peace;
PImage CompleteHand;
PImage Cellphone;

/* Colors */
color BLUE   = color(90, 109, 238);
color YELLOW = color(255, 204, 0);
color WHITE  = color(255);
color BLACK  = color(0);
color RED    = color(255, 0, 0);
color GREEN  = color(0, 255, 0);

color CLOSED_COLOR = RED;    //Color to Indicate Closed Finger
color OPENED_COLOR = GREEN;  //Color to Indicate Opened Finger

final unsigned int SERVO_STEP = 5; //Angulation Servo Steps
final unsigned int OPEN = 175;     //Opened Finger Angulation
final unsigned int CLOSE = 5;      //Closed Finger Angulation

/* Servo Pins */
final int POLEGAR_PIN   = 11;
final int INDICADOR_PIN = 8;
final int MEDIO_PIN     = 7;
final int ANELAR_PIN    = 5;
final int MINIMO_PIN    = 6;

/* Fingers Position */
int POLEGAR_POSITION   = OPEN;
int INDICADOR_POSITION = OPEN;
int MEDIO_POSITION     = OPEN;
int ANELAR_POSITION    = OPEN;
int MINIMO_POSITION    = OPEN;

Arduino arduino; //Arduino Global Object

/*---------------------------------------------------------------------------------------------*/
/*                                        Initial Setup                                        */
/*---------------------------------------------------------------------------------------------*/
void setup() {

  arduino = new Arduino(this, Arduino.list()[0]);

  size(780, 650); //Screen Size

  /* Loading Images */
  Background   = loadImage("Background.png");
  OpenHand     = loadImage("OpenHand.png");
  ClosedHand   = loadImage("ClosedHand.png");
  Rock         = loadImage("Rock.png");
  Peace        = loadImage("Peace.png");
  CompleteHand = loadImage("CompleteHand.gif");
  Cellphone    = loadImage("Cellphone.jpg");

  /* Setting Up Servo Motors */
  arduino.pinMode(POLEGAR_PIN,   Arduino.SERVO);
  arduino.pinMode(INDICADOR_PIN, Arduino.SERVO);
  arduino.pinMode(MEDIO_PIN,     Arduino.SERVO);
  arduino.pinMode(ANELAR_PIN,    Arduino.SERVO);
  arduino.pinMode(MINIMO_PIN,    Arduino.SERVO);

  /* Opening Hand */
  arduino.servoWrite(POLEGAR_PIN,   OPEN);
  arduino.servoWrite(INDICADOR_PIN, OPEN);
  arduino.servoWrite(ANELAR_PIN,    OPEN);
  arduino.servoWrite(MEDIO_PIN,     OPEN);
  arduino.servoWrite(MINIMO_PIN,    OPEN);
}

/*---------------------------------------------------------------------------------------------*/
/*                                            Looping                                          */
/*---------------------------------------------------------------------------------------------*/
void draw() {

  background(Background);

  fill(BLUE);
  rect(760, 0, 20, height);      //Screen Split
  rect(1180, 0, 20, height);     //Right Split
  rect(0, 0, 20, height);        //Left Split
  rect(0, height-20, width, 20); //Bottom Split
  rect(0, 450, 760, 20);         //Control Split
  rect(0, -30, width, 70);       //Header

  textSize(31);
  fill(BLACK);
  text("Controle Prótese", 240, 30); //Left Text

  /* Images Position */
  image(CompleteHand, 50, 100);
  image(OpenHand, 30, 490);
  image(ClosedHand, 180, 530);
  image(Rock, 320, 490);
  image(Peace, 500, 480);
  image(Cellphone, 640, 470);

  /* Control */
  textSize(38);
  if(open_finger_verify(POLEGAR_POSITION)) {
    fill(OPENED_COLOR);
    text("Polegar: Aberto", 375, 120);
  }
  else {
    fill(CLOSED_COLOR);
    text("Polegar: Fechado", 375, 120);
  }
  ellipse(310, 190, 40, 40);

  if(open_finger_verify(INDICADOR_POSITION)) {
    fill(OPENED_COLOR);
    text("Indicador: Aberto", 375, 190);
  }
  else {
    fill(CLOSED_COLOR);
    text("Indicador: Fechado", 375, 190);
  }
  ellipse(260, 90, 40, 40);

  if(open_finger_verify(MEDIO_POSITION)) {
    fill(OPENED_COLOR);
    text("Médio: Aberto", 375, 260);
  }
  else {
    fill(CLOSED_COLOR);
    text("Médio: Fechado", 375, 260);
  }
  ellipse(185, 80, 40, 40);

  if(open_finger_verify(ANELAR_POSITION)) {
    fill(OPENED_COLOR);
    text("Anelar: Aberto", 375, 330);
  }
  else {
    fill(CLOSED_COLOR);
    text("Anelar: Fechado", 375, 330);
  }
  ellipse(120, 90, 40, 40);

  if(open_finger_verify(MINIMO_POSITION)) {
    fill(OPENED_COLOR);
    text("Mínimo: Aberto", 375, 400);
  }
  else {
    fill(CLOSED_COLOR);
    text("Mínimo: Fechado", 375, 400);
  }
  ellipse(60, 150, 40, 40);
}

/*---------------------------------------------------------------------------------------------*/
/*                                         Mouse Event                                         */
/*---------------------------------------------------------------------------------------------*/
void mouseClicked() {

  if((mouseX >= 30 && mouseX <= 130) && (mouseY >= 490 && mouseY <= 610)) {
    println("Mao Aberta");
    servo_controlled_move(POLEGAR_PIN, POLEGAR_POSITION, OPEN);
    servo_controlled_move(INDICADOR_PIN, INDICADOR_POSITION, OPEN);
    servo_controlled_move(MEDIO_PIN, MEDIO_POSITION, OPEN);
    servo_controlled_move(ANELAR_PIN, ANELAR_POSITION, OPEN);
    servo_controlled_move(MINIMO_PIN, MINIMO_POSITION, OPEN);
  }

  if((mouseX >= 180 && mouseX <= 270) && (mouseY >= 530 && mouseY <= 620)) {
    println("Mao Fechada");
    servo_controlled_move(MINIMO_PIN, MINIMO_POSITION, CLOSE);
    servo_controlled_move(ANELAR_PIN, ANELAR_POSITION, CLOSE);
    servo_controlled_move(MEDIO_PIN, MEDIO_POSITION, CLOSE);
    servo_controlled_move(INDICADOR_PIN, INDICADOR_POSITION, CLOSE);
    servo_controlled_move(POLEGAR_PIN, POLEGAR_POSITION, CLOSE);
  }

  if((mouseX >= 320 && mouseX <= 440) && (mouseY >= 490 && mouseY <= 620)) {
    println("Mao Rock");
    servo_controlled_move(MINIMO_PIN, MINIMO_POSITION, OPEN);
    servo_controlled_move(ANELAR_PIN, ANELAR_POSITION, CLOSE);
    servo_controlled_move(MEDIO_PIN, MEDIO_POSITION, CLOSE);
    servo_controlled_move(INDICADOR_PIN, INDICADOR_POSITION, OPEN);
    servo_controlled_move(POLEGAR_PIN, POLEGAR_POSITION, OPEN);
  }

  if((mouseX >= 500 && mouseX <= 578) && (mouseY >= 480 && mouseY <= 628)) {
    println("Mao Peace");
    servo_controlled_move(MINIMO_PIN, MINIMO_POSITION, CLOSE);
    servo_controlled_move(ANELAR_PIN, ANELAR_POSITION, CLOSE);
    servo_controlled_move(MEDIO_PIN, MEDIO_POSITION, OPEN);
    servo_controlled_move(INDICADOR_PIN, INDICADOR_POSITION, OPEN);
    servo_controlled_move(POLEGAR_PIN, POLEGAR_POSITION, CLOSE);
  }

  if((mouseX >= 640 && mouseX <= 740) && (mouseY >= 470 && mouseY <= 620)) {
    println("Celular");
    servo_controlled_move(MINIMO_PIN, MINIMO_POSITION, CLOSE);
    servo_controlled_move(ANELAR_PIN, ANELAR_POSITION, CLOSE);
    servo_controlled_move(MEDIO_PIN, MEDIO_POSITION, 60);
    servo_controlled_move(INDICADOR_PIN, INDICADOR_POSITION, 90);
    servo_controlled_move(POLEGAR_PIN, POLEGAR_POSITION, 100);
  }
}

//TRUE  => Open
//FALSE => Close
boolean open_finger_verify(int FINGER_POSITION) {
  if(FINGER_POSITION == CLOSE) return false;
  else return true;
}

/*---------------------------------------------------------------------------------------------*/
/*                                       Finger Movement                                       */
/*---------------------------------------------------------------------------------------------*/
void servo_controlled_move(int MOTOR_PIN, int ACTUAL_POSITION, int DESIRED_POSITION) {

  while(ACTUAL_POSITION != DESIRED_POSITION) {
    if(ACTUAL_POSITION > DESIRED_POSITION) ACTUAL_POSITION = ACTUAL_POSITION - SERVO_STEP;
    else if(ACTUAL_POSITION < DESIRED_POSITION) ACTUAL_POSITION = ACTUAL_POSITION + SERVO_STEP;
    else break;
    arduino.servoWrite(MOTOR_PIN, ACTUAL_POSITION);
    delay(25);
  }

  switch(MOTOR_PIN) {
    case POLEGAR_PIN:
      POLEGAR_POSITION = DESIRED_POSITION;
      break;
    case INDICADOR_PIN:
      INDICADOR_POSITION = DESIRED_POSITION;
      break;
    case MEDIO_PIN:
    MEDIO_POSITION = DESIRED_POSITION;
      break;
    case ANELAR_PIN:
      ANELAR_POSITION = DESIRED_POSITION;
      break;
    case MINIMO_PIN:
      MINIMO_POSITION = DESIRED_POSITION;
      break;
  }
}