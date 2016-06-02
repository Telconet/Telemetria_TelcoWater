/*  
 *  ------ Waspmote Pro Code Example -------- 
 *  
 *  Explanation: This is the basic Code for Waspmote Pro
 *  
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify  
 *  it under the terms of the GNU General Public License as published by  
 *  the Free Software Foundation, either version 3 of the License, or  
 *  (at your option) any later version.  
 *   
 *  This program is distributed in the hope that it will be useful,  
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of  
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
 *  GNU General Public License for more details.  
 *   
 *  You should have received a copy of the GNU General Public License  
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.  
 */
     
// Put your libraries here (#include ...)
#include <WaspFrame.h>
#include <WaspFrameConstants.h>
#include <WaspSensorSW.h>
#include <WaspWIFI.h>
#include <stdint.h>
#include <string.h>
#include <WaspUtils.h>


//WIFI MAC 0006666c1c87
#define RED_TN

// SOCKET
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////

// TCP server settings
/////////////////////////////////
#define IP_ADDRESS "192.168.1.101"
#define IP_ADDRESS_TN "172.24.4.71"
#define REMOTE_PORT 5010
#define REMOTE_PORT_TN 40050      //por ahora
#define LOCAL_PORT 34999
/////////////////////////////////


//Nuestra IP. etc (home)
/////////////////////////////////
#define MY_IP "192.168.1.180"
#define NETMASK   "255.255.255.0"
#define GATEWAY   "192.168.1.1"


//Nuestra IP. etc (TN)
/////////////////////////////////
#define MY_IP_TN "10.10.10.247"
#define NETMASK_TN   "255.255.255.0"
#define GATEWAY_TN   "10.10.10.1"

// WiFi AP Casa
/////////////////////////////////
#define ESSID "stophaxingus"
#define AUTHKEY "Eduardo363" //"Eduardo363"
//@cc3s026092k13#TNA 18 chars

//cuando clave tiene $ no coge///
/////////////////////////////////

//TN WIFI MESHLIUM
////////////////////////////////
#define ESSID_TN "meshlium"
#define AUTHKEY_TN "@cc3s0/26092k13#TNSA"
//No coge con $
///////////////////////////////


#define TIMEOUT_WIFI 60000  //1 minuto


//Variables globales de informacion
float ph = 0.0f;
float doxygen = 0.0f;
float temperatura = 0.0f;


//ID del waspmote
char waspmote_id[17] = {0};


//Referente al sensor pH
#define DIRECCION_CAL_PH_10  1024
#define DIRECCION_CAL_PH_7   1028
#define DIRECCION_CAL_PH_4   1032
#define DIRECCION_CAL_TEMP   1036
#define CALIBRACION_DO_0     1040
#define CALIBRACION_DO_100   1044

//Sondas
pHClass pHSensor;
pt1000Class temperatureSensor;
DOClass DOSensor;


void setup() {


  //Leemos la memoria EEPROM para obtener la información de calibración del sensor de pH
  float ph4 = 0.0f;
  float ph7 = 0.0f;
  float ph10 = 0.0f;
  float caltemp = 0.0f;
  
  leerFloatEEPROM(&ph4, DIRECCION_CAL_PH_4);
  leerFloatEEPROM(&ph7, DIRECCION_CAL_PH_7);
  leerFloatEEPROM(&ph10, DIRECCION_CAL_PH_10);
  leerFloatEEPROM(&caltemp, DIRECCION_CAL_TEMP);
  
  USB.println(ph4);
  USB.println(ph7);
  USB.println(ph10);
  USB.println(caltemp);
  
  
  pHSensor.setCalibrationPoints(ph10, ph7, ph4, caltemp);
  
  //Ahora el sensor de oxigeno disuelto
  float calib_do_100 = 0.0f;
  float calib_do_0 = 0.0f;
  
  leerFloatEEPROM(&calib_do_100, CALIBRACION_DO_100);
  leerFloatEEPROM(&calib_do_0, CALIBRACION_DO_0);
  
  USB.println(calib_do_100);
  USB.println(calib_do_0);
  
  DOSensor.setCalibrationPoints(calib_do_100, calib_do_0);
  
  //Inicializamos WIFI y RTC.
  //wifi_setup();
  RTC.ON();  

}


