//+------------------------------------------------------------------+
//|                                            SkyCoreAtlasPrime.mq4 |
//|                               Copyright 2025, Pixels Of Midnight |
//|                                https://www.pixelsofmidnight.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Pixels of Midnight"
#property link "https://www.pixelsofmidnight.com/"
#property version "1.0"
#property strict
#property icon "TradeTech_Logo.ico"
double Risk();
#import

string Separador8 = "---Entre el Password---";

#define MAX_LINEAS_LOG 5
string logVisual[MAX_LINEAS_LOG];
int logIndex = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LogEnPantalla(string mensaje)
  {
// Sistema simplificado: solo guardamos el mensaje, sin mostrarlo
// Ya no usamos el buffer circular
  }

// Función para mostrar cuadrito del Stochastic
void MostrarBanderaStoch(bool activado, string tipo)
  {
   string nombreRect = "stoch_rect";
   string nombreLabel = "stoch_label";

   int x = 10; // Posición X (esquina izquierda)
   int y = 30; // Posición Y (fija en la esquina superior)

   if(!activado)
     {
      // Si no está activo, eliminar los objetos
      ObjectDelete(0, nombreRect);
      ObjectDelete(0, nombreLabel);
      return;
     }

   color colorRect = clrGray; // Color por defecto (gris)
   string texto = "SCHO";

   if(tipo == "MEGABUY")
     {
      colorRect = clrLime;   // Verde brillante
      texto = "SCHO✓"; // ✓ indica autorizado
     }
   else
      if(tipo == "MEGASELL")
        {
         colorRect = clrRed;    // Rojo brillante
         texto = "SCHO✓"; // ✓ indica autorizado
        }
      else
         if(tipo == "BUY")
            colorRect = clrLime;   // Verde para BUY
         else
            if(tipo == "SELL")
               colorRect = clrRed;    // Rojo para SELL
            else
               if(tipo == "NONE")
                  colorRect = clrGray;   // Gris para zona neutra (50-90)

// Crear rectángulo de fondo
   ObjectCreate(0, nombreRect, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nombreRect, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nombreRect, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nombreRect, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nombreRect, OBJPROP_XSIZE, 150);
   ObjectSetInteger(0, nombreRect, OBJPROP_YSIZE, 25);
   ObjectSetInteger(0, nombreRect, OBJPROP_COLOR, colorRect);
   ObjectSetInteger(0, nombreRect, OBJPROP_BACK, true);
   ObjectSetInteger(0, nombreRect, OBJPROP_BGCOLOR, colorRect);
   ObjectSetInteger(0, nombreRect, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, nombreRect, OBJPROP_WIDTH, 2);

// Crear texto "SCHO"
   ObjectCreate(0, nombreLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nombreLabel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nombreLabel, OBJPROP_XDISTANCE, x + 75);
   ObjectSetInteger(0, nombreLabel, OBJPROP_YDISTANCE, y + 8);
   ObjectSetInteger(0, nombreLabel, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, nombreLabel, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, nombreLabel, OBJPROP_FONT, "Arial Bold");
   ObjectSetString(0, nombreLabel, OBJPROP_TEXT, texto);
  }

// Función para mostrar cuadrito MEGA (compra/venta autorizada)
void MostrarBanderaMEGA(bool megaBuy, bool megaSell)
  {
   string nombreRect = "mega_rect";
   string nombreLabel = "mega_label";

   int x = 10; // Posición X (esquina izquierda)
   int y = 5; // Posición Y (más arriba que SCHO)

// SIEMPRE mostrar el cuadrito MEGA
   color colorRect = clrGray;
   string texto = "MEGA";

   if(megaBuy)
     {
      colorRect = clrLime;   // Verde brillante
      texto = "MEGA✓";
     }
   else
      if(megaSell)
        {
         colorRect = clrRed;    // Rojo brillante
         texto = "MEGA✓";
        }
      else
        {
         // Sin oportunidad = gris
         colorRect = clrGray;
         texto = "MEGA";
        }

// Crear rectángulo de fondo
   ObjectCreate(0, nombreRect, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nombreRect, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nombreRect, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nombreRect, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nombreRect, OBJPROP_XSIZE, 150);
   ObjectSetInteger(0, nombreRect, OBJPROP_YSIZE, 25);
   ObjectSetInteger(0, nombreRect, OBJPROP_COLOR, colorRect);
   ObjectSetInteger(0, nombreRect, OBJPROP_BACK, true);
   ObjectSetInteger(0, nombreRect, OBJPROP_BGCOLOR, colorRect);
   ObjectSetInteger(0, nombreRect, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, nombreRect, OBJPROP_WIDTH, 2);

// Crear texto
   ObjectCreate(0, nombreLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nombreLabel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nombreLabel, OBJPROP_XDISTANCE, x + 75);
   ObjectSetInteger(0, nombreLabel, OBJPROP_YDISTANCE, y + 8);
   ObjectSetInteger(0, nombreLabel, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, nombreLabel, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, nombreLabel, OBJPROP_FONT, "Arial Bold");
   ObjectSetString(0, nombreLabel, OBJPROP_TEXT, texto);
  }

// Función para mostrar cuadrito de medias móviles con orientación
void MostrarBanderaMA(int periodo, int orientacion)
  {
   string nombreRect = "ma_rect_" + IntegerToString(periodo);
   string nombreLabel = "ma_label_" + IntegerToString(periodo);

   int x = 10; // Posición X (esquina izquierda)
   int y = 30 + (periodo == 5 ? 30 : periodo == 50 ? 55 : 80); // Posición Y según período

// Determinar color según orientación
   color colorRect = clrGray; // Gris por defecto (lateral)
   if(orientacion == 1)
      colorRect = clrLime;   // Verde para alcista
   else
      if(orientacion == -1)
         colorRect = clrRed;    // Rojo para bajista

// Crear rectángulo de fondo
   ObjectCreate(0, nombreRect, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nombreRect, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nombreRect, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nombreRect, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nombreRect, OBJPROP_XSIZE, 150);
   ObjectSetInteger(0, nombreRect, OBJPROP_YSIZE, 25);
   ObjectSetInteger(0, nombreRect, OBJPROP_COLOR, colorRect);
   ObjectSetInteger(0, nombreRect, OBJPROP_BACK, true);
   ObjectSetInteger(0, nombreRect, OBJPROP_BGCOLOR, colorRect);
   ObjectSetInteger(0, nombreRect, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, nombreRect, OBJPROP_WIDTH, 2);

// Crear texto con el período
   ObjectCreate(0, nombreLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nombreLabel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nombreLabel, OBJPROP_XDISTANCE, x + 75);
   ObjectSetInteger(0, nombreLabel, OBJPROP_YDISTANCE, y + 8);
   ObjectSetInteger(0, nombreLabel, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, nombreLabel, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, nombreLabel, OBJPROP_FONT, "Arial Bold");
   ObjectSetString(0, nombreLabel, OBJPROP_TEXT, IntegerToString(periodo));
  }

// Dibuja el objetivo de cierre por protección de pérdidas junto a los cuadritos de MAs
void MostrarObjetivoProteccionPerdidas()
  {
   string nameRect  = "ma_rect_obj_prot";
   string nameLabel = "ma_label_obj_prot";

   int x = 10;
   int y = 30 + 105; // Debajo de los tres cuadritos (5/50/200)

// Calcular estado y texto
   string texto = "Objetivo cierre: —";
   color colText = clrWhite;

   int consecutivas = CountConsecutiveLosingClosedByMagicSymbol(MagicNumber);
// Usar la misma métrica que el panel derecho: perdidaAcumulada()
   double perdidasAccPanel = perdidaAcumulada();
   if(proteccionPerdidas && consecutivas >= perdidasConsecutivasMin && perdidasAccPanel < 0)
     {
      double perdidasAbs = MathAbs(perdidasAccPanel);
      double factor   = porcentajeExtraCierre / 100.0;
      double objetivo = perdidasAbs + (perdidasAbs * factor);
      double flotante = GetFloatingProfitByMagicSymbol(MagicNumber);

      texto = "Objetivo cierre: $" + DoubleToStr(objetivo, 2) +
              "  (flot: $" + DoubleToStr(flotante, 2) +
              ", +" + DoubleToStr(porcentajeExtraCierre, 2) + "%)";
      colText = (flotante >= objetivo ? clrLime : clrGold);
     }
   else
     {
      if(!proteccionPerdidas)
         texto = "Protección pérdidas: OFF";
      else
         if(consecutivas < perdidasConsecutivasMin)
            texto = "Esperando " + IntegerToString(perdidasConsecutivasMin) + " pérdidas";
         else
            texto = "Sin pérdidas acumuladas";
      colText = clrSilver;
     }

// Fondo
   ObjectCreate(0, nameRect, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nameRect, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nameRect, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nameRect, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nameRect, OBJPROP_XSIZE, 300);
   ObjectSetInteger(0, nameRect, OBJPROP_YSIZE, 25);
   ObjectSetInteger(0, nameRect, OBJPROP_COLOR, clrDimGray);
   ObjectSetInteger(0, nameRect, OBJPROP_BACK, true);
   ObjectSetInteger(0, nameRect, OBJPROP_BGCOLOR, clrDimGray);
   ObjectSetInteger(0, nameRect, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, nameRect, OBJPROP_WIDTH, 1);

// Texto
   ObjectCreate(0, nameLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nameLabel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nameLabel, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, nameLabel, OBJPROP_YDISTANCE, y + 6);
   ObjectSetInteger(0, nameLabel, OBJPROP_COLOR, colText);
   ObjectSetInteger(0, nameLabel, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, nameLabel, OBJPROP_TEXT, texto);
  }

// Verifica si estamos en horario peligroso según análisis histórico
// Usa hora del broker (ya calibrada con tus datos históricos)
bool EstaEnHorarioPeligroso()
  {
   if(!evitarHorariosPeligrosos)
      return false;

   int horaActual = Hour(); // Hora del broker MT4
   int minutoActual = Minute();
   int diaActual = DayOfWeek(); // 0=Domingo, 1=Lunes, ..., 5=Viernes, 6=Sábado

// ===== Bloqueo especial de VIERNES CAÓTICO =====
// Viernes desde 7:30 AM hasta 7:30 PM hora Ecuador
// En hora del broker: desde 12:30 PM viernes hasta 00:30 AM sábado
   if(bloquearViernesCaotico)
     {
      // Verificar si es viernes después de las 12:30 PM
      if(diaActual == 5) // Viernes
        {
         if(horaActual > horaInicioViernes || (horaActual == horaInicioViernes && minutoActual >= minutoInicioViernes))
           {
            return true;
           }
        }
      // Verificar si es sábado antes de las 00:30 AM (continuación del viernes)
      if(diaActual == 6) // Sábado
        {
         if(horaActual == 0 && minutoActual < 30)
           {
            return true;
           }
        }
     }

// ===== Franjas horarias peligrosas normales =====
// Franja 1: 17:00-20:00 (pérdidas más grandes: -$218, -$59)
   bool enFranja1 = (horaActual >= horaPeligrosa1Inicio && horaActual < horaPeligrosa1Fin);

// Franja 2: 09:00-10:00 (rachas de 5 pérdidas: -$58)
   bool enFranja2 = (horaActual >= horaPeligrosa2Inicio && horaActual < horaPeligrosa2Fin);

   if(enFranja1 || enFranja2)
     {
      return true;
     }

   return false;
  }

// Muestra info de horario actual y tiempo hasta próximo horario peligroso
void MostrarInfoHorarioPeligroso()
  {
   string nameRect  = "horario_rect";
   string nameLabel = "horario_label";

   int x = 10;
   int y = 30 + 135; // Debajo del objetivo de cierre

   int horaActual = Hour();
   int minutoActual = Minute();
   int diaActual = DayOfWeek();

// Calcular tiempo hasta próximo horario peligroso
   int horasHasta = -1;
   int minutosHasta = 0;
   string proximaFranja = "";
   color colTexto = clrWhite;

   bool enPeligro = EstaEnHorarioPeligroso();

// Verificar si estamos en VIERNES CAÓTICO
   bool enViernesCaotico = false;
   if(bloquearViernesCaotico)
     {
      if(diaActual == 5 && (horaActual > horaInicioViernes || (horaActual == horaInicioViernes && minutoActual >= minutoInicioViernes)))
         enViernesCaotico = true;
      if(diaActual == 6 && horaActual == 0 && minutoActual < 30)
         enViernesCaotico = true;
     }

   if(enPeligro)
     {
      // Estamos EN horario peligroso
      if(enViernesCaotico)
        {
         // Calcular tiempo hasta fin del viernes caótico (sábado 00:30)
         if(diaActual == 5)
           {
            // Viernes: calcular hasta medianoche + 30 min
            horasHasta = (24 - horaActual - 1);
            minutosHasta = 30 + (60 - minutoActual);
            if(minutosHasta >= 60)
              {
               horasHasta++;
               minutosHasta -= 60;
              }
           }
         else
            if(diaActual == 6)
              {
               // Sábado temprano: calcular hasta 00:30
               horasHasta = 0;
               minutosHasta = 30 - minutoActual;
              }
         proximaFranja = "FIN Viernes Caótico";
         colTexto = clrRed;
        }
      else
         if(horaActual >= horaPeligrosa1Inicio && horaActual < horaPeligrosa1Fin)
           {
            // En franja 1: calcular tiempo restante hasta el fin
            horasHasta = (horaPeligrosa1Fin - horaActual - 1);
            minutosHasta = 60 - minutoActual;
            if(minutosHasta == 60)
              {
               horasHasta++;
               minutosHasta = 0;
              }
            proximaFranja = "FIN Franja 1";
            colTexto = clrRed;
           }
         else
            if(horaActual >= horaPeligrosa2Inicio && horaActual < horaPeligrosa2Fin)
              {
               // En franja 2
               horasHasta = (horaPeligrosa2Fin - horaActual - 1);
               minutosHasta = 60 - minutoActual;
               if(minutosHasta == 60)
                 {
                  horasHasta++;
                  minutosHasta = 0;
                 }
               proximaFranja = "FIN Franja 2";
               colTexto = clrRed;
              }
     }
   else
     {
      // Fuera de horario peligroso: calcular tiempo hasta el próximo inicio
      int distancia1 = (horaPeligrosa1Inicio >= horaActual) ? (horaPeligrosa1Inicio - horaActual) : (24 + horaPeligrosa1Inicio - horaActual);
      int distancia2 = (horaPeligrosa2Inicio >= horaActual) ? (horaPeligrosa2Inicio - horaActual) : (24 + horaPeligrosa2Inicio - horaActual);

      if(distancia1 <= distancia2)
        {
         horasHasta = distancia1;
         minutosHasta = (60 - minutoActual) % 60;
         if(minutosHasta > 0)
            horasHasta--;
         proximaFranja = "Franja 1 (17-20h)";
         colTexto = clrLime;
        }
      else
        {
         horasHasta = distancia2;
         minutosHasta = (60 - minutoActual) % 60;
         if(minutosHasta > 0)
            horasHasta--;
         proximaFranja = "Franja 2 (9-10h)";
         colTexto = clrLime;
        }
     }

   string texto = "Hora: " + IntegerToString(horaActual, '0') + ":" +
                  (minutoActual < 10 ? "0" : "") + IntegerToString(minutoActual) +
                  " | " + (enPeligro ? "⛔ EN PELIGRO" : "Próx: " + proximaFranja) +
                  " en " + IntegerToString(horasHasta) + "h " + IntegerToString(minutosHasta) + "m";

// Fondo: rojo transparente si está en peligro, verde transparente si no
   color colorFondo = enPeligro ? C'180,50,50' : C'50,180,50'; // Rojo semitransparente / Verde semitransparente

// Fondo
   ObjectCreate(0, nameRect, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nameRect, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nameRect, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nameRect, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nameRect, OBJPROP_XSIZE, 350);
   ObjectSetInteger(0, nameRect, OBJPROP_YSIZE, 25);
   ObjectSetInteger(0, nameRect, OBJPROP_COLOR, colorFondo);
   ObjectSetInteger(0, nameRect, OBJPROP_BACK, true);
   ObjectSetInteger(0, nameRect, OBJPROP_BGCOLOR, colorFondo);
   ObjectSetInteger(0, nameRect, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, nameRect, OBJPROP_WIDTH, 1);

// Texto: siempre blanco para buen contraste
   ObjectCreate(0, nameLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nameLabel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nameLabel, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, nameLabel, OBJPROP_YDISTANCE, y + 6);
   ObjectSetInteger(0, nameLabel, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, nameLabel, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, nameLabel, OBJPROP_TEXT, texto);
  }


//+------------------------------------------------------------------+
//| Función para calcular altura promedio de las barras             |
//+------------------------------------------------------------------+
double CalcularAlturaPromedioBarras(int numBarras = 20)
  {
   if(numBarras <= 0)
      numBarras = 20;

   double sumaAlturas = 0.0;
   int barrasValidas = 0;

   for(int i = 1; i <= numBarras; i++)
     {
      double high = iHigh(NULL, 0, i);
      double low = iLow(NULL, 0, i);

      if(high > 0 && low > 0)
        {
         double alturaBarra = high - low;
         sumaAlturas += alturaBarra;
         barrasValidas++;
        }
     }

   if(barrasValidas > 0)
      return sumaAlturas / barrasValidas;
   else
      return 0.0;
  }

//+------------------------------------------------------------------+
//| Función para obtener TP dinámico                                |
//+------------------------------------------------------------------+
double ObtenerTPDinamico()
  {
   if(!calculoTPSLAutomatico)
      return TP;

// Usar variable global alturaPromedio (ya calculada previamente)
   if(alturaPromedio <= 0)
      return TP;

   return (alturaPromedio / Point) * tpMultiplicador;  // Convertir a pips antes de multiplicar
  }

//+------------------------------------------------------------------+
//| Función para obtener SL dinámico                                |
//+------------------------------------------------------------------+
double ObtenerSLDinamico()
  {
   if(!calculoTPSLAutomatico)
      return SL;

// Usar variable global alturaPromedio (ya calculada previamente)
   if(alturaPromedio <= 0)
      return SL;

   return (alturaPromedio / Point) * slMultiplicador;  // Convertir a pips antes de multiplicar
  }

//+------------------------------------------------------------------+
//|Variables que posiblemennte no este usando                          |
//+------------------------------------------------------------------+

double VP = 200;               // Distancia Orden pendiente
bool useBE = false;            // Usar BreakEvent
double variableBreak = 110;    // BreakEvent
double bZero = 300;            // Cantidad de pips por debajo

bool cuentaCent = false;       // Es Cuenta Cent?
int myPorciertoPerdida = 1;    //%Perdida Global
bool salidaAutomatica = false; // Salida Automtica

double lots;
double lotsBuy;
double lotsSell;
double alturaPromedio = 0.0; // Variable global para altura promedio de barras (usada para TP/SL dinámico)
bool Mynotification = false;   // Aviso al crear una orden
bool MyRiesgo = false;         // Aviso de Riesgo
bool versionSegura = false;    // Detectar Solo Tendencia
bool versionInvertida = false; // Resetear Martingala
int reseteador = 3;            // Resetear martingala
bool usarNotificacionDia = true;
bool conmutadorMontoInicial = true;
double montoInicial = 0;
//+------------------------------------------------------------------+
//|Fin de Variables que posiblemnte no este usando                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Separador4 = "---Tiempo entre ordenes(Minutos)---";
// input int      CantHorasEspera = 5;//Cantidad de Minutos
string Separador5 = "---Gestión del Precio---";

// input double TPLimit = 0.6;
// input double valorMinProfit = 100.09;
// input int xPorCiento = 0;//Take profit en %

//+------------------------------------------------------------------+
//|Parametros Globales                                               |
//+------------------------------------------------------------------+

string PastMaxMin = "Solo_MaxMin_Ind";
int CantHorasEspera = 5; // Cantidad de Minutos (reducido para mayor reactividad)
bool NuevaOperacion = false;
input string Separador1 = "---Parametros Globales---";
extern int MaxSpread = 90; // Spread Máximo de Operación
input int MagicNumber = 555;
double metaDiaria = 0;      // Meta Diaria
int CantOperacionesMax = 1; // Max cantidad de Operaciones

bool activarParidad = true;
int cantOpe = 1;        // Cantidad de Operaciones por Par



//+------------------------------------------------------------------+
//|Fin Parametros Globales                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Configuracion 1                                                   |
//+------------------------------------------------------------------+
input string Separador2 = "---Configuracion---";
bool useTP = true; //usar TP Fijo?
input double   TP=1500;//Take profit
bool useSL = true; //usar SL Fijo?
input double   SL=1250;//Stop Lost
// ===== NUEVO: TP/SL DINÁMICO BASADO EN ALTURA DE BARRAS =====
input bool calculoTPSLAutomatico = true; // Usar cálculo automático de TP/SL basado en altura de barras
input int barrasParaPromedio = 20; // Cantidad de barras para calcular altura promedio
input double tpMultiplicador = 1.0; // TP = X veces la altura promedio de las barras
input double slMultiplicador = 3.0; // SL = X veces la altura promedio de las barras

// ===== NUEVOS CONTROLES DE BANDERAS =====
input bool banderaEstocastico = false; // Usar bandera de estocástico (primera condición)
input bool restriccionMedia200 = false; // Usar restricción MA200 (BUY encima, SELL debajo)
input bool usarMegaComoGatillo = true; // Usar MEGA-BANDERA como gatillo (deshabilita cruce MA8xMA5)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OBLevel = 50;// nivel medio - para ventas (estoc > 50 con pendiente negativa)
int OSLevel = 50;// nivel medio - para compras (estoc < 50 con pendiente positiva)
bool usarIA = false; //usar IA
double tpPercent = 1.5;//TP proporcion
double slPercent = 0.5;//Sl proporcion
int VelasContra = 8;             // Velas a esperar antes de evaluar
double DojiRatio = 0.25;         // Máximo % de cuerpo vs rango total para considerar doji
double RechazoMinimo = 1.1;      // Mínimo % de mecha a favor del movimiento
double  extraSlSpace = 0;//Espacio extra despues del SL
input bool useTS = true; // Activar Trailing Stop manualmente
input double minDistanceToActivateTS = 10000.0; // Distancia mínima en pips para activar TS
input double trailingStopBuffer = 6000.0; // Buffer en pips antes de mover el trailing stop
input double initialTSMove = 6000.0; // Pips que se mueve el SL inicialmente (ej: mitad de minDistance)
input bool useBreakevenStop = true; // Activar Breakeven Stop (SL a 0)
input double breakevenDistance = 3000.0; // Distancia en pips para activar breakeven
input double breakevenLossPips = 1000.0; // Pérdida en pips para el breakeven (ej: -1000 = pequeña pérdida)
input bool useMA200Exit = false; // Cerrar operación si barra cierra del otro lado de MA200
int countTS = 102;//Max for TS
double datatrailingStopPercentage = 0.5; //Trailing Stop
double N = 1;    // Nivel de Entrada
double myVela = 1;    // espacio despues del SL

//+------------------------------------------------------------------+
//| Protección de pérdidas acumuladas                                 |
//+------------------------------------------------------------------+
input bool proteccionPerdidas = false;                  // Activar protección de pérdidas
input int perdidasConsecutivasMin = 1;                 // Activar a partir de N pérdidas consecutivas
input double porcentajeExtraCierre = 1.0;              // % extra sobre pérdidas acumuladas para cerrar (ej: 1.0 = 1%)



//input int CloseTime = 240; // duracion de una operacion abierta en minutos
//input int MAX_BARS = 15; // Duracion de una operacion abierta en Barras
// input double   PP = 100;//Posicion pendiente;


// input double   lotajeDeseado = 0.01;//Lotaje Inicial
double lotajeDeseado=0.01; // Lotaje Inicial
//input double lotajePorCada500Balance = 0.1;

//+------------------------------------------------------------------+
//| Configuración de Rango Horizontal                                  |
//+------------------------------------------------------------------+
input string SeparadorRangoHorizontal = "---Rango Horizontal---";
input bool detectarRangoHorizontal = true; // Activar detección de rango horizontal

//+------------------------------------------------------------------+
//| Configuración de Filtros Modulares IsMarketSafe()                |
//+------------------------------------------------------------------+
input string SeparadorFiltrosModulares = "---Filtros Modulares IsMarketSafe---";
// Activar/desactivar cada filtro
input bool usarFiltroEMATrenzada        = true;
input bool usarFiltroRangoAdaptativo    = true;
input bool usarFiltroPrecioPegadoEMA    = true;
input bool usarFiltroSlopeEMA           = true;
input bool usarFiltroAnguloEMA          = true;
input bool usarFiltroCanalEstrecho      = true;
input bool usarFiltroAlternanciaVelas   = true;
input bool usarFiltroMechasLargas       = true;
input bool usarFiltroCuerpoMinimo       = true;
input bool usarFiltroFaltaContinuacion  = true;
input bool usarFiltroRetrocesoInmediato = true;
input bool usarFiltroAceleracionReal    = true;
input bool mostrarDebugFiltros          = false;

// Parámetros de sensibilidad
input int    filtroLookback                 = 20;
input int    filtroEMATrenzadaMaxCruces     = 3;
input double filtroRangoMinMultiplicadorATR = 1.8;
input double filtroPrecioPegadoFactorATR    = 0.30;
input double filtroPrecioPegadoMaxRatio     = 0.40;
input double filtroSlopeMinFactorATR        = 0.20;
input double filtroAnguloMinGrados          = 3.5;
input double filtroCanalFactorATR           = 0.35;
input double filtroCanalMaxRatioCentral     = 0.50;
input double filtroAlternanciaMaxRatio      = 0.45;
input double filtroMechasFactorCuerpo       = 2.0;
input double filtroCuerpoMinFactorAltura    = 0.25;
input double filtroContinuacionMinFactorAlt = 0.30;
input double filtroRetrocesoMaxFactorAlt    = 0.40;
input double filtroAceleracionMinFactorAlt  = 0.20;
//+------------------------------------------------------------------+
//| Fin Configuración de Filtros Modulares                          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Fin Configuración de Rango Horizontal                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Parámetros de Interés Compuesto                                   |
//+------------------------------------------------------------------+
input string SeparadorInteresCompuesto = "---Interés Compuesto---";
bool useInteresCompuesto = true; // Activar Interés Compuesto
input double capitalBase = 3000.0; // Capital base para 0.01 lotes
input double lotsPorCapital = 0.01; // Lotes por cada unidad de capital base
//+------------------------------------------------------------------+
//|Fin Interés Compuesto                                             |
//+------------------------------------------------------------------+

input int maxLost = 20;       // Maxima perdida consecutiva
bool usarRestriccionVelaGrande = true; // Usar restricción de vela grande
input bool martingala = true;  // Usar Martingala (true=activada | false=desactivada)
input int cuandoUsarMartingala = 1; // Activar Martingala después de N pérdidas (recomendado: 1)
double porcentajeExtra = 0.1; // % Ganancia extra
input double myMultiplierBuy = 4.0; // Multiplicador Martingala para COMPRAS
input double myMultiplierSell = 4.0; // Multiplicador Martingala para VENTAS
input int tipoMartingala = 1; // Tipo de Martingala: 0=Clásica | 1=Nueva (Racha Mala)
input bool hacerMartingalaAcumulativo = false; // Martingala acumulativa: cubrir todas las pérdidas

//+------------------------------------------------------------------+
//| Configuración de Scalping Agresivo                              |
//+------------------------------------------------------------------+
input string SeparadorScalping = "---Scalping Agresivo---";
input bool usarScalpingAgresivo = false; // Activar scalping agresivo
input int gananciaMinimaTics = 3000; // Ganancia mínima en tics para cerrar (mitad de 2408)
input int gananciaRapidaTics = 1500; // Ganancia rápida en tics para cerrar rápido
bool cerrarEnPrimeraGanancia = true; // Cerrar en la primera ganancia mínima

//+------------------------------------------------------------------+
//| Protección de Drawdown                                           |
//+------------------------------------------------------------------+
input string SeparadorDD = "---Protección de Drawdown---";
input bool usarProteccionDrawdown = true; // Activar protección de drawdown
input double maxDrawdownPorcentaje = 50.0; // Máximo drawdown permitido sobre el balance inicial (%)
bool cerrarSoloPerdedoras = true; // Si true, cierra únicamente posiciones en pérdida; si false, cierra todo
int slippage = 3; // Deslizamiento máximo en puntos para cierres/aperturas

//+------------------------------------------------------------------+
//|Filtros de Tendencia                                              |
//+------------------------------------------------------------------+
string SeparadorFiltros = "---Filtros de Tendencia---";
bool usarFiltrosTendencia = true; // Activar/desactivar filtros
int filtrosMinimosRequeridos = 3; // Mínimo de filtros que deben confirmar (reducido para mayor reactividad)
bool filtrarPorMA50 = true; // Filtrar por EMA50
bool filtrarPorRSI = true; // Filtrar por RSI
bool filtrarPorMACD = true; // Filtrar por MACD
bool filtrarPorADX = true; // Filtrar por ADX
bool filtrarPorEstructura = true; // Filtrar por estructura de precio
bool filtrarPorVelocidadMA = true; // Filtrar por velocidad de EMA50
bool modoReactivo = true; // Modo reactivo: reduce filtros y tiempos de espera

color colorLineaAlta = clrLime; // Color línea filtro BUY
color colorLineaBaja = clrRed; // Color línea filtro SELL
int grosorLinea = 2; // Grosor de las líneas visuales

// ===== Filtros adicionales de alineación de tendencia =====
bool usarFiltroPendienteMA200 = true; // Exigir pendiente de MA200 a favor
int pendienteLookbackBars = 20; // Barras para medir la pendiente de MA200
double pendienteMinPipsPorBarra = 0.05; // Umbral mínimo (pips/barra)
bool evitarRangoMA200 = true; // No operar si MA200 está casi horizontal
// Nuevo: filtro de horizontalidad para MA50
bool usarFiltroPendienteMA50 = true; // Bloquear si MA50 está casi horizontal
double pendienteMinPipsPorBarraMA50 = 0.08; // Umbral mínimo (pips/barra) para MA50
bool usarFiltroMA50 = true; // Usar MA50 para tendencia corta
int periodoMA50 = 5; // Período de la MA para tendencia corta

// Filtro de horarios peligrosos (basado en análisis histórico)
input bool evitarHorariosPeligrosos = true; // Bloquear horarios con más pérdidas históricas
input int offsetBrokerGMT = 2; // Offset del broker respecto a GMT (ej: GMT+2 → valor=2)
input int horaPeligrosa1Inicio = 17; // Hora inicio bloqueo 1 (hora del broker MT4)
input int horaPeligrosa1Fin = 20;    // Hora fin bloqueo 1 (hora del broker MT4)
input int horaPeligrosa2Inicio = 9;  // Hora inicio bloqueo 2 (hora del broker MT4)
input int horaPeligrosa2Fin = 10;    // Hora fin bloqueo 2 (hora del broker MT4)

// Bloqueo de viernes caóticos
input bool bloquearViernesCaotico = true; // Bloquear viernes desde 7:30 AM hasta 7:30 PM (hora Ecuador)
input int horaInicioViernes = 12; // Hora inicio bloqueo viernes (hora del broker = 7:30 AM Ecuador)
input int minutoInicioViernes = 30; // Minuto inicio bloqueo viernes
input int horaFinViernes = 24; // Hora fin bloqueo viernes (00:00 = media noche, 7:30 PM Ecuador del viernes)

// ===== Sistema de Entrada por Alineación de Medias =====
string SeparadorEntradaMedias = "---Entrada por Alineación de Medias---";
bool usarEntradaPorMedias = true; // Activar entrada por alineación de medias
bool usarEstocastico = true; // Usar Stochastic para timing de entrada
input bool ajusteEntradaStochastic = false; // EXPERIMENTO: Cerrar y reabrir posiciones según Stochastic
input bool usarCierrePorEstocastico = false; // Activar cierre de posiciones por estocástico (sobreventa/sobrecompra)
int periodoMACorta = 50; // Período de la MA corta (por defecto 50)
int periodoMALarga = 200; // Período de la MA larga (por defecto 200)
int barrasParaTendencia = 5; // Barras para calcular tendencia de las medias
int periodoMAUltraCorta = 5; // Período de la MA ultracorta (por defecto 5)

//+------------------------------------------------------------------+
//|Fin Filtros de Tendencia                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Fin Configuracion 1                                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Horario de Trabajo                                                |
//+------------------------------------------------------------------+

