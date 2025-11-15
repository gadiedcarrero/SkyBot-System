#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Highs"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrBlack
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Lows"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrBlack
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

double HighBuffer[];
double LowBuffer[];

int OnInit()
{
    SetIndexBuffer(0, HighBuffer);
    SetIndexStyle(0, DRAW_ARROW, EMPTY);
    SetIndexArrow(0, 234);
    SetIndexLabel(0, "Up Arrow");

    SetIndexBuffer(1, LowBuffer);
    SetIndexStyle(1, DRAW_ARROW, EMPTY);
    SetIndexArrow(1, 233);
    SetIndexLabel(1, "Down Arrow");

    ArrayInitialize(HighBuffer, EMPTY_VALUE);
    ArrayInitialize(LowBuffer, EMPTY_VALUE);

    return (INIT_SUCCEEDED);
}

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
    ArrayInitialize(HighBuffer, EMPTY_VALUE);
    ArrayInitialize(LowBuffer, EMPTY_VALUE);

    int N = 5; // Número de barras antes y después para considerar

    for (int i = N; i < rates_total - N; i++)
    {
        bool isHigh = true;
        bool isLow = true;

        for (int j = i - N; j <= i + N; j++)
        {
            if (j != i)
            {
                if (high[i] <= high[j])
                {
                    isHigh = false;
                }
                if (low[i] >= low[j])
                {
                    isLow = false;
                }
            }
        }
        if (isHigh)
        {
            HighBuffer[i] = high[i];
        }

        if (isLow)
        {
            LowBuffer[i] = low[i];
        }
    }

    return (rates_total);
}