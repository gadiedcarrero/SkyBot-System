# Refactorización de `IsMarketSafe()` en módulos de filtros (MQL4)

## Objetivo

Reemplazar la función monolítica actual `IsMarketSafe()` por un **conjunto de funciones de filtro** más pequeñas, cada una configurable mediante `extern` inputs.  

La API externa del sistema **NO debe cambiar**:

```mq4
enterUp   = (!rangoActivo && stochListoParaBuy  && IsMarketSafe());
enterDown = (!rangoActivo && stochListoParaSell && IsMarketSafe());
```

`IsMarketSafe()` debe seguir existiendo y devolver `bool`, pero internamente solo llamará a los nuevos filtros modulares.

---

## Contexto actual

- Lenguaje: **MQL4**
- Ya existe una variable global:

```mq4
double alturaPromedio;     // altura promedio de las últimas N barras
bool   detectarRangoHorizontal;  // si es false, IsMarketSafe() devuelve true
```

- `alturaPromedio` se actualiza en `CalcularAlturaPromedioBarras()` y se usa para TP/SL dinámicos.
- La versión actual de `IsMarketSafe()` (v2.7) contiene estos bloques lógicos:

1. EMA trenzada (`EMA 9` vs `EMA 20`)
2. Rango adaptativo (basado en ATR)
3. Precio pegado a EMA14
4. Slope de EMA14
5. Ángulo de EMA14
6. Canal estrecho (densidad en el centro del rango)
7. Alternancia de velas
8. Mechas largas
9. Cuerpo mínimo
10. Falta de continuación
11. Retroceso inmediato
12. Aceleración real

Cada bloque es una condición tipo “si se cumple → return false”.

---

## Tareas a implementar

### 1️⃣ Crear `extern` para activar/desactivar cada filtro

```mq4
extern bool usarFiltroEMATrenzada        = true;
extern bool usarFiltroRangoAdaptativo    = true;
extern bool usarFiltroPrecioPegadoEMA    = true;
extern bool usarFiltroSlopeEMA           = true;
extern bool usarFiltroAnguloEMA          = true;
extern bool usarFiltroCanalEstrecho      = true;
extern bool usarFiltroAlternanciaVelas   = true;
extern bool usarFiltroMechasLargas       = true;
extern bool usarFiltroCuerpoMinimo       = true;
extern bool usarFiltroFaltaContinuacion  = true;
extern bool usarFiltroRetrocesoInmediato = true;
extern bool usarFiltroAceleracionReal    = true;

extern bool mostrarDebugFiltros          = false;
```

---

### 2️⃣ Crear `extern` para parámetros de sensibilidad

```mq4
extern int    filtroLookback                 = 20;
extern int    filtroEMATrenzadaMaxCruces     = 3;

extern double filtroRangoMinMultiplicadorATR = 1.8;
extern double filtroPrecioPegadoFactorATR    = 0.30;
extern double filtroPrecioPegadoMaxRatio     = 0.40;

extern double filtroSlopeMinFactorATR        = 0.20;
extern double filtroAnguloMinGrados          = 3.5;

extern double filtroCanalFactorATR           = 0.35;
extern double filtroCanalMaxRatioCentral     = 0.50;

extern double filtroAlternanciaMaxRatio      = 0.45;

extern double filtroMechasFactorCuerpo       = 2.0;

extern double filtroCuerpoMinFactorAltura    = 0.25;
extern double filtroContinuacionMinFactorAlt = 0.30;
extern double filtroRetrocesoMaxFactorAlt    = 0.40;
extern double filtroAceleracionMinFactorAlt  = 0.20;
```

---

### 3️⃣ Crear funciones de filtro independientes

Cada filtro debe seguir esta firma:

```mq4
bool FiltroEMATrenzada(int lookback, int maxCruces);
bool FiltroRangoAdaptativo(int lookback, double atr, double minRangeFactorATR);
bool FiltroPrecioPegadoEMA(int lookback, double atr, double distFactorATR, double maxRatio);
bool FiltroSlopeEMA(double atr, double minSlopeFactorATR);
bool FiltroAnguloEMA(double point, double minGrados);
bool FiltroCanalEstrecho(int lookback, double atr, double factorATR, double maxRatioCentral);
bool FiltroAlternanciaVelas(int lookback, double maxRatioAlternancia);
bool FiltroMechasLargas();
bool FiltroCuerpoMinimo(double minFactorAltura);
bool FiltroFaltaContinuacion(double minFactorAltura);
bool FiltroRetrocesoInmediato(double maxFactorAltura);
bool FiltroAceleracionReal(double minFactorAltura);
```

Mover la lógica actual de `IsMarketSafe()` a estas funciones.  
Cada función debe retornar `false` si su condición falla.

---

### 4️⃣ Reescribir `IsMarketSafe()` como agregador de filtros

```mq4
bool IsMarketSafe()
{
   if(!detectarRangoHorizontal)
      return(true);

   double point = MarketInfo(Symbol(), MODE_POINT);
   double atr   = iATR(NULL,0,14,0);

   if(alturaPromedio <= 0)
      alturaPromedio = atr * 1.2;

   if(usarFiltroEMATrenzada &&
      !FiltroEMATrenzada(filtroLookback, filtroEMATrenzadaMaxCruces))
      return(false);

   if(usarFiltroRangoAdaptativo &&
      !FiltroRangoAdaptativo(filtroLookback, atr, filtroRangoMinMultiplicadorATR))
      return(false);

   if(usarFiltroPrecioPegadoEMA &&
      !FiltroPrecioPegadoEMA(filtroLookback, atr, filtroPrecioPegadoFactorATR, filtroPrecioPegadoMaxRatio))
      return(false);

   if(usarFiltroSlopeEMA &&
      !FiltroSlopeEMA(atr, filtroSlopeMinFactorATR))
      return(false);

   if(usarFiltroAnguloEMA &&
      !FiltroAnguloEMA(point, filtroAnguloMinGrados))
      return(false);

   if(usarFiltroCanalEstrecho &&
      !FiltroCanalEstrecho(filtroLookback, atr, filtroCanalFactorATR, filtroCanalMaxRatioCentral))
      return(false);

   if(usarFiltroAlternanciaVelas &&
      !FiltroAlternanciaVelas(filtroLookback, filtroAlternanciaMaxRatio))
      return(false);

   if(usarFiltroMechasLargas &&
      !FiltroMechasLargas())
      return(false);

   if(usarFiltroCuerpoMinimo &&
      !FiltroCuerpoMinimo(filtroCuerpoMinFactorAltura))
      return(false);

   if(usarFiltroFaltaContinuacion &&
      !FiltroFaltaContinuacion(filtroContinuacionMinFactorAlt))
      return(false);

   if(usarFiltroRetrocesoInmediato &&
      !FiltroRetrocesoInmediato(filtroRetrocesoMaxFactorAlt))
      return(false);

   if(usarFiltroAceleracionReal &&
      !FiltroAceleracionReal(filtroAceleracionMinFactorAlt))
      return(false);

   return(true);
}
```

---

### 5️⃣ Mantener compatibilidad con el EA

No modificar:

- Lógica de entradas/salidas  
- TP/SL  
- Martingala  
- `enterUp`, `enterDown`  

Solo se refactoriza el sistema de filtros.

---

### 6️⃣ Validación

1. Compilar sin errores.  
2. Backtest → debe dar resultados idénticos a v2.7 con los defaults.  
3. Probar filtros individuales apagados.  

---

## Fin del documento
