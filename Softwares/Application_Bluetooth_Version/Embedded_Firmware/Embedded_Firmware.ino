
/* **********************************************************************************************
 *
 * Tittle: Firmware_Bluetooth.ino
 *
 * Description:  SensePro Bluetooth Version v5 Firmware
 *
 * Version:      5
 * Date:         19/10/2016  19:21:46
 * Author:       Gustavo Celani
 * Organization: CDTTA - Centro de Desenvolvimento e Transferência de Tencologia Assistiva
 *
 * *********************************************************************************************/

/* Libraries */
#include <Servo.h> //Servo Motor

/* Bluetooth Control */
int BluetoothReceive[3];   //Untreated Data Received Over Bluetooth
int DataReceived[2];       //Treated Data Received Over Bluetooth
bool bt_readed = false;    //Success Readed

/* Servo Pins */
#define MOTOR_POLEGAR_PIN   10  //Polegar   PWM Servo Pin
#define MOTOR_INDICADOR_PIN 11  //Indicador PWM Servo Pin
#define MOTOR_MEDIO_PIN     12  //Medio     PWM Servo Pin
#define MOTOR_ANELAR_PIN    9   //Anelar    PWM Servo Pin
#define MOTOR_MOTOR_PIN     13  //Minimo    PWM Servo Pin

/* Servo Motors */
Servo MOTOR_POLEGAR;     //Servo Motor Polegar
Servo MOTOR_INDICADOR;   //Servo Motor Indicador
Servo MOTOR_MEDIO;       //Servo Motor Medio
Servo MOTOR_ANELAR;      //Servo Motor Anelar
Servo MOTOR_MINIMO;      //Servo Motor Minimo

/* Hand Control Varibles */
#define OPEN  175  //Servo Angulation to Open Hand
#define CLOSE 5    //Servo Angulation to Close Hand

/* Servo Step Angulation */
unsigned int STEP_SERVO = 5;

/*Estados dos sensores*/
unsigned int STATE_POLEGAR   = 0;
unsigned int STATE_INDICADOR = 0;
unsigned int STATE_MEDIO     = 0;
unsigned int STATE_ANELAR    = 0;
unsigned int STATE_MINIMO    = 0;

/* FSR (Force Sensor Resistive) Control Vairables */
unsigned int TS_POLEGAR   = 0;
unsigned int TS_INDICADOR = 0;
unsigned int TS_MEDIO     = 0;
unsigned int TS_ANELAR    = 0;
unsigned int TS_MINIMO    = 0;

/* FSR (Force Sensor Resistive) Pins */
#define SENSOR_POLEGAR_PIN    A0  //Analog Pin to Polegar FSR
#define SENSOR_INDICADOR_PIN  A1  //Analog Pin to Indicador FSR
#define SENSOR_MEDIO_PIN      A2  //Analog Pin to Medio FSR
#define SENSOR_ANELAR_PIN     A3  //Analog Pin to Anelar FSR
#define SENSOR_MINIMO_PIN     A4  //Analog Pin to Minimo FSR

/*---------------------------------------------------------------------------------------------*/
/*                                            Functions                                        */
/*---------------------------------------------------------------------------------------------*/