// input string t;// "---Cerrar Operaciones en Fin de Semana---";
string Separador3= "---Horario de Trabajo---";
bool useTime = true; // Usar Horario de Trabajo
string e="Weekend";

enum DaysOfWeek
  {
   Monday = 1,
   Tuesday = 2,
   Wednesday = 3,
   Thursday = 4,
   Friday = 5,
   Saturday = 6,
   Sunday = 0
  };

DaysOfWeek StartDay = Monday;
DaysOfWeek EndDay = Friday;

int CloseHour=19;
int CloseMinute=50;
bool Weekend=true;
bool CloseAll=false;;

//+------------------------------------------------------------------+
//|Fin Horario de Trabajo                                                |
//+------------------------------------------------------------------+

// input int MaximaPerdida = 100;//Maxima perdida consecutiva
// int MaximaGanancia = 10;//Maxima Ganancia Consecutiva
// bool multiples = false;//Multiples Entradas
// input int cantOperaciones = 6;//Cantidad de Operaciones Abiertas
// input int valorPerdida = 20;//% de Pérdida Máxima
double precioFijo = 0;

double Sma5AltoRed0, Sma10AltoYellow0, Sma5BajoMagenta0, Sma10BajoWhite0, Ema50Aqua0, BBMain0, BBHigh0, BBLow0, Sma200Green0;
double Sma5AltoRed1, Sma10AltoYellow1, Sma5BajoMagenta1, Sma10BajoWhite1, Ema50Aqua1, BBMain1, BBHigh1, BBLow1, Sma200Green1;
double myPriceNow, myPricePre;
double myStch, myADX;

// cosas de fibo
int Fib_Period = 80;
int level_count;
double level_array[10] = {0, 0.236, 0.382, 0.5, 0.618, 0.764, 1, 1.618, 2.618, 4.236};
double LotajeCreacionMartingala;
int ContadorORdenes = 1;
int TicketHistory;
double Profit;

// Variables para nueva estrategia de martingala - SEPARADAS PARA BUY Y SELL
double lotajePerdidoGuardadoBuy = 0.0;   // Guarda el lotaje de la operación perdida BUY
double lotajePerdidoGuardadoSell = 0.0;  // Guarda el lotaje de la operación perdida SELL
bool enRachaMalaBuy = false;             // Indica si BUY está en racha mala (operando a 0.01)
bool enRachaMalaSell = false;            // Indica si SELL está en racha mala (operando a 0.01)
double perdidasAcumuladasBuy = 0.0;      // Acumula el monto en dolares de todas las perdidas BUY
double perdidasAcumuladasSell = 0.0;     // Acumula el monto en dolares de todas las perdidas SELL
bool tipoOperacionGanadoraBuy = false;   // true si BUY ganó con 0.01 y está listo para martingala
bool tipoOperacionGanadoraSell = false;  // true si SELL ganó con 0.01 y está listo para martingala
double lotajeMinimo = 0.01;              // Lotaje mínimo durante racha mala
int numeroDeIntentosBuy = 0;             // Contador de intentos para Martingala Clásica BUY
int numeroDeIntentosSell = 0;            // Contador de intentos para Martingala Clásica SELL

bool Convergente = True; // Detectar Patron convergente

int LotDigits = 2;

int OperacionAbierta;
int OperacionCloseAbierta;
int OperacionAbiertaLimit;
int OperacionePendiente;
double lotsCompra;
double lotsVenta;
int index = 0;

// bool     bandera= true;

int ContadorGanancias = 0;

int ContadorOrdenesNegativas = 0;
int ContadorOrdenesTotal = 0;
// double   Nivel=29.0;//Nivel del ADX
// int      Periodos=14;//Perido del ADX
int KperiodoAmarillo = 9;
int DperiodoAmarillo = 2;
int SlowingAmarillo = 4;
int KperiodoRojo = 55;
int DperiodoRojo = 2;
int SlowingRojo = 4;
int SMAPeriodoLento = 14;
int SMAPeriodoRapido = 1;

//////////////////////////////////////////////////////////////
// Variable para resetear cuando sean mas de 5
bool PrimeraVezDespuesDeCincoBuy = true;
bool PrimeraVezDespuesDeCincoSell = true;
// Nuevo Robot
double posBuy;
double posSell;
double posTPBuy;
double posTPSell;
double posSLBuy;
double posSLSell;
bool comenzaronLosBuys = false;
bool comenzaronLosSells = false;

// input int TiempoEspera = 6;//minutos para volver a operar
datetime timeofOperation = TimeCurrent();
datetime timeofClose = TimeCurrent();
datetime candletime = 0;
datetime currenttime = 0;
int Ticket;
int periodKernel = 10;
int periodEma = 1;
bool normal = false; // Activar trading tradicional

bool medio = false;       // Activar deteccion de tendencia
bool Kernel = false;      // Activar Operaciones kernel
bool KernelMedio = false; // Activar Operaciones kernelMedio
bool MiIndicador = true;  // Activar Operacion Icustom
bool automatico = true;

string Separador7 = "---Cierre Según Profit---";

bool ResetProfit = true;
bool CerrarByProfit = true; // Cerrar si se alcanza meta
// input bool gananciaFija = false;//Desea Ganancia Fija
// input double NumGan = 10;// Profit Fijo
// input double NumPer = 10;// Maxima perdida permitida en %
// input double porCientoGan = 0.5;// profit en %
bool cerradoGlobal = false;
bool cerradoGlobalBuys = true;
bool cerradoGlobalSells = true;

// bool activarCuentaCompras = false;
// bool activarCuentaVentas = false;
int contarCompras = 0;
int contarVentas = 0;

int emaPeriodo = 0;
int FasterMA = 5;  // MA5 (la más rápida)
int FasterShift = 0;
int FasterMode = 2; // 0 = sma, 1 = ema, 2 = smma, 3 = lwma

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MediumMA = 8;  // MA8 (la media)
int MediumShift = 0;
int MediumMode = 2; // 0 = sma, 1 = ema, 2 = smma, 3 = lwma

// input SlowerMA    =   34;
int SlowerMA = 200;
int SlowerShift = 0;
int SlowerMode = 2; // 0 = sma, 1 = ema, 2 = smma, 3 = lwma

/*******************************************************************************/
int FastMA = 12;
int SlowMA = 26;
int SignalMA = 9;
int MAPeriod = 13;
int MAMethod = 1;
int MAAppliedPrice = 0;
int Line = 0;
int DigitsInc = 2;

/*******************************************************************************/

bool bandera = true;

/****************************************************************/
bool SARBuy = false;
bool SARSell = false;
bool MyMACDDown = false;
bool MyMACDUp = false;
bool FlechaBlueUp = false;
bool FlechaOrangeDown = false;
bool FlechaGreenUp = false;
bool FlechaRedDown = false;
bool firstTimeGreen = false;
bool firstTimeRed = false;
bool firstTimeBlue = false;
bool firstTimeOrange = false;
double puntoEntradaBajista;
double puntoEntradaAlcista;
bool firstTimeMACDDown = false;
bool firstTimeMACDUp = false;
bool downTrend = false;
bool upperTrend = false;
string myVolume = "myVolume";
string myProfit = "myProfit";
/**************************************************************/

/********Variables de la Interfaz Grafica*************/
bool btnComprar = false;
bool btnVender = false;
/****************************************************/
bool AplicarNextMartingala = false;

int hstTotal = 0;

int lastOrderNumber = 0;
int ordenestickes[];
int posicionTick = 1;

bool myFirstOrderPend = true;

// extern double porCientoPer = 2;

double fasterNow, fasterPre, mediumNow, mediumPre, slowerNow, slowerPre, myParabolic, myStochNow, myStochPre;
double fasterNow30, fasterNow60, fasterNowH4, fasterNowD1, fasterNowW1, fasterNowMN;

double incBuy = 0;
double incSell = 0;
double incBuyExtremo = 0;
double incSellExtremo = 0;

double equidadGuardada = 0;
double equidadGuardadaTemp = 0;

bool condicionExtrema = false;
bool primeraVez = true;

// Declaración del array
string arrayParName[30] = {"NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL"};

//////////////////////////////////////////////////////////////
// Variable para guardar el ultimo precio de la ultima operacion
double lastPrice[2] = {0, 0};
//////////////////////////////////////////////////////////////
// Variable para guardar la ultima perdida
int contadorPerdidasGlobales = 1;

// Variable Inicio de ciclo
bool comienzoOperacion = false;

// Operacion Ganada
bool operacionGanada = false;

int incrementadorPerdidas = 0;
// Variable para mover el arreglo de ordenes pendientes
int incrementadorOrdenPendiente = 0;
// Variable para fijar el tiempo en que se creo la operacion
datetime operationTime = 0;

// Variables para fijar el SL Buy and Sell (SEPARADAS)
double priceSLBuy = 0;
double priceSLSell = 0;

// Variables para fijar el TP Buy and Sell (SEPARADAS)
double priceTPBuy = 0;
double priceTPSell = 0;

// Variable para ver la perdida Mayor
double perdidaMayor = 0;

// Variable para ver el Flotante Mayor
double flotanteMayor = 0;

double balance = AccountBalance();

double flotanteMayorPercent = 0;
double perdidaMayorPercent = 0;

double highs[20];

// Crea arrays para guardar los últimos 2 valores de myArrowUP y myArrowDown
double last2Buys[2];
double last2Sells[2];

//Para hacer un arreglo y extraer el tamaño de vela promedio
double averageCandleLengths[200];
int currentLengthIndex = 0;

//Para checquear si se cumple la condicion1 y 2
bool estadoBuy = false;
bool estadoSell = false;

//Arreglos globales para guardar los valores de las flechas
double signalTypeBuy[20];  // Array para guardar si la señal es de compra
double signalTypeSell[20];  // Array para guardar si la señal es de venta
datetime signalTimeBuy[20];  // Array para guardar la hora de las señales de compra
datetime signalTimeSell[20];  // Array para guardar la hora de las señales de venta
double signal[40];  // Array para guardar las señales de compra y venta
double linePrices[25];  // Array para guardar los precios de las líneas

//two high prices buy
double highest, secondHighest;

//two low prices sell
double lowest, secondLowest;

//Array para guardar los open and close time
int openCloseTime[2];

// Dia mas alto y mas bajo
double actualHighestPrice = -1;
double actualLowestPrice = -1;
double anteriorHighestPrice = -1;
double anteriorLowestPrice = -1;
bool isRobotActive = true;

// Bandera para saber si se ha pasado la informacion
bool SeHaPasadoInformacion;

// Variable global para rastrear si la zona ya ha sido dibujada
bool zonaDibujada = false;

// Variable global para almacenar la fecha del último dibujo
datetime lastDrawDate = 0;

double automaticSLBuy;
double automaticSLSell;
double tempAutomaticSLBuy =-1;
double tempAutomaticSLSell =-1;
double openBuyPrice;
double openSellPrice;

// Varables para guardar los valores de los fvg
double highAlcista;
double lowAlcista;
double highBajista;
double lowBajista;

// Nuevas variables Globales
// ===== Umbrales del Stochastic =====


// ===== Banderas globales “de inicio” para tu setup base =====
// Se encienden cuando en algún tick se cumple la condición
bool CondicionBuy  = false;  // inicio BUY visto al menos una vez
bool CondicionSell = false;  // inicio SELL visto al menos una vez

// ===== Banderas globales del flujo Stochastic (Close/Close) =====
// BUY: ver >80 -> luego <20 -> salir por arriba de 20
// SELL: ver <20 -> luego >80 -> salir por abajo de 80
bool G_seenOB   = false;  // se vio sobrecompra
bool G_seenOS   = false;  // se vio sobreventa
bool G_obThenOs = false;  // tras OB llegó a OS (camino BUY)
bool G_osThenOb = false;  // tras OS llegó a OB (camino SELL)

// (Opcional) últimas señales completas detectadas (útiles para debug UI)
bool G_readyBuy  = false;
bool G_readySell = false;

// ===== Banderas globales para alineación de medias (OptimusHoraLoca) =====
bool G_mediasAlineadasBuy  = false;  // Las 3 medias están alineadas para BUY
bool G_mediasAlineadasSell = false;  // Las 3 medias están alineadas para SELL
bool G_stochBuyFlag        = false;  // Stochastic completó camino para BUY
bool G_stochSellFlag       = false;  // Stochastic completó camino para SELL
bool G_megaBuyFlag         = false;  // MEGA-BANDERA BUY (modo bandera persistente)
bool G_megaSellFlag        = false;  // MEGA-BANDERA SELL (modo bandera persistente)

// ===== Control de órdenes fantasma (bloqueadas) =====
bool G_phantomBuyDetected  = false;  // Se detectó un intento de BUY fantasma (bloqueado)
bool G_phantomSellDetected = false;  // Se detectó un intento de SELL fantasma (bloqueado)









//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {


// definir CantHorasEspera

   CantHorasEspera = Period();

//---
   Ticket = 0;
//---
   string client = NULL;

// Make sure the client is online in order to get his client name and account number
   if(IsConnected())
      client = AccountInfoString(ACCOUNT_NAME) + " / " + DoubleToStr(AccountInfoInteger(ACCOUNT_LOGIN), 0);
   LogEnPantalla("el cliente es " + client);

// All good...
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
// Eliminar objetos visuales al desmontar el EA
   ObjectDelete(0, "marketsafe_rect");
   ObjectDelete(0, "marketsafe_label");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Protección de drawdown antes de cualquier otra gestión
   CheckProteccionDrawdown();