void loop() {
  
  
  
      
      

    
    
  Utils.setLED(LED0, LED_ON);
  delay(1000);
  Utils.setLED(LED0, LED_OFF);

  if( intFlag & RTC_INT )
  {
    interruptRTC();
  }
  
  
  //Leemos
      
      float nivel_ph = 0.0f;
      float ph = 0.0f;
      float temperatura = 0.0f;
      
      SensorSW.ON();  
      delay(1000);
      
      //pH & temperatura
      nivel_ph = pHSensor.readpH();
      temperatura = temperatureSensor.readTemperature();
      ph = pHSensor.pHConversion(nivel_ph, temperatura);
          
      //DO
      float doxygen = DOSensor.readDO();
      doxygen = DOSensor.DOConversion(doxygen);
      
      USB.println(ph);
      USB.println(temperatura);
      USB.println(doxygen);
      
      USB.println(" ");
      
      //Apagamos tarjeta SW
      SensorSW.OFF();


  WIFI.ON(socket);

  // 2. Join AP
  if (WIFI.join(ESSID_TN)) 
  {
    USB.println(F("Conectado al AP"));

#ifdef RED_TN
    int status = WIFI.setTCPclient(IP_ADDRESS_TN, REMOTE_PORT_TN, LOCAL_PORT);
#else
    int status = WIFI.setTCPclient(IP_ADDRESS, REMOTE_PORT, LOCAL_PORT);
#endif

    USB.println(status);

    // 3. Call the function to create a TCP connection 
    if (status) 
    {
      // 4. Now the connection is open, and we can use send and read functions 
      // to control the connection. 
      USB.println(F("TCP client set"));
      RTC.ON();

      /*SensorSW.ON();  
      
      delay(2000);
      
      //Leemos
      
      float nivel_ph = 0.0f;
      float temperatura = 0.0f;
      float ph = 0.0f;
      
      //pH & temperatura
      nivel_ph = pHSensor.readpH();
      temperatura = temperatureSensor.readTemperature();
      ph = pHSensor.pHConversion(nivel_ph, temperatura);
          
      //DO
      float doxygen = DOSensor.readDO();
      doxygen = DOSensor.DOConversion(doxygen);
      
      //Apagamos tarjeta SW
      SensorSW.OFF();*/


      // 5. Create new frame (ASCII)
      frame.createFrame(ASCII,"WM_DC_CAM1"); 
      
      // set frame fields 
      frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() );
      frame.addSensor(SENSOR_PH, ph);
      frame.addSensor(SENSOR_TCA, temperatura); 
      frame.addSensor(SENSOR_DO, doxygen);    
      frame.showFrame();

      // 6. Sends to the TCP connection 
      WIFI.send(frame.buffer,frame.length);

      // 7. Closes the TCP connection. 
      USB.println(F("Close TCP socket"));
      WIFI.close(); 
    }
    else
    {
      USB.println(F("TCP client NOT set"));
    } 
  }
  else
  {   
    USB.println(F("NO conectado al AP"));
  }

  // Switch off the module
  //WIFI.OFF();  
  USB.println(F("***************************"));

  //Apagamos la tarjeta de sensores y wifi
  WIFI.leave();
  WIFI.OFF();
  USB.println(F("WIFI apagado..."));


  Utils.setLED(LED1, LED_ON);
  delay(3000);
  Utils.setLED(LED1, LED_OFF);

  USB.println(F("Nos vamos a dormir..."));
  PWR.deepSleep("00:00:05:00", RTC_OFFSET, RTC_ALM1_MODE2, SENS_OFF);   //duerme 20 minuto //ALL_OFF  //ALL_OFF
  USB.println("Nos levantamos");

  delay(1000);
}



/**********************************
 *
 *  wifi_setup - function used to 
 *  configure the WiFi parameters 
 *
 ************************************/
void wifi_setup()
{  
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }
  //WIFI.setRemoteHost(�192.168.1.101�, 5010);

  WIFI.resetValues();
  WIFI.setChannel(4);

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
  WIFI.setConnectionOptions(CLIENT); 
  USB.println(F("Tipo cliente configurado"));
  // 2. Configure the way the modules will resolve the IP address. 

#ifdef RED_TN
  WIFI.setDHCPoptions(DHCP_OFF); 
  USB.println(F("DHCP OFF (TN)"));

#else
  WIFI.setDHCPoptions(DHCP_OFF); 
  USB.println(F("DHCP OFF")); 
#endif

#ifndef RED_TN
  // 2.2. Configure the static IP address
  // Beware of the AP address and network mask you try to connect to
  WIFI.setIp(MY_IP); 
  // 2.3. set Netmask
  WIFI.setNetmask(NETMASK); 
  // 2.4. set DNS address
  WIFI.setDNS(MAIN,"8.8.8.8","www.google.com");
  // 2.5. set gateway address
  WIFI.setGW(GATEWAY);
  USB.println(F("Parametros IP establecidos"));
#else
  // 2.2. Configure the static IP address
  // Beware of the AP address and network mask you try to connect to
  WIFI.setIp(MY_IP_TN); 
  // 2.3. set Netmask
  WIFI.setNetmask(NETMASK_TN); 
  // 2.4. set DNS address
  WIFI.setDNS(MAIN,"8.8.8.8","www.google.com");
  // 2.5. set gateway address
  WIFI.setGW(GATEWAY_TN);
  USB.println(F("Parametros IP establecidos (TN)"));
#endif


  // 3. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL); 
  USB.println(F("Join mode set "));

#ifndef RED_TN
  // 4. Set Authentication key
  WIFI.setAuthKey(WPA2,AUTHKEY);
  USB.println(F("authentication set (home)")); 
#else
  WIFI.setAuthKey(WPA1,AUTHKEY_TN);
  USB.println(F("authentication set (TN)")); 
#endif


  WIFI.setDebugMode(0);

  // 5. Store values
  WIFI.storeData();
  USB.println(F("WIFI setup complete  "));

}


/*Lee un float desde la memoria EEPROM. El valor es leído y 
 *devuelto en formato little-endian.
 */
void leerFloatEEPROM(float *valor, int direccionInicial){

  //Valor es el bloque de memoria donde devolveremos el valor leído
  uint8_t *valor_int_cast = (uint8_t *)valor;

  int i = 0;
  for(i = 0; i < 4 ; i++){
    uint8_t valorLeido = Utils.readEEPROM(direccionInicial + i);
    *(valor_int_cast+i) = valorLeido;
  }
}


//Deep Sleep
void interruptRTC()
{
  USB.println(F("---------------------"));
  USB.println(F("Interrupt de RTC capturado"));
  USB.println(F("---------------------"));
  intFlag &= ~(RTC_INT);  
  delay(5000);
}