// TRUE  => Success
// FALSE => Fail
bool bluetooth_read() { 

  int i = 48; //48 ... 57
  int j = 0;  //00 ... 09

  unsigned int count = 0; //Control Loop to Read 3 Char Values

  bool BR1 = false; //TRUE => First Read Success
  bool BR2 = false; //TRUE => Second Read Success

  for(int aux=0; aux<3; aux++)
  {
    if(Serial.available()) {
      BluetoothReceive[aux] = Serial.read();
      count++;
    }
    delay(10);
  }

  if(count != 3) return false;

  if(BluetoothReceive[0] != 'a' &&
     BluetoothReceive[0] != 'b' &&
     BluetoothReceive[0] != 'c' &&
     BluetoothReceive[0] != 'd' &&
     BluetoothReceive[0] != 'e' &&
     BluetoothReceive[0] != 'f' &&
     BluetoothReceive[0] != 'g') return false;
  
  for(i = 48; i < 58; i++) { //ASCII Protocol
      if(BluetoothReceive[1] == i && BR1 == false) {BluetoothReceive[1] = j*10; BR1 = true;}
      if(BluetoothReceive[2] == i && BR2 == false) {BluetoothReceive[2] = j;    BR2 = true;}
      if(BR1 == true && BR2 == true) break;
      j++;
  }

  if(BR1 == false || BR2 == false) return false;

  DataReceived[0] = BluetoothReceive[0];
  DataReceived[1] = BluetoothReceive[1] + BluetoothReceive[2];

  return true;
}

void sensors_calibration() {
  TS_POLEGAR   = analogRead(SENSOR_POLEGAR_PIN);
  TS_INDICADOR = analogRead(SENSOR_INDICADOR_PIN);
  TS_MEDIO     = analogRead(SENSOR_MEDIO_PIN);
  TS_ANELAR    = analogRead(SENSOR_ANELAR_PIN);
  TS_MINIMO    = analogRead(SENSOR_MINIMO_PIN);
}

void sensoried_close() {
  int VAL_SENSOR;  //Instant Sensor Value
  int POS = OPEN;  //Open as Initial to Close

  int PRESSURE = map(DataReceived[1], 10, 99, 5, 900);

  VAL_SENSOR = analogRead(SENSOR_MINIMO_PIN);
  VAL_SENSOR = map(VAL_SENSOR, TS_MINIMO, 1023, 0, 1023);
  while(VAL_SENSOR <= PRESSURE && POS > STEP_SERVO) {
    POS = POS - STEP_SERVO;
    MOTOR_MINIMO.write(POS);
    VAL_SENSOR = analogRead(SENSOR_MINIMO_PIN);
    VAL_SENSOR = map(VAL_SENSOR, TS_MINIMO, 1023, 0, 1023);
  } POS = OPEN;

  VAL_SENSOR = analogRead(SENSOR_ANELAR_PIN);
  VAL_SENSOR = map(VAL_SENSOR, TS_ANELAR, 1023, 0, 1023);
  while(VAL_SENSOR <= PRESSURE && POS > STEP_SERVO) {
    POS = POS - STEP_SERVO;
    MOTOR_ANELAR.write(POS);
    VAL_SENSOR = analogRead(SENSOR_ANELAR_PIN);
    VAL_SENSOR = map(VAL_SENSOR, TS_ANELAR, 1023, 0, 1023);
  } POS = OPEN;

  VAL_SENSOR = analogRead(SENSOR_MEDIO_PIN);
  VAL_SENSOR = map(VAL_SENSOR, TS_MEDIO, 1023, 0, 1023);
  while(VAL_SENSOR <= PRESSURE && POS > STEP_SERVO) {
    POS = POS - STEP_SERVO;
    MOTOR_MEDIO.write(POS);
    VAL_SENSOR = analogRead(SENSOR_MEDIO_PIN);
    VAL_SENSOR = map(VAL_SENSOR, TS_MEDIO, 1023, 0, 1023);
  } POS = OPEN;
  
  VAL_SENSOR = analogRead(SENSOR_INDICADOR_PIN);
  VAL_SENSOR = map(VAL_SENSOR, TS_INDICADOR, 1023, 0, 1023);
  while(VAL_SENSOR <= PRESSURE && POS > STEP_SERVO) {
    POS = POS - STEP_SERVO;
    MOTOR_INDICADOR.write(POS);
    VAL_SENSOR = analogRead(SENSOR_INDICADOR_PIN);
    VAL_SENSOR = map(VAL_SENSOR, TS_INDICADOR, 1023, 0, 1023);
  } POS = OPEN;

  VAL_SENSOR = analogRead(SENSOR_POLEGAR_PIN);
  VAL_SENSOR = map(VAL_SENSOR, TS_POLEGAR, 1023, 0, 1023);
  while(VAL_SENSOR <= PRESSURE && POS > STEP_SERVO) {
    POS = POS - STEP_SERVO;
    MOTOR_POLEGAR.write(POS);
    VAL_SENSOR = analogRead(SENSOR_POLEGAR_PIN);
    VAL_SENSOR = map(VAL_SENSOR, TS_POLEGAR, 1023, 0, 1023);
  } POS = OPEN;
}