// Protección de pérdidas acumuladas: cierre anticipado si recupera pérdidas + % extra
   if(proteccionPerdidas)
      ApplyProteccionPerdidas();

   ObjectDelete("obj_rect");
   ChartSetInteger(ChartID(), CHART_FOREGROUND, 0, false);
   ObjectCreate(ChartID(), "obj_rect", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_BACK, false);
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_XSIZE, 260);
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_YSIZE, 580);
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_XDISTANCE, 260);
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_YDISTANCE, 580);
//--- set background color
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_BGCOLOR, clrKhaki);
//--- set border type
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_BORDER_TYPE, BORDER_SUNKEN);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_COLOR, clrBlack);
//--- set flat border line style
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_STYLE, STYLE_SOLID);
//--- set flat border width
   ObjectSetInteger(ChartID(), "obj_rect", OBJPROP_WIDTH, 1);

   ObjectDelete("obj_rect_Precio");
   ChartSetInteger(ChartID(), CHART_FOREGROUND, 0, false);
   ObjectCreate(ChartID(), "obj_rect_Precio", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_BACK, false);
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_XSIZE, 260);
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_YSIZE, 50);
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_XDISTANCE, 260);
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_YDISTANCE, 50);
//--- set background color
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_BGCOLOR, clrWhite);
//--- set border type
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_BORDER_TYPE, BORDER_SUNKEN);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_COLOR, clrBlack);
//--- set flat border line style
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_STYLE, STYLE_SOLID);
//--- set flat border width
   ObjectSetInteger(ChartID(), "obj_rect_Precio", OBJPROP_WIDTH, 1);

   ObjectDelete("flotanteM");
   ObjectCreate("flotanteM", OBJ_LABEL, 0, 0, 0);
   ObjectSet("flotanteM", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("flotanteM", OBJPROP_XDISTANCE, 30);
   ObjectSet("flotanteM", OBJPROP_YDISTANCE, 540);
   ObjectSetText("flotanteM", DoubleToStr(flotanteMayor, 2) + " (" + DoubleToStr(flotanteMayorPercent, 2) + "%) F", 14, "Poppins", clrRed);

   ObjectDelete("perdidaM");
   ObjectCreate("perdidaM", OBJ_LABEL, 0, 0, 0);
   ObjectSet("perdidaM", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("perdidaM", OBJPROP_XDISTANCE, 30);
   ObjectSet("perdidaM", OBJPROP_YDISTANCE, 510);
   ObjectSetText("perdidaM", DoubleToStr(perdidaMayor, 2) + " (" + DoubleToStr(perdidaMayorPercent, 2) + "%) P", 14, "Poppins", clrRed);

   ObjectDelete("array9");
   ObjectCreate("array9", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array9", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array9", OBJPROP_XDISTANCE, 30);
   ObjectSet("array9", OBJPROP_YDISTANCE, 480);
   if(valorPerdidaArray(9) < 0)
      ObjectSetText("array9", IntegerToString(contadorPerdidaArray(9)) + " Perdidas " + NombreArray(9) + ": " + DoubleToStr(valorPerdidaArray(9), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(19) < 0)
         ObjectSetText("array9", IntegerToString(contadorPerdidaArray(19)) + " Perdidas " + NombreArray(19) + ": " + DoubleToStr(valorPerdidaArray(19), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array9", IntegerToString(contadorPerdidaArray(9)) + " Perdidas " + NombreArray(9) + ": " + DoubleToStr(valorPerdidaArray(9), 2), 10, "Poppins", clrGreen);

   ObjectDelete("array8");
   ObjectCreate("array8", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array8", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array8", OBJPROP_XDISTANCE, 30);
   ObjectSet("array8", OBJPROP_YDISTANCE, 450);
   if(valorPerdidaArray(8) < 0)
      ObjectSetText("array8", IntegerToString(contadorPerdidaArray(8)) + " Perdidas " + NombreArray(8) + ": " + DoubleToStr(valorPerdidaArray(8), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(18) < 0)
         ObjectSetText("array8", IntegerToString(contadorPerdidaArray(18)) + " Perdidas " + NombreArray(18) + ": " + DoubleToStr(valorPerdidaArray(18), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array8", IntegerToString(contadorPerdidaArray(8)) + " Perdidas " + NombreArray(8) + ": " + DoubleToStr(valorPerdidaArray(8), 2), 10, "Poppins", clrGreen);

   ObjectDelete("array7");
   ObjectCreate("array7", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array7", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array7", OBJPROP_XDISTANCE, 30);
   ObjectSet("array7", OBJPROP_YDISTANCE, 420);
   if(valorPerdidaArray(7) < 0)
      ObjectSetText("array7", IntegerToString(contadorPerdidaArray(7)) + " Perdidas " + NombreArray(7) + ": " + DoubleToStr(valorPerdidaArray(7), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(17) < 0)
         ObjectSetText("array7", IntegerToString(contadorPerdidaArray(17)) + " Perdidas " + NombreArray(17) + ": " + DoubleToStr(valorPerdidaArray(17), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array7", IntegerToString(contadorPerdidaArray(7)) + " Perdidas " + NombreArray(7) + ": " + DoubleToStr(valorPerdidaArray(7), 2), 10, "Poppins", clrGreen);

   ObjectDelete("array6");
   ObjectCreate("array6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array6", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array6", OBJPROP_XDISTANCE, 30);
   ObjectSet("array6", OBJPROP_YDISTANCE, 390);
   if(valorPerdidaArray(6) < 0)
      ObjectSetText("array6", IntegerToString(contadorPerdidaArray(6)) + " Perdidas " + NombreArray(6) + ": " + DoubleToStr(valorPerdidaArray(6), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(16) < 0)
         ObjectSetText("array6", IntegerToString(contadorPerdidaArray(16)) + " Perdidas " + NombreArray(16) + ": " + DoubleToStr(valorPerdidaArray(16), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array6", IntegerToString(contadorPerdidaArray(6)) + " Perdidas " + NombreArray(6) + ": " + DoubleToStr(valorPerdidaArray(6), 2), 10, "Poppins", clrGreen);

   ObjectDelete("array5");
   ObjectCreate("array5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array5", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array5", OBJPROP_XDISTANCE, 30);
   ObjectSet("array5", OBJPROP_YDISTANCE, 360);
   if(valorPerdidaArray(5) < 0)
      ObjectSetText("array5", IntegerToString(contadorPerdidaArray(5)) + " Perdidas " + NombreArray(5) + ": " + DoubleToStr(valorPerdidaArray(5), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(15) < 0)
         ObjectSetText("array5", IntegerToString(contadorPerdidaArray(15)) + " Perdidas " + NombreArray(15) + ": " + DoubleToStr(valorPerdidaArray(15), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array5", IntegerToString(contadorPerdidaArray(5)) + " Perdidas " + NombreArray(5) + ": " + DoubleToStr(valorPerdidaArray(5), 2), 10, "Poppins", clrGreen);

   ObjectDelete("array4");
   ObjectCreate("array4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array4", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array4", OBJPROP_XDISTANCE, 30);
   ObjectSet("array4", OBJPROP_YDISTANCE, 330);
   if(valorPerdidaArray(4) < 0)
      ObjectSetText("array4", IntegerToString(contadorPerdidaArray(4)) + " Perdidas " + NombreArray(4) + ": " + DoubleToStr(valorPerdidaArray(4), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(14) < 0)
         ObjectSetText("array4", IntegerToString(contadorPerdidaArray(14)) + " Perdidas " + NombreArray(14) + ": " + DoubleToStr(valorPerdidaArray(14), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array4", IntegerToString(contadorPerdidaArray(4)) + " Perdidas " + NombreArray(4) + ": " + DoubleToStr(valorPerdidaArray(4), 2), 10, "Poppins", clrGreen);

   ObjectDelete("array3");
   ObjectCreate("array3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array3", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array3", OBJPROP_XDISTANCE, 30);
   ObjectSet("array3", OBJPROP_YDISTANCE, 300);
   if(valorPerdidaArray(3) < 0)
      ObjectSetText("array3", IntegerToString(contadorPerdidaArray(3)) + " Perdidas " + NombreArray(3) + ": " + DoubleToStr(valorPerdidaArray(3), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(13) < 0)
         ObjectSetText("array3", IntegerToString(contadorPerdidaArray(13)) + " Perdidas " + NombreArray(13) + ": " + DoubleToStr(valorPerdidaArray(13), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array3", IntegerToString(contadorPerdidaArray(3)) + " Perdidas " + NombreArray(3) + ": " + DoubleToStr(valorPerdidaArray(3), 2), 10, "Poppins", clrGreen);

   ObjectDelete("array2");
   ObjectCreate("array2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array2", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array2", OBJPROP_XDISTANCE, 30);
   ObjectSet("array2", OBJPROP_YDISTANCE, 270);
   if(valorPerdidaArray(2) < 0)
      ObjectSetText("array2", IntegerToString(contadorPerdidaArray(2)) + " Perdidas " + NombreArray(2) + ": " + DoubleToStr(valorPerdidaArray(2), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(12) < 0)
         ObjectSetText("array2", IntegerToString(contadorPerdidaArray(12)) + " Perdidas " + NombreArray(12) + ": " + DoubleToStr(valorPerdidaArray(12), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array2", IntegerToString(contadorPerdidaArray(2)) + " Perdidas " + NombreArray(2) + ": " + DoubleToStr(valorPerdidaArray(2), 2), 10, "Poppins", clrGreen);

   ObjectDelete("array1");
   ObjectCreate("array1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array1", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array1", OBJPROP_XDISTANCE, 30);
   ObjectSet("array1", OBJPROP_YDISTANCE, 240);
   if(valorPerdidaArray(1) < 0)
      ObjectSetText("array1", IntegerToString(contadorPerdidaArray(1)) + " Perdidas " + NombreArray(1) + ": " + DoubleToStr(valorPerdidaArray(1), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(11) < 0)
         ObjectSetText("array1", IntegerToString(contadorPerdidaArray(11)) + " Perdidas " + NombreArray(11) + ": " + DoubleToStr(valorPerdidaArray(1), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array1", IntegerToString(contadorPerdidaArray(1)) + " Perdidas " + NombreArray(1) + ": " + DoubleToStr(valorPerdidaArray(1), 2), 10, "Poppins", clrGreen);

   ObjectDelete("array0");
   ObjectCreate("array0", OBJ_LABEL, 0, 0, 0);
   ObjectSet("array0", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("array0", OBJPROP_XDISTANCE, 30);
   ObjectSet("array0", OBJPROP_YDISTANCE, 210);
   if(valorPerdidaArray(0) < 0)
      ObjectSetText("array0", IntegerToString(contadorPerdidaArray(0)) + " Perdidas " + NombreArray(0) + ": " + DoubleToStr(valorPerdidaArray(0), 2), 10, "Poppins", clrRed);
   else
      if(valorPerdidaArray(10) < 0)
         ObjectSetText("array0", IntegerToString(contadorPerdidaArray(10)) + " Perdidas " + NombreArray(10) + ": " + DoubleToStr(valorPerdidaArray(10), 2), 10, "Poppins", clrRed);
      else
         ObjectSetText("array0", IntegerToString(contadorPerdidaArray(0)) + " Perdidas " + NombreArray(0) + ": " + DoubleToStr(valorPerdidaArray(0), 2), 10, "Poppins", clrGreen);

   ObjectDelete("sell");
   ObjectCreate("sell", OBJ_LABEL, 0, 0, 0);
   ObjectSet("sell", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("sell", OBJPROP_XDISTANCE, 30);
   ObjectSet("sell", OBJPROP_YDISTANCE, 180);
   ObjectSetText("sell", "Proximo lotaje: " + DoubleToStr(CalcularProximoLotaje(), 2), 10, "Poppins", Black);

   ObjectDelete("abiertas");
   ObjectCreate("abiertas", OBJ_LABEL, 0, 0, 0);
   ObjectSet("abiertas", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("abiertas", OBJPROP_XDISTANCE, 30);
   ObjectSet("abiertas", OBJPROP_YDISTANCE, 150);
   ObjectSetText("abiertas", "Equidad: " + DoubleToStr(AccountEquity(), 3), 10, "Poppins", Black);

   ObjectDelete("perdidaAcumulada");
   ObjectCreate("perdidaAcumulada", OBJ_LABEL, 0, 0, 0);
   ObjectSet("perdidaAcumulada", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("perdidaAcumulada", OBJPROP_XDISTANCE, 30);
   ObjectSet("perdidaAcumulada", OBJPROP_YDISTANCE, 120);
   ObjectSetText("perdidaAcumulada", "Perdida Acumulada: " + DoubleToStr(perdidaAcumulada(), 3), 10, "Poppins", Black);

   ObjectDelete("gananciaBuy");
   ObjectCreate("gananciaBuy", OBJ_LABEL, 0, 0, 0);
   ObjectSet("gananciaBuy", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("gananciaBuy", OBJPROP_XDISTANCE, 30);
   ObjectSet("gananciaBuy", OBJPROP_YDISTANCE, 90);
   if(EquityByBuy() < 0)
     {
      ObjectSetText("gananciaBuy", "Perdida BUY: " + DoubleToStr(EquityByBuy(), 3), 10, "Poppins", clrRed);
     }
   else
      if(EquityByBuy() > 0)
        {
         ObjectSetText("gananciaBuy", "Ganancia BUY: " + DoubleToStr(EquityByBuy(), 3), 10, "Poppins", clrGreen);
        }
      else
        {
         ObjectSetText("gananciaBuy", "Ganancia BUY: " + DoubleToStr(EquityByBuy(), 3), 10, "Poppins", clrBlueViolet);
        }

   ObjectDelete("gananciaSell");
   ObjectCreate("gananciaSell", OBJ_LABEL, 0, 0, 0);
   ObjectSet("gananciaSell", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("gananciaSell", OBJPROP_XDISTANCE, 30);
   ObjectSet("gananciaSell", OBJPROP_YDISTANCE, 60);
   if(EquityBySell() < 0)
     {
      ObjectSetText("gananciaSell", "Perdida SELL: " + DoubleToStr(EquityBySell(), 3), 10, "Poppins", clrRed);
     }
   else
      if(EquityBySell() > 0)
        {
         ObjectSetText("gananciaSell", "Ganancia SELL: " + DoubleToStr(EquityBySell(), 3), 10, "Poppins", clrGreen);
        }
      else
        {
         ObjectSetText("gananciaSell", "Ganancia SELL: " + DoubleToStr(EquityBySell(), 3), 10, "Poppins", clrBlueViolet);
        }

   ObjectDelete("gananciaPar");
   ObjectCreate("gananciaPar", OBJ_LABEL, 0, 0, 0);
   ObjectSet("gananciaPar", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet("gananciaPar", OBJPROP_XDISTANCE, 30);
   ObjectSet("gananciaPar", OBJPROP_YDISTANCE, 5);
   ObjectSetText("gananciaPar", "Balance: " + DoubleToStr(AccountBalance(), 3), 14, "Poppins", clrGreen);



   if(useTime)
     {
      GetActiveHours(Symbol());

      // Verificar si estamos dentro del rango de días activos
      if(DayOfWeek() >= StartDay && DayOfWeek() <= EndDay)
        {
         // Verificar si estamos dentro del rango de horas activas
         if(openCloseTime[0] < openCloseTime[1])
           {
            if(Hour() >= openCloseTime[0] && Hour() < openCloseTime[1])
              {
               Weekend = false;
               CloseAll = false;
              }
            else
              {
               // Si estamos fuera del rango de horas activas, marcar como fin de semana
               Weekend = true;
              }
           }
         else
           {
            if(Hour() >= openCloseTime[0] || Hour() < openCloseTime[1])
              {
               Weekend = false;
               CloseAll = false;
              }
            else
              {
               // Si estamos fuera del rango de horas activas, marcar como fin de semana
               Weekend = true;
              }
           }

        }
      else
        {
         // Si estamos fuera del rango de días activos, marcar como fin de semana
         Weekend = true;
        }
     }
   else
     {
      Weekend = false;
     }


//LlegoMeta();
   if(usarNotificacionDia)
     {

      //SetLotSize();
      agregarParNameToArray();
      perdidaFlotante();
      mayorPerdida();



      if(!HayOrdenesBuy() && !HayOrdenesSell())
        {
         primeraVez = true;
         condicionExtrema = false;
        }

      if(Weekend == true)
        {

         if(usarNotificacionDia)
           {
            Comment("Fuera de Horario");
            detectarSenal();
            //CloseAllBuyStops();
            //CloseAllSellStops();
            //CloseAllBuyLimits();
            // CloseAllSellLimits();
            // CerrarSiLLegoaSL();
            // CerrarSiLLegoaTP();
           }

         if(!SeHaPasadoInformacion)
           {
            HandleEndOfWorkHours();
            SeHaPasadoInformacion = true;
           }
        }
      else
        {
         string horarioTrabajo = "Horario de Trabajo\n";
         string horaInicioCierre = "Hora de inicio: " + IntegerToString(openCloseTime[0]) + " Hora de cierre: " + IntegerToString(openCloseTime[1]);
         Comment(horarioTrabajo + horaInicioCierre);

         datetime currentDate = TimeCurrent();
         // Convertir currentDate a UTC (si no está ya en UTC)
         datetime currentDateUTC = currentDate - (TimeGMTOffsetMio() * 3600);

         datetime currentDay = currentDateUTC - (TimeHour(currentDateUTC) * 3600 + TimeMinute(currentDateUTC) * 60 + TimeSeconds(currentDateUTC));

         datetime workStartTime = currentDay + openCloseTime[0] * 3600;

         // Eliminar el objeto TimeZone si existe (limpiar cuadro azul antiguo)
         ObjectDelete(0, "TimeZone");

         if(Weekend == false)
           {
            UpdateHighLowPrices();
            SeHaPasadoInformacion = false;
           }

         fvgExtremo();
         CerrarSiLLegoaSL();
         CerrarSiLLegoaTP();

         // Cierre por estocástico (opcional)
         if(usarCierrePorEstocastico)
           {
            cierreEstocasticoBuy();
            cierreEstocasticoSell();
           }

         //BorrarOrdenesSiUnaCreada();
         //cerrarContrariasPorMedia200(); // COMENTADO: No cerrar automáticamente por cruce de media200
         //cerrarSiSeFueEnContra();
         //CerrarSiApareceFlechaContraria();

         if(useTS)
           {
            MyTrailingStop();
           }

         if(useBreakevenStop)
           {
            MyBreakevenStop();
           }

         if(useMA200Exit)
           {
            CheckMA200Exit();
           }

         // Verificar scalping agresivo
         CheckScalpingAgresivo();

         // COMENTADO: Ahora 'martingala' es un input controlado por el usuario
         // La lógica de racha mala funciona desde la primera pérdida si martingala=true
         /*
         if(contadorPerdidas()>= cuandoUsarMartingala)
           {
            martingala = true;
           }
         else
           {
            martingala = false;
           }
         */

         // MODIFICADO: Permitir crear órdenes si hay menos de 2 (para compra y venta simultáneas)
         if(Weekend == false && (ContadordeBuys() + ContadordeSells() < 2))
           {
            CrearOrdenes();
           }
        }



      if(ChecaLibro() > 0)  // Si hay ordenes Abiertas, Busco cerrarla
        {

         if(automatico = true)
           {
            if(salidaAutomatica)
              {
              }
           }
        }
      else // No hay ordenes Abiertas por este Expert, asi que podemos buscar señal
        {
        }

      if(ChecaHistory() > 0)  // Si hay Ordenes Cerradas, veo si dieron profit o no
        {
        }
     }
   else
     {
      Comment("Detenido por llegar a profit");
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// Codigo del Indicador                                               +
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cerrarSiSeFueEnContra()
  {
   if(VerificarOperacionEnContraAvanzada() == 1)
     {
      LogEnPantalla("Movimiento Contrario detectado Buy");
      Print(">>> LLAMANDO CloseAllBuys() desde: Movimiento Contrario (línea ~1646)");
      CloseAllBuys();
     }
   else
      if(VerificarOperacionEnContraAvanzada() == 2)
        {
         LogEnPantalla("Movimiento Contrario detectado Sell");
         CloseAllSells();
        }
  }


// Detecta una vela de cuerpo pequeño con mecha larga en dirección favorable
bool EsDojiConRechazoAFavor(int velaIdx, int tipo)
  {
   double open = Open[velaIdx];
   double close = Close[velaIdx];
   double high = High[velaIdx];
   double low = Low[velaIdx];
   double cuerpo = MathAbs(open - close);
   double rango = high - low;

   if(rango == 0)
      return false;

   double ratioCuerpo = cuerpo / rango;
   double mechaAFavor = 0;

   if(tipo == OP_BUY)
      mechaAFavor = MathMin(open, close) - low; // Mecha inferior
   else
      if(tipo == OP_SELL)
         mechaAFavor = high - MathMax(open, close); // Mecha superior

   double ratioRechazo = mechaAFavor / rango;

   LogEnPantalla("   → Eval vela "  + DoubleToString(velaIdx, 2) + " | cuerpo: " + DoubleToString(cuerpo, 2)   + " rango: " + DoubleToString(rango, 2) +
                 " ratioCuerpo: " + DoubleToString(ratioCuerpo, 2)  + " ratioRechazo: " + DoubleToString(ratioRechazo, 2));

   return (ratioCuerpo < DojiRatio && ratioRechazo > RechazoMinimo);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool esTendenciaMayorAlcista()
  {
   double emaFast = iMA(NULL, PERIOD_M15, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaSlow = iMA(NULL, PERIOD_M15, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   return emaFast > emaSlow;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool esTendenciaMayorBajista()
  {
   double emaFast = iMA(NULL, PERIOD_M15, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaSlow = iMA(NULL, PERIOD_M15, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   return emaFast < emaSlow;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MostrarEstadoBot(string linea1 = "", string linea2 = "", string linea3 = "", string linea4 = "")
  {
// Función desactivada - no mostrar texto
   Comment("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MostrarEstadoBotExtendido(string linea1 = "", string linea2 = "", string linea3 = "", string linea4 = "", string linea5 = "", string linea6 = "", string linea7 = "", string linea8 = "", string linea9 = "", string linea10 = "")
  {
// Función desactivada - no mostrar texto
   Comment("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int VerificarOperacionEnContraAvanzada()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            int tipo = OrderType();
            datetime openTime = OrderOpenTime();
            int openShift = iBarShift(NULL, 0, openTime, false);

            if(openShift <= 3)
               return 3;

            int enContra = 0;
            int aFavor = 0;
            int doji = 0;

            for(int j = openShift - 1; j >= openShift - 3; j--)
              {
               double open = iOpen(NULL, 0, j);
               double close = iClose(NULL, 0, j);
               double high = iHigh(NULL, 0, j);
               double low = iLow(NULL, 0, j);
               double body = MathAbs(close - open);
               double range = high - low;

               bool esDoji = body < (range * 0.2);
               bool velaContraria = false;
               bool velaAFavor = false;
               bool envolvente = false;

               if(tipo == OP_BUY)
                 {
                  velaContraria = close < open && body > (range * 0.5);
                  velaAFavor = close > open && body > (range * 0.5);

                  if(j < Bars - 2)
                    {
                     double prevOpen = iOpen(NULL, 0, j + 1);
                     double prevClose = iClose(NULL, 0, j + 1);
                     if(close < open && open >= prevClose && close <= prevOpen)
                        envolvente = true;
                    }
                 }

               if(tipo == OP_SELL)
                 {
                  velaContraria = close > open && body > (range * 0.5);
                  velaAFavor = close < open && body > (range * 0.5);

                  if(j < Bars - 2)
                    {
                     double prevOpen = iOpen(NULL, 0, j + 1);
                     double prevClose = iClose(NULL, 0, j + 1);
                     if(close > open && open <= prevClose && close >= prevOpen)
                        envolvente = true;
                    }
                 }

               if(esDoji)
                  doji++;
               else
                  if(velaContraria)
                     enContra++;
                  else
                     if(velaAFavor)
                        aFavor++;

               // Visual
               if(velaContraria)
                 {
                  string name = "Reversa_" + IntegerToString(j) + "_" + IntegerToString(i);
                  ObjectCreate(name, OBJ_ARROW, 0, Time[j], tipo == OP_BUY ? High[j] + Point * 10 : Low[j] - Point * 10);
                  ObjectSetInteger(0, name, OBJPROP_ARROWCODE, tipo == OP_BUY ? 234 : 233);
                  ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);
                 }

               if(envolvente)
                 {
                  LogEnPantalla("🚨 Cierre por envolvente contraria");
                  return tipo == OP_BUY ? 1 : 2;
                 }
              }

            // Nueva condición: 1 vela en contra + 1 doji
            if(enContra == 1 && doji == 1)
              {
               LogEnPantalla("⚠️ 1 vela en contra + doji. Cierre anticipado.");
               return tipo == OP_BUY ? 1 : 2;
              }

            // Condición estándar
            if(enContra >= 2)
              {
               LogEnPantalla("🔴 Se detectaron " + IntegerToString(enContra) + " velas en contra.");
               return tipo == OP_BUY ? 1 : 2;
              }

            // Mostrar estado neutral
            LogEnPantalla(
               "✅ Operación sigue abierta"+
               "Tipo: " + (tipo == OP_BUY ? "BUY" : "SELL")+
               "Velas en contra: " + IntegerToString(enContra)+
               "Dojis: " + IntegerToString(doji)
            );
           }
        }
     }

   return 3; // No hay operación o condiciones no se cumplen para cierre
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CerrarSiApareceFlechaContraria()
  {
   int i=0;


   CondicionBuy = highAlcista != EMPTY_VALUE && lowAlcista != EMPTY_VALUE;
   CondicionSell = highBajista != EMPTY_VALUE && lowBajista != EMPTY_VALUE;


   for(int y = 0; y < OrdersTotal(); y++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            if(OrderType() == OP_BUY && OrderProfit() < 0 && CondicionSell)
              {
               Print(">>> LLAMANDO CloseAllBuys() desde: BUY con pérdida + CondicionSell (línea ~1864)");
               CloseAllBuys();
              }

            else
               if(OrderType() == OP_SELL && OrderProfit() < 0 && CondicionBuy)
                 {
                  CloseAllSells();
                 }
           }
        }
     }





  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BorrarOrdenesSiUnaCreada()
  {

// Comprueba si hay exactamente una orden de compra o venta
   if(ContadordeBuys() == 1 || ContadordeSells() == 1)
     {
      // Ejecuta las funciones para cerrar las órdenes pendientes
      //CloseAllBuyStops();
      //CloseAllSellStops();
      CloseAllBuyLimits();
      CloseAllSellLimits();
      LogEnPantalla("Eliminando porque ya hay un sell o un buy");
     }


  }

// ===== Resets para llamar cuando cierres operación =====
void ResetBuyFlags()
  {


   CondicionBuy = false;
   G_seenOB = false;
   G_obThenOs = false;
   G_readyBuy = false;
// Resetear banderas de alineación
   G_mediasAlineadasBuy = false;
   G_stochBuyFlag = false;
// Resetear FVG alcista cuando se ejecuta orden BUY
   highAlcista = EMPTY_VALUE;
   lowAlcista = EMPTY_VALUE;


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetSellFlags()
  {


   CondicionSell = false;
   G_seenOS = false;
   G_osThenOb = false;
   G_readySell = false;
// Resetear banderas de alineación
   G_mediasAlineadasSell = false;
   G_stochSellFlag = false;
// Resetear FVG bajista cuando se ejecuta orden SELL
   highBajista = EMPTY_VALUE;
   lowBajista = EMPTY_VALUE;


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetAllFlags()
  {
   ResetBuyFlags();
   ResetSellFlags();
  }

//+------------------------------------------------------------------+
//| Detectar vela grande para evitar operar en velas fuertes        |
//+------------------------------------------------------------------+
bool EsVelaGrande(int velaIndex = 0)
  {
// Calcular el rango promedio de las últimas 20 velas
   double promedioRango = 0;
   for(int i = 1; i <= 20; i++)
     {
      promedioRango += (High[i] - Low[i]);
     }
   promedioRango = promedioRango / 20;

// Calcular el rango de la vela actual
   double rangoActual = High[velaIndex] - Low[velaIndex];

// Método 1: Si el rango actual es más del 300% del promedio (menos restrictivo)
   bool esGrandePorPromedio = (rangoActual > promedioRango * 3.0);

// Método 2: Si el rango actual es mayor a 3000 pips (umbral fijo para oro)
   bool esGrandePorUmbral = (rangoActual > 3000.0 * Point);

// Es grande si cumple cualquiera de los dos criterios
   bool esGrande = esGrandePorPromedio || esGrandePorUmbral;

// Debug detallado cada vez que se evalúa

   return esGrande;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyBreakevenStop()
  {
   int NumeroDeOrdenes = OrdersTotal(); // cantidad de ordenes total en el libro
   double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point; // Nivel mínimo de stop permitido por el broker

// Distancia en pips para activar el breakeven
   double breakevenDistancePips = breakevenDistance;
// Pérdida en pips para el breakeven (negativo = pequeña pérdida)
   double breakevenLossPipsValue = breakevenLossPips;

   for(int i = 0; i < NumeroDeOrdenes; i++)  // Revisa todas las órdenes abiertas
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)  // Selecciona la orden y verifica condiciones
        {
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
           {
            if(OrderType() == OP_BUY)
              {
               // Breakeven para Buy: mover SL a precio de apertura - breakevenLossPips cuando esté a favor por breakevenDistance pips
               double profitInPips = (Bid - OrderOpenPrice()) / Point;
               double breakevenPrice = OrderOpenPrice() - (breakevenLossPipsValue * Point); // Precio de apertura - pérdida configurada
               if(profitInPips >= breakevenDistancePips && OrderStopLoss() < breakevenPrice)
                 {
                  double newStopLoss = breakevenPrice;

                 }
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  // Breakeven para Sell: mover SL a precio de apertura + breakevenLossPips cuando esté a favor por breakevenDistance pips
                  double profitInPips = (OrderOpenPrice() - Ask) / Point;
                  double breakevenPrice = OrderOpenPrice() + (breakevenLossPipsValue * Point); // Precio de apertura + pérdida configurada
                  if(profitInPips >= breakevenDistancePips && (OrderStopLoss() > breakevenPrice || OrderStopLoss() == 0))
                    {
                     double newStopLoss = breakevenPrice;

                    }
                 }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Calcula la tendencia de una media móvil                          |
//+------------------------------------------------------------------+
int CalcularTendenciaMA(int periodo, int barrasLookback)
  {
// Pendiente en pips/barra con umbral para considerar lateralidad
   int lb = MathMax(2, barrasLookback);
   double ma_actual = iMA(NULL, 0, periodo, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ma_anterior = iMA(NULL, 0, periodo, 0, MODE_SMA, PRICE_CLOSE, 1 + lb);

   double slopePipsPerBar = (ma_actual - ma_anterior) / (lb * Point);

// Elegir umbral según la MA
   double umbral = pendienteMinPipsPorBarra; // default (MA larga)
   if(periodo == periodoMACorta || periodo == 50)
      umbral = pendienteMinPipsPorBarraMA50;

   if(slopePipsPerBar > umbral)
      return 1; // Alcista
   else
      if(slopePipsPerBar < -umbral)
         return -1; // Bajista
      else
         return 0; // Lateral (gris)
  }

//+------------------------------------------------------------------+
//| Cierra operaciones si barra completa cierra del otro lado MA200 |
//+------------------------------------------------------------------+
void CheckMA200Exit()
  {
// Obtener la MA200 de la barra anterior (barra completa cerrada)
   double ma200_1 = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 1);

// Precios de la barra anterior (índice 1 = última barra cerrada)
   double open_1 = iOpen(NULL, 0, 1);
   double close_1 = iClose(NULL, 0, 1);
   double high_1 = iHigh(NULL, 0, 1);
   double low_1 = iLow(NULL, 0, 1);

   int NumeroDeOrdenes = OrdersTotal();

   for(int i = NumeroDeOrdenes - 1; i >= 0; i--)  // Recorrer desde el final para evitar problemas al cerrar
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType() == OP_BUY)
           {
            // Para BUY: cerrar si la barra completa cerró por debajo de MA200
            // Verificamos que toda la barra (apertura y cierre) esté por debajo de MA200
            if(close_1 < ma200_1 && open_1 < ma200_1)
              {
               // Cerrar la operación BUY
               Print("🔴🔴🔴 BUY CERRADO POR CheckMA200Exit() | Precio cruzó debajo de MA200");
               bool result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 10, clrOrange);

              }
           }
         else
            if(OrderType() == OP_SELL)
              {
               // Para SELL: cerrar si la barra completa cerró por encima de MA200
               // Verificamos que toda la barra (apertura y cierre) esté por encima de MA200
               if(close_1 > ma200_1 && open_1 > ma200_1)
                 {
                  // LOG: Identificar que CheckMA200Exit está cerrando
                  LogEnPantalla("🔴🔴🔴 SELL CERRADO POR CheckMA200Exit() - Barra cerró encima de MA200");
                  Print("🔴🔴🔴 SELL CERRADO POR CheckMA200Exit() | Ticket: ", OrderTicket(), " | Close:", close_1, " > MA200:", ma200_1);
                  // Cerrar la operación SELL
                  bool result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 10, clrOrange);

                 }
              }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyTrailingStop()
  {
   int NumeroDeOrdenes = OrdersTotal(); // cantidad de ordenes total en el libro
   double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point; // Nivel mínimo de stop permitido por el broker

// Distancia mínima en pips para activar el trailing stop
   double minDistancePips = minDistanceToActivateTS;

// Pips que se mueve el SL inicialmente
   double initialMovePips = initialTSMove;

   for(int i = 0; i < NumeroDeOrdenes; i++)  // Revisa todas las órdenes abiertas
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)  // Selecciona la orden y verifica condiciones
        {
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
           {
            if(OrderType() == OP_BUY)
              {
               // Trailing stop inteligente para Buy
               double profitInPips = (Bid - OrderOpenPrice()) / Point;
               double currentSLInPips = (OrderStopLoss() - OrderOpenPrice()) / Point;

               // Solo procesar si está a favor por la distancia mínima
               if(profitInPips >= minDistancePips)
                 {
                  double newStopLoss;

                  // Si es la primera vez que se activa el trailing stop
                  if(currentSLInPips < 0) // SL inicial está en pérdida
                    {
                     // Mover SL inicialmente por initialMovePips
                     newStopLoss = OrderOpenPrice() + (initialMovePips * Point);
                    }
                  else
                    {
                     // A partir de aquí, mover SL en cada tick SIEMPRE que el precio vaya a favor
                     // Calcular nuevo SL basado en el precio actual
                     double proposedNewSL = Bid - (minDistancePips * Point); // Mantener distancia fija del precio actual

                     // Solo mover si el nuevo SL está más arriba que el actual (precio subió)
                     if(proposedNewSL > OrderStopLoss())
                       {
                        newStopLoss = proposedNewSL;
                       }
                     else
                       {
                        // Precio bajó, mantener SL estático
                        return; // No hacer nada, mantener SL actual
                       }
                    }

                  // Verificar distancia mínima del broker y modificar
                  if((Bid - newStopLoss) >= StopLevel)
                    {
                     if(!OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, Green))
                        return;
                    }
                 }
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  // Trailing stop inteligente para Sell
                  double profitInPips = (OrderOpenPrice() - Ask) / Point;
                  double currentSLInPips = (OrderOpenPrice() - OrderStopLoss()) / Point;

                  // Solo procesar si está a favor por la distancia mínima
                  if(profitInPips >= minDistancePips)
                    {
                     double newStopLoss;

                     // Si es la primera vez que se activa el trailing stop
                     if(currentSLInPips < 0 || OrderStopLoss() == 0) // SL inicial está en pérdida o no existe
                       {
                        // Mover SL inicialmente por initialMovePips
                        newStopLoss = OrderOpenPrice() - (initialMovePips * Point);
                       }
                     else
                       {
                        // A partir de aquí, mover SL en cada tick SIEMPRE que el precio vaya a favor
                        // Calcular nuevo SL basado en el precio actual
                        double proposedNewSL = Ask + (minDistancePips * Point); // Mantener distancia fija del precio actual

                        // Solo mover si el nuevo SL está más abajo que el actual (precio bajó)
                        if(proposedNewSL < OrderStopLoss())
                          {
                           newStopLoss = proposedNewSL;
                          }
                        else
                          {
                           // Precio subió, mantener SL estático
                           return; // No hacer nada, mantener SL actual
                          }
                       }

                     // Verificar distancia mínima del broker y modificar
                     if((newStopLoss - Ask) >= StopLevel)
                       {
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, Red))
                           return;
                       }
                    }
                 }
           }
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeGMTOffsetMio()
  {
// Obtener la hora local
   datetime localTime = TimeLocal();
// Obtener la hora del servidor
   datetime serverTime = TimeCurrent();
// Calcular el desfase horario en segundos
   int offset = (int)(localTime - serverTime);
// Convertir el desfase horario a horas
   return offset / 3600;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateHighLowPrices()
  {
   if(isRobotActive)
     {
      if(Bid > actualHighestPrice)
        {
         actualHighestPrice = Bid;
        }
      if(Bid < actualLowestPrice || actualLowestPrice == -1)
        {
         actualLowestPrice = Bid;
        }
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HandleEndOfWorkHours()
  {
   anteriorHighestPrice = actualHighestPrice;
   anteriorLowestPrice = actualLowestPrice;
   actualHighestPrice = -1;
   actualLowestPrice = -1;
   /*  DrawHLineTP(anteriorHighestPrice);
    DrawHLineSL(anteriorLowestPrice); */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BorrarLineaNadaAbierto()
  {
   if((ContadordeBuys() == 0 && ContadordeSells() == 0)&&(ContadordeBuysStop() == 0 && ContadordeSellsStop() == 0))
     {
      BorrarSL();
      BorrarTP();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CerrarSiLLegoaSL()
  {
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY)

           {
            if(Bid < priceSLBuy)
              {
               Print(">>> CerrarSiLLegoaSL() BUY | Bid=", Bid, " | priceSLBuy=", priceSLBuy, " | Diferencia:", (priceSLBuy - Bid) / Point, " pips | SL ALCANZADO!");

               operacionGanada = false;
               incrementadorPerdidas++;
               contadorPerdidasGlobales++;

               Print(">>> LLAMANDO CloseAllBuys() desde: CerrarSiLLegoaSL() - BUY llegó a SL (línea ~2311)");
               CloseAllBuys();
               resetValues();
               ResetBuyFlags();
               // Resetear MEGA-BANDERA BUY
               G_megaBuyFlag = false;

              }
           }

         if(OrderType() == OP_SELL)
           {
            if(Ask > priceSLSell)
              {
               LogEnPantalla("🔴🔴🔴 SELL CERRADO POR CerrarSiLLegoaSL() - SL alcanzado");
               Print("🔴🔴🔴 SELL CERRADO POR SL | Ask:", Ask, " > priceSLSell:", priceSLSell);
               operacionGanada = false;
               incrementadorPerdidas++;
               contadorPerdidasGlobales++;
               CloseAllSells();
               resetValues();
               ResetSellFlags();
               // Resetear MEGA-BANDERA SELL
               G_megaSellFlag = false;
              }
           }
        }

  }

// -------------------------------------------------------------------
// Helpers globales (pega esto en el área global de tu EA)
// Stochastic %K (Close/Close), método SMA, 8-3-3 como en tu estrategia
double StochK(int shift)
  {
   return iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, shift);
  }

// Cruce hacia ARRIBA de un nivel (entre vela [2] y vela [1] cerradas)
bool CrossUp(double level)
  {
   double kPrev = StochK(2);
   double kNow  = StochK(1);
   return (kPrev < level && kNow >= level);
  }

// Cruce hacia ABAJO de un nivel (entre vela [2] y vela [1] cerradas)
bool CrossDown(double level)
  {
   double kPrev = StochK(2);
   double kNow  = StochK(1);
   return (kPrev > level && kNow <= level);
  }
// -------------------------------------------------------------------


// -------------------------------------------------------------------
// Cierre por estocástico: cerrar BUYS si el estocástico entra a sobreventa
// Lógica corregida: Si hay un BUY activo y el estocástico entra en sobreventa,
// significa que aún no está listo para subir, debemos cerrar
void cierreEstocasticoBuy()
  {
// DEBUG: Logs de debugging
   double kNow = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 1);
   double kPrev = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 2);
   int totalBuys = ContadordeBuys();

// NUEVA LÓGICA: Verificar si el estocástico ESTÁ en sobreventa (no solo cruza)
// Si ya cruzó y ahora está en sobreventa, cerramos
   bool conditionEnSobreventa = (kNow < OSLevel); // Está en sobreventa (menor que 10)
   bool conditionHasBuys = totalBuys > 0;


// Cerrar por estocástico independientemente del estado de useTS
   if(conditionEnSobreventa && conditionHasBuys)
     {
      LogEnPantalla("Cerrando BUY porque el estocástico está en sobreventa");
      Print(">>> LLAMANDO CloseAllBuys() desde: cierreEstocasticoBuy() - Estocástico en sobreventa (línea ~2388)");
      CloseAllBuys();
      ResetBuyFlags();
     }
   else
     {

     }

  }

// Cierre por estocástico: cerrar SELLS si el estocástico entra a sobrecompra
// Lógica corregida: Si hay un SELL activo y el estocástico entra en sobrecompra,
// significa que aún no está listo para bajar, debemos cerrar
void cierreEstocasticoSell()
  {
// DEBUG: Logs de debugging
   double kNow = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 1);
   double kPrev = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 2);
   int totalSells = ContadordeSells();

// NUEVA LÓGICA: Verificar si el estocástico ESTÁ en sobrecompra (no solo cruza)
// Si ya cruzó y ahora está en sobrecompra, cerramos
   bool conditionEnSobrecompra = (kNow > OBLevel); // Está en sobrecompra (mayor que 90)
   bool conditionHasSells = totalSells > 0;



// Cerrar por estocástico independientemente del estado de useTS
   if(conditionEnSobrecompra && conditionHasSells)
     {
      LogEnPantalla("🔴🔴🔴 SELL CERRADO POR cierreEstocasticoSell() - Estocástico en sobrecompra");
      Print("🔴🔴🔴 SELL CERRADO POR ESTOCASTICO | kNow:", kNow, " > OBLevel:", OBLevel);
      CloseAllSells();
      ResetSellFlags();
     }
   else
     {

     }

  }
// -------------------------------------------------------------------


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CerrarSiLLegoaTP()
  {

   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY)
           {
            if(Bid > priceTPBuy)
              {


               LogEnPantalla("Cerrando por TP");
               CloseAllBuys();
               resetValues();
               ResetBuyFlags();
               // Resetear MEGA-BANDERA BUY
               G_megaBuyFlag = false;
              }
           }

         if(OrderType() == OP_SELL)
           {
            if(Ask < priceTPSell)
              {
               LogEnPantalla("🔴🔴🔴 SELL CERRADO POR CerrarSiLLegoaTP() - TP alcanzado");
               Print("🔴🔴🔴 SELL CERRADO POR TP | Ask:", Ask, " < priceTPSell:", priceTPSell);
               CloseAllSells();
               resetValues();
               ResetSellFlags();
               // Resetear MEGA-BANDERA SELL
               G_megaSellFlag = false;
              }
           }
        }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cerrarSiTimeOver()
  {
   if(TimeCurrent() > operationTime + 10 * 60 && operationTime != 0)
     {
      if(ContadordeSellsStop() == 2 || ContadordeBuysStop() == 2)
        {
         incrementadorPerdidas++;
         CloseAllBuys();
         CloseAllSells();
        }
     }
  }

// Para resetear el array sumador de perdidas

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool trendBuy()
  {
   double PriceWhite = iMA(NULL, 0, FasterMA, FasterShift, FasterMode, PRICE_CLOSE, 0);
   double PriceGreen = iMA(NULL, 0, MediumMA, MediumShift, MediumMode, PRICE_CLOSE, 0);
   double PriceRed = iMA(NULL, 0, SlowerMA, SlowerShift, SlowerMode, PRICE_CLOSE, 0);
   double myRSI = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);

   if(PriceGreen > PriceRed && PriceWhite > PriceRed && myRSI > 50)
     {
      return true;
     }
   else
      return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool trendSell()
  {
   double PriceWhite = iMA(NULL, 0, FasterMA, FasterShift, FasterMode, PRICE_CLOSE, 0);
   double PriceGreen = iMA(NULL, 0, MediumMA, MediumShift, MediumMode, PRICE_CLOSE, 0);
   double PriceRed = iMA(NULL, 0, SlowerMA, SlowerShift, SlowerMode, PRICE_CLOSE, 0);
   double myRSI = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);

   if(PriceGreen < PriceRed && PriceWhite < PriceRed && myRSI < 50)
     {
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void resetValues()
  {
   tempAutomaticSLBuy = -1;
   tempAutomaticSLSell = -1;
   estadoBuy = false;
   estadoSell = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CerrarSiHayMasDeDosOrdenesPendientes()
  {

   if(ContadordeSellsStop() > 2 || ContadordeBuysStop() > 2)
     {
      incrementadorPerdidas++;
      CloseAllBuys();
      CloseAllSells();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CerrarSiHayUnaSolaOrdenPendientes()
  {

   if(!(ContadordeSellsStop() == 1 || ContadordeBuysStop() == 1))
     {
      incrementadorPerdidas++;
      CloseAllBuys();
      CloseAllSells();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void borrarPendienteSellSiEntroBuy()
  {
   if(ContadordeBuys() > 0)
     {
      CloseAllSells();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void borrarPendienteBuySiEntroSell()
  {
   if(ContadordeSells() > 0)
     {
      CloseAllBuys();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CerrarSiHayDosAbiertas()
  {

   if(ContadordeSells() > 1 || ContadordeBuys() > 1)
     {
      operacionGanada = false;
      incrementadorPerdidas++;
      contadorPerdidasGlobales++;
      // Borrar todo
      CloseAllBuys();
      CloseAllSells();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHLineSLBuy(double price)
  {
   ObjectDelete("lineSLBuy");
   ObjectCreate(0, "lineSLBuy", OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, "lineSLBuy", OBJPROP_COLOR, clrRed);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHLineSLSell(double price)
  {
   ObjectDelete("lineSLSell");
   ObjectCreate(0, "lineSLSell", OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, "lineSLSell", OBJPROP_COLOR, clrOrangeRed);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHLineTPBuy(double price)
  {
   ObjectDelete("lineTPBuy");
   ObjectCreate(0, "lineTPBuy", OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, "lineTPBuy", OBJPROP_COLOR, clrLimeGreen);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHLineTPSell(double price)
  {
   ObjectDelete("lineTPSell");
   ObjectCreate(0, "lineTPSell", OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, "lineTPSell", OBJPROP_COLOR, clrGreen);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HayOrdenesBuyPendientes()
  {
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUYLIMIT)
        {
         return true;
        }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HayOrdenesBuy()
  {
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUY)
        {
         comenzaronLosBuys = true;
         return true;
        }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HayOrdenesSell()
  {
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_SELL)
        {
         comenzaronLosSells = true;
         return true;
        }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Functions:
//- HLineCreate()
//- HLineMove()
//- HLineDelete()

//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+
bool HLineCreate(const long chart_ID = 0,                   // chart's ID
                 const string name = "HLine",               // line name
                 const int sub_window = 0,                  // subwindow index
                 double price = 0,                          // line price
                 const color clr = clrRed,                  // line color
                 const ENUM_LINE_STYLE style = STYLE_SOLID, // line style
                 const int width = 1,                       // line width
                 const bool back = false,                   // in the background
                 const bool selection = true,               // highlight to move
                 const bool hidden = true,                  // hidden in the object list
                 const long z_order = 0)                    // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID, name, OBJ_HLINE, sub_window, 0, price))
     {

      return (false);
     }
//--- set line color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set line display style
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set line width
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return (true);
  }
//+------------------------------------------------------------------+
//| Move horizontal line                                             |
//+------------------------------------------------------------------+
bool HLineMove(const long chart_ID = 0,     // chart's ID
               const string name = "HLine", // line name
               double price = 0)            // line price
  {
//--- if the line price is not set, move it to the current Bid price level
   if(!price)
      price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move a horizontal line
   if(!ObjectMove(chart_ID, name, 0, 0, price))
     {

      return (false);
     }
//--- successful execution
   return (true);
  }
//+------------------------------------------------------------------+
//| Delete a horizontal line                                         |
//+------------------------------------------------------------------+
bool HLineDelete(const long chart_ID = 0,     // chart's ID
                 const string name = "HLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a horizontal line
   if(!ObjectDelete(chart_ID, name))
     {

      return (false);
     }
//--- successful execution
   return (true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetActiveHours(string symbol)
  {
   string shortSymbol;

// Definir una lista de símbolos especiales
   string specialSymbols[] = {"US100.ecn", "EU50.ecn", "US500.ecn"};

   for(int i = 0; i < ArraySize(specialSymbols); i++)
     {
      if(symbol == specialSymbols[i])
        {
         shortSymbol = symbol;
         break;
        }
      else
        {
         shortSymbol = StringSubstr(symbol, 0, 6);
        }
     }

   if(shortSymbol == "EURAUD" || shortSymbol == "AUDJPY" || shortSymbol == "AUDUSD" || shortSymbol == "AUDNZD" || shortSymbol == "AUDCAD" || shortSymbol == "NZDCAD")
     {
      // La sesión de Sydney es de 9:00 a 18:00 hora local, que es de 22:00 a 7:00 UTC.
      openCloseTime[0] = 0;
      openCloseTime[1] = 24;
     }
   else
      if(shortSymbol == "GBPUSD" || shortSymbol == "GBPJPY" || shortSymbol == "EURGBP")
        {
         // La sesión de Londres es de 8:00 a 17:00 hora local, que es de 7:00 a 16:00 UTC.
         openCloseTime[0] = 0;
         openCloseTime[1] = 24;
        }
      else
         if(shortSymbol == "USDJPY" || shortSymbol == "CHFJPY" || shortSymbol == "CADJPY" || shortSymbol == "EURJPY")
           {
            // La sesión de Tokio es de 9:00 a 18:00 hora local, que es de 00:00 a 9:00 UTC.
            openCloseTime[0] = 0;
            openCloseTime[1] = 24;
           }
         else
            if(shortSymbol == "EURUSD" || shortSymbol == "USDCHF" || shortSymbol == "USDCAD")
              {
               // La sesión de Nueva York es de 8:00 a 17:00 hora local, que es de 13:00 a 22:00 UTC.
               openCloseTime[0] = 0;
               openCloseTime[1] = 24;
              }
            else
               if(shortSymbol == "XAUUSD" || shortSymbol == "XAGUSD")
                 {
                  // Los metales preciosos tienden a ser más volátiles durante la sesión de Nueva York.
                  openCloseTime[0] = 0;
                  openCloseTime[1] = 24;
                 }
               else
                  if(shortSymbol == "CHFSGD")
                    {
                     // Asumiendo que la sesión de Singapur es relevante, que es de 1:00 a 10:00 UTC.
                     openCloseTime[0] = 0;
                     openCloseTime[1] = 24;
                    }
                  else
                     if(shortSymbol == "EURCHF" || shortSymbol == "GBPCHF" || shortSymbol == "AUDCHF" || shortSymbol == "CADCHF" || shortSymbol == "NZDCHF")
                       {
                        // La sesión de Zúrich es de 8:00 a 17:00 hora local, que es de 7:00 a 16:00 UTC.
                        openCloseTime[0] = 0;
                        openCloseTime[1] = 24;
                       }
                     else
                        if(shortSymbol == "US100.ecn")
                          {
                           // Horarios para US100.ecn en UTC
                           openCloseTime[0] = 0;  // 1:00 pm UTC
                           openCloseTime[1] = 24;  // 10:00 pm UTC
                          }
                        else
                          {
                           // Si el par de divisas no está en la lista, devuelve un valor predeterminado.
                           openCloseTime[0] = 0;
                           openCloseTime[1] = 24;
                          }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double anteriorNoPerdio()
  {
   int totalOrders = OrdersHistoryTotal();
   for(int i = totalOrders - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            if((OrderProfit() + OrderSwap() + OrderCommission()) < 0)
              {
               return MathAbs(OrderOpenPrice() - OrderClosePrice()) / Point;
              }
            else
              {
               return 0;
              }
           }
        }
     }
   return 0;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BorrarSL()
  {
   ObjectDelete(0, "lineSL");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BorrarTP()
  {
   ObjectDelete(0, "lineTP");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsStrongTrend(string par)
  {
   double myAdx = iADX(par, 60, 14, 0, 0, 1);

   if(myAdx > 25 && myAdx < 30)
      return true;
   else
      return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int parNormal(string parBase, string parComprobar)
  {
   string base1 = StringSubstr(parBase, 0, 3);
   string base2 = StringSubstr(parBase, 3, 3);

   string comp1 = StringSubstr(parComprobar, 0, 3);
   string comp2 = StringSubstr(parComprobar, 3, 3);

// Verifica si al menos una de las monedas del parBase está presente en parComprobar
   if(base1 == comp1 || base1 == comp2 || base2 == comp1 || base2 == comp2)
     {
      // Ambas monedas están presentes en el par a comprobar
      if(base1 == comp1 || base2 == comp2)
        {
         return 1; // Orden normal
        }
      else
         if(base1 == comp2 || base2 == comp1)
           {
            return -1; // Orden inverso
           }
     }
   return 0; // No hay relación
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double averageCandleLength(int period)
  {
   double totalLength = 0.0;
   for(int i = 0; i < period; i++)
     {
      double high = iHigh(NULL, 0, i);
      double low = iLow(NULL, 0, i);
      totalLength += (high - low);
     }
   double averageLengthInPrice = totalLength / period;
   double averageLengthInPips = averageLengthInPrice / Point;
   return averageLengthInPips;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double priceDistance(double price1, double price2)
  {
   return MathAbs(price1 - price2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void maximosMinimos()
  {
   double tolerance = 20 * Point;  // Define una tolerancia para considerar dos precios como "cercanos"
   int closePricesCount = 0;
   for(int i = 0; i < 39; i++)
     {
      for(int j = i + 1; j < 40; j++)
        {
         if(priceDistance(signal[i], signal[j]) <= tolerance)
           {
            closePricesCount++;
            if(closePricesCount >= 3)
              {
               // Desplaza los elementos del array hacia la derecha
               for(int k = 24; k > 0; k--)
                 {
                  linePrices[k] = linePrices[k-1];
                 }
               // Guarda el nuevo precio en la posición 0
               linePrices[0] = signal[i];

               // Dibuja una línea en el precio signalTypeBuy[i]
               string lineName = "Line" + IntegerToString(i);
               ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, signal[i]);
               ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrBlueViolet);
               break;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BorrarSRLine()
  {
   int maxLines = 10;
   int lineCount = 0;
   string farthestLineName;
   double farthestLineDistance = 0;

   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string objName = ObjectName(i);
      if(ObjectType(objName) == OBJ_HLINE)
        {
         lineCount++;
         if(lineCount > maxLines)
           {
            ObjectDelete(objName);
            lineCount--;
           }
         else
            if(lineCount > 6)
              {
               double linePrice = ObjectGet(objName, OBJPROP_PRICE1);
               double distance = MathAbs(Bid - linePrice);
               if(distance > farthestLineDistance)
                 {
                  farthestLineDistance = distance;
                  farthestLineName = objName;
                 }
              }
        }
     }

   if(lineCount > 6 && farthestLineName != "")
     {
      ObjectDelete(farthestLineName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkCrossingPriceBuy()
  {
   for(int i = 0; i < 25; i++)
     {
      if(Close[0] > linePrices[i] && Close[1] < linePrices[i])
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkCrossingPriceSell()
  {
   for(int i = 0; i < 25; i++)
     {
      if(Close[0] < linePrices[i] && Close[1] > linePrices[i])
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getTwoHighestPrices()
  {
   highest = signalTypeBuy[0];
   secondHighest = -1;

   for(int i = 1; i < 2; i++)
     {
      if(signalTypeBuy[i] > highest)
        {
         secondHighest = highest;
         highest = signalTypeBuy[i];
        }
      else
         if(signalTypeBuy[i] > secondHighest)
           {
            secondHighest = signalTypeBuy[i];
           }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getTwoLowestPrices()
  {
   lowest = signalTypeSell[0];
   secondLowest = DBL_MAX;

   for(int i = 1; i < 2; i++)
     {
      if(signalTypeSell[i] != 0 && signalTypeSell[i] < lowest)
        {
         secondLowest = lowest;
         lowest = signalTypeSell[i];
        }
      else
         if(signalTypeSell[i] != 0 && signalTypeSell[i] < secondLowest)
           {
            secondLowest = signalTypeSell[i];
           }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CrearSLBuy(double mySL)
  {
   Print(">>> CrearSLBuy() INICIO | mySL=", mySL, " | Bid=", Bid, " | usarIA=", usarIA, " | useSL=", useSL);

   if(usarIA)
     {
      useSL = false;
      double averageRangeInPips = AverageRangeInPips(High, Low, 0, 200) / Point;
      double additionalPips = averageRangeInPips * extraSlSpace;
      priceSLBuy = NormalizeDouble(mySL - slPercent * averageRangeInPips * Point, Digits);
      priceSLBuy -= additionalPips * Point;
      Print(">>> CrearSLBuy() RAMA usarIA | averageRange=", averageRangeInPips, " | additionalPips=", additionalPips, " | priceSLBuy=", priceSLBuy);
     }
   else
      if(useSL == false)
        {
         double averageRangeInPips = AverageRangeInPips(High, Low, 0, 200) / Point;
         double additionalPips = averageRangeInPips * extraSlSpace;
         priceSLBuy = NormalizeDouble(mySL, Digits);
         priceSLBuy -= additionalPips * Point;
         Print(">>> CrearSLBuy() RAMA useSL=false | averageRange=", averageRangeInPips, " | additionalPips=", additionalPips, " | priceSLBuy=", priceSLBuy);
        }
      else
        {
         double slDinamico = ObtenerSLDinamico();
         priceSLBuy = NormalizeDouble(Bid - slDinamico * Point, Digits);
         Print(">>> CrearSLBuy() RAMA useSL=true | ObtenerSLDinamico()=", slDinamico, " | priceSLBuy=", priceSLBuy);
        }
   DrawHLineSLBuy(priceSLBuy);
   Print(">>> CrearSLBuy() FINAL | priceSLBuy=", priceSLBuy, " | Distancia del Bid:", (Bid - priceSLBuy) / Point, " pips");

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CrearSLSell(double mySL)
  {

   if(usarIA)
     {
      useSL = false;
      double averageRangeInPips = AverageRangeInPips(High, Low, 0, 200) / Point;
      double additionalPips = averageRangeInPips * extraSlSpace;
      priceSLSell = NormalizeDouble(mySL + slPercent * averageRangeInPips * Point, Digits);
      priceSLSell += additionalPips * Point;
     }
   else
      if(useSL == false)
        {
         double averageRangeInPips = AverageRangeInPips(High, Low, 0, 200) / Point;
         double additionalPips = averageRangeInPips * extraSlSpace;
         priceSLSell = NormalizeDouble(mySL, Digits);
         priceSLSell += additionalPips * Point;
        }
      else
        {
         priceSLSell = NormalizeDouble(Ask + ObtenerSLDinamico() * Point, Digits);
        }
   DrawHLineSLSell(priceSLSell);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CrearTPBuy(double orderOpenPrice)
  {

   double slDistance = orderOpenPrice - priceSLBuy; // Calcula la distancia al SL
   if(usarIA)
     {
      useTP = false;
      priceTPBuy = orderOpenPrice + tpPercent * slDistance; // Establece el TP al doble de la distancia al SL
     }
   else
      if(useTP == false)
        {
         priceTPBuy = orderOpenPrice + N * slDistance; // Establece el TP a N veces la distancia al SL
        }
      else
        {
         priceTPBuy = NormalizeDouble(Ask + ObtenerTPDinamico() * Point, Digits);

        }
   DrawHLineTPBuy(priceTPBuy);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CrearTPSell(double orderOpenPrice)
  {

   double slDistance = priceSLSell - orderOpenPrice; // Calcula la distancia al SL
   if(usarIA)
     {
      useTP = false;
      priceTPSell = orderOpenPrice - tpPercent * slDistance; // Establece el TP al doble de la distancia al SL
     }
   else
      if(useTP == false)
        {
         priceTPSell = orderOpenPrice - N * slDistance; // Establece el TP a N veces la distancia al SL
        }
      else
        {
         priceTPSell = NormalizeDouble(Bid - ObtenerTPDinamico() * Point, Digits);
        }
   DrawHLineTPSell(priceTPSell);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AreThreeBearishCandles(const double &open[], const double &close[], int indice)
  {
   return (close[indice] < open[indice] &&
           close[indice + 1] < open[indice + 1] &&
           close[indice + 2] < open[indice + 2]);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AreThreeBullishCandles(const double &open[], const double &close[], int indice)
  {
   return (close[indice] > open[indice] &&
           close[indice + 1] > open[indice + 1] &&
           close[indice + 2] > open[indice + 2]);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fvgExtremo()
  {

// Calcular el promedio de los rangos de las últimas 10 velas en pips
   double averageRangeInPips = AverageRangeInPips(High, Low, 0, 200) / Point;

   int i = 1;

// Obtener estocástico de la vela cerrada para verificar sobrecompra/sobreventa
   double kStoch = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, i);

// Detectar FVG alcista SOLO si está en zona baja (0-50)
   if(Low[i] > High[i + 2] && MathAbs(Low[i] - High[i + 2]) / Point >= averageRangeInPips && AreThreeBullishCandles(Open, Close, i) && kStoch < OSLevel)
     {
      highAlcista = Low[i];
      lowAlcista = High[i + 2];
     }
// NO resetear si ya hay un FVG alcista activo
   else
      if(highAlcista == EMPTY_VALUE)
        {
         highAlcista = EMPTY_VALUE;
         lowAlcista = EMPTY_VALUE;
        }

// Detectar FVG bajista SOLO si está en zona alta (50-100)
   if(High[i] < Low[i + 2] && MathAbs(Low[i + 2] - High[i]) / Point >= averageRangeInPips && AreThreeBearishCandles(Open, Close, i) && kStoch > OBLevel)
     {
      highBajista = High[i];
      lowBajista = Low[i + 2];
     }
// NO resetear si ya hay un FVG bajista activo
   else
      if(highBajista == EMPTY_VALUE)
        {
         highBajista = EMPTY_VALUE;
         lowBajista = EMPTY_VALUE;
        }

  }

//+------------------------------------------------------------------+
//|Función para evaluar filtros de tendencia                         |
//+------------------------------------------------------------------+
bool evaluarFiltrosTendencia(int direccion) // 1=BUY, 2=SELL
  {
   if(!usarFiltrosTendencia)
      return true; // Si están desactivados, siempre permitir

// 1. FILTRO DE TENDENCIA PRINCIPAL
   double ma200 = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ema50 = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, 1);
   double ema50_anterior = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, 2);
   double precioActual = Close[1];

// 2. FILTRO DE MOMENTUM
   double rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 1);
   double macd_main = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
   double macd_signal = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);

// 3. FILTRO DE VELOCIDAD
   double adx = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, 1);

// 4. FILTRO DE ESTRUCTURA (Higher Highs/Lower Lows)
   bool estructuraAlcista = (High[1] > High[2] && Low[1] > Low[2]);
   bool estructuraBajista = (High[1] < High[2] && Low[1] < Low[2]);

   int filtrosConfirmados = 0;
   string detallesFiltros = "";

   if(direccion == 1) // FILTROS PARA BUY
     {
      // Filtro 1: Tendencia - Precio debe estar por encima de EMA50
      if(!filtrarPorMA50 || precioActual > ema50)
        {
         filtrosConfirmados++;
         detallesFiltros += "EMA50✅ ";
        }
      else
         detallesFiltros += "EMA50❌ ";

      // Filtro 2: Momentum - RSI no debe estar en sobrecompra extrema
      if(!filtrarPorRSI || rsi < 75)
        {
         filtrosConfirmados++;
         detallesFiltros += "RSI✅ ";
        }
      else
         detallesFiltros += "RSI❌ ";

      // Filtro 3: MACD positivo
      if(!filtrarPorMACD || macd_main > macd_signal)
        {
         filtrosConfirmados++;
         detallesFiltros += "MACD✅ ";
        }
      else
         detallesFiltros += "MACD❌ ";

      // Filtro 4: ADX muestra tendencia fuerte
      if(!filtrarPorADX || adx > 25)
        {
         filtrosConfirmados++;
         detallesFiltros += "ADX✅ ";
        }
      else
         detallesFiltros += "ADX❌ ";

      // Filtro 5: Estructura alcista o al menos no bajista
      if(!filtrarPorEstructura || estructuraAlcista || !estructuraBajista)
        {
         filtrosConfirmados++;
         detallesFiltros += "EST✅ ";
        }
      else
         detallesFiltros += "EST❌ ";

      // Filtro 6: EMA50 debe estar subiendo (tendencia a corto plazo)
      if(!filtrarPorVelocidadMA || ema50 > ema50_anterior)
        {
         filtrosConfirmados++;
         detallesFiltros += "VEL✅ ";
        }
      else
         detallesFiltros += "VEL❌ ";
     }
   else
      if(direccion == 2) // FILTROS PARA SELL
        {
         // Filtro 1: Tendencia - Precio debe estar por debajo de EMA50
         if(!filtrarPorMA50 || precioActual < ema50)
           {
            filtrosConfirmados++;
            detallesFiltros += "EMA50✅ ";
           }
         else
            detallesFiltros += "EMA50❌ ";

         // Filtro 2: Momentum - RSI no debe estar en sobreventa extrema
         if(!filtrarPorRSI || rsi > 25)
           {
            filtrosConfirmados++;
            detallesFiltros += "RSI✅ ";
           }
         else
            detallesFiltros += "RSI❌ ";

         // Filtro 3: MACD negativo
         if(!filtrarPorMACD || macd_main < macd_signal)
           {
            filtrosConfirmados++;
            detallesFiltros += "MACD✅ ";
           }
         else
            detallesFiltros += "MACD❌ ";

         // Filtro 4: ADX muestra tendencia fuerte
         if(!filtrarPorADX || adx > 25)
           {
            filtrosConfirmados++;
            detallesFiltros += "ADX✅ ";
           }
         else
            detallesFiltros += "ADX❌ ";

         // Filtro 5: Estructura bajista o al menos no alcista
         if(!filtrarPorEstructura || estructuraBajista || !estructuraAlcista)
           {
            filtrosConfirmados++;
            detallesFiltros += "EST✅ ";
           }
         else
            detallesFiltros += "EST❌ ";

         // Filtro 6: EMA50 debe estar bajando (tendencia a corto plazo)
         if(!filtrarPorVelocidadMA || ema50 < ema50_anterior)
           {
            filtrosConfirmados++;
            detallesFiltros += "VEL✅ ";
           }
         else
            detallesFiltros += "VEL❌ ";
        }

// REGLA DE CONFLUENCIA: Requerir mínimo de filtros (ajustado por modo reactivo)
   int filtrosRequeridos = modoReactivo ? MathMax(2, filtrosMinimosRequeridos - 1) : filtrosMinimosRequeridos;
   bool resultado = (filtrosConfirmados >= filtrosRequeridos);

// Logging detallado
   LogEnPantalla("🔍 Filtros " + (direccion == 1 ? "BUY" : "SELL") +
                 ": " + IntegerToString(filtrosConfirmados) + "/6 - " +
                 (resultado ? "✅ VÁLIDO" : "❌ RECHAZADO"));
   LogEnPantalla("📊 " + detallesFiltros);

   return resultado;
  }

//+------------------------------------------------------------------+
//|Función para dibujar líneas visuales de filtros                  |
//+------------------------------------------------------------------+
void dibujarLineasTPSL()
  {
// Verificar si hay órdenes abiertas
   bool hayOrden = false;
   double tpOrden = 0;
   double slOrden = 0;
   int tipoOrden = -1;
   double precioApertura = 0;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            hayOrden = true;
            tpOrden = OrderTakeProfit();
            slOrden = OrderStopLoss();
            tipoOrden = OrderType();
            precioApertura = OrderOpenPrice();
            break; // Tomamos la primera orden encontrada
           }
        }
     }

   if(hayOrden)
     {
      // HAY ORDEN ABIERTA
      double tpDinamico = ObtenerTPDinamico();
      double slDinamico = ObtenerSLDinamico();

      // Si la orden tiene TP/SL configurados, usarlos; si no, calcularlos
      double lineaTP = 0;
      double lineaSL = 0;

      if(tipoOrden == OP_BUY)
        {
         // BUY: TP arriba (verde), SL abajo (roja)
         lineaTP = precioApertura + (tpDinamico * Point);
         lineaSL = precioApertura - (slDinamico * Point);
        }
      else
         if(tipoOrden == OP_SELL)
           {
            // SELL: TP abajo (verde), SL arriba (roja)
            lineaTP = precioApertura - (tpDinamico * Point);
            lineaSL = precioApertura + (slDinamico * Point);
           }

      // Dibujar LineTP (verde)
      ObjectDelete("LineTP");
      ObjectCreate("LineTP", OBJ_HLINE, 0, 0, lineaTP);
      ObjectSet("LineTP", OBJPROP_COLOR, clrLime);
      ObjectSet("LineTP", OBJPROP_WIDTH, 2);
      ObjectSet("LineTP", OBJPROP_STYLE, STYLE_SOLID);

      // Dibujar LineSL (roja)
      ObjectDelete("LineSL");
      ObjectCreate("LineSL", OBJ_HLINE, 0, 0, lineaSL);
      ObjectSet("LineSL", OBJPROP_COLOR, clrRed);
      ObjectSet("LineSL", OBJPROP_WIDTH, 2);
      ObjectSet("LineSL", OBJPROP_STYLE, STYLE_SOLID);
     }
   else
     {
      // NO HAY ORDEN: Mostrar líneas dinámicas (por defecto como BUY: verde arriba, roja abajo)
      double tpDinamico = ObtenerTPDinamico();
      double slDinamico = ObtenerSLDinamico();

      // Línea TP (verde) arriba - como BUY
      double precioTP = Ask + (tpDinamico * Point);
      ObjectDelete("LineTP");
      ObjectCreate("LineTP", OBJ_HLINE, 0, 0, precioTP);
      ObjectSet("LineTP", OBJPROP_COLOR, clrLime);
      ObjectSet("LineTP", OBJPROP_WIDTH, 2);
      ObjectSet("LineTP", OBJPROP_STYLE, STYLE_SOLID);

      // Línea SL (roja) abajo - como BUY
      double precioSL = Bid - (slDinamico * Point);
      ObjectDelete("LineSL");
      ObjectCreate("LineSL", OBJ_HLINE, 0, 0, precioSL);
      ObjectSet("LineSL", OBJPROP_COLOR, clrRed);
      ObjectSet("LineSL", OBJPROP_WIDTH, 2);
      ObjectSet("LineSL", OBJPROP_STYLE, STYLE_SOLID);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int detectarSenal()
  {
   int i = 1;
   int y = 6;

// Indicador 1
   double myArrowUP = iCustom(NULL, 0, PastMaxMin, 0, y);
   double myArrowDown = iCustom(NULL, 0, PastMaxMin, 1, y);

// Hay una flecha roja
   bool detectadaFlechaBuy = myArrowUP != 2147483647;

// Hay una flecha verde
   bool detectadaFlechaSell = myArrowDown != 2147483647;

   if(detectadaFlechaBuy)
     {
      // Desplaza los elementos del array hacia la izquierda
      ArrayCopy(last2Buys, last2Buys, 0, 1, WHOLE_ARRAY);

      // Guarda el valor de la última señal de compra detectada
      last2Buys[1] = myArrowUP;
     }

   if(detectadaFlechaSell)
     {
      // Desplaza los elementos del array hacia la izquierda
      ArrayCopy(last2Sells, last2Sells, 0, 1, WHOLE_ARRAY);

      // Guarda el valor de la última señal de venta detectada
      last2Sells[1] = myArrowDown;
     }

// Condición para devolver 1: máximos cada vez más altos y mínimos cada vez más altos, y el precio actual está por encima del último alto
// if(last2Buys[1] > last2Buys[0] && last2Sells[1] > last2Sells[0] && Close[i] > last2Buys[1])
   if(last2Buys[1] > last2Buys[0] && last2Sells[1] > last2Sells[0])
     {
      return 1;
     }

// Condición para devolver 2: máximos cada vez más bajos y mínimos cada vez más bajos, y el precio actual está por debajo del último bajo
//if(last2Buys[1] < last2Buys[0] && last2Sells[1] < last2Sells[0] && Close[i] < last2Sells[1])
   if(last2Buys[1] < last2Buys[0] && last2Sells[1] < last2Sells[0])
     {
      return 2;
     }

// Si ninguna de las condiciones anteriores se cumple, devuelve 3
   return 3;
  }



//+------------------------------------------------------------------+
//| Función para calcular lotaje base con interés compuesto         |
//+------------------------------------------------------------------+
double CalcularLotajeBase()
  {
   double lotajeCalculado;

   if(useInteresCompuesto)
     {
      // Calcular lotaje basado en el balance actual
      double balanceActual = AccountBalance();
      double multiplicador = balanceActual / capitalBase;
      lotajeCalculado = multiplicador * lotsPorCapital;

      // Normalizar el lotaje
      double minlot = MarketInfo(Symbol(), MODE_MINLOT);
      double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
      double lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);

      lotajeCalculado = NormalizeDouble(lotajeCalculado / lotstep, 0) * lotstep;

      // Asegurar que esté dentro de los límites
      if(lotajeCalculado < minlot)
         lotajeCalculado = minlot;
      if(lotajeCalculado > maxlot)
         lotajeCalculado = maxlot;

      LogEnPantalla("Interés Compuesto: Balance=" + DoubleToString(balanceActual, 2) +
                    " | Lotaje calculado=" + DoubleToString(lotajeCalculado, 2));
     }
   else
     {
      // Usar el lotaje manual definido
      lotajeCalculado = lotajeDeseado;
     }

   return lotajeCalculado;
  }

//+------------------------------------------------------------------+
//| Función para calcular próximo lotaje SIN afectar el martingala   |
//+------------------------------------------------------------------+
double CalcularProximoLotaje(int orderType = OP_SELL)
  {
   double minlot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MaximalLots = 800.0;
   double lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   // Seleccionar multiplicador según el tipo de orden
   double multiplier = (orderType == OP_BUY) ? myMultiplierBuy : myMultiplierSell;

// Calcular lotaje base dinámico (con o sin interés compuesto)
   double lotajeBaseActual = CalcularLotajeBase();

// ===== MARTINGALA CLÁSICA =====
   if(tipoMartingala == 0)
     {
      // Revisar el historial - SOLO del tipo orderType
      for(int x = OrdersHistoryTotal() - 1; x >= 0; x--)
        {
         if(OrderSelect(x, SELECT_BY_POS, MODE_HISTORY))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == orderType)
              {
               double prevLots = OrderLots();

               // CASO 1: Operación GANADORA
               if(OrderProfit() > 0)
                 {
                  // Reset a lotaje base
                  double lotsCalculado = lotajeBaseActual;
                  lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                  if(lotsCalculado < minlot)
                     lotsCalculado = minlot;
                  if(lotsCalculado > MaximalLots)
                     lotsCalculado = MaximalLots;
                  return lotsCalculado;
                 }
               // CASO 2: Operación PERDEDORA
               else
                 {
                  if(!martingala)
                    {
                     double lotsCalculado = lotajeBaseActual;
                     lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                     if(lotsCalculado < minlot)
                        lotsCalculado = minlot;
                     if(lotsCalculado > MaximalLots)
                        lotsCalculado = MaximalLots;
                     return lotsCalculado;
                    }
                  else
                    {
                     // Multiplicar el lotaje anterior
                     double lotsCalculado = prevLots * multiplier;
                     lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                     if(lotsCalculado < minlot)
                        lotsCalculado = minlot;
                     if(lotsCalculado > MaximalLots)
                        lotsCalculado = MaximalLots;
                     return lotsCalculado;
                    }
                 }
              }
           }
        }

      // Si no hay historial, usar lotaje base calculado
      double lotsCalculado = lotajeBaseActual;
      lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
      if(lotsCalculado < minlot)
         lotsCalculado = minlot;
      if(lotsCalculado > MaximalLots)
         lotsCalculado = MaximalLots;
      return lotsCalculado;
     }

// ===== MARTINGALA NUEVA (RACHA MALA) =====
   else
     {
      // NUEVO: Leer variables según orderType (sin modificarlas)
      bool enRachaMalaActual = (orderType == OP_BUY) ? enRachaMalaBuy : enRachaMalaSell;
      double lotajePerdidoGuardadoActual = (orderType == OP_BUY) ? lotajePerdidoGuardadoBuy : lotajePerdidoGuardadoSell;
      double perdidasAcumuladasActual = (orderType == OP_BUY) ? perdidasAcumuladasBuy : perdidasAcumuladasSell;
      bool tipoOperacionGanadoraActual = (orderType == OP_BUY) ? tipoOperacionGanadoraBuy : tipoOperacionGanadoraSell;

      // Revisar el historial sin modificar contadores ni variables globales - SOLO del tipo orderType
      for(int x = OrdersHistoryTotal() - 1; x >= 0; x--)
        {
         if(OrderSelect(x, SELECT_BY_POS, MODE_HISTORY))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == orderType)
              {
               double prevLots = OrderLots();

               // CASO 1: Operación GANADORA
               if(OrderProfit() > 0)
                 {
                  if(enRachaMalaActual && prevLots <= lotajeMinimo)
                    {
                     // NUEVO: NO aplicamos multiplicador inmediatamente
                     // Esperamos a que la siguiente operación ganadora aplique el multiplicador
                     if(lotajePerdidoGuardadoActual > 0)
                       {
                        LogEnPantalla("✓ Ganó en racha mala - Esperando próxima ganancia para aplicar multiplicador");

                        // CALCULAR PRÓXIMO LOTAJE DE RECUPERACIÓN PARA DASHBOARD
                        if(hacerMartingalaAcumulativo && perdidasAcumuladasActual > 0)
                          {
                           // Buscar ganancia de la última operación de 0.01
                           double ganancia001 = (OrderProfit() > 0) ? OrderProfit() : 1.0;

                           // Fórmula simple: (Pérdidas / Ganancia por 0.01) * 0.01 * Multiplicador
                           double lotsCalculado = (perdidasAcumuladasActual / ganancia001) * lotajeMinimo * multiplier;

                           lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                           if(lotsCalculado < minlot)
                              lotsCalculado = minlot;
                           if(lotsCalculado > MaximalLots)
                              lotsCalculado = MaximalLots;
                           return lotsCalculado;
                          }
                        else
                          {
                           // Modo normal
                           double lotsCalculado = lotajeMinimo;
                           lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                           if(lotsCalculado < minlot)
                              lotsCalculado = minlot;
                           if(lotsCalculado > MaximalLots)
                              lotsCalculado = MaximalLots;
                           return lotsCalculado;
                          }
                       }
                     else
                       {
                        // No había lotaje guardado, volver al inicial
                        double lotsCalculado = lotajeBaseActual;
                        lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                        if(lotsCalculado < minlot)
                           lotsCalculado = minlot;
                        if(lotsCalculado > MaximalLots)
                           lotsCalculado = MaximalLots;
                        return lotsCalculado;
                       }
                    }
                  // Si ganamos con martingala aplicado (lote mayor al base)
                  else
                     if(prevLots > lotajeBaseActual)
                       {
                        // Reseteamos todo al ganar con martingala
                        double lotsCalculado = lotajeBaseActual;
                        lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                        if(lotsCalculado < minlot)
                           lotsCalculado = minlot;
                        if(lotsCalculado > MaximalLots)
                           lotsCalculado = MaximalLots;
                        return lotsCalculado;
                       }
                     // Ganancia normal
                     else
                       {
                        double lotsCalculado = lotajeBaseActual;
                        lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                        if(lotsCalculado < minlot)
                           lotsCalculado = minlot;
                        if(lotsCalculado > MaximalLots)
                           lotsCalculado = MaximalLots;
                        return lotsCalculado;
                       }
                 }
               // CASO 2: Operación PERDEDORA
               else
                 {
                  if(!martingala)
                    {
                     double lotsCalculado = lotajeBaseActual;
                     lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                     if(lotsCalculado < minlot)
                        lotsCalculado = minlot;
                     if(lotsCalculado > MaximalLots)
                        lotsCalculado = MaximalLots;
                     return lotsCalculado;
                    }
                  else
                    {
                     // Si acabamos de perder con martingala aplicado (lote mayor al base)
                     if(prevLots > lotajeBaseActual)
                       {
                        // Guardamos este lotaje perdido y entramos en racha mala
                        double lotsCalculado = lotajeMinimo;
                        lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                        if(lotsCalculado < minlot)
                           lotsCalculado = minlot;
                        if(lotsCalculado > MaximalLots)
                           lotsCalculado = MaximalLots;
                        return lotsCalculado;
                       }
                     // Si estamos en racha mala
                     else
                        if(enRachaMalaActual)
                          {
                           // Seguimos operando con lotaje mínimo
                           double lotsCalculado = lotajeMinimo;
                           lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                           if(lotsCalculado < minlot)
                              lotsCalculado = minlot;
                           if(lotsCalculado > MaximalLots)
                              lotsCalculado = MaximalLots;
                           return lotsCalculado;
                          }
                        // Primera pérdida con lotaje normal
                        else
                          {
                           // Guardamos el lotaje y entramos en racha mala
                           double lotsCalculado = lotajeMinimo;
                           lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
                           if(lotsCalculado < minlot)
                              lotsCalculado = minlot;
                           if(lotsCalculado > MaximalLots)
                              lotsCalculado = MaximalLots;
                           return lotsCalculado;
                          }
                    }
                 }
              }
           }
        }

      // Si no hay historial, usar lotaje base calculado
      double lotsCalculado = lotajeBaseActual;
      lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
      if(lotsCalculado < minlot)
         lotsCalculado = minlot;
      if(lotsCalculado > MaximalLots)
         lotsCalculado = MaximalLots;
      return lotsCalculado;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyMartingala(int orderType = OP_BUY)
  {
// === LOG DE PRUEBA - VERIFICAR QUE SE EJECUTA CÓDIGO NUEVO ===
   static int contadorLlamadas = 0;
   contadorLlamadas++;

// === FIN LOG DE PRUEBA ===

// NUEVO: Variables locales que apuntan a las correctas según orderType
   double lotajePerdidoGuardado;
   bool enRachaMala;
   double perdidasAcumuladas;
   bool tipoOperacionGanadora;

   if(orderType == OP_BUY)
     {
      lotajePerdidoGuardado = lotajePerdidoGuardadoBuy;
      enRachaMala = enRachaMalaBuy;
      perdidasAcumuladas = perdidasAcumuladasBuy;
      tipoOperacionGanadora = tipoOperacionGanadoraBuy;
     }
   else // OP_SELL
     {
      lotajePerdidoGuardado = lotajePerdidoGuardadoSell;
      enRachaMala = enRachaMalaSell;
      perdidasAcumuladas = perdidasAcumuladasSell;
      tipoOperacionGanadora = tipoOperacionGanadoraSell;
     }

// Obtención de Información del Mercado y Cuenta
   double myAccountBalance = AccountBalance();
   double minlot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   double leverage = AccountLeverage();
   double lotsize = MarketInfo(Symbol(), MODE_LOTSIZE);
   double stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   double MaximalLots = 800.0;
   double lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);

// Calcular lotaje base dinámico (con o sin interés compuesto)
   double lotajeBaseActual = CalcularLotajeBase();
   double lotsCalculado = 0.0;

// Control de Pérdidas Máximas
   if(contadorPerdidas() > maxLost)
     {
      lotsCalculado = lotajeBaseActual;
      lotajePerdidoGuardado = 0.0;
      enRachaMala = false;
      perdidasAcumuladas = 0.0;  // NUEVO: Reset perdidas acumuladas
      LogEnPantalla("Pérdidas máximas alcanzadas. Reset completo. Lotaje: "+ DoubleToString(lotsCalculado, 2));
      lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
      if(lotsCalculado < minlot)
         lotsCalculado = minlot;
      if(lotsCalculado > MaximalLots)
         lotsCalculado = MaximalLots;

      // Escribir variables de vuelta antes de retornar
      if(orderType == OP_BUY)
        {
         lotajePerdidoGuardadoBuy = lotajePerdidoGuardado;
         enRachaMalaBuy = enRachaMala;
         perdidasAcumuladasBuy = perdidasAcumuladas;
         tipoOperacionGanadoraBuy = tipoOperacionGanadora;
        }
      else
        {
         lotajePerdidoGuardadoSell = lotajePerdidoGuardado;
         enRachaMalaSell = enRachaMala;
         perdidasAcumuladasSell = perdidasAcumuladas;
         tipoOperacionGanadoraSell = tipoOperacionGanadora;
        }

      return lotsCalculado;
     }


// Revisión del Historial de Órdenes - SOLO del tipo orderType
   for(int x = OrdersHistoryTotal() - 1; x >= 0; x--)
     {
      if(OrderSelect(x, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == orderType)
           {


            double prevLots = OrderLots();

            // CASO 1: Operación GANADORA
            if(OrderProfit() > 0)
              {


               // Si ganamos durante racha mala (operando a 0.01)
               if(enRachaMala && prevLots <= lotajeMinimo)
                 {


                  // NUEVO: Marcamos que ganó en racha mala
                  tipoOperacionGanadora = true;



                  // NUEVO: NO aplicamos multiplicador inmediatamente
                  if(lotajePerdidoGuardado > 0)
                    {

                     LogEnPantalla("✓ Ganó en racha mala - Esperando próxima ganancia para aplicar multiplicador");

                     // Seguimos con lotaje mínimo, próxima decisión en Compra()/Venta()
                     lotsCalculado = lotajeMinimo;
                    }
                  else
                    {
                     lotsCalculado = lotajeBaseActual;
                     enRachaMala = false;
                     tipoOperacionGanadora = false;
                     lotajePerdidoGuardado = 0.0;
                     perdidasAcumuladas = 0.0;  // IMPORTANTE: Reset perdidas acumuladas
                    }
                 }
               else
                 {


                  // Solo resetear si ganó con lotaje >= base Y es la segunda ganancia consecutiva
                  // (primera fue a 0.01, segunda es con lotaje alto)
                  if(prevLots >= lotajeBaseActual && tipoOperacionGanadora == true)
                    {
                     lotsCalculado = lotajeBaseActual;
                     lotajePerdidoGuardado = 0.0;
                     enRachaMala = false;
                     perdidasAcumuladas = 0.0;
                     tipoOperacionGanadora = false;
                    }
                  else
                    {

                     lotsCalculado = lotajeBaseActual;
                    }
                 }

               // Normalizar y retornar
               lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
               if(lotsCalculado < minlot)
                  lotsCalculado = minlot;
               if(lotsCalculado > MaximalLots)
                  lotsCalculado = MaximalLots;

               // Verificar margen
               double requiredMargin = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * lotsCalculado;
               if(AccountFreeMargin() < requiredMargin)
                 {
                  LogEnPantalla("Sin margen suficiente. Usando lotaje mínimo: "+ DoubleToString(minlot, 2));

                  // Escribir variables de vuelta antes de retornar
                  if(orderType == OP_BUY)
                    {
                     lotajePerdidoGuardadoBuy = lotajePerdidoGuardado;
                     enRachaMalaBuy = enRachaMala;
                     perdidasAcumuladasBuy = perdidasAcumuladas;
                     tipoOperacionGanadoraBuy = tipoOperacionGanadora;
                    }
                  else
                    {
                     lotajePerdidoGuardadoSell = lotajePerdidoGuardado;
                     enRachaMalaSell = enRachaMala;
                     perdidasAcumuladasSell = perdidasAcumuladas;
                     tipoOperacionGanadoraSell = tipoOperacionGanadora;
                    }

                  return minlot;
                 }

               // Escribir variables de vuelta antes de retornar
               if(orderType == OP_BUY)
                 {
                  lotajePerdidoGuardadoBuy = lotajePerdidoGuardado;
                  enRachaMalaBuy = enRachaMala;
                  perdidasAcumuladasBuy = perdidasAcumuladas;
                  tipoOperacionGanadoraBuy = tipoOperacionGanadora;
                 }
               else
                 {
                  lotajePerdidoGuardadoSell = lotajePerdidoGuardado;
                  enRachaMalaSell = enRachaMala;
                  perdidasAcumuladasSell = perdidasAcumuladas;
                  tipoOperacionGanadoraSell = tipoOperacionGanadora;
                 }

               return lotsCalculado;
              }
            // CASO 2: Operación PERDEDORA
            else
              {
               Print("🔴🔴 DEBUG PERDEDORA | prevLots:", prevLots, " | lotajeBaseActual:", lotajeBaseActual,
                     " | martingala:", martingala, " | enRachaMala(local):", enRachaMala);

               if(!martingala)
                 {
                  lotsCalculado = lotajeBaseActual;
                  LogEnPantalla("Martingala desactivada. Lotaje: "+ DoubleToString(lotsCalculado, 2));
                  Print("🔴🔴 RAMA: Martingala DESACTIVADA");
                 }
               else
                 {
                  // Si acabamos de perder con martingala aplicado (lote mayor al base)
                  if(prevLots > lotajeBaseActual)
                    {
                     Print("🔴🔴 RAMA: Perdió con martingala aplicado");

                     // Guardamos este lotaje perdido y entramos en racha mala
                     lotajePerdidoGuardado = prevLots;
                     enRachaMala = true;

                     // IMPORTANTE: Resetear tipoOperacionGanadora porque se rompió la secuencia de dos ganancias consecutivas
                     tipoOperacionGanadora = false;

                     // NUEVO: Acumular perdida en dolares si modo acumulativo
                     if(hacerMartingalaAcumulativo)
                       {
                        double perdidalActual = MathAbs(OrderProfit() + OrderSwap() + OrderCommission());
                        perdidasAcumuladas += perdidalActual;

                       }



                     lotsCalculado = lotajeMinimo;
                     LogEnPantalla("Perdió con martingala. Guardando lotaje: "+ DoubleToString(prevLots, 2) +
                                   ". Entrando en racha mala con: "+ DoubleToString(lotsCalculado, 2));
                    }
                  // Si estamos en racha mala
                  else
                     if(enRachaMala)
                       {
                        Print("🔴🔴 RAMA: Ya en racha mala");
                        // Seguimos operando con lotaje mínimo
                        lotsCalculado = lotajeMinimo;
                        LogEnPantalla("En racha mala. Operando con: "+ DoubleToString(lotsCalculado, 2));
                       }
                     // Primera pérdida con lotaje normal
                     else
                       {
                        Print("🔴🔴 RAMA: Primera pérdida - Entrando en racha mala");
                        // Guardamos el lotaje y entramos en racha mala
                        lotajePerdidoGuardado = prevLots;
                        enRachaMala = true;

                        // NUEVO: Acumular perdida en dolares si modo acumulativo
                        if(hacerMartingalaAcumulativo)
                          {
                           double perdidalActual = MathAbs(OrderProfit() + OrderSwap() + OrderCommission());
                           perdidasAcumuladas += perdidalActual;

                          }



                        lotsCalculado = lotajeMinimo;
                        LogEnPantalla("Primera pérdida. Guardando lotaje: "+ DoubleToString(prevLots, 2) +
                                      ". Entrando en racha mala con: "+ DoubleToString(lotsCalculado, 2));
                       }
                 }

               // Normalizar y retornar
               lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
               if(lotsCalculado < minlot)
                  lotsCalculado = minlot;
               if(lotsCalculado > MaximalLots)
                  lotsCalculado = MaximalLots;

               // Escribir variables de vuelta antes de retornar
               if(orderType == OP_BUY)
                 {
                  lotajePerdidoGuardadoBuy = lotajePerdidoGuardado;
                  enRachaMalaBuy = enRachaMala;
                  perdidasAcumuladasBuy = perdidasAcumuladas;
                  tipoOperacionGanadoraBuy = tipoOperacionGanadora;

                  Print("🔴 DEBUG MyMartingala(BUY) PERDEDORA | Retornando: ", lotsCalculado,
                        " | enRachaMalaBuy→", enRachaMalaBuy,
                        " | lotajePerdidoGuardadoBuy→", lotajePerdidoGuardadoBuy);
                 }
               else
                 {
                  lotajePerdidoGuardadoSell = lotajePerdidoGuardado;
                  enRachaMalaSell = enRachaMala;
                  perdidasAcumuladasSell = perdidasAcumuladas;
                  tipoOperacionGanadoraSell = tipoOperacionGanadora;
                 }

               return lotsCalculado;
              }
           }
        }
     }

// Si no se encontró ninguna orden previa, establecer el lote base calculado
   if(lotsCalculado == 0.0)
     {
      lotsCalculado = lotajeBaseActual;
      lotajePerdidoGuardado = 0.0;
      enRachaMala = false;
      perdidasAcumuladas = 0.0;  // NUEVO: Reset perdidas acumuladas
      LogEnPantalla("Primera orden. Lotaje: "+ DoubleToString(lotsCalculado, 2));
     }

// 🔒 Normalizar SIEMPRE antes de retornar
   lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
   if(lotsCalculado < minlot)
      lotsCalculado = minlot;
   if(lotsCalculado > MaximalLots)
      lotsCalculado = MaximalLots;

// NUEVO: Escribir variables locales de vuelta a las globales correctas
   if(orderType == OP_BUY)
     {
      lotajePerdidoGuardadoBuy = lotajePerdidoGuardado;
      enRachaMalaBuy = enRachaMala;
      perdidasAcumuladasBuy = perdidasAcumuladas;
      tipoOperacionGanadoraBuy = tipoOperacionGanadora;
     }
   else // OP_SELL
     {
      lotajePerdidoGuardadoSell = lotajePerdidoGuardado;
      enRachaMalaSell = enRachaMala;
      perdidasAcumuladasSell = perdidasAcumuladas;
      tipoOperacionGanadoraSell = tipoOperacionGanadora;
     }

   return lotsCalculado;
  }

//+------------------------------------------------------------------+
//| Scalping Agresivo - Cerrar en ganancia mínima                   |
//+------------------------------------------------------------------+
void CheckScalpingAgresivo()
  {
   if(!usarScalpingAgresivo)
      return;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            double profit = OrderProfit() + OrderSwap() + OrderCommission();
            double openPrice = OrderOpenPrice();
            double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;
            double profitTics = 0;

            // Calcular ganancia en tics
            if(OrderType() == OP_BUY)
              {
               profitTics = (currentPrice - openPrice) / Point;
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  profitTics = (openPrice - currentPrice) / Point;
                 }

            // Cerrar si alcanza ganancia mínima
            if(profitTics >= gananciaMinimaTics && profit > 0)
              {
               bool closed = false;
               string tipoOrden = (OrderType() == OP_BUY) ? "BUY" : "SELL";
               if(OrderType() == OP_BUY)
                 {
                  LogEnPantalla("🔴🔴🔴 BUY CERRADO POR CheckScalpingAgresivo() - Ganancia alcanzada");
                  Print("🔴🔴🔴 BUY CERRADO POR SCALPING | Tics:", profitTics, " >= ", gananciaMinimaTics, " | Profit:", profit);
                  closed = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrGreen);
                 }
               else
                  if(OrderType() == OP_SELL)
                    {
                     LogEnPantalla("🔴🔴🔴 SELL CERRADO POR CheckScalpingAgresivo() - Ganancia alcanzada");
                     Print("🔴🔴🔴 SELL CERRADO POR SCALPING | Tics:", profitTics, " >= ", gananciaMinimaTics, " | Profit:", profit);
                     closed = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
                    }

               if(closed)
                 {
                  LogEnPantalla("🎯 SCALPING: " + tipoOrden + " Cerrado con " + DoubleToString(profitTics, 0) + " tics de ganancia. Profit: $" + DoubleToString(profit, 2));
                  // Reset variables de martingala solo si NO estamos en racha mala
                  // NUEVO: Resetear según tipo de orden
                  if(OrderType() == OP_BUY && !enRachaMalaBuy)
                    {
                     // No está en racha mala BUY, reset completo
                     lotajePerdidoGuardadoBuy = 0.0;
                     perdidasAcumuladasBuy = 0.0;
                     tipoOperacionGanadoraBuy = false;
                    }
                  else if(OrderType() == OP_SELL && !enRachaMalaSell)
                    {
                     // No está en racha mala SELL, reset completo
                     lotajePerdidoGuardadoSell = 0.0;
                     perdidasAcumuladasSell = 0.0;
                     tipoOperacionGanadoraSell = false;
                    }

                  // Resetear MEGA-BANDERA al cerrar operación
                  G_megaBuyFlag = false;
                  G_megaSellFlag = false;
                 }
              }
            // Cerrar rápido si alcanza ganancia rápida
            else
               if(profitTics >= gananciaRapidaTics && profit > 0 && cerrarEnPrimeraGanancia)
                 {
                  bool closed = false;
                  string tipoOrden = (OrderType() == OP_BUY) ? "BUY" : "SELL";
                  if(OrderType() == OP_BUY)
                    {
                     LogEnPantalla("🔴🔴🔴 BUY CERRADO POR SCALPING RÁPIDO - Primera ganancia");
                     Print("🔴🔴🔴 BUY CERRADO POR SCALPING RAPIDO | Tics:", profitTics, " >= ", gananciaRapidaTics, " | Profit:", profit);
                     closed = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrLime);
                    }
                  else
                     if(OrderType() == OP_SELL)
                       {
                        LogEnPantalla("🔴🔴🔴 SELL CERRADO POR SCALPING RÁPIDO - Primera ganancia");
                        Print("🔴🔴🔴 SELL CERRADO POR SCALPING RAPIDO | Tics:", profitTics, " >= ", gananciaRapidaTics, " | Profit:", profit);
                        closed = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrLime);
                       }

                  if(closed)
                    {
                     LogEnPantalla("⚡ SCALPING RÁPIDO: Cerrado con " + DoubleToString(profitTics, 0) + " tics. Profit: $" + DoubleToString(profit, 2));
                     // Reset variables de martingala solo si NO estamos en racha mala
                     // NUEVO: Resetear según tipo de orden
                     if(OrderType() == OP_BUY && !enRachaMalaBuy)
                       {
                        // No está en racha mala BUY, reset completo
                        lotajePerdidoGuardadoBuy = 0.0;
                        perdidasAcumuladasBuy = 0.0;
                        tipoOperacionGanadoraBuy = false;
                       }
                     else if(OrderType() == OP_SELL && !enRachaMalaSell)
                       {
                        // No está en racha mala SELL, reset completo
                        lotajePerdidoGuardadoSell = 0.0;
                        perdidasAcumuladasSell = 0.0;
                        tipoOperacionGanadoraSell = false;
                       }
                     // Resetear MEGA-BANDERA al cerrar operación
                     G_megaBuyFlag = false;
                     G_megaSellFlag = false;
                    }
                 }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Protección de Drawdown                                           |
//+------------------------------------------------------------------+
void CheckProteccionDrawdown()
  {
   if(!usarProteccionDrawdown)
      return;

   double accountBalance = AccountBalance();
   double equity  = AccountEquity();
   if(accountBalance <= 0.0)
      return;

   double ddPorcentaje = 100.0 * (accountBalance - equity) / accountBalance;
   if(ddPorcentaje < maxDrawdownPorcentaje)
      return;

// Cerrar posiciones según configuración
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
         continue;

      bool cerrar = true;
      if(cerrarSoloPerdedoras)
        {
         double profitSinSwap = OrderProfit() + OrderCommission();
         cerrar = (profitSinSwap < 0.0);
        }

      if(cerrar)
        {
         bool ok = false;
         if(OrderType() == OP_BUY)
           {
            Print("🔴🔴🔴 BUY CERRADO POR DRAWDOWN | DD%:", ddPorcentaje, " > Max:", maxDrawdownPorcentaje);
            ok = OrderClose(OrderTicket(), OrderLots(), Bid,  slippage, clrRed);
           }
         else
            if(OrderType() == OP_SELL)
              {
               LogEnPantalla("🔴🔴🔴 SELL CERRADO POR CheckProteccionDrawdown() - Drawdown excedido");
               Print("🔴🔴🔴 SELL CERRADO POR DRAWDOWN | DD%:", ddPorcentaje, " > Max:", maxDrawdownPorcentaje);
               ok = OrderClose(OrderTicket(), OrderLots(), Ask,  slippage, clrRed);
              }


        }
     }
  }

//+------------------------------------------------------------------+
//| Selector de Martingala - Llama a la función apropiada           |
//+------------------------------------------------------------------+
double SeleccionarMartingala(int orderType = OP_BUY)
  {
   if(tipoMartingala == 0)
      return MartingalaClasica(orderType);
   else
      return MyMartingala(orderType);
  }

//+------------------------------------------------------------------+
//| Martingala Clásica - Multiplica el lotaje en cada pérdida       |
//+------------------------------------------------------------------+
double MartingalaClasica(int orderType = OP_BUY)
  {
   // NUEVO: Variables locales que apuntan a las correctas según orderType
   int numeroDeIntentos;
   if(orderType == OP_BUY)
      numeroDeIntentos = numeroDeIntentosBuy;
   else
      numeroDeIntentos = numeroDeIntentosSell;

   const int maxIntentos = maxLost;

   // Seleccionar multiplicador según el tipo de orden
   double multiplier = (orderType == OP_BUY) ? myMultiplierBuy : myMultiplierSell;

// Obtención de Información del Mercado y Cuenta
   double minlot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MaximalLots = 800.0;
   double lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);

// Calcular lotaje base dinámico (con o sin interés compuesto)
   double lotajeBaseActual = CalcularLotajeBase();
   double lotsCalculado = 0.0;

// Control de Pérdidas Máximas
   if(contadorPerdidas() > maxLost)
     {
      lotsCalculado = lotajeBaseActual;
      numeroDeIntentos = 0;
      LogEnPantalla("Pérdidas máximas alcanzadas (Clásica). Reset. Lotaje: "+ DoubleToString(lotsCalculado, 2));
      lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
      if(lotsCalculado < minlot)
         lotsCalculado = minlot;
      if(lotsCalculado > MaximalLots)
         lotsCalculado = MaximalLots;

      // Escribir de vuelta a variable global
      if(orderType == OP_BUY)
         numeroDeIntentosBuy = numeroDeIntentos;
      else
         numeroDeIntentosSell = numeroDeIntentos;

      return lotsCalculado;
     }

// Revisión del Historial de Órdenes - SOLO del tipo orderType
   for(int x = OrdersHistoryTotal() - 1; x >= 0; x--)
     {
      if(OrderSelect(x, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == orderType)
           {
            double prevLots = OrderLots();

            // CASO 1: Operación GANADORA
            if(OrderProfit() > 0)
              {
               // Reset a lotaje base
               lotsCalculado = lotajeBaseActual;
               numeroDeIntentos = 0;
               LogEnPantalla("Ganancia (Clásica). Reset. Lotaje: "+ DoubleToString(lotsCalculado, 2));

               // Normalizar y retornar
               lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
               if(lotsCalculado < minlot)
                  lotsCalculado = minlot;
               if(lotsCalculado > MaximalLots)
                  lotsCalculado = MaximalLots;

               // Escribir de vuelta a variable global
               if(orderType == OP_BUY)
                  numeroDeIntentosBuy = numeroDeIntentos;
               else
                  numeroDeIntentosSell = numeroDeIntentos;

               return lotsCalculado;
              }
            // CASO 2: Operación PERDEDORA
            else
              {
               if(!martingala)
                 {
                  lotsCalculado = lotajeBaseActual;
                  LogEnPantalla("Martingala desactivada (Clásica). Lotaje: "+ DoubleToString(lotsCalculado, 2));
                 }
               else
                 {
                  // Aplicar martingala si está activada y no se ha alcanzado el máximo de intentos
                  if(numeroDeIntentos < maxIntentos)
                    {
                     numeroDeIntentos++;
                     lotsCalculado = prevLots * multiplier;
                     string tipoOrden = (orderType == OP_BUY) ? "BUY" : "SELL";
                     LogEnPantalla("Pérdida (Clásica " + tipoOrden + "). Multiplicando: "+ DoubleToString(prevLots, 2) + " x " + DoubleToString(multiplier, 2) + " = " + DoubleToString(lotsCalculado, 2));
                    }
                  else
                    {
                     // Se alcanzó el máximo de intentos, volver al lotaje base
                     lotsCalculado = lotajeBaseActual;
                     numeroDeIntentos = 0;
                     LogEnPantalla("Máx intentos alcanzados (Clásica). Reset. Lotaje: "+ DoubleToString(lotsCalculado, 2));
                    }
                 }

               // Normalizar y retornar
               lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
               if(lotsCalculado < minlot)
                  lotsCalculado = minlot;
               if(lotsCalculado > MaximalLots)
                  lotsCalculado = MaximalLots;

               // Verificar margen
               double requiredMargin = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * lotsCalculado;
               if(AccountFreeMargin() < requiredMargin)
                 {
                  LogEnPantalla("Sin margen suficiente (Clásica). Usando lotaje mínimo: "+ DoubleToString(minlot, 2));

                  // Escribir de vuelta a variable global
                  if(orderType == OP_BUY)
                     numeroDeIntentosBuy = numeroDeIntentos;
                  else
                     numeroDeIntentosSell = numeroDeIntentos;

                  return minlot;
                 }

               // Escribir de vuelta a variable global
               if(orderType == OP_BUY)
                  numeroDeIntentosBuy = numeroDeIntentos;
               else
                  numeroDeIntentosSell = numeroDeIntentos;

               return lotsCalculado;
              }
           }
        }
     }

// Si no se encontró ninguna orden previa, establecer el lote base calculado
   if(lotsCalculado == 0.0)
     {
      lotsCalculado = lotajeBaseActual;
      numeroDeIntentos = 0;
      LogEnPantalla("Primera orden (Clásica). Lotaje: "+ DoubleToString(lotsCalculado, 2));
     }

// Normalizar SIEMPRE antes de retornar
   lotsCalculado = NormalizeDouble(lotsCalculado / lotstep, 0) * lotstep;
   if(lotsCalculado < minlot)
      lotsCalculado = minlot;
   if(lotsCalculado > MaximalLots)
      lotsCalculado = MaximalLots;

   // Escribir de vuelta a variable global
   if(orderType == OP_BUY)
      numeroDeIntentosBuy = numeroDeIntentos;
   else
      numeroDeIntentosSell = numeroDeIntentos;

   return lotsCalculado;
  }

// Filtro 1: horario seguro (si está fuera de 00:00–02:00 UTC)
bool filtro1()
  {
   int hora = TimeHour(TimeCurrent());
   return (hora < 0 || hora >= 2);
  }

// Filtro 2: evita entrar tras dos velas grandes y en misma dirección
bool filtro2()
  {
   double body1 = MathAbs(Open[1] - Close[1]);
   double body2 = MathAbs(Open[2] - Close[2]);
   bool mismaDireccion =
      (Close[1] > Open[1] && Close[2] > Open[2]) || // ambas alcistas
      (Close[1] < Open[1] && Close[2] < Open[2]);   // ambas bajistas
   return !(body1 > 7 && body2 > 7 && mismaDireccion);
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int operarSoloEn()
  {
   int numPerdidas = contadorPerdidas();

   if(numPerdidas == 0)
     {
      return 3;
     }
   else
     {
      for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
           {
            if(OrderSymbol() == Symbol() &&
               (OrderType() == OP_BUY || OrderType() == OP_SELL) &&
               OrderMagicNumber() == MagicNumber)
              {
               if(OrderProfit() < 0)
                 {
                  // Última operación con pérdida encontrada
                  if(OrderType() == OP_BUY)
                    {
                     return 1;
                    }
                  else
                     if(OrderType() == OP_SELL)
                       {
                        return 2;
                       }
                 }
              }
           }
        }
     }

// Si no hay pérdidas recientes, se permite operar libremente
   return 3;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool esZonaPeligrosaParaBuy()
  {
   double rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double upperBand = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double precioActual = Close[0];

   if(rsi > 70)
     {
      LogEnPantalla("Zona peligrosa para BUY: RSI sobre 70");
      LogEnPantalla("Zona peligrosa para BUY: RSI sobre 70");
      return true;
     }

   if(precioActual > upperBand)
     {
      LogEnPantalla("Zona peligrosa para BUY: Precio fuera de banda superior");
      LogEnPantalla("Zona peligrosa para BUY: Precio fuera de banda superior");
      return true;
     }

   return false; // zona segura
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool esZonaPeligrosaParaSell()
  {
   double rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double lowerBand = iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double precioActual = Close[0];

   if(rsi < 30)
     {
      LogEnPantalla("Zona peligrosa para SELL: RSI debajo de 30");
      LogEnPantalla("Zona peligrosa para SELL: RSI debajo de 30");
      return true;
     }

   if(precioActual < lowerBand)
     {
      LogEnPantalla("Zona peligrosa para SELL: Precio fuera de banda inferior");
      return true;
     }

   return false; // zona segura
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LogTriggerBuyDebug()
  {
   double kNow  = iStochastic(NULL, 0, 8, 3, 3, MODE_SMA, 1, MODE_MAIN, 1);
   double kPrev = iStochastic(NULL, 0, 8, 3, 3, MODE_SMA, 1, MODE_MAIN, 2);

   bool exitOS = (kPrev < OSLevel && kNow >= OSLevel); // salida de sobreventa
   bool condicionBuyNow = (highAlcista != EMPTY_VALUE && lowAlcista != EMPTY_VALUE);

   PrintFormat(
      "BUY  trigger dbg | kPrev=%.2f kNow=%.2f OB=%d OS=%d | seenOB=%d obThenOs=%d exitOS=%d | CondicionBuyNow=%d CondicionBuy(latched)=%d | readyBuy=%d",
      kPrev, kNow, OBLevel, OSLevel, G_seenOB, G_obThenOs, exitOS, condicionBuyNow, CondicionBuy, G_readyBuy
   );
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LogTriggerSellDebug()
  {
   double kNow  = iStochastic(NULL, 0, 8, 3, 3, MODE_SMA, 1, MODE_MAIN, 1);
   double kPrev = iStochastic(NULL, 0, 8, 3, 3, MODE_SMA, 1, MODE_MAIN, 2);

   bool exitOB = (kPrev > OBLevel && kNow <= OBLevel); // salida de sobrecompra
   bool condicionSellNow = (highBajista != EMPTY_VALUE && lowBajista != EMPTY_VALUE);

   PrintFormat(
      "SELL trigger dbg | kPrev=%.2f kNow=%.2f OB=%d OS=%d | seenOS=%d osThenOb=%d exitOB=%d | CondicionSellNow=%d CondicionSell(latched)=%d | readySell=%d",
      kPrev, kNow, OBLevel, OSLevel, G_seenOS, G_osThenOb, exitOB, condicionSellNow, CondicionSell, G_readySell
   );
  }

//+------------------------------------------------------------------+
//| Funciones de Filtro Modulares para IsMarketSafe()               |
//+------------------------------------------------------------------+
bool FiltroEMATrenzada(int lookback, int maxCruces)
  {
   int crossCount = 0;
   for(int i=1; i<lookback; i++)
     {
      double fNow  = iMA(NULL,0,9,0,MODE_EMA,PRICE_CLOSE,i);
      double sNow  = iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,i);
      double fPrev = iMA(NULL,0,9,0,MODE_EMA,PRICE_CLOSE,i+1);
      double sPrev = iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,i+1);

      bool crossUp   = fPrev < sPrev && fNow > sNow;
      bool crossDown = fPrev > sPrev && fNow < sNow;
      if(crossUp || crossDown)
         crossCount++;
     }
   if(crossCount >= maxCruces)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroRangoAdaptativo(int lookback, double atr, double minRangeFactorATR)
  {
   double rangeHigh = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,lookback,0));
   double rangeLow  = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,lookback,0));
   double range = rangeHigh - rangeLow;

   if(range < (atr * minRangeFactorATR))
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroPrecioPegadoEMA(int lookback, double atr, double distFactorATR, double maxRatio)
  {
   int touches = 0;
   for(int i=1; i<lookback; i++)
     {
      double emaMid = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,i);
      double dist = MathAbs(Close[i] - emaMid);

      if(dist < (atr * distFactorATR))
         touches++;
     }
   if(touches > lookback * maxRatio)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroSlopeEMA(double atr, double minSlopeFactorATR)
  {
   double emaNow  = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0);
   double emaPast = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,5);
   double slope = MathAbs(emaNow - emaPast) / 5;

   if(slope < atr * minSlopeFactorATR)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroAnguloEMA(double point, double minGrados)
  {
// Protección contra división por cero
   if(point <= 0)
      return(true); // Si point es inválido, permitir operación

   double emaNow  = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0);
   double emaPast = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,5);
   double rawSlope = emaNow - emaPast;
   double doublePoint = 5 * point;

// Protección adicional contra división por cero
   if(doublePoint == 0)
      return(true);

   double angle = MathAbs(MathArctan(rawSlope / doublePoint)) * 57.2958;

   if(angle < minGrados)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroCanalEstrecho(int lookback, double atr, double factorATR, double maxRatioCentral)
  {
   double rangeHigh = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,lookback,0));
   double rangeLow  = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,lookback,0));
   double range = rangeHigh - rangeLow;
   double mid = rangeLow + (range / 2.0);
   int centerTouches = 0;

   for(int i=1; i<lookback; i++)
     {
      if(MathAbs(Close[i] - mid) < (atr * factorATR))
         centerTouches++;
     }
   if(centerTouches > lookback * maxRatioCentral)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroAlternanciaVelas(int lookback, double maxRatioAlternancia)
  {
   int alternations = 0;
   for(int i=1; i<lookback; i++)
     {
      bool upNow  = Close[i] > Open[i];
      bool upPrev = Close[i+1] > Open[i+1];

      if(upNow != upPrev)
         alternations++;
     }
   if(alternations > lookback * maxRatioAlternancia)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroMechasLargas()
  {
   double body = MathAbs(Open[1] - Close[1]);
   double wickUp = High[1] - MathMax(Open[1], Close[1]);
   double wickDown = MathMin(Open[1], Close[1]) - Low[1];

// mecha mayor que cuerpo × factor = ruptura falsa
   if(wickUp > body * filtroMechasFactorCuerpo || wickDown > body * filtroMechasFactorCuerpo)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroCuerpoMinimo(double minFactorAltura)
  {
   double body = MathAbs(Open[1] - Close[1]);
   if(body < alturaPromedio * minFactorAltura)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroFaltaContinuacion(double minFactorAltura)
  {
   double continuation = MathAbs(Close[1] - Close[3]);
   if(continuation < alturaPromedio * minFactorAltura)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroRetrocesoInmediato(double maxFactorAltura)
  {
   double retroceso = MathAbs(Close[0] - Close[1]);
   if(retroceso > alturaPromedio * maxFactorAltura)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiltroAceleracionReal(double minFactorAltura)
  {
   double accel = MathAbs(Close[0] - Close[2]);
   if(accel < alturaPromedio * minFactorAltura)
      return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//| Fin Funciones de Filtro Modulares                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsMarketSafe()
  {
   if(!detectarRangoHorizontal)
     {

      return(true);
     }

   double point = MarketInfo(Symbol(), MODE_POINT);
   double atr   = iATR(NULL,0,14,0);

   if(alturaPromedio <= 0)
      alturaPromedio = atr * 1.2;


   if(usarFiltroEMATrenzada &&
      !FiltroEMATrenzada(filtroLookback, filtroEMATrenzadaMaxCruces))
     {
      return(false);
     }

   if(usarFiltroRangoAdaptativo &&
      !FiltroRangoAdaptativo(filtroLookback, atr, filtroRangoMinMultiplicadorATR))
     {
      return(false);
     }

   if(usarFiltroPrecioPegadoEMA &&
      !FiltroPrecioPegadoEMA(filtroLookback, atr, filtroPrecioPegadoFactorATR, filtroPrecioPegadoMaxRatio))
     {
      return(false);
     }

   if(usarFiltroSlopeEMA &&
      !FiltroSlopeEMA(atr, filtroSlopeMinFactorATR))
     {
      return(false);
     }

   if(usarFiltroAnguloEMA &&
      !FiltroAnguloEMA(point, filtroAnguloMinGrados))
     {
      return(false);
     }

   if(usarFiltroCanalEstrecho &&
      !FiltroCanalEstrecho(filtroLookback, atr, filtroCanalFactorATR, filtroCanalMaxRatioCentral))
     {
      return(false);
     }

   if(usarFiltroAlternanciaVelas &&
      !FiltroAlternanciaVelas(filtroLookback, filtroAlternanciaMaxRatio))
     {
      return(false);
     }

   if(usarFiltroMechasLargas &&
      !FiltroMechasLargas())
     {
      return(false);
     }

   if(usarFiltroCuerpoMinimo &&
      !FiltroCuerpoMinimo(filtroCuerpoMinFactorAltura))
     {
      return(false);
     }

   if(usarFiltroFaltaContinuacion &&
      !FiltroFaltaContinuacion(filtroContinuacionMinFactorAlt))
     {
      return(false);
     }

   if(usarFiltroRetrocesoInmediato &&
      !FiltroRetrocesoInmediato(filtroRetrocesoMaxFactorAlt))
     {
      return(false);
     }

   if(usarFiltroAceleracionReal &&
      !FiltroAceleracionReal(filtroAceleracionMinFactorAlt))
     {
      return(false);
     }

   return(true);
  }




//+------------------------------------------------------------------+
//| Función para actualizar la visualización del estado del mercado |
//+------------------------------------------------------------------+
void UpdateMarketSafeVisual()
  {
   bool isSafe = IsMarketSafe();
   string nombreRect = "marketsafe_rect";
   string nombreLabel = "marketsafe_label";

// Posición: debajo del panel TP/SL
   int mercadoX = 10;
   int mercadoY = 30 + 135 + 25 + 5 + 25 + 5 + 25 + 5; // Debajo del panel TP/SL

   string textoMercado = "Mercado Horizontal";

// Color verde cuando es seguro, rojo cuando no es seguro
   color colorFondoMercado = isSafe ? C'50,180,50' : C'180,50,50'; // Verde o rojo semitransparente
   color colorTextoMercado = clrYellow;

// Eliminar objetos si existen
   ObjectDelete(0, nombreRect);
   ObjectDelete(0, nombreLabel);

// Fondo
   ObjectCreate(0, nombreRect, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nombreRect, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nombreRect, OBJPROP_XDISTANCE, mercadoX);
   ObjectSetInteger(0, nombreRect, OBJPROP_YDISTANCE, mercadoY);
   ObjectSetInteger(0, nombreRect, OBJPROP_XSIZE, 450);
   ObjectSetInteger(0, nombreRect, OBJPROP_YSIZE, 25);
   ObjectSetInteger(0, nombreRect, OBJPROP_COLOR, colorFondoMercado);
   ObjectSetInteger(0, nombreRect, OBJPROP_BACK, true);
   ObjectSetInteger(0, nombreRect, OBJPROP_BGCOLOR, colorFondoMercado);
   ObjectSetInteger(0, nombreRect, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, nombreRect, OBJPROP_WIDTH, 1);

// Texto
   ObjectCreate(0, nombreLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nombreLabel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nombreLabel, OBJPROP_XDISTANCE, mercadoX + 5);
   ObjectSetInteger(0, nombreLabel, OBJPROP_YDISTANCE, mercadoY + 6);
   ObjectSetInteger(0, nombreLabel, OBJPROP_COLOR, colorTextoMercado);
   ObjectSetInteger(0, nombreLabel, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, nombreLabel, OBJPROP_TEXT, textoMercado);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CrearOrdenes()
  {
// ===== Variables locales =====
   bool condicionBuyIchu = false;
   bool condicionSellIchu = false;
   bool condicionBuyMedia = false;
   bool condicionSellMedia = false;
   bool CondicionStop = false;

   double precioCompra = 0;
   double precioVenta  = 0;

   bool enterUp = false;
   bool enterDown = false;

   const int DAY_SECONDS = CantHorasEspera * 60;
   datetime now = TimeCurrent();

   int i = 1; // usar vela cerrada para MAs y Stoch
   double currentPrice = iClose(NULL, 0, 0);

// ===== Medias (lo que ya tenías) =====
   double media35Amarillo = iMA(NULL, 0, 35, 0, MODE_EMA, PRICE_CLOSE, i);
   double media50Rojo     = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, i);
   double mediaPrice      = iMA(NULL, 0, 1,  0, MODE_SMA, PRICE_CLOSE, i);
   double media200        = iMA(NULL, 0, 200,0, MODE_SMA, PRICE_CLOSE, i);

// ====== Stochastic Close/Close (línea principal %K) - SMOOTH ======
   double kNow  = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 1);
   double kPrev = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 2);

// ====== Actualizar máquina de estados STOCH global ======
   if(kNow > OBLevel)
      G_seenOB = true;
   if(kNow < OSLevel)
      G_seenOS = true;

// CORREGIDO: Para BUY necesitamos Stochastic en zona baja (0-50)
// Para SELL necesitamos Stochastic en zona alta (50-100)

// Detectar entrada en sobreventa para BUY
   if(kNow < OSLevel)
      G_obThenOs = true; // camino BUY - Stochastic en zona baja

// Detectar entrada en sobrecompra para SELL
   if(kNow > OBLevel)
      G_osThenOb = true; // camino SELL - Stochastic en zona alta

   bool kInOS = (kNow <= OSLevel);  // Está en sobreventa (<10)
   bool kInOB = (kNow >= OBLevel);  // Está en sobrecompra (>90)

// CORREGIDO: Solo activar cuando hay FVG + Stochastic en zona correcta
// BUY: Stochastic debe estar en zona baja (< 50) con pendiente positiva
// SELL: Stochastic debe estar en zona alta (> 50) con pendiente negativa

   G_readyBuy  = (CondicionBuy && G_obThenOs && kInOS);
   G_readySell = (CondicionSell && G_osThenOb && kInOB);

// ====== Tu condición base de “inicio” (LATCH) ======
// Se encienden cuando “aparece” el setup; no se apagan aquí.
   bool CondicionBuyNow  = (highAlcista  != EMPTY_VALUE && lowAlcista  != EMPTY_VALUE);
   bool CondicionSellNow = (highBajista  != EMPTY_VALUE && lowBajista != EMPTY_VALUE);

   if(CondicionBuyNow)
      CondicionBuy  = true;  // <-- global, persiste
   if(CondicionSellNow)
      CondicionSell = true;  // <-- global, persiste

// ===== Filtros extra que ya usabas =====
   // RESTRICCIÓN ELIMINADA: Ahora se permiten compras y ventas simultáneas sin restricción de MA200
   condicionBuyMedia  = true;  // Sin restricción de media200
   condicionSellMedia = true;  // Sin restricción de media200

// int numPerdidas = contadorPerdidas();
   int soloEn = operarSoloEn();

// Detectar inicio de nuevos ciclos
   static bool ultimoCondicionBuy = false;
   static bool ultimoCondicionSell = false;

// Debug: Mostrar estado de FVG cada tick
   static int debugCounter = 0;
   debugCounter++;


   if(CondicionBuyNow && !ultimoCondicionBuy)
     {
      LogEnPantalla("🟢 CICLO ALCISTA INICIADO - FVG detectado en sobrecompra");
     }

   if(CondicionSellNow && !ultimoCondicionSell)
     {
      LogEnPantalla("🔴 CICLO BAJISTA INICIADO - FVG detectado en sobreventa");
     }

   ultimoCondicionBuy = CondicionBuyNow;
   ultimoCondicionSell = CondicionSellNow;

// Verificar si hay vela grande (evitar operar en velas fuertes)
// Evaluamos tanto la vela actual como la anterior para máxima protección
   bool velaGrandeActual = EsVelaGrande(0);  // Vela actual
   bool velaGrandeAnterior = EsVelaGrande(1); // Vela anterior
   bool velaGrande = velaGrandeActual || velaGrandeAnterior; // Cualquiera de las dos

   double rangoVelaActual = (High[0] - Low[0]) / Point;
   double rangoVelaAnterior = (High[1] - Low[1]) / Point;

// Aplicar restricción de vela grande solo si está habilitada
   bool restriccionVela = usarRestriccionVelaGrande ? !velaGrande : true;

// Evaluar filtros de tendencia ANTES de mostrar estado
   bool filtrosBuyOK = false;
   bool filtrosSellOK = false;

   if(usarFiltrosTendencia)
     {
      filtrosBuyOK = evaluarFiltrosTendencia(1);
      filtrosSellOK = evaluarFiltrosTendencia(2);
     }
   else
     {
      filtrosBuyOK = true;
      filtrosSellOK = true;
     }

// Calcular pendiente MA200 para mostrar
   double pendienteMA200 = 0;
   string pendienteTexto = "N/A";
   if(usarFiltroPendienteMA200)
     {
      int lb = MathMax(2, pendienteLookbackBars);
      double ma_now = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 1);
      double ma_then = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 1 + lb);
      pendienteMA200 = (ma_now - ma_then) / (lb * Point); // pips por barra

      double umbral = pendienteMinPipsPorBarra;
      if(pendienteMA200 > umbral)
         pendienteTexto = DoubleToStr(pendienteMA200, 2) + " pips/barra (Alcista)";
      else
         if(pendienteMA200 < -umbral)
            pendienteTexto = DoubleToStr(pendienteMA200, 2) + " pips/barra (Bajista)";
         else
            pendienteTexto = DoubleToStr(pendienteMA200, 2) + " pips/barra (Lateral)";
     }

// Calcular tendencia corta con MA50
   string tendenciaCortaTexto = "N/A";
   if(usarFiltroMA50)
     {
      double precioActual = iClose(NULL, 0, 1); // Precio de cierre de la vela anterior
      double ma50_actual = iMA(NULL, 0, periodoMA50, 0, MODE_SMA, PRICE_CLOSE, 1);

      if(precioActual > ma50_actual)
         tendenciaCortaTexto = "MA" + IntegerToString(periodoMA50) + " (Alcista)";
      else
         if(precioActual < ma50_actual)
            tendenciaCortaTexto = "MA" + IntegerToString(periodoMA50) + " (Bajista)";
         else
            tendenciaCortaTexto = "MA" + IntegerToString(periodoMA50) + " (Lateral)";
     }

// Calcular valor del estocástico para display (necesario fuera del bloque)
   double stochDisplayNow = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 1);

// Calcular estado de medias para entrada por alineación
   string estadoMediasTexto = "N/A";
   if(usarEntradaPorMedias)
     {
      int tendenciaMAUltraCorta = CalcularTendenciaMA(periodoMAUltraCorta, barrasParaTendencia);
      int tendenciaMACorta = CalcularTendenciaMA(periodoMACorta, barrasParaTendencia);
      int tendenciaMALarga = CalcularTendenciaMA(periodoMALarga, barrasParaTendencia);

      string textoUltraCorta = (tendenciaMAUltraCorta == 1 ? "Alcista" : tendenciaMAUltraCorta == -1 ? "Bajista" : "Lateral");
      string textoCorta = (tendenciaMACorta == 1 ? "Alcista" : tendenciaMACorta == -1 ? "Bajista" : "Lateral");
      string textoLarga = (tendenciaMALarga == 1 ? "Alcista" : tendenciaMALarga == -1 ? "Bajista" : "Lateral");

      // Información adicional del precio vs MA200 y estocástico
      double precioActual = iClose(NULL, 0, 1);
      double ma200_actual = iMA(NULL, 0, periodoMALarga, 0, MODE_SMA, PRICE_CLOSE, 1);
      // Calcular pendiente de MA200 para detectar rango
      int lbCol = MathMax(2, pendienteLookbackBars);
      double ma200_then = iMA(NULL, 0, periodoMALarga, 0, MODE_SMA, PRICE_CLOSE, 1 + lbCol);
      double slopeMA200 = (ma200_actual - ma200_then) / (lbCol * Point); // pips/barra
      bool esRango = evitarRangoMA200 && MathAbs(slopeMA200) < pendienteMinPipsPorBarra;
      string textoPrecio = (precioActual > ma200_actual ? "Encima" : precioActual < ma200_actual ? "Debajo" : "Igual");

      // Información del estocástico
      string textoStoch = "Stoch:" + DoubleToStr(stochDisplayNow, 1) + " OB:" + (G_seenOB ? "✅" : "❌") + " OS:" + (G_seenOS ? "✅" : "❌");

      estadoMediasTexto = "MA" + IntegerToString(periodoMAUltraCorta) + ":" + textoUltraCorta + " | MA" + IntegerToString(periodoMACorta) + ":" + textoCorta + " | MA" + IntegerToString(periodoMALarga) + ":" + textoLarga + " | Precio:" + textoPrecio + " | " + textoStoch;
     }

// Preparar información de medias en columnas
   string infoMedias = "";
   if(usarEntradaPorMedias)
     {
      int tendenciaMAUltraCorta = CalcularTendenciaMA(periodoMAUltraCorta, barrasParaTendencia);
      int tendenciaMACorta = CalcularTendenciaMA(periodoMACorta, barrasParaTendencia);
      int tendenciaMALarga = CalcularTendenciaMA(periodoMALarga, barrasParaTendencia);

      string textoUltraCorta = (tendenciaMAUltraCorta == 1 ? "Alcista ↗" : tendenciaMAUltraCorta == -1 ? "Bajista ↘" : "Lateral →");
      string textoCorta = (tendenciaMACorta == 1 ? "Alcista ↗" : tendenciaMACorta == -1 ? "Bajista ↘" : "Lateral →");
      string textoLarga = (tendenciaMALarga == 1 ? "Alcista ↗" : tendenciaMALarga == -1 ? "Bajista ↘" : "Lateral →");

      double precioActual = iClose(NULL, 0, 1);
      double ma200_actual = iMA(NULL, 0, periodoMALarga, 0, MODE_SMA, PRICE_CLOSE, 1);
      string textoPrecio = (precioActual > ma200_actual ? "Encima ✅" : precioActual < ma200_actual ? "Debajo ⬇" : "Igual");
      // Calcular si la MA200 está en rango (pendiente casi 0)
      int lbCol = MathMax(2, pendienteLookbackBars);
      double ma200_then = iMA(NULL, 0, periodoMALarga, 0, MODE_SMA, PRICE_CLOSE, 1 + lbCol);
      double slopeMA200 = (ma200_actual - ma200_then) / (lbCol * Point); // pips/barra
      bool esRango = evitarRangoMA200 && MathAbs(slopeMA200) < pendienteMinPipsPorBarra;

      // Verificar alineación completa
      bool alineacionBuy = (tendenciaMAUltraCorta == 1 && tendenciaMACorta == 1 && tendenciaMALarga == 1);
      bool alineacionSell = (tendenciaMAUltraCorta == -1 && tendenciaMACorta == -1 && tendenciaMALarga == -1);
      string estadoAlineacion = esRango ? "RANGO (MA200 plana) ⛔" : (alineacionBuy ? "ALINEADO BUY ✅" : alineacionSell ? "ALINEADO SELL ✅" : "Sin alineación ❌");

      // Estado de banderas
      string estadoBanderas = "Banderas: MA-BUY:" + (G_mediasAlineadasBuy ? "✅" : "❌") +
                              " | MA-SELL:" + (G_mediasAlineadasSell ? "✅" : "❌") +
                              " | Stoch-BUY:" + (G_stochBuyFlag ? "✅" : "❌") +
                              " | Stoch-SELL:" + (G_stochSellFlag ? "✅" : "❌");

      infoMedias = "═══ MEDIAS MÓVILES ═══\n" +
                   "   MA5  (" + IntegerToString(periodoMAUltraCorta) + "): " + textoUltraCorta + "\n" +
                   "   MA50 (" + IntegerToString(periodoMACorta) + "): " + textoCorta + "\n" +
                   "   MA200(" + IntegerToString(periodoMALarga) + "): " + textoLarga + "\n" +
                   "   Precio vs MA200: " + textoPrecio + "\n" +
                   "   Estado: " + estadoAlineacion + "\n" +
                   (esRango ? "   Nota: Rango activo, entradas bloqueadas\n" : "") +
                   "   " + estadoBanderas;
     }
   else
     {
      infoMedias = "Sistema: FVG + Stochastic (modo legacy)";
     }

// NO mostrar información en pantalla - solo mostrar el cuadrito del Stochastic
   Comment("");

// Dibujar líneas visuales de filtros
   dibujarLineasTPSL();

// ===== Filtro: Pendiente de MA200 =====
   bool pendienteOkBuy = true;
   bool pendienteOkSell = true;
   if(usarFiltroPendienteMA200)
     {
      int lb = MathMax(2, pendienteLookbackBars);
      double ma_now = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 1);
      double ma_then = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 1 + lb);
      double pendiente = (ma_now - ma_then) / (lb * Point); // pips por barra
      double umbral = pendienteMinPipsPorBarra;
      pendienteOkBuy  = (pendiente >  umbral); // favor alcista
      pendienteOkSell = (pendiente < -umbral); // favor bajista
     }

// ===== Filtro: Tendencia corta con MA50 =====
   bool tendenciaCortaOkBuy = true;
   bool tendenciaCortaOkSell = true;
   if(usarFiltroMA50)
     {
      double precioActual = iClose(NULL, 0, 1); // Precio de cierre de la vela anterior
      double ma50_actual = iMA(NULL, 0, periodoMA50, 0, MODE_SMA, PRICE_CLOSE, 1);

      tendenciaCortaOkBuy = (precioActual > ma50_actual);  // Precio por encima de MA50 = alcista
      tendenciaCortaOkSell = (precioActual < ma50_actual); // Precio por debajo de MA50 = bajista
     }

// ===== Sistema de Entrada por Alineación de Medias =====
   if(usarEntradaPorMedias)
     {
      Print(">>> DEBUG: Entrando a bloque usarEntradaPorMedias");
      // Calcular tendencia de las tres medias
      int tendenciaMAUltraCorta = CalcularTendenciaMA(periodoMAUltraCorta, barrasParaTendencia);
      int tendenciaMACorta = CalcularTendenciaMA(periodoMACorta, barrasParaTendencia);
      int tendenciaMALarga = CalcularTendenciaMA(periodoMALarga, barrasParaTendencia);

      // Condición adicional: precio vs MA200
      double precioActual = iClose(NULL, 0, 0); // Precio actual (vela en formación)
      double ma200_actual = iMA(NULL, 0, periodoMALarga, 0, MODE_SMA, PRICE_CLOSE, 0); // MA200 actual
      bool precioEncimaMA200 = (precioActual > ma200_actual);
      bool precioDebajoMA200 = (precioActual < ma200_actual);

      // Condición adicional: Estocástico (camino completo como en OptimusExtreme) - SMOOTH
      double stochNow  = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 1);
      double stochPrev = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 2);

      // Actualizar máquina de estados STOCH global
      if(stochNow > OBLevel)
         G_seenOB = true;
      if(stochNow < OSLevel)
         G_seenOS = true;

      // CORREGIDO: Para BUY necesitamos Stochastic en zona baja (0-50)
      // Para SELL necesitamos Stochastic en zona alta (50-100)
      // Cambiamos la lógica: BUY cuando está en OS, SELL cuando está en OB

      // Detectar entrada en sobreventa para BUY
      if(stochNow < OSLevel)
         G_obThenOs = true; // camino BUY - Stochastic en zona baja

      // Detectar entrada en sobrecompra para SELL
      if(stochNow > OBLevel)
         G_osThenOb = true; // camino SELL - Stochastic en zona alta

      // Cambiamos las condiciones de salida
      bool stochInOS = (stochNow <= OSLevel);  // Está en sobreventa (<10)
      bool stochInOB = (stochNow >= OBLevel);  // Está en sobrecompra (>90)

      // ===== SISTEMA DE BANDERAS POR ETAPAS =====

      // ETAPA 1: Verificar alineación de medias (se activa cuando se alinean)
      bool mediasAlcistas = (tendenciaMAUltraCorta == 1 && tendenciaMACorta == 1 && tendenciaMALarga == 1);
      bool mediasBajistas = (tendenciaMAUltraCorta == -1 && tendenciaMACorta == -1 && tendenciaMALarga == -1);

      // ⚠️ ANULAR BANDERAS SI LAS CONDICIONES CAMBIAN ⚠️
      // CORREGIDO: Resetear si YA NO hay alineación alcista (más estricto)
      if(G_mediasAlineadasBuy && !mediasAlcistas)
        {
         LogEnPantalla("=⚠️ Banderas BUY reseteadas - No hay alineación");
         G_mediasAlineadasBuy = false;
         G_stochBuyFlag = false;
         G_seenOB = false;
         G_phantomBuyDetected = false; // RESETEAR phantom al perder alineación
         // NO resetear G_obThenOs - se mantiene activo mientras Stochastic esté en zona


         // NUEVO: Re-evaluar inmediatamente si se recuperó la alineación
         if(mediasAlcistas && precioEncimaMA200)
           {
            G_mediasAlineadasBuy = true;
            LogEnPantalla("=✅ Banderas BUY reactivadas - Alineación alcista");
            // NUEVO: Al reactivar, es un nuevo ciclo, limpiar phantom
            G_phantomBuyDetected = false;
           }
        }

      // CORREGIDO: Resetear si YA NO hay alineación bajista (más estricto)
      if(G_mediasAlineadasSell && !mediasBajistas)
        {
         LogEnPantalla("=⚠️ Banderas SELL reseteadas - No hay alineación");
         G_mediasAlineadasSell = false;
         G_stochSellFlag = false;
         G_seenOS = false;
         G_phantomSellDetected = false; // RESETEAR phantom al perder alineación
         // NO resetear G_osThenOb - se mantiene activo mientras Stochastic esté en zona


         // NUEVO: Re-evaluar inmediatamente si se recuperó la alineación
         if(mediasBajistas && precioDebajoMA200)
           {
            G_mediasAlineadasSell = true;
            LogEnPantalla("=✅ Banderas SELL reactivadas - Alineación bajista");
            // NUEVO: Al reactivar, es un nuevo ciclo, limpiar phantom
            G_phantomSellDetected = false;
           }
        }

      // ADICIONAL: Resetear también si el precio cruza MA200 en contra
      if(G_mediasAlineadasBuy && precioDebajoMA200)
        {
         LogEnPantalla("=⚠️ Banderas BUY reseteadas - Precio < MA200");
         G_mediasAlineadasBuy = false;
         G_stochBuyFlag = false;
         G_seenOB = false;
         G_phantomBuyDetected = false; // RESETEAR phantom al cruzar MA200
         // NO resetear G_obThenOs - se mantiene activo mientras Stochastic esté en zona


         // NUEVO: Re-evaluar inmediatamente si volvió arriba
         if(mediasAlcistas && precioEncimaMA200)
           {
            G_mediasAlineadasBuy = true;
            LogEnPantalla("=✅ Banderas BUY reactivadas - Precio > MA200");
            // NUEVO: Al reactivar, es un nuevo ciclo, limpiar phantom
            G_phantomBuyDetected = false;
           }
        }

      if(G_mediasAlineadasSell && precioEncimaMA200)
        {
         LogEnPantalla("=⚠️ Banderas SELL reseteadas - Precio > MA200");
         G_mediasAlineadasSell = false;
         G_stochSellFlag = false;
         G_seenOS = false;
         G_phantomSellDetected = false; // RESETEAR phantom al cruzar MA200
         // NO resetear G_osThenOb - se mantiene activo mientras Stochastic esté en zona


         // NUEVO: Re-evaluar inmediatamente si volvió abajo
         if(mediasBajistas && precioDebajoMA200)
           {
            G_mediasAlineadasSell = true;
            LogEnPantalla("=✅ Banderas SELL reactivadas - Precio < MA200");
            // NUEVO: Al reactivar, es un nuevo ciclo, limpiar phantom
            G_phantomSellDetected = false;
           }
        }
      // CORREGIDO: Para BUY necesitamos medias alcistas Y precio POR ENCIMA de MA200
      if(mediasAlcistas && precioEncimaMA200)
         G_mediasAlineadasBuy = true;  // Bandera: medias listas para BUY

      // CORREGIDO: Para SELL necesitamos medias bajistas Y precio POR DEBAJO de MA200
      if(mediasBajistas && precioDebajoMA200)
         G_mediasAlineadasSell = true; // Bandera: medias listas para SELL

      // DEBUG: Log cuando se activan las banderas
      if(mediasAlcistas && precioEncimaMA200 && !G_mediasAlineadasBuy)
        {
         G_mediasAlineadasBuy = true;
        }

      if(mediasBajistas && precioDebajoMA200 && !G_mediasAlineadasSell)
        {
         G_mediasAlineadasSell = true;
        }

      // ETAPA 2: Verificar Stochastic para BUY/SELL - SISTEMA DE BANDERAS PERSISTENTES
      // Las banderas se activan al SALIR de la zona y solo se desactivan al entrar en zona contraria

      // Detectar SALIDA de sobreventa (OS) - momento de activar bandera BUY
      bool salidaDeOS = (stochPrev < OSLevel && stochNow >= OSLevel);  // Salió de <10

      // Detectar SALIDA de sobrecompra (OB) - momento de activar bandera SELL
      bool salidaDeOB = (stochPrev > OBLevel && stochNow <= OBLevel);  // Salió de >90

      // Detectar ENTRADA en sobrecompra (OB) - momento de desactivar bandera BUY
      bool entradaEnOB = (stochNow > OBLevel);

      // Detectar ENTRADA en sobreventa (OS) - momento de desactivar bandera SELL
      bool entradaEnOS = (stochNow < OSLevel);

      // LÓGICA CON SECUENCIA Y PENDIENTE:
      // La bandera depende de la pendiente del Stochastic y su posición

      int zonaMedia = 50;
      bool pendientePositiva = (stochNow > stochPrev); // Subiendo
      bool pendienteNegativa = (stochNow < stochPrev); // Bajando

      // ===== SIMPLIFICADO: Bandera Stochastic basada en PENDIENTE (slope) =====
      // Como dice el usuario: "la pendiente es el precio en sí"
      bool stochSubiendo = (stochNow > stochPrev);  // Pendiente positiva
      bool stochBajando  = (stochNow < stochPrev);  // Pendiente negativa

      // BANDERA SCHO (Stochastic):
      // Verde = Stochastic subiendo
      // Roja  = Stochastic bajando
      if(stochSubiendo && stochNow < OSLevel)  // BUY: zona baja (0-50) + pendiente positiva
        {
         G_stochBuyFlag = true;
         G_stochSellFlag = false;
        }
      else
         if(stochBajando && stochNow > OBLevel)  // SELL: zona alta (50-100) + pendiente negativa
           {
            G_stochBuyFlag = false;
            G_stochSellFlag = true;
           }
      // Zona neutral: NO cambiar flags, mantener estado actual del ciclo

      // ===== CORREGIDO: Sistema de Mega-Banderas basado en ALINEACIÓN EN TIEMPO REAL =====
      // MEGA-BUY: Activar solo si las TRES medias son alcistas
      if(mediasAlcistas && precioEncimaMA200)
         G_megaBuyFlag = true;
      else
        {
         if(G_megaBuyFlag)
            LogEnPantalla("=⚠️ MEGA-BUY desactivada - Alineación perdida");
         G_megaBuyFlag = false;
        }

      // MEGA-SELL: Activar solo si las TRES medias son bajistas
      if(mediasBajistas && precioDebajoMA200)
        {
         G_megaSellFlag = true; // ACTIVAR mega-bandera SELL
        }
      else
        {
         if(G_megaSellFlag)
            LogEnPantalla("=⚠️ MEGA-SELL desactivada - Alineación perdida");
         G_megaSellFlag = false;
        }

      // Verificar si hay posiciones abiertas para saber cuándo resetear
      bool hayPosicionesBuy = (ContadordeBuys() > 0);
      bool hayPosicionesSell = (ContadordeSells() > 0);

      // Si NO hay posiciones, resetear las banderas MEGA
      static bool ultimaHayPosicionesBuy = false;
      static bool ultimaHayPosicionesSell = false;

      if(!hayPosicionesBuy && ultimaHayPosicionesBuy)
        {
         // Se cerraron todas las posiciones BUY, resetear bandera MEGA
         G_megaBuyFlag = false;
         G_phantomBuyDetected = false; // RESETEAR bandera de phantom al resetear MEGA
        }

      if(!hayPosicionesSell && ultimaHayPosicionesSell)
        {
         // Se cerraron todas las posiciones SELL, resetear bandera MEGA
         G_megaSellFlag = false;
         G_phantomSellDetected = false; // RESETEAR bandera de phantom al resetear MEGA
        }

      ultimaHayPosicionesBuy = hayPosicionesBuy;
      ultimaHayPosicionesSell = hayPosicionesSell;

      // ===== NUEVO: Calcular pendiente de MA1 (PRECIO EN BRUTO) como GATILLO FINAL =====
      // El gatillo final es el cruce de MA8 con MA5
      // Orden: 1) BANDERA ESTOCASTICO (inicia ciclo), 2) MEGA-BANDERA (confirma), 3) CRUCE MA8xMA5 (ejecuta)
      double ma8_now  = iMA(NULL, 0, MediumMA, 0, MediumMode, PRICE_CLOSE, 0);  // MA8 (la media)
      double ma5_now  = iMA(NULL, 0, FasterMA, 0, FasterMode, PRICE_CLOSE, 0);  // MA5 (la más rápida)

      // Gatillo (trigger) basado en posición relativa MA8 vs MA5:
      // BUY:  MA8 por encima de MA5 (cruce alcista)
      // SELL: MA8 por debajo de MA5 (cruce bajista)
      bool ma1GatilloBuy  = usarMegaComoGatillo ? true : (ma8_now > ma5_now);  // MEGA como gatillo o cruce MA8xMA5  // MA8 cruza por encima de MA5
      bool ma1GatilloSell = usarMegaComoGatillo ? true : (ma8_now < ma5_now);  // MEGA como gatillo o cruce MA8xMA5  // MA8 cruza por debajo de MA5

      // Verificar pendiente del Stochastic para ejecutar
      bool stochPendientePositiva = (stochNow > stochPrev);  // Subiendo
      bool stochPendienteNegativa = (stochNow < stochPrev);  // Bajando

      // CONDICIONES FINALES DE ENTRADA
      bool stochListoParaBuy  = (G_megaBuyFlag && (banderaEstocastico ? G_stochBuyFlag : true) && ma1GatilloBuy);
      bool stochListoParaSell = (G_megaSellFlag && (banderaEstocastico ? G_stochSellFlag : true) && ma1GatilloSell);



      // Mostrar cuadrito MEGA (arriba de todo) - SIEMPRE usar banderas globales
      static bool ultimoMegaBuy = false;
      static bool ultimoMegaSell = false;

      // Log cuando cambien las banderas MEGA
      if(ultimoMegaBuy != G_megaBuyFlag || ultimoMegaSell != G_megaSellFlag)
        {
         MostrarBanderaMEGA(G_megaBuyFlag, G_megaSellFlag);
         ultimoMegaBuy = G_megaBuyFlag;
         ultimoMegaSell = G_megaSellFlag;
        }

      // Forzar actualización visual SIEMPRE (mostrar según banderas globales)
      MostrarBanderaMEGA(G_megaBuyFlag, G_megaSellFlag);

      // Debug: mostrar estado actual (solo cada 100 ticks para no saturar)
      static int megaDebugCounter = 0;
      megaDebugCounter++;


      // Mostrar cuadrito SCHO (estado del Stochastic)
      MostrarBanderaStoch(true, G_stochBuyFlag ? "BUY" : G_stochSellFlag ? "SELL" : "NONE");

      // Mostrar cuadritos de medias móviles con su orientación individual
      MostrarBanderaMA(200, tendenciaMALarga);
      MostrarBanderaMA(50, tendenciaMACorta);
      MostrarBanderaMA(5, tendenciaMAUltraCorta);
      // Mostrar objetivo de cierre por protección de pérdidas
      MostrarObjetivoProteccionPerdidas();
      // Mostrar info de horario y tiempo hasta próximo horario peligroso
      MostrarInfoHorarioPeligroso();
      // Mostrar altura promedio de barras (lado izquierdo, debajo de horario peligroso)
      string nombreAlturaRect = "altura_rect";
      string nombreAlturaLabel = "altura_label";

      int alturaX = 10;
      int alturaY = 30 + 135 + 25 + 5; // Debajo del cartel de horario peligroso

      // Calcular altura promedio globalmente para uso en TP/SL dinámico y otras funciones
      alturaPromedio = CalcularAlturaPromedioBarras(barrasParaPromedio);
      double alturaPromedioEnPips = alturaPromedio / Point;
      string textoAltura = "Altura promedio (" + IntegerToString(barrasParaPromedio) + " barras): " + DoubleToStr(alturaPromedioEnPips, 1) + " pips";

      color colorFondoAltura = calculoTPSLAutomatico ? C'50,180,50' : C'128,128,128'; // Verde semitransparente o gris
      color colorTextoAltura = calculoTPSLAutomatico ? clrYellow : clrWhite;

      // Fondo
      ObjectCreate(0, nombreAlturaRect, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_XDISTANCE, alturaX);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_YDISTANCE, alturaY);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_XSIZE, 450);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_YSIZE, 25);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_COLOR, colorFondoAltura);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_BACK, true);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_BGCOLOR, colorFondoAltura);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, nombreAlturaRect, OBJPROP_WIDTH, 1);

      // Texto
      ObjectCreate(0, nombreAlturaLabel, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nombreAlturaLabel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, nombreAlturaLabel, OBJPROP_XDISTANCE, alturaX + 5);
      ObjectSetInteger(0, nombreAlturaLabel, OBJPROP_YDISTANCE, alturaY + 6);
      ObjectSetInteger(0, nombreAlturaLabel, OBJPROP_COLOR, colorTextoAltura);
      ObjectSetInteger(0, nombreAlturaLabel, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, nombreAlturaLabel, OBJPROP_TEXT, textoAltura);
      // Mostrar TP y SL calculados (debajo del cartel de altura promedio)
      string nombreTPSLRect = "tpsl_rect";
      string nombreTPSLLabel = "tpsl_label";

      int tpslX = 10;
      int tpslY = 30 + 135 + 25 + 5 + 25 + 5; // Debajo del cartel de altura promedio

      double tpCalculado = ObtenerTPDinamico();
      double slCalculado = ObtenerSLDinamico();
      string textoTPSL = "TP: " + DoubleToStr(tpCalculado, 1) + " pips | SL: " + DoubleToStr(slCalculado, 1) + " pips";

      color colorFondoTPSL = calculoTPSLAutomatico ? C'50,100,180' : C'128,128,128'; // Azul semitransparente o gris
      color colorTextoTPSL = calculoTPSLAutomatico ? clrYellow : clrWhite;

      // Fondo
      ObjectCreate(0, nombreTPSLRect, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_XDISTANCE, tpslX);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_YDISTANCE, tpslY);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_XSIZE, 450);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_YSIZE, 25);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_COLOR, colorFondoTPSL);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_BACK, true);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_BGCOLOR, colorFondoTPSL);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, nombreTPSLRect, OBJPROP_WIDTH, 1);

      // Texto
      ObjectCreate(0, nombreTPSLLabel, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nombreTPSLLabel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, nombreTPSLLabel, OBJPROP_XDISTANCE, tpslX + 5);
      ObjectSetInteger(0, nombreTPSLLabel, OBJPROP_YDISTANCE, tpslY + 6);
      ObjectSetInteger(0, nombreTPSLLabel, OBJPROP_COLOR, colorTextoTPSL);
      ObjectSetInteger(0, nombreTPSLLabel, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, nombreTPSLLabel, OBJPROP_TEXT, textoTPSL);



      // ETAPA 3: Ejecutar cuando AMBAS banderas estén activas y NO haya rango
      // Reutilizar cálculo de pendiente para rango
      int lbExec = MathMax(2, pendienteLookbackBars);
      double ma200_now_exec = iMA(NULL, 0, periodoMALarga, 0, MODE_SMA, PRICE_CLOSE, 1);
      double ma200_then_exec = iMA(NULL, 0, periodoMALarga, 0, MODE_SMA, PRICE_CLOSE, 1 + lbExec);
      double slopeExec = (ma200_now_exec - ma200_then_exec) / (lbExec * Point);
      bool rangoActivo = evitarRangoMA200 && MathAbs(slopeExec) < pendienteMinPipsPorBarra;

      // NUEVA LÓGICA: MA5 es el gatillo (trigger), las otras son condiciones de zona
      // Solo ejecutar si la MA5 cambió de dirección (es el impulso)
      static int ultimaTendenciaMA5 = 0;
      bool ma5TriggeaCompr = (tendenciaMAUltraCorta == 1 && ultimaTendenciaMA5 != 1); // MA5 se volvió alcista
      bool ma5TriggeaVenta = (tendenciaMAUltraCorta == -1 && ultimaTendenciaMA5 != -1); // MA5 se volvió bajista

      // Actualizar última tendencia de MA5
      if(tendenciaMAUltraCorta != 0)
         ultimaTendenciaMA5 = tendenciaMAUltraCorta;

      // NUEVA LÓGICA: Usar mega-banderas GLOBALES (modo bandera persistente) + pendiente del Stochastic
      // 1. MEGA-BANDERA activa (modo bandera persistente)
      // 2. Pendiente del Stochastic confirma la dirección
      // 3. Pendiente del Stochastic M5 debe estar a favor del movimiento
      // BUY: Stochastic entre 0-50 con pendiente positiva
      // SELL: Stochastic entre 50-100 con pendiente negativa

      // Calcular estocástico M5 y su pendiente
      double stochM5_Now  = iStochastic(NULL, PERIOD_M5, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 1);
      double stochM5_Prev = iStochastic(NULL, PERIOD_M5, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 2);
      bool stochM5_PendientePositiva = (stochM5_Now > stochM5_Prev); // M5 subiendo
      bool stochM5_PendienteNegativa = (stochM5_Now < stochM5_Prev); // M5 bajando

      // Agregar condición de pendiente M5 a favor del movimiento
      bool stochM5_FavorBuy = stochM5_PendientePositiva;  // M5 subiendo = favor BUY
      bool stochM5_FavorSell = stochM5_PendienteNegativa; // M5 bajando = favor SELL


      // DEBUG: Ver valores de condiciones MEGA
      Print(">>> DEBUG PRE-MEGA: rangoActivo=", rangoActivo, " | stochListoParaBuy=", stochListoParaBuy, " | stochListoParaSell=", stochListoParaSell, " | IsMarketSafe()=", IsMarketSafe());
      Print(">>> DEBUG PRE-MEGA FLAGS: G_megaBuyFlag=", G_megaBuyFlag, " | G_megaSellFlag=", G_megaSellFlag, " | ma1GatilloBuy=", ma1GatilloBuy, " | ma1GatilloSell=", ma1GatilloSell);

      // MODIFICADO: Permitir ambas órdenes simultáneas
      bool buyMegaCondition = (!rangoActivo && stochListoParaBuy && IsMarketSafe());
      bool sellMegaCondition = (!rangoActivo && stochListoParaSell && IsMarketSafe());

      // Si cualquiera es true, activar AMBAS
      if(buyMegaCondition || sellMegaCondition)
        {
         enterUp = true;
         enterDown = true;
         Print(">>> DEBUG MEGA: buyMegaCondition=", buyMegaCondition, " | sellMegaCondition=", sellMegaCondition, " | RESULTADO: enterUp=", enterUp, " enterDown=", enterDown);
        }
      else
        {
         enterUp = false;
         enterDown = false;
        }

      // Actualizar visualización del estado del mercado
      UpdateMarketSafeVisual();

      // EXPERIMENTO: Ajuste de entrada por Stochastic
      if(ajusteEntradaStochastic)
        {
         // Si hay posiciones BUY abiertas y el Stochastic vuelve a <10 sin haber llegado a zona neutra (50)
         // Esto significa que se fue muy rápido hacia abajo sin consolidar el movimiento alcista
         if(ContadordeBuys() > 0 && stochNow < OSLevel && stochPrev >= OSLevel)
           {
            // Verificar si el Stochastic subió al menos hasta 50 antes de volver
            static double stochMax = 0;
            if(ContadordeBuys() > 0)
              {
               if(stochNow > stochMax)
                  stochMax = stochNow; // Guardar máximo alcanzado
              }
            else
               stochMax = 0; // Resetear cuando no hay posiciones

            if(stochMax < 50)
              {
               Print(">>> LLAMANDO CloseAllBuys() desde: Ajuste Entrada Stochastic - stochMax<50, no llegó a zona neutra (línea ~5642) | stochMax=", stochMax, " | stochNow=", stochNow);
               CloseAllBuys(); // Cerrar todas las posiciones BUY
               stochMax = 0; // Resetear contador
              }
            else
              {
               stochMax = 0; // Resetear porque sí llegó a zona neutra
              }
           }

         // Si hay posiciones SELL abiertas y el Stochastic vuelve a >90 sin haber llegado a zona neutra (50)
         // Esto significa que se fue muy rápido hacia arriba sin consolidar el movimiento bajista
         if(ContadordeSells() > 0 && stochNow > OBLevel && stochPrev <= OBLevel)
           {
            // Verificar si el Stochastic bajó al menos hasta 50 antes de volver
            static double stochMin = 100;
            if(ContadordeSells() > 0)
              {
               if(stochNow < stochMin)
                  stochMin = stochNow; // Guardar mínimo alcanzado
              }
            else
               stochMin = 100; // Resetear cuando no hay posiciones

            if(stochMin > 50)
              {
               CloseAllSells(); // Cerrar todas las posiciones SELL
               stochMin = 100; // Resetear contador
              }
            else
              {
               stochMin = 100; // Resetear porque sí llegó a zona neutra
              }
           }
        }

      // Log de estado de medias
      static int logMediasCounter = 0;
      logMediasCounter++;

     }
   else
     {
      // Sistema original (FVG + Stoch + filtros) - MODIFICADO para permitir ambas órdenes simultáneas
      bool buyCondition = (CondicionBuy  && G_readyBuy && condicionBuyMedia && restriccionVela && filtrosBuyOK && pendienteOkBuy && tendenciaCortaOkBuy);
      bool sellCondition = (CondicionSell && G_readySell && condicionSellMedia && restriccionVela && filtrosSellOK && pendienteOkSell && tendenciaCortaOkSell);

      // Si cualquiera es true, activar AMBAS
      if(buyCondition || sellCondition)
        {
         enterUp = true;
         enterDown = true;
         Print(">>> DEBUG CONDITIONS: buyCondition=", buyCondition, " | sellCondition=", sellCondition, " | RESULTADO: enterUp=", enterUp, " enterDown=", enterDown);
        }
      else
        {
         enterUp = false;
         enterDown = false;
        }
     }

// Debug detallado de condiciones de entrada
   static int debugEntradaCounter = 0;
   debugEntradaCounter++;


// Notificar cuando hay señal pero no se puede ejecutar por condición de media
   if((CondicionBuy && G_readyBuy) && !condicionBuyMedia)
     {
      LogEnPantalla("⚠️ SEÑAL BUY bloqueada - Precio por debajo de media200");
     }


   if((CondicionBuy && G_readyBuy && condicionBuyMedia && restriccionVela && filtrosBuyOK) && usarFiltroPendienteMA200 && !pendienteOkBuy)
     {
      LogEnPantalla("⚠️ SEÑAL BUY bloqueada - Pendiente MA200 bajista");
     }

   if((CondicionSell && G_readySell && condicionSellMedia && restriccionVela && filtrosSellOK) && usarFiltroPendienteMA200 && !pendienteOkSell)
     {
      LogEnPantalla("⚠️ SEÑAL SELL bloqueada - Pendiente MA200 alcista");
     }

   if((CondicionBuy && G_readyBuy && condicionBuyMedia && restriccionVela && filtrosBuyOK) && usarFiltroMA50 && !tendenciaCortaOkBuy)
     {
      LogEnPantalla("⚠️ SEÑAL BUY bloqueada - Precio por debajo de MA" + IntegerToString(periodoMA50));
     }

   if((CondicionSell && G_readySell && condicionSellMedia && restriccionVela && filtrosSellOK) && usarFiltroMA50 && !tendenciaCortaOkSell)
     {
      LogEnPantalla("⚠️ SEÑAL SELL bloqueada - Precio por encima de MA" + IntegerToString(periodoMA50));
     }

   if((CondicionSell && G_readySell) && !condicionSellMedia)
     {
      LogEnPantalla("⚠️ SEÑAL SELL bloqueada - Precio por encima de media200");
     }

// Notificar cuando hay señal pero no se puede ejecutar por vela grande
   if(usarRestriccionVelaGrande && (CondicionBuy && G_readyBuy && condicionBuyMedia) && velaGrande)
     {
      LogEnPantalla("⚠️ SEÑAL BUY bloqueada - Vela muy grande detectada");
     }

// Notificar cuando hay señal pero no se puede ejecutar por filtros
   if(usarFiltrosTendencia && (CondicionBuy && G_readyBuy && condicionBuyMedia && restriccionVela) && !filtrosBuyOK)
     {
      LogEnPantalla("⚠️ SEÑAL BUY bloqueada - Filtros de tendencia no cumplidos");
     }

   if(usarFiltrosTendencia && (CondicionSell && G_readySell && condicionSellMedia && restriccionVela) && !filtrosSellOK)
     {
      LogEnPantalla("⚠️ SEÑAL SELL bloqueada - Filtros de tendencia no cumplidos");
     }

   if(usarRestriccionVelaGrande && (CondicionSell && G_readySell && condicionSellMedia) && velaGrande)
     {
      LogEnPantalla("⚠️ SEÑAL SELL bloqueada - Vela muy grande detectada");
     }

// DEBUG: Logging detallado del timing de señales
   static datetime ultimaSeñalBuy = 0;
   static datetime ultimaSeñalSell = 0;

   if(CondicionBuy && G_readyBuy && !ultimaSeñalBuy)
     {
      ultimaSeñalBuy = TimeCurrent();
      LogEnPantalla("🟢 SEÑAL BUY DETECTADA: " + TimeToString(TimeCurrent(), TIME_SECONDS));
     }

   if(CondicionSell && G_readySell && !ultimaSeñalSell)
     {
      ultimaSeñalSell = TimeCurrent();
      LogEnPantalla("🔴 SEÑAL SELL DETECTADA: " + TimeToString(TimeCurrent(), TIME_SECONDS));
     }

   if(enterUp)
      LogTriggerBuyDebug();
   if(enterDown)
      LogTriggerSellDebug();

// Verificar horario peligroso y bloquear si corresponde
   bool horarioPeligroso = EstaEnHorarioPeligroso();
   if(horarioPeligroso)
     {
      LogEnPantalla("⛔ HORARIO PELIGROSO (" + IntegerToString(Hour()) + ":00) - Operaciones bloqueadas");
      return; // Salir sin ejecutar órdenes
     }

// Tiempo de espera dinámico: más corto en modo reactivo
   int tiempoEsperaMinutos = modoReactivo ? MathMax(1, CantHorasEspera / 3) : CantHorasEspera;
   const int Timein_SECONDS = tiempoEsperaMinutos * 60;
   datetime restatiempo = TimeCurrent() - Timein_SECONDS;

   // MODIFICADO: Verificar tiempo UNA VEZ para permitir ambas órdenes simultáneas
   bool tiempoParaNuevaOperacion = (timeofOperation < restatiempo);

// ====== COMPRA ======
   if(tiempoParaNuevaOperacion && enterUp)
     {
      // RESTRICCIÓN ELIMINADA: Ya no se bloquea BUY por posición respecto a MA200
      // Permite compras y ventas simultáneas sin restricción de MA200


      NuevaOperacion = false;
      // MOVIDO: No actualizar timeofOperation aquí, se actualiza al final después de ambas órdenes

      // Logging de ejecución para comparar timing
      LogEnPantalla("🚀 EJECUTANDO BUY: " + TimeToString(TimeCurrent(), TIME_SECONDS));

      // DEBUG: Verificar condiciones antes de ejecutar BUY
      double precioActualDebug = iClose(NULL, 0, 0);
      double ma200ActualDebug = iMA(NULL, 0, periodoMALarga, 0, MODE_SMA, PRICE_CLOSE, 0);


      if(ContadordeBuys() == 0)
        {
         if(tempAutomaticSLBuy == -1)
            tempAutomaticSLBuy = lowAlcista;
         comienzoOperacion = true;

         automaticSLBuy = tempAutomaticSLBuy;
         openBuyPrice   = currentPrice;

         // ===== LOG DETALLADO DE CONDICIONES DE COMPRA =====
         double precioActual = iClose(NULL, 0, 0);
         double media200_actual = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 1);
         double mediaPrice_actual = iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, 1);
         double media35_actual = iMA(NULL, 0, 35, 0, MODE_EMA, PRICE_CLOSE, 1);
         double media50_actual = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, 1);


         CrearSLBuy(automaticSLBuy);
         CrearTPBuy(openBuyPrice);
         Compra();
       

         // Notificar ejecución de orden
         LogEnPantalla("✅ ORDEN BUY EJECUTADA - Ciclo alcista completado");

         // Resetear flags después de ejecutar la orden
         ResetBuyFlags();

         operationTime = TimeCurrent();
        }
     }

// ====== VENTA ======
   Print(">>> DEBUG SELL: enterDown=", enterDown, " | tiempoParaNuevaOperacion=", tiempoParaNuevaOperacion, " | timeofOperation=", timeofOperation, " | restatiempo=", restatiempo);

   if(tiempoParaNuevaOperacion && enterDown)
     {
      Print(">>> DEBUG SELL: ENTRANDO a sección SELL");
      // RESTRICCIÓN ELIMINADA: Ya no se bloquea SELL por posición respecto a MA200
      // Permite compras y ventas simultáneas sin restricción de MA200


      NuevaOperacion = false;
      // MOVIDO: No actualizar timeofOperation aquí, se actualiza al final después de ambas órdenes

      // Logging de ejecución para comparar timing
      LogEnPantalla("🚀 EJECUTANDO SELL: " + TimeToString(TimeCurrent(), TIME_SECONDS));

      // DEBUG: Verificar condiciones antes de ejecutar SELL
      double precioActualDebug = iClose(NULL, 0, 0);
      double ma200ActualDebug = iMA(NULL, 0, periodoMALarga, 0, MODE_SMA, PRICE_CLOSE, 0);

      int contadorSells = ContadordeSells();
      Print(">>> DEBUG SELL: ContadordeSells()=", contadorSells);

      if(ContadordeSells() == 0)
        {
         if(tempAutomaticSLSell == -1)
            tempAutomaticSLSell = highBajista;
         comienzoOperacion = true;

         automaticSLSell = tempAutomaticSLSell;
         openSellPrice   = currentPrice;

         // ===== LOG DETALLADO DE CONDICIONES DE VENTA =====
         double precioActual = iClose(NULL, 0, 0);
         double media200_actual = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 1);
         double mediaPrice_actual = iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, 1);
         double media35_actual = iMA(NULL, 0, 35, 0, MODE_EMA, PRICE_CLOSE, 1);
         double media50_actual = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, 1);


         CrearSLSell(automaticSLSell);
         CrearTPSell(openSellPrice);
         Print(">>> DEBUG SELL: Llamando a Venta()...");
         bool resultVenta = Venta();
         Print(">>> DEBUG SELL: Venta() retornó: ", resultVenta);


         // Notificar ejecución de orden
         LogEnPantalla("✅ ORDEN SELL EJECUTADA - Ciclo bajista completado");

         // Resetear flags después de ejecutar la orden
         ResetSellFlags();

         operationTime = TimeCurrent();
        }
     }

   // MODIFICADO: Actualizar timeofOperation DESPUÉS de intentar crear ambas órdenes
   if(tiempoParaNuevaOperacion && (enterUp || enterDown))
     {
      timeofOperation = TimeCurrent();
      Print(">>> DEBUG: timeofOperation actualizado a ", timeofOperation);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setPairLabel(string pairID, string pair, double trendUp, double trendDown, int xDistance, int yDistance)
  {
   string objectNameID = pairID;
   string objectName = pair;

   ObjectDelete(objectNameID);
   ObjectCreate(objectNameID, OBJ_LABEL, 0, 0, 0);
   ObjectSet(objectNameID, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSet(objectNameID, OBJPROP_XDISTANCE, xDistance);
   ObjectSet(objectNameID, OBJPROP_YDISTANCE, yDistance);

   if(trendUp == 1)
      ObjectSetText(objectNameID, pair + " Fuerte ", 8, "Poppins", clrGreenYellow);
   else
      if(trendDown == 1)
         ObjectSetText(objectNameID, pair + " Fuerte ", 8, "Poppins", clrRed);
      else
         ObjectSetText(objectNameID, pair + " Debil ", 8, "Poppins", clrBlue);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SonarAlarma()
  {
   if(MyRiesgo)
     {
      if(AccountEquity() < AccountBalance() * 40 / 100)
        {
         string message = "Cuidado el valor de la equidad es de " + DoubleToStr(AccountBalance() * 40 / 100);
         LogEnPantalla(message);
         SendNotification(message);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LlegoMeta()
  {

   bool resultSellLimit = false;
   bool resultBuyLimit = false;

   if(conmutadorMontoInicial == true)
     {
      montoInicial = AccountBalance();
      conmutadorMontoInicial = false;
     }


// Si se cumple la meta hace Weekend = true
   if(((AccountEquity() - montoInicial) >= metaDiaria) && metaDiaria != 0)
     {
      usarNotificacionDia = false;
      CloseAllBuys();
      CloseAllSells();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IdentificadorLotajeMenor()
  {
   double lotajeMenor = 1000;

   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber)
        {
         if(OrderLots() == lotajeDeseado)
           {
            lotajeMenor = OrderLots();
            break;
           }
         else
            if(OrderLots() < lotajeMenor)
              {
               lotajeMenor = OrderLots();
              }
        }
   return (lotajeMenor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ContadordeSells()
  {
   int countSell = 0;
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_SELL)
         countSell++;

   return (countSell);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ContadordeSellsLimit()
  {
   int countSell = 0;
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_SELLLIMIT)
         countSell++;
   return (countSell);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ContadordeSellsStop()
  {
   int countSell = 0;
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_SELLSTOP)
         countSell++;
   return (countSell);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ContadordeBuys()
  {
   int countBuy = 0;
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUY)
         countBuy++;
   return (countBuy);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ContadordeBuysLimit()
  {
   int countBuy = 0;
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUYLIMIT)
         countBuy++;
   return (countBuy);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ContadordeBuysStop()
  {
   int countBuy = 0;
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUYSTOP)
         countBuy++;
   return (countBuy);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DailyProfitByPair()
  {
   double profit = 0;
   for(int x = OrdersHistoryTotal(); x >= 0; x--)  // Reviso el historial en orden inverso
     {
      int see = OrderSelect(x - 1, SELECT_BY_POS, MODE_HISTORY); // selecciono la ultima
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         if(OrderProfit() < 0)
           {
            profit += OrderProfit() + OrderSwap() + OrderCommission();
           }
         else
           {
            break;
           }
        }
     }
   return (profit);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EquityByPair()
  {
   double TotalProfit = 0;
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
         TotalProfit += OrderProfit() - OrderSwap() - OrderCommission();
   return (TotalProfit);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EquityByBuy()
  {
   double TotalProfit = 0;
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUY)
         TotalProfit += OrderProfit() + OrderSwap() + OrderCommission();
   return (TotalProfit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EquityBySell()
  {
   double TotalProfit = 0;
   for(int iPos = OrdersTotal() - 1; iPos >= 0; iPos--)
      if(OrderSelect(iPos, SELECT_BY_POS) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_SELL)
         TotalProfit += OrderProfit() + OrderSwap() + OrderCommission();
   return (TotalProfit);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseOrderPendientesSiSeactivaOriginal()
  {

   int total = OrdersTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();
      bool result = false;
      if((type == OP_BUY))
        {
         CloseAllBuyStops();
         CloseAllSellStops();
        }
      else
         if(type == OP_SELL)
           {
            CloseAllBuyStops();
            CloseAllSellStops();

           }
     }

   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitBuys()
  {
   int total = OrdersTotal();
   double profit = 0;
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();
      bool result = false;

      if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_BUY))
        {

         profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
     }

   return (profit);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitSells()
  {
   int total = OrdersTotal();
   double profit = 0;
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();
      bool result = false;

      if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_SELL))
        {

         profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
     }

   return (profit);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllBuys()
  {
   static int closeAttempts = 0;
   closeAttempts++;

// Evitar demasiados intentos consecutivos
   if(closeAttempts > 10)
     {
      Sleep(5000);
      closeAttempts = 0;
      return 0;
     }



   int total = OrdersTotal();
   int closedCount = 0;
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();
      bool result = false;

      if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_BUY))
        {


         // Verificar que la orden aún existe antes de intentar cerrarla
         if(OrderSelect(OrderTicket(), SELECT_BY_TICKET))
           {
            int ticketBuy = OrderTicket();
            Print("🔴🔴🔴 BUY CERRADO POR CloseAllBuys() | Ticket #", ticketBuy);
            result = OrderClose(ticketBuy, OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 10, clrGreen);
            if(result == false)
              {
               int error = GetLastError();
               // Solo mostrar alert una vez por orden
               static int lastAlertedTicket = 0;
               if(lastAlertedTicket != ticketBuy)
                 {
                  Alert("Order ", ticketBuy, " failed to close. Error:", error);
                  lastAlertedTicket = ticketBuy;
                 }
               Sleep(1000); // Reducir el sleep
              }
            else
              {
               RegistrarCierreOperacion(ticketBuy, "TP/SL - CloseAllBuys");
               closedCount++;
               closeAttempts = 0; // Reset contador al cerrar exitosamente
              }
           }

        }
      else
         if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_BUYSTOP))
           {
            result = OrderDelete(OrderTicket());
            LogEnPantalla("Ordenes elminadas");
           }
     }



// Resetear MEGA-BANDERA BUY al cerrar todas las posiciones BUY
   if(closedCount > 0)
     {
      G_megaBuyFlag = false;
     }

   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllBuyStops()
  {
   int total = OrdersTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();
      bool result = false;

      if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_BUYSTOP))
        {
         result = OrderDelete(OrderTicket());
         LogEnPantalla("Ordenes elminadas");
        }
     }

   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllBuyLimits()
  {
   int total = OrdersTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();
      bool result = false;

      if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_BUYLIMIT))
        {
         result = OrderDelete(OrderTicket());
         LogEnPantalla("Ordenes elminadas");
        }
     }

   return (0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllSells()
  {
   static int closeAttemptsSell = 0;
   closeAttemptsSell++;

// Evitar demasiados intentos consecutivos
   if(closeAttemptsSell > 10)
     {
      Sleep(5000);
      closeAttemptsSell = 0;
      return 0;
     }



   int total = OrdersTotal();
   int closedCount = 0;
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();
      bool result = false;

      if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_SELL))
        {


         // Verificar que la orden aún existe antes de intentar cerrarla
         if(OrderSelect(OrderTicket(), SELECT_BY_TICKET))
           {
            int ticketSell = OrderTicket();
            Print("⚠️ CloseAllSells() intentando cerrar SELL #", ticketSell);
            result = OrderClose(ticketSell, OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 10, clrRed);
            if(result == false)
              {
               int error = GetLastError();
               // Solo mostrar alert una vez por orden
               static int lastAlertedTicketSell = 0;
               if(lastAlertedTicketSell != ticketSell)
                 {
                  Alert("Order ", ticketSell, " failed to close. Error:", error);
                  lastAlertedTicketSell = ticketSell;
                 }
               Sleep(1000); // Reducir el sleep
              }
            else
              {
               RegistrarCierreOperacion(ticketSell, "TP/SL - CloseAllSells");
               closedCount++;
               closeAttemptsSell = 0; // Reset contador al cerrar exitosamente
              }
           }

        }
      else
         if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_SELLSTOP))
           {
            result = OrderDelete(OrderTicket());
            LogEnPantalla("Ordenes elminadas");
           }
     }



// Resetear MEGA-BANDERA SELL al cerrar todas las posiciones SELL
   if(closedCount > 0)
     {
      G_megaSellFlag = false;
     }

   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllSellStops()
  {

   int total = OrdersTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();
      bool result = false;


      if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_SELLSTOP))
        {
         result = OrderDelete(OrderTicket());
         LogEnPantalla("Ordenes elminadas");
        }
     }

   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllSellLimits()
  {

   int total = OrdersTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();
      bool result = false;


      if((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && type == OP_SELLLIMIT))
        {
         result = OrderDelete(OrderTicket());
         LogEnPantalla("Ordenes elminadas");
        }
     }

   return (0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseOrder()
  {
   int total = OrdersTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      int type = OrderType();

      bool result = false;

      switch(type)
        {
         // Close opened long positions
         case OP_BUY:
            if((OrderProfit() > 0 || OrderProfit() <= 0) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
              {
               int ticketBuy = OrderTicket();
               Print("🔴🔴🔴 BUY CERRADO POR CloseOrder() | Ticket #", ticketBuy, " | Profit:", OrderProfit());
               result = OrderClose(ticketBuy, OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 10, clrGreen);
               if(result)
                  RegistrarCierreOperacion(ticketBuy, "Cierre Manual/Automatico");
              }

            break;

         // Close opened short positions
         case OP_SELL:
            if((OrderProfit() > 0 || OrderProfit() <= 0) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
              {
               int ticketSell = OrderTicket();
               result = OrderClose(ticketSell, OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 10, clrRed);
               if(result)
                  RegistrarCierreOperacion(ticketSell, "Cierre Manual/Automatico");
              }
            break;
        }

      if(result == false)
        {
         // Alert("Order ", OrderTicket(), " failed to close. Error:", GetLastError());
         // Sleep(3000);
        }
     }

   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DailyProfit()
  {
   double profit = 0;
   hstTotal = OrdersHistoryTotal();
   int i;
   for(i = 0; i < hstTotal; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == TRUE)
        {
         if(OrderType() > 1)
            continue;
         if(TimeToStr(TimeCurrent(), TIME_DATE) == TimeToStr(OrderCloseTime(), TIME_DATE))
           {

            profit += OrderProfit() + OrderSwap() + OrderCommission();
           }
        }
     }
   return (profit);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DailyEquity()
  {
   double profit = 0;
   profit = AccountEquity() - (AccountBalance() + AccountCredit());
   return (profit);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChecaLibro()
  {
   int NumeroDeOrdenes = OrdersTotal();      // cantidad de ordenes total en el libro
   bool Seleccionado = false;                // Ordenes activas en el libro de ordenes
   int OrdenesDeEsteExpert = 0;              // controla si pudo o no seleccionar una orden
   for(int i = 0; i < NumeroDeOrdenes; i++)  // Revisa todas las ordenes del Libro
     {
      Seleccionado = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);                          // Selecciona la orden por su posicion en el libro dada por i
      if(OrderSymbol() == Symbol() && Seleccionado && OrderMagicNumber() == MagicNumber)  // comprueba que tenga el mismo simbolo,se pudo seleccionar y el magicnumber coincida
        {
         OrdenesDeEsteExpert++; // Si Magic number coincide agrega 1 al contador
         if(OrdenesDeEsteExpert < 2)
            Ticket = OrderTicket(); // Tomo el valor del primer ticket con nuestro magic number
        }
     }

   return (OrdenesDeEsteExpert); // Devuelve el numero de ordenes con el Magic Number
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChecaHistory()
  {

   int NumeroDeOrdenesCerradas = OrdersHistoryTotal(); // Contador de Ordenes
   bool Seleccionado = false;                          // Ordenes activas en el libro de ordenes
   int OrdenesCerradasDeEsteExpert = 0;                // controla si pudo o no seleccionar una orden

   for(int i = NumeroDeOrdenesCerradas; i >= 0; i--)  // Revisa todas las ordenes de la historia en Orden Inverso
     {

      Seleccionado = OrderSelect(NumeroDeOrdenesCerradas - 1, SELECT_BY_POS, MODE_HISTORY); // Selecciona todas las ordenes de la historia
      if(OrderSymbol() == Symbol() && Seleccionado && OrderMagicNumber() == MagicNumber)    // comprueba que tenga el mismo simbolo,se pudo seleccionar y el magicnumber coincida
        {
         OrdenesCerradasDeEsteExpert++;                                                    // Si Magig number coincide agrega 1 al contador
         Seleccionado = OrderSelect(NumeroDeOrdenesCerradas, SELECT_BY_POS, MODE_HISTORY); // Selecciona la ultima orden en la historia
         TicketHistory = OrderTicket();                                                    // Tomo el valor del Ultimo ticket con nuestro magic number
         break;
        }
     }

   return (OrdenesCerradasDeEsteExpert); // Devuelve el numero de ordenes Cerradas
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NoEsta(int numeroOrden)
  {

   int i;
   int NumeroDeOrdenesCerradas = OrdersHistoryTotal();
   for(i = 0; i <= NumeroDeOrdenesCerradas - 1; i++)  // Cycle operator header
     {
      // Brace opening the cycle body

      if(ordenestickes[i] == numeroOrden)
        {
         return false;
         break;
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DailyEquityByPair()
  {

   int total = OrdersTotal();
   double profit = 0;
   for(int i = total - 1; i >= 0; i--)
     {
      int y = OrderSelect(i, SELECT_BY_POS);
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
     }
   return profit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perdidaAcumulada()
  {

   double perdidaGlobal = 0;
   int cont = 0;
   for(int x = OrdersHistoryTotal(); x >= 0; x--)  // Reviso el historial en orden inverso
     {
      int see = OrderSelect(x - 1, SELECT_BY_POS, MODE_HISTORY); // selecciono la ultima
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderProfit() < 0)
        {
         perdidaGlobal = perdidaGlobal + OrderProfit() + OrderCommission();
        }
      else
         break;
     }
   if(perdidaGlobal > 0)
      perdidaGlobal = 0;
   return perdidaGlobal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Declaración del array

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void agregarParNameToArray()
  {
   static int contadorSimbol = 0; // Contador para los símbolos agregados
   bool estaEnLista = false; // Booleano para verificar si el símbolo ya está en el array

   int totalOrders = OrdersHistoryTotal(); // Obtengo el total de órdenes en el historial
   if(totalOrders == 0)   // Verifico si no hay órdenes en el historial
     {
      return; // Salgo de la función si no hay órdenes
     }

   for(int x = totalOrders - 1; x >= 0; x--)   // Reviso el historial en orden inverso
     {
      if(OrderSelect(x, SELECT_BY_POS, MODE_HISTORY))  // Selecciono la orden en la posición x
        {
         estaEnLista = false; // Inicializo la variable en false para cada orden
         for(int y = 0; y < contadorSimbol; y++)   // Reviso si el símbolo ya está en el array
           {
            if(arrayParName[y] == OrderSymbol())
              {
               estaEnLista = true; // Si está, establezco estaEnLista en true
               break;
              }
           }
         // Si la variable estaEnLista no se puso en true, significa que el símbolo no está en el array
         if(!estaEnLista)
           {
            if(contadorSimbol < ArraySize(arrayParName))   // Verifico que el índice esté dentro del rango
              {
               arrayParName[contadorSimbol] = OrderSymbol();
               contadorSimbol++;
              }
            else
              {
               return; // Detener el proceso si el array está lleno
              }
           }
        }
     }

// Ordenar el array alfabéticamente usando una función personalizada
   SortStringArray(arrayParName, contadorSimbol);
  }

// Función para ordenar un array de strings
void SortStringArray(string &arr[], int size)
  {
   for(int i = 0; i < size - 1; i++)
     {
      for(int j = 0; j < size - i - 1; j++)
        {
         if(StringCompare(arr[j], arr[j + 1]) > 0)
           {
            // Intercambiar arr[j] y arr[j + 1]
            string temp = arr[j];
            arr[j] = arr[j + 1];
            arr[j + 1] = temp;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perdidaAcumuladaBuy()
  {
   double perdida = 0;
   for(int x = OrdersHistoryTotal(); x >= 0; x--)  // Reviso el historial en orden inverso
     {
      int see = OrderSelect(x - 1, SELECT_BY_POS, MODE_HISTORY); // selecciono la ultima
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY)
        {
         if(OrderProfit() < 0)
            perdida = perdida + OrderProfit();
         else
            break;
        }
     }
   return perdida;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perdidaAcumuladaSell()
  {
   double perdida = 0;
   for(int x = OrdersHistoryTotal(); x >= 0; x--)  // Reviso el historial en orden inverso
     {
      int see = OrderSelect(x - 1, SELECT_BY_POS, MODE_HISTORY); // selecciono la ultima
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL)
        {
         if(OrderProfit() < 0)
            perdida = perdida + OrderProfit();
         else
            break;
        }
     }
   return perdida;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perdidaAcumuladaPorPar(int value)
  {

   double perdidaAcumuladaGlobal = 0;
   for(int x = OrdersHistoryTotal(); x >= 0; x--)  // Reviso el historial en orden inverso
     {
      if(OrderSelect(x - 1, SELECT_BY_POS, MODE_HISTORY)  // selecciono la ultima
         && OrderSymbol() == arrayParName[value] && OrderMagicNumber() == MagicNumber && OrderProfit() < 0)
        {
         perdidaAcumuladaGlobal += OrderProfit() + OrderCommission();
        }
      else
         if(OrderSymbol() == arrayParName[value] && OrderMagicNumber() == MagicNumber && OrderProfit() > 0)
            break;
     }
   if(perdidaAcumuladaGlobal > 0)
      perdidaAcumuladaGlobal = 0;
   return (perdidaAcumuladaGlobal);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int contadorPerdidaPorPar(int value)
  {

   int contador = 0;
   for(int x = OrdersHistoryTotal(); x >= 0; x--)  // Reviso el historial en orden inverso
     {
      if(OrderSelect(x - 1, SELECT_BY_POS, MODE_HISTORY)  // selecciono la ultima
         && OrderSymbol() == arrayParName[value] && OrderMagicNumber() == MagicNumber && OrderProfit() < 0)
        {
         contador++;
        }
      else
         if(OrderSymbol() == arrayParName[value] && OrderMagicNumber() == MagicNumber && OrderProfit() > 0)
            break;
     }

   return (contador);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int contadorPerdidadelPar()
  {
   int contador = 0;
   for(int x = OrdersHistoryTotal(); x >= 0; x--)  // Reviso el historial en orden inverso
     {
      if(OrderSelect(x - 1, SELECT_BY_POS, MODE_HISTORY)  // selecciono la ultima
         && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderProfit() < 0)
        {
         contador++;
        }
      else
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderProfit() > 0)
            break;
     }

   return (contador);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void perdidaFlotante()
  {
   if((AccountProfit() <= 0) && (AccountProfit() < flotanteMayor))
      flotanteMayor = AccountProfit();

// Verificar que balance no sea cero antes de realizar la división
   if(balance != 0)
     {
      flotanteMayorPercent = 100 * flotanteMayor / balance;
     }
   else
     {
      LogEnPantalla("Error: División por cero evitada. El balance es cero.");
      flotanteMayorPercent = 0; // O maneja el caso de otra manera
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void mayorPerdida()
  {
   double perdida = 0;
   for(int i = 0; i <= 29; i++)
     {
      perdida = perdida + perdidaAcumuladaPorPar(i);
     }
   if(perdida < perdidaMayor)
      perdidaMayor = perdida;

// Verificar que balance no sea cero antes de realizar la división
   if(balance != 0)
     {
      perdidaMayorPercent = 100 * perdidaMayor / balance;
     }
   else
     {
      LogEnPantalla("Error: División por cero evitada. El balance es cero.");
      perdidaMayorPercent = 0; // O maneja el caso de otra manera
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string NombreArray(int value)
  {
   return arrayParName[value];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double valorPerdidaArray(int value)
  {
   return perdidaAcumuladaPorPar(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int contadorPerdidaArray(int value)
  {
   return contadorPerdidaPorPar(value);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int contadorPerdidas()
  {
   int perdida = 0;
   for(int x = OrdersHistoryTotal(); x >= 0; x--)  // Reviso el historial en orden inverso
     {
      int see = OrderSelect(x - 1, SELECT_BY_POS, MODE_HISTORY); // selecciono la ultima
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         if(OrderProfit() < 0)
            perdida = perdida + 1;
         else
            break;
        }
     }
   return perdida;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double priceBUpper()
  {
   double myBUpper = iBands(NULL, 0, 20, 2, 0, 0, 1, 1);
   return myBUpper;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double priceBLower()
  {
   double myBLower = iBands(NULL, 0, 20, 2, 0, 0, 2, 1);
   return myBLower;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AverageRangeInPips(const double &high[], const double &low[], int startIndex, int count)
  {
   double totalRange = 0.0;
   int validCount = 0;

   for(int i = startIndex; i < startIndex + count && i < Bars; i++)
     {
      double range = high[i] - low[i];
      totalRange += range;
      validCount++;
     }

   if(validCount == 0)
      return 0.0;

   double averageRange = totalRange / validCount;
   return averageRange; // Devuelve el rango promedio en términos de precio
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Compra()
  {
   RefreshRates();

// Inicializar lotaje con el valor calculado por la martingala
   lotsBuy = SeleccionarMartingala(OP_BUY);

   Print("🔍 DEBUG Compra() | lotsBuy después de Martingala: ", lotsBuy,
         " | enRachaMalaBuy: ", enRachaMalaBuy,
         " | lotajePerdidoGuardadoBuy: ", lotajePerdidoGuardadoBuy,
         " | tipoOperacionGanadoraBuy: ", tipoOperacionGanadoraBuy);


   if(enRachaMalaBuy && lotajePerdidoGuardadoBuy > 0 && tipoOperacionGanadoraBuy == true)
     {


      // Obtener información de mercado
      double minlot = MarketInfo(Symbol(), MODE_MINLOT);
      double lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
      double MaximalLots = 800.0;
      double lotajeBaseActual = CalcularLotajeBase();



      // Aplicar multiplicador a la siguiente operación ganadora BUY
      // MODO ACUMULATIVO: Calcular lotaje que cubra perdidas acumuladas
      if(hacerMartingalaAcumulativo && perdidasAcumuladasBuy > 0)
        {


         // NUEVO: Buscar la ganancia de la operación BUY con 0.01 para restarla
         double gananciaOperacion001 = 0.0;
         for(int x = OrdersHistoryTotal() - 1; x >= 0; x--)
           {
            if(OrderSelect(x, SELECT_BY_POS, MODE_HISTORY))
              {
               if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber &&
                  OrderType() == OP_BUY && OrderLots() <= lotajeMinimo &&
                  OrderProfit() > 0)
                 {
                  gananciaOperacion001 = OrderProfit() + OrderSwap() + OrderCommission();
                  break;
                 }
              }
           }


         // Calcular pérdida neta (pérdidas acumuladas - ganancia de 0.01)
         double perdidaNeta = perdidasAcumuladasBuy - gananciaOperacion001;


         if(perdidaNeta > 0)
           {
            // NUEVO: Calcular lotaje basado en pérdida real, no en tics
            // Estimamos que necesitamos ganar aproximadamente la pérdida neta
            // Usamos la ganancia promedio esperada de la última operación ganadora
            double gananciaPromedioPor01Lote = (gananciaOperacion001 > 0) ? gananciaOperacion001 : 1.0;

            // FÓRMULA SIMPLE Y DIRECTA

            // Fórmula: (Pérdidas / Ganancia por 0.01) * 0.01 * Multiplicador
            double lotajeNecesario = (perdidasAcumuladasBuy / gananciaPromedioPor01Lote) * lotajeMinimo * myMultiplierBuy;


            lotsBuy = NormalizeDouble(lotajeNecesario / lotstep, 0) * lotstep;

           }
         else
           {
            // Si la ganancia de 0.01 cubre todas las pérdidas, usar lotaje base
            lotsBuy = lotajeBaseActual;

           }
        }
      else
        {

         // MODO NORMAL: Multiplicador
         lotsBuy = lotajePerdidoGuardadoBuy * myMultiplierBuy;
        }


      lotsBuy = NormalizeDouble(lotsBuy / lotstep, 0) * lotstep;

      if(lotsBuy < minlot)
         lotsBuy = minlot;
      if(lotsBuy > MaximalLots)
         lotsBuy = MaximalLots;

      LogEnPantalla("✓✓ Multiplicador aplicado BUY - Lotaje: " + DoubleToString(lotsBuy, 2));

      // ⚠️ NO RESETEAR AQUÍ - El reset ocurre cuando gana con el lotaje alto
      // Las variables se mantienen para saber que está recuperando pérdidas
      // El reset lo hace MyMartingala() cuando detecta ganancia con lotaje >= base
     }



// VALIDACIÓN DE FANTASMA ELIMINADA: Permitir BUY sin restricciones de precio
   double candidateBuyPrice = NormalizeDouble(Ask, Digits);

   int TicketNuevoCompra = OrderSend(NULL, OP_BUY, lotsBuy, candidateBuyPrice, 10, 0, 0, NULL, MagicNumber, 0, clrGreen);
   if(TicketNuevoCompra < 0)
     {
      Alert("OrdenSend Error: ", GetLastError());

      return (false);
     }
   else
     {
      Alert("Order Sent Succesfully, Ticket # is: " + string(TicketNuevoCompra));

      // NUEVO: Imprimir análisis de indicadores técnicos
      ImprimirAnalisisIndicadores("BUY", TicketNuevoCompra, lotsBuy, Ask);

      OperacionAbierta = TicketNuevoCompra;
      // OperacionCloseAbierta = TicketNuevoCloseCompra;
      // activarCuentaVentas = true;
      // activarCuentaCompras = false;
      return (true);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Venta()
  {

   RefreshRates();

// Inicializar lotaje con el valor calculado por la martingala
   lotsSell = SeleccionarMartingala(OP_SELL);



// NUEVO: Sistema de confirmación de tendencia para martingala


   if(enRachaMalaSell && lotajePerdidoGuardadoSell > 0 && tipoOperacionGanadoraSell == true)
     {


      // Obtener información de mercado
      double minlot = MarketInfo(Symbol(), MODE_MINLOT);
      double lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
      double MaximalLots = 800.0;
      double lotajeBaseActual = CalcularLotajeBase();


      // Aplicar multiplicador a la siguiente operación ganadora SELL
      // MODO ACUMULATIVO: Calcular lotaje que cubra perdidas acumuladas
      if(hacerMartingalaAcumulativo && perdidasAcumuladasSell > 0)
        {


         // NUEVO: Buscar la ganancia de la operación SELL con 0.01 para restarla
         double gananciaOperacion001 = 0.0;
         for(int x = OrdersHistoryTotal() - 1; x >= 0; x--)
           {
            if(OrderSelect(x, SELECT_BY_POS, MODE_HISTORY))
              {
               if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber &&
                  OrderType() == OP_SELL && OrderLots() <= lotajeMinimo &&
                  OrderProfit() > 0)
                 {
                  gananciaOperacion001 = OrderProfit() + OrderSwap() + OrderCommission();
                  break;
                 }
              }
           }


         // Calcular pérdida neta (pérdidas acumuladas - ganancia de 0.01)
         double perdidaNeta = perdidasAcumuladasSell - gananciaOperacion001;



         if(perdidaNeta > 0)
           {

            // NUEVO: Calcular lotaje basado en pérdida real, no en tics
            // Estimamos que necesitamos ganar aproximadamente la pérdida neta
            // Usamos la ganancia promedio esperada de la última operación ganadora
            double gananciaPromedioPor01Lote = (gananciaOperacion001 > 0) ? gananciaOperacion001 : 1.0;

            // Fórmula: (Pérdidas / Ganancia por 0.01) * 0.01 * Multiplicador
            double lotajeNecesario = (perdidasAcumuladasSell / gananciaPromedioPor01Lote) * lotajeMinimo * myMultiplierSell;



            lotsSell = NormalizeDouble(lotajeNecesario / lotstep, 0) * lotstep;

           }
         else
           {
            // Si la ganancia de 0.01 cubre todas las pérdidas, usar lotaje base
            lotsSell = lotajeBaseActual;

           }
        }
      else
        {

         // MODO NORMAL: Multiplicador
         lotsSell = lotajePerdidoGuardadoSell * myMultiplierSell;

        }

      lotsSell = NormalizeDouble(lotsSell / lotstep, 0) * lotstep;
      if(lotsSell < minlot)
         lotsSell = minlot;
      if(lotsSell > MaximalLots)
         lotsSell = MaximalLots;

      LogEnPantalla("✓✓ Multiplicador aplicado SELL - Lotaje: " + DoubleToString(lotsSell, 2));

      // ⚠️ NO RESETEAR AQUÍ - El reset ocurre cuando gana con el lotaje alto
      // Las variables se mantienen para saber que está recuperando pérdidas
      // El reset lo hace MyMartingala() cuando detecta ganancia con lotaje >= base
     }



// VALIDACIÓN DE FANTASMA ELIMINADA: Permitir SELL sin restricciones de precio
   double candidateSellPrice = NormalizeDouble(Bid, Digits);

   int TicketNuevoVenta = OrderSend(NULL, OP_SELL, lotsSell, candidateSellPrice, 10, 0, 0, NULL, MagicNumber, 0, clrRed);

   if(TicketNuevoVenta < 0)
     {
      Alert("OrdenSend Error: ", GetLastError());
      return (false);
     }
   else
     {
      Alert("Order Sent Succesfully, Ticket # is: " + string(TicketNuevoVenta));

      // NUEVO: Imprimir análisis de indicadores técnicos
      ImprimirAnalisisIndicadores("SELL", TicketNuevoVenta, lotsSell, Bid);

      OperacionAbierta = TicketNuevoVenta;
      // OperacionCloseAbierta=TicketNuevoCloseVenta;
      // activarCuentaVentas = true;
      // activarCuentaCompras = false;
      return (true);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ObtenerProfitTotal()
  {
   double profitByPair = 0;
   for(int x = OrdersHistoryTotal(); x >= 0; x--)  // Reviso el historial en orden inverso
     {
      int see = OrderSelect(x - 1, SELECT_BY_POS, MODE_HISTORY); // selecciono la ultima
      if(OrderSymbol() == Symbol() && OrderProfit() < 0 && OrderMagicNumber() == MagicNumber)
        {
         profitByPair = profitByPair + OrderProfit();
         return profitByPair;
        }
      else
         if(OrderSymbol() == Symbol() && OrderProfit() > 0 && OrderMagicNumber() == MagicNumber)
           {
            break;
           }
     }
   return profitByPair;
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Utilidades: PnL flotante y conteo de pérdidas consecutivas        |
//+------------------------------------------------------------------+
double GetFloatingProfitByMagicSymbol(int magic)
  {
   double floating = 0.0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() != Symbol())
         continue;
      if(OrderMagicNumber() != magic)
         continue;
      floating += (OrderProfit() + OrderSwap() + OrderCommission());
     }
   return floating;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountConsecutiveLosingClosedByMagicSymbol(int magic)
  {
   int count = 0;
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         continue;
      if(OrderSymbol() != Symbol())
         continue;
      if(OrderMagicNumber() != magic)
         continue;
      double p = OrderProfit() + OrderSwap() + OrderCommission();
      if(p < 0)
         count++;
      else
         if(p > 0)
            break;
     }
   return count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllByMagicSymbol(int magic)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() != Symbol())
         continue;
      if(OrderMagicNumber() != magic)
         continue;
      int type = OrderType();
      double price = (type == OP_BUY) ? Bid : Ask;
      double closeLots = OrderLots();
      string tipoOrden = (type == OP_BUY) ? "BUY" : "SELL";
      Print("🔴🔴🔴 ", tipoOrden, " CERRADO POR CloseAllByMagicSymbol() | Ticket #", OrderTicket(), " | Magic:", magic);
      bool closed = OrderClose(OrderTicket(), closeLots, NormalizeDouble(price, Digits), 10, clrBlack);

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyProteccionPerdidas()
  {
   int consecutivas = CountConsecutiveLosingClosedByMagicSymbol(MagicNumber);
   if(consecutivas < perdidasConsecutivasMin)
      return;

// Usar la misma fuente que el panel derecho: perdidas del historial reciente
   double perdidasPanel = perdidaAcumulada(); // negativa si hay pérdidas recientes
   double perdidasAbs = MathAbs(perdidasPanel);
   if(perdidasAbs <= 0.0)
      return;

   double factor = porcentajeExtraCierre / 100.0; // 1.0 = 1%
   double objetivo = perdidasAbs + (perdidasAbs * factor);
   double flotante = GetFloatingProfitByMagicSymbol(MagicNumber);

// Cerrar si el flotante ya cubre pérdidas acumuladas + % adicional
   if(flotante >= objetivo && objetivo > 0)
     {

      Alert("Protección de pérdidas: cerrando recuperando ", DoubleToString(flotante, 2),
            " (objetivo ", DoubleToString(objetivo, 2), ") en ", Symbol());
      // Cerrar por lados, usando las funciones existentes del EA
      CloseAllBuys();
      CloseAllSells();
     }
  }

//+------------------------------------------------------------------+
//| Función para imprimir análisis de indicadores técnicos          |
//| Simbología: ??!!?? para poder filtrar en logs                    |
//+------------------------------------------------------------------+
void ImprimirAnalisisIndicadores(string tipoOperacion, int ticket, double lotaje, double precio)
  {

// ===== RSI - Índice de Fuerza Relativa =====
   double rsi_0 = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);  // Vela actual
   double rsi_1 = iRSI(NULL, 0, 14, PRICE_CLOSE, 1);  // Vela anterior
   double rsi_2 = iRSI(NULL, 0, 14, PRICE_CLOSE, 2);  // 2 velas atrás

   string rsi_tendencia = "";
   double rsi_pendiente = rsi_0 - rsi_2;  // Pendiente en 2 velas
   if(rsi_0 > rsi_1 && rsi_1 > rsi_2)
      rsi_tendencia = "SUBIENDO";
   else
      if(rsi_0 < rsi_1 && rsi_1 < rsi_2)
         rsi_tendencia = "BAJANDO";
      else
         rsi_tendencia = "LATERAL";

// Verificar si confirma la operación
   string rsi_confirmacion = "";
   if(tipoOperacion == "BUY" && rsi_pendiente > 0)
      rsi_confirmacion = "CONFIRMA";
   else
      if(tipoOperacion == "SELL" && rsi_pendiente < 0)
         rsi_confirmacion = "CONFIRMA";
      else
         rsi_confirmacion = "NO-CONFIRMA";

   string rsi_zona = "";
   if(rsi_0 > 70)
      rsi_zona = "🔴 SOBRECOMPRA";
   else
      if(rsi_0 < 30)
         rsi_zona = "🔴 SOBREVENTA";
      else
         if(rsi_0 > 60)
            rsi_zona = "🟡 CERCA SOBRECOMPRA";
         else
            if(rsi_0 < 40)
               rsi_zona = "🟡 CERCA SOBREVENTA";
            else
               rsi_zona = "🟢 ZONA NEUTRA";

   string rsi_agotamiento = "";
   if(tipoOperacion == "BUY" && rsi_0 > 70)
      rsi_agotamiento = "⚠️ AGOTAMIENTO ALCISTA POSIBLE";
   else
      if(tipoOperacion == "SELL" && rsi_0 < 30)
         rsi_agotamiento = "⚠️ AGOTAMIENTO BAJISTA POSIBLE";
      else
         rsi_agotamiento = "✅ SIN SEÑAL DE AGOTAMIENTO";


// ===== MACD - Moving Average Convergence Divergence =====
   double macd_main_0 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double macd_main_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
   double macd_signal_0 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
   double macd_signal_1 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
   double macd_hist_0 = macd_main_0 - macd_signal_0;
   double macd_hist_1 = macd_main_1 - macd_signal_1;

   string macd_tendencia = "";
   double macd_pendiente = macd_main_0 - macd_main_1;  // Pendiente del MACD
   if(macd_main_0 > macd_main_1)
      macd_tendencia = "SUBIENDO";
   else
      if(macd_main_0 < macd_main_1)
         macd_tendencia = "BAJANDO";
      else
         macd_tendencia = "PLANO";

// Verificar si confirma la operación
   string macd_confirmacion = "";
   if(tipoOperacion == "BUY" && macd_pendiente > 0)
      macd_confirmacion = "CONFIRMA";
   else
      if(tipoOperacion == "SELL" && macd_pendiente < 0)
         macd_confirmacion = "CONFIRMA";
      else
         macd_confirmacion = "NO-CONFIRMA";

   string macd_cruce = "";
   if(macd_main_0 > macd_signal_0 && macd_main_1 <= macd_signal_1)
      macd_cruce = "🟢 CRUCE ALCISTA RECIENTE";
   else
      if(macd_main_0 < macd_signal_0 && macd_main_1 >= macd_signal_1)
         macd_cruce = "🔴 CRUCE BAJISTA RECIENTE";
      else
         if(macd_main_0 > macd_signal_0)
            macd_cruce = "🟢 MACD SOBRE SEÑAL";
         else
            macd_cruce = "🔴 MACD BAJO SEÑAL";

   string macd_fuerza = "";
   double macd_abs = MathAbs(macd_hist_0);
   if(macd_abs < 0.05)
      macd_fuerza = "⚠️ HORIZONTAL - POCA FUERZA";
   else
      if(macd_abs > 0.2)
         macd_fuerza = "💪 FUERTE MOMENTUM";
      else
         macd_fuerza = "📊 MOMENTUM MODERADO";

   string macd_divergencia = "";
   if(tipoOperacion == "BUY" && macd_hist_0 < macd_hist_1)
      macd_divergencia = "⚠️ POSIBLE DIVERGENCIA BAJISTA";
   else
      if(tipoOperacion == "SELL" && macd_hist_0 > macd_hist_1)
         macd_divergencia = "⚠️ POSIBLE DIVERGENCIA ALCISTA";
      else
         macd_divergencia = "✅ SIN DIVERGENCIA";


// ===== STOCHASTIC - Oscilador Estocástico =====
   double stoch_k_0 = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 0);
   double stoch_k_1 = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 1);
   double stoch_k_2 = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 2);
   double stoch_d_0 = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_SIGNAL, 0);

   string stoch_tendencia = "";
   double stoch_pendiente = stoch_k_0 - stoch_k_2;  // Pendiente en 2 velas
   if(stoch_k_0 > stoch_k_1 && stoch_k_1 > stoch_k_2)
      stoch_tendencia = "SUBIENDO";
   else
      if(stoch_k_0 < stoch_k_1 && stoch_k_1 < stoch_k_2)
         stoch_tendencia = "BAJANDO";
      else
         stoch_tendencia = "LATERAL";

// Verificar si confirma la operación
   string stoch_confirmacion = "";
   if(tipoOperacion == "BUY" && stoch_pendiente > 0)
      stoch_confirmacion = "CONFIRMA";
   else
      if(tipoOperacion == "SELL" && stoch_pendiente < 0)
         stoch_confirmacion = "CONFIRMA";
      else
         stoch_confirmacion = "NO-CONFIRMA";

   string stoch_zona = "";
   if(stoch_k_0 > 80)
      stoch_zona = "🔴 SOBRECOMPRA";
   else
      if(stoch_k_0 < 20)
         stoch_zona = "🔴 SOBREVENTA";
      else
         if(stoch_k_0 > 70)
            stoch_zona = "🟡 CERCA SOBRECOMPRA";
         else
            if(stoch_k_0 < 30)
               stoch_zona = "🟡 CERCA SOBREVENTA";
            else
               stoch_zona = "🟢 ZONA NEUTRA";

   string stoch_cruce = "";
   if(stoch_k_0 > stoch_d_0 && stoch_k_1 <= stoch_d_0)
      stoch_cruce = "🟢 CRUCE ALCISTA K>D";
   else
      if(stoch_k_0 < stoch_d_0 && stoch_k_1 >= stoch_d_0)
         stoch_cruce = "🔴 CRUCE BAJISTA K<D";
      else
         if(stoch_k_0 > stoch_d_0)
            stoch_cruce = "🟢 K SOBRE D";
         else
            stoch_cruce = "🔴 K BAJO D";

   string stoch_agotamiento = "";
   if(tipoOperacion == "BUY" && stoch_k_0 > 80)
      stoch_agotamiento = "⚠️ AGOTAMIENTO ALCISTA POSIBLE";
   else
      if(tipoOperacion == "SELL" && stoch_k_0 < 20)
         stoch_agotamiento = "⚠️ AGOTAMIENTO BAJISTA POSIBLE";
      else
         stoch_agotamiento = "✅ SIN SEÑAL DE AGOTAMIENTO";


// ===== ANÁLISIS COMBINADO =====
// Detectar horizontalidad
   bool horizontal = false;
   int puntos_horizontalidad = 0;
   if(macd_abs < 0.05)
      puntos_horizontalidad++;
   if(MathAbs(stoch_k_0 - stoch_k_1) < 5)
      puntos_horizontalidad++;
   if(MathAbs(rsi_0 - rsi_1) < 5)
      puntos_horizontalidad++;

   string mensaje_horizontal = "";
   if(puntos_horizontalidad >= 2)
     {
      horizontal = true;
      mensaje_horizontal = "MERCADO HORIZONTAL (" + IntegerToString(puntos_horizontalidad) + "/3 planos)";
     }
   else
      mensaje_horizontal = "Mercado con tendencia";

// Detectar agotamiento combinado
   int puntos_agotamiento = 0;
   string mensaje_agotamiento = "";
   if(tipoOperacion == "BUY")
     {
      if(rsi_0 > 70)
         puntos_agotamiento++;
      if(stoch_k_0 > 80)
         puntos_agotamiento++;
      if(macd_hist_0 < macd_hist_1)
         puntos_agotamiento++;

      if(puntos_agotamiento >= 2)
         mensaje_agotamiento = "ALERTA: AGOTAMIENTO ALCISTA (" + IntegerToString(puntos_agotamiento) + "/3)";
      else
         mensaje_agotamiento = "Sin agotamiento alcista";
     }
   else
      if(tipoOperacion == "SELL")
        {
         if(rsi_0 < 30)
            puntos_agotamiento++;
         if(stoch_k_0 < 20)
            puntos_agotamiento++;
         if(macd_hist_0 > macd_hist_1)
            puntos_agotamiento++;

         if(puntos_agotamiento >= 2)
            mensaje_agotamiento = "ALERTA: AGOTAMIENTO BAJISTA (" + IntegerToString(puntos_agotamiento) + "/3)";
         else
            mensaje_agotamiento = "Sin agotamiento bajista";
        }

// Confirmación de todos los indicadores
   int confirmaciones = 0;
   string mensaje_confirmaciones = "";
   if(tipoOperacion == "BUY")
     {
      if(rsi_0 > 50)
         confirmaciones++;
      if(macd_main_0 > macd_signal_0)
         confirmaciones++;
      if(stoch_k_0 > 50)
         confirmaciones++;

      if(confirmaciones == 3)
         mensaje_confirmaciones = "TODOS CONFIRMAN BUY (3/3)";
      else
         if(confirmaciones >= 2)
            mensaje_confirmaciones = "MAYORIA CONFIRMA (2/3)";
         else
            mensaje_confirmaciones = "POCOS CONFIRMAN (" + IntegerToString(confirmaciones) + "/3)";
     }
   else
      if(tipoOperacion == "SELL")
        {
         if(rsi_0 < 50)
            confirmaciones++;
         if(macd_main_0 < macd_signal_0)
            confirmaciones++;
         if(stoch_k_0 < 50)
            confirmaciones++;

         if(confirmaciones == 3)
            mensaje_confirmaciones = "TODOS CONFIRMAN SELL (3/3)";
         else
            if(confirmaciones >= 2)
               mensaje_confirmaciones = "MAYORIA CONFIRMA (2/3)";
            else
               mensaje_confirmaciones = "POCOS CONFIRMAN (" + IntegerToString(confirmaciones) + "/3)";
        }

// NUEVO: Contador de pendientes confirmando
   int pendientes_confirman = 0;
   if(rsi_confirmacion == "CONFIRMA")
      pendientes_confirman++;
   if(macd_confirmacion == "CONFIRMA")
      pendientes_confirman++;
   if(stoch_confirmacion == "CONFIRMA")
      pendientes_confirman++;

   string mensaje_pendientes = "PENDIENTES: " + IntegerToString(pendientes_confirman) + "/3 CONFIRMAN";
   if(pendientes_confirman < 2)
      mensaje_pendientes = mensaje_pendientes + " ALERTA!";


  }

//+------------------------------------------------------------------+
//| Función para registrar cierre de operaciones con análisis       |
//| Simbología: ??!!?? para poder filtrar en logs                    |
//+------------------------------------------------------------------+
void RegistrarCierreOperacion(int ticket, string razonCierre)
  {
   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return;

   double profit = OrderProfit() + OrderSwap() + OrderCommission();
   string tipoOp = (OrderType() == OP_BUY) ? "BUY" : "SELL";
   string resultado = (profit > 0) ? "GANANCIA" : "PERDIDA";

// Obtener datos de los indicadores en el momento del cierre
   double rsi_cierre = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double macd_main = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double macd_signal = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
   double stoch_k = iStochastic(NULL, 0, 8, 5, 5, MODE_SMA, 1, MODE_MAIN, 0);


  }

//+------------------------------------------------------------------+
