//+------------------------------------------------------------------+
//|                                                  fvgEstricto.mq4 |
//|                                   Copyright 2024, Gadied Carrero |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
#property copyright "Copyright 2019, Gadied Carrero"
#property link "https://www.mql5.com"
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 4
//--- plot topBuyFVG
#property indicator_label1 "topBuyFVG"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrYellow
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- plot bottomBuyFVG
#property indicator_label2 "bottomBuyFVG"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrYellow
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- plot topSellFVG
#property indicator_label3 "topSellFVG"
#property indicator_type3 DRAW_ARROW
#property indicator_color3 clrDeepPink
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
//--- plot bottomSellFVG
#property indicator_label4 "bottomSellFVG"
#property indicator_type4 DRAW_ARROW
#property indicator_color4 clrDeepPink
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

//--- input parameters

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime timeofOperation = TimeCurrent();
datetime candletime = 0;
datetime currenttime = 0;
datetime Actiontime;
datetime LastActiontime = 0;

//--- indicator buffers
double topBuyFVG[];
double bottomBuyFVG[];
double topSellFVG[];
double bottomSellFVG[];
double SLBuffer[];
double TPBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, topBuyFVG);
    SetIndexStyle(0, DRAW_ARROW, EMPTY);
    SetIndexArrow(0, 234);
    SetIndexLabel(0, "Top FVG");

    SetIndexBuffer(1, bottomBuyFVG);
    SetIndexStyle(1, DRAW_ARROW, EMPTY);
    SetIndexArrow(1, 233);
    SetIndexLabel(1, "Bottom FVG");

    SetIndexBuffer(2, topSellFVG);
    SetIndexStyle(2, DRAW_ARROW, EMPTY);
    SetIndexArrow(2, 234);
    SetIndexLabel(2, "Top FVG");

    SetIndexBuffer(3, bottomSellFVG);
    SetIndexStyle(3, DRAW_ARROW, EMPTY);
    SetIndexArrow(3, 233);
    SetIndexLabel(3, "Bottom FVG");

    SetIndexBuffer(4, SLBuffer);
    SetIndexBuffer(5, TPBuffer);

    //---
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    //---
    int i;
    int counted_bars = IndicatorCounted();
    if (counted_bars < 0)
        return (-1);
    if (counted_bars > 0)
        counted_bars--;
    int limit = Bars - counted_bars;
    if (counted_bars == 0)
        limit -= 1 + 9;

    //----
    currenttime = Time[0];

    // Calcular el promedio de los rangos de las últimas 10 velas en pips
    double averageRangeInPips = AverageRangeInPips(high, low, 0, 200);

    for (i = 0; i <= limit; i++)
    {
        if (i >= 1)
        {
            // Detectar FVG alcista
            if (low[i] > high[i + 2] && MathAbs(low[i] - high[i + 2]) / Point >= averageRangeInPips && AreThreeBullishCandles(open, close, i))
            {
                topBuyFVG[i] = low[i];
                bottomBuyFVG[i] = high[i + 2];
                SLBuffer[i] = low[i + 1];
                TPBuffer[i] = high[i + 1];
            }

            // Detectar FVG bajista
            if (high[i] < low[i + 2] && MathAbs(high[i] - low[i + 2]) / Point >= averageRangeInPips && AreThreeBearishCandles(open, close, i))
            {
                bottomSellFVG[i] = high[i];
                topSellFVG[i] = low[i + 2];
                SLBuffer[i] = high[i + 1];
                TPBuffer[i] = low[i + 1];
            }
        }
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
}

//+------------------------------------------------------------------+
//| Function to calculate the average range of the last 10 candles in pips |
//+------------------------------------------------------------------+
double AverageRangeInPips(const double &high[], const double &low[], int startIndex, int count)
{
    double totalRange = 0.0;
    int validCount = 0;

    for (int i = startIndex; i < startIndex + count && i < Bars; i++)
    {
        double range = high[i] - low[i];
        totalRange += range;
        validCount++;
    }

    if (validCount == 0)
        return 0.0;

    double averageRange = totalRange / validCount;
    return averageRange / Point; // Convertir a pips
}

//+------------------------------------------------------------------+
//| Function to check if the last three candles are bullish          |
//+------------------------------------------------------------------+
bool AreThreeBullishCandles(const double &open[], const double &close[], int index)
{
    return (close[index] > open[index] &&
            close[index + 1] > open[index + 1] &&
            close[index + 2] > open[index + 2]);
}

//+------------------------------------------------------------------+
//| Function to check if the last three candles are bearish          |
//+------------------------------------------------------------------+
bool AreThreeBearishCandles(const double &open[], const double &close[], int index)
{
    return (close[index] < open[index] &&
            close[index + 1] < open[index + 1] &&
            close[index + 2] < open[index + 2]);
}