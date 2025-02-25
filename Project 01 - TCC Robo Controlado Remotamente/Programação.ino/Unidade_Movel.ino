#include <math.h>
#include <SPI.h>
#include "nRF24L01.h"
#include "RF24.h"
int joystick[2];
RF24 radio(7,8);
const uint64_t pipe = 0xE8E8F0F0E1LL;
 


double arctan = 0.0;
double angulo = 0;
double axisX = 0.0;
double axisY = 0.0;
double potX = 0.0;
double potY = 0.0;
double Yquadrado = 0;
double Xquadrado = 0;
double somaXY = 0;

double ex = 2;
int ponteH_Dir0 = 9;
int ponteH_Dir1 = 10;

int ponteH_Esq0 = 5;
int ponteH_Esq1 = 6;

double motorDirPWM = 0;
double motorEsqPWM = 0;
double motorDir_DT_Cycle =0;
double motorEsq_DT_Cycle=0;
double senoangulo = 0;
double seno = 0;

//ponteH: 0 e 1(LSB) = motor gira sentido horario
//        1 e 0 LSB) = motor gira sentido anti-horario
//        1 e 1(LSB)= motor trava
//        0 e 0(LSB)= motor para sem travamento
void setup(){

pinMode (ponteH_Dir0, OUTPUT);
pinMode (ponteH_Dir1, OUTPUT);

pinMode (ponteH_Esq0, OUTPUT);
pinMode (ponteH_Esq1, OUTPUT);



Serial.begin(9600);
  radio.begin();
  radio.openReadingPipe(1,pipe);
  radio.startListening();

}//fecha void setup