/*---------------------------------------------------------------------------------------------*/
/*                                        Initial Setup                                        */
/*---------------------------------------------------------------------------------------------*/
void setup() {

  Serial.begin(9600);

  /* Servo Motors */
  MOTOR_POLEGAR.attach(MOTOR_POLEGAR_PIN);
  MOTOR_INDICADOR.attach(MOTOR_INDICADOR_PIN);
  MOTOR_MEDIO.attach(MOTOR_MEDIO_PIN);
  MOTOR_ANELAR.attach(MOTOR_ANELAR_PIN);
  MOTOR_MINIMO.attach(MOTOR_MOTOR_PIN);

  /* FSR (Force Sensor Resistive) */
  pinMode(SENSOR_POLEGAR_PIN, INPUT);
  pinMode(SENSOR_INDICADOR_PIN, INPUT);
  pinMode(SENSOR_MEDIO_PIN, INPUT);
  pinMode(SENSOR_ANELAR_PIN, INPUT);
  pinMode(SENSOR_MINIMO_PIN, INPUT);

  delay(2000); //Wait 2 seconds to Stabilize Sensors
  sensors_calibration();
}

/*---------------------------------------------------------------------------------------------*/
/*                                            Looping                                          */
/*---------------------------------------------------------------------------------------------*/
void loop() {

  bt_readed = false;
  bt_readed = bluetooth_read();

  if(bt_readed == true) {
    switch(DataReceived[0]) {
      
      case 97: { //Polegar 'a'
        Serial.print("Polegar"); //Confirmation Debug
        int POS = (int) map(DataReceived[1], 10, 99, OPEN, CLOSE);
        MOTOR_POLEGAR.write(POS);
      } break;

      case 98: { //Indicador 'b'
        Serial.print("Indicador");  //Confirmation Debug
        int POS = (int) map(DataReceived[1], 10, 99, OPEN, CLOSE);
        MOTOR_INDICADOR.write(POS);
      } break;

      case 99: { //Medio 'c'
        Serial.print("Medio");  //Confirmation Debug
        int POS = (int) map(DataReceived[1], 10, 99, OPEN, CLOSE);
        MOTOR_MEDIO.write(POS);
      } break;

      case 100: { //Anelar 'd'
        Serial.print("Anelar");  //Confirmation Debug
        int POS = (int) map(DataReceived[1], 10, 99, OPEN, CLOSE);
        MOTOR_ANELAR.write(POS);
      } break;

      case 101: { //Minimo 'e'
        Serial.print("Minimo");  //Confirmation Debug
        int POS = (int) map(DataReceived[1], 10, 99, OPEN, CLOSE);
        MOTOR_MINIMO.write(POS);
      } break;

      case 102: { //Open 'f'
        Serial.print("Open");  //Confirmation Debug
        MOTOR_POLEGAR.write(OPEN);
        MOTOR_INDICADOR.write(OPEN);
        MOTOR_MEDIO.write(OPEN);
        MOTOR_ANELAR.write(OPEN);
        MOTOR_MINIMO.write(OPEN);
      } break;

      case 103: { //Sensoried Close 'g'
        Serial.print("Sensoried Close"); //Confirmation Debug
        sensoried_close();
      } break;
    }
  }
}