void loop(){

  
  if ( radio.available() )
  {
    // Dump the payloads until we've gotten everything
    bool done = false;
    while (!done)
    {
      // Fetch the payload, and see if this was the last one.
      done = radio.read( joystick, sizeof(joystick) );
      double potX = (joystick[0]);
      double potY = (joystick[1]);
      if (potX==0)potX=1;
      if(potX==1023)potX=1024;
      if (potY==0)potY=1;
      if(potY==1023)potY=1024;

      double axisX = (potX - 512);
      if(axisX>512) axisX=512;
      if(axisX<-512) axisX=-512;
      double axisY = (potY - 512);
      if(axisY>512) axisY=512;
      if(axisY<-512) axisY=-512;

      double arctan = atan2 (axisY, axisX);
      double angulo = (arctan*180)/3.141592;
      if (angulo==0)angulo=1;
      double Yquadrado = pow(axisX,2);
      double Xquadrado = pow(axisY,2);
      double somaXY = Yquadrado+Xquadrado;
      double vetor = sqrt(somaXY);
      if (vetor>512) vetor=512;
      double seno = sin(arctan);
     double coss = cos(arctan);

      Serial.print("angulacao:");
      Serial.print(angulo);
      Serial.print("\tEixo X");
      Serial.print(axisX);
      Serial.print("\tEixo Y");
      Serial.print(axisY);

 if (vetor<100)//coordenada de giro horario
            {
              
              motorDirPWM = (vetor/512)*255;
              motorEsqPWM = (vetor/512)*255;
              motorDir_DT_Cycle = (motorDirPWM/255)*100;
              motorEsq_DT_Cycle = (motorEsqPWM/255)*100;
              Serial.println("\t PARADO");
              
              
              digitalWrite(ponteH_Dir0,LOW);
              digitalWrite(ponteH_Dir1,LOW);
              digitalWrite(ponteH_Esq0,LOW);
              digitalWrite(ponteH_Esq1,LOW);
            }else
      if ((angulo>=-20) && (angulo<20))//coordenada de giro horario
            {
              
              motorDirPWM = (vetor/512)*255;
              motorEsqPWM = (vetor/512)*255;
              motorDir_DT_Cycle = (motorDirPWM/255)*100;
              motorEsq_DT_Cycle = (motorEsqPWM/255)*100;
              Serial.print("\t Vetor");
              Serial.print(vetor);
              Serial.print("\t HORARIO ");
              Serial.print("\t PWM Dir:");
               Serial.print(motorDirPWM);
              Serial.print("\t Potencia Dir:");
              Serial.print(motorDir_DT_Cycle);
              Serial.print("\t PWM Esq:");
              Serial.print(motorEsqPWM);
              Serial.print("\t Potencia Esq:");
              Serial.println(motorEsq_DT_Cycle);
              
              digitalWrite(ponteH_Dir0,LOW);
              analogWrite(ponteH_Dir1,motorDirPWM);
              analogWrite(ponteH_Esq0,motorEsqPWM);
              digitalWrite(ponteH_Esq1,LOW);
            }else


                  if ((angulo<=80) && (angulo>=20))//coordenada de curva no quadrante I
                  {
                    
                    motorDirPWM = ((vetor/512)*(angulo/90))*255;
                    motorEsqPWM = ((vetor/512)*seno)*255;
                    motorDir_DT_Cycle = (motorDirPWM/255)*100;
                    motorEsq_DT_Cycle = (motorEsqPWM/255)*100;
                    Serial.print("\t Vetor");
                    Serial.print(vetor);
                    Serial.print("\t QUADRANTE I ");
                    Serial.print("\t PWM Dir:");
                     Serial.print(motorDirPWM);
                    Serial.print("\t Potencia Dir:");
                    Serial.print(motorDir_DT_Cycle);
                    Serial.print("\t PWM Esq:");
                    Serial.print(motorEsqPWM);
                    Serial.print("\t Potencia Esq:");
                    Serial.println(motorEsq_DT_Cycle);
                  
                    digitalWrite(ponteH_Dir0,LOW);
                    analogWrite(ponteH_Dir1,motorDirPWM);
                    digitalWrite(ponteH_Esq0,LOW);
                   analogWrite(ponteH_Esq1,motorEsqPWM);
                    
               
                      
                    }else
                          if ((angulo>80) && (angulo<100))//potencia a frente
                          {
                           motorDirPWM = ((vetor/512))*255;
                            motorEsqPWM = motorDirPWM;
                            motorDir_DT_Cycle = (motorDirPWM/255)*100;
                            motorEsq_DT_Cycle = (motorEsqPWM/255)*100;
                            Serial.print("\t Vetor");
                            Serial.print(vetor);
                            Serial.print("\t FRENTE ");
                            Serial.print("\t PWM Dir:");
                             Serial.print(motorDirPWM);
                            Serial.print("\t Potencia Dir:");
                            Serial.print(motorDir_DT_Cycle);
                            Serial.print("\t PWM Esq:");
                            Serial.print(motorEsqPWM);
                            Serial.print("\t Potencia Esq:");
                            Serial.println(motorEsq_DT_Cycle);
                            
                            digitalWrite(ponteH_Dir0,LOW);
                            analogWrite(ponteH_Dir1,motorDirPWM);
                            digitalWrite(ponteH_Esq0,LOW);
                            analogWrite(ponteH_Esq1,motorEsqPWM);
                          }
                          else
                          if ((angulo>=100)&&(angulo<160))//coordenada no quadrante II
                          {
                            motorDirPWM = ((vetor/512)*((181-angulo)/90)*255);
                            motorEsqPWM = ((vetor/512)*seno)*255;
                            motorDir_DT_Cycle = (motorDirPWM/255)*100;
                            motorEsq_DT_Cycle = (motorEsqPWM/255)*100;
                            Serial.print("\t Vetor");
                            Serial.print(vetor);
                            Serial.print("\t QUADRANTE II ");
                            Serial.print("\t PWM Dir:");
                             Serial.print(motorDirPWM);
                            Serial.print("\t Potencia Dir:");
                            Serial.print(motorDir_DT_Cycle);
                            Serial.print("\t PWM Esq:");
                            Serial.print(motorEsqPWM);
                            Serial.print("\t Potencia Esq:");
                            Serial.println(motorEsq_DT_Cycle);
                          
                            digitalWrite(ponteH_Dir0,LOW);
                            analogWrite(ponteH_Dir1,motorDirPWM);
                            digitalWrite(ponteH_Esq0,LOW);
                           analogWrite(ponteH_Esq1,motorEsqPWM);
                         
                            
                          }else
                          if ((angulo<=-160)||(angulo>=160))//Giro sentido antihorario
                          {
                            motorDirPWM = (vetor/512)*255;
                            motorEsqPWM = (vetor/512)*255;
                            motorDir_DT_Cycle = (motorDirPWM/255)*100;
                            motorEsq_DT_Cycle = (motorEsqPWM/255)*100;
                            Serial.print("\t Vetor");
                            Serial.print(vetor);
                            Serial.print("\t ANTIHORARIO ");
                            Serial.print("\t PWM Dir:");
                            Serial.print(motorDirPWM);
                            Serial.print("\t Potencia Dir:");
                            Serial.print(motorDir_DT_Cycle);
                            Serial.print("\t PWM Esq:");
                            Serial.print(motorEsqPWM);
                            Serial.print("\t Potencia Esq:");
                            Serial.println(motorEsq_DT_Cycle);
                            
                            analogWrite(ponteH_Dir0,motorDirPWM);
                            digitalWrite(ponteH_Dir1,LOW);
                            digitalWrite(ponteH_Esq0,LOW);
                          analogWrite(ponteH_Esq1,motorEsqPWM);
                          }else
                          if ((angulo>-160)&&(angulo<-100))//quadrante III
                            {
                              motorDirPWM = ((vetor/512)*((angulo-1)/-180)*255);
                            motorEsqPWM = ((vetor/512)*-1*seno)*255;
                            motorDir_DT_Cycle = (motorDirPWM/255)*100;
                            motorEsq_DT_Cycle = (motorEsqPWM/255)*100;
                            Serial.print("\t Vetor");
                            Serial.print(vetor);
                            Serial.print("\t QUADRANTE III ");
                            Serial.print("\t PWM Dir:");
                             Serial.print(motorDirPWM);
                            Serial.print("\t Potencia Dir:");
                            Serial.print(motorDir_DT_Cycle);
                            Serial.print("\t PWM Esq:");
                            Serial.print(motorEsqPWM);
                            Serial.print("\t Potencia Esq:");
                            Serial.println(motorEsq_DT_Cycle);
                            
                            analogWrite(ponteH_Dir0,motorDirPWM);
                            digitalWrite(ponteH_Dir1,LOW);
                           analogWrite(ponteH_Esq0,motorEsqPWM);
                            digitalWrite(ponteH_Esq1,LOW);
                            
                                }else
                                  if ((angulo>=-100) && (angulo<-80))//potencia para trás
                                    {
                                      motorDirPWM = ((vetor/512))*255;
                                      motorEsqPWM = motorDirPWM;
                                      motorDir_DT_Cycle = (motorDirPWM/255)*100;
                                      motorEsq_DT_Cycle = (motorEsqPWM/255)*100;
                                      Serial.print("\t Vetor");
                                      Serial.print(vetor);
                                      Serial.print("\t MARCHA RÉ ");
                                      Serial.print("\t PWM Dir:");
                                       Serial.print(motorDirPWM);
                                      Serial.print("\t Potencia Dir:");
                                      Serial.print(motorDir_DT_Cycle);
                                      Serial.print("\t PWM Esq:");
                                      Serial.print(motorEsqPWM);
                                      Serial.print("\t Potencia Esq:");
                                      Serial.println(motorEsq_DT_Cycle);
                                      
                                      analogWrite(ponteH_Dir0,motorDirPWM);
                                      digitalWrite(ponteH_Dir1,LOW);
                                      analogWrite(ponteH_Esq0,motorEsqPWM);
                                      digitalWrite(ponteH_Esq1,LOW);
                          
                                            }else
                                            if ((angulo>=-80) && (angulo<-20))//quadrante IV
                                            {
                                            motorDirPWM = ((vetor/512)*(((90-(-1*angulo))/90)))*255;
                                            motorEsqPWM = ((vetor/512)*-1*seno)*255;
                                            motorDir_DT_Cycle = (motorDirPWM/255)*100;
                                            motorEsq_DT_Cycle = (motorEsqPWM/255)*100;
                                            Serial.print("\t Vetor");
                                            Serial.print(vetor);
                                            Serial.print("\t QUADRANTE IV ");
                                            Serial.print("\t PWM Dir:");
                                             Serial.print(motorDirPWM);
                                            Serial.print("\t Potencia Dir:");
                                            Serial.print(motorDir_DT_Cycle);
                                            Serial.print("\t PWM Esq:");
                                            Serial.print(motorEsqPWM);
                                            Serial.print("\t Potencia Esq:");
                                            Serial.println(motorEsq_DT_Cycle);
                                          
                                            analogWrite(ponteH_Dir0,motorDirPWM);
                                            digitalWrite(ponteH_Dir1,LOW);
                                            analogWrite(ponteH_Esq0,motorEsqPWM);
                                            digitalWrite(ponteH_Esq1,LOW);
                      }
  }
  }
  else
  {
    Serial.println("SEM TRANSMISSAO");
              digitalWrite(ponteH_Dir0,LOW);
              digitalWrite(ponteH_Dir1,LOW);
              digitalWrite(ponteH_Esq0,LOW);
              digitalWrite(ponteH_Esq1,LOW);
  }
  
  


  }


