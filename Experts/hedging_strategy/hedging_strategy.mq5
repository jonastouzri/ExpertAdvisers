//+------------------------------------------------------------------+
//|                                             hedging_strategy.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <MyFiles/PositionHandlerV2.mqh>
#include <MyFiles/Util.mqh>




int MACD; 
int BARS;
int MA200;




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   MACD = iMACD(_Symbol, _Period, 12,26,9, PRICE_CLOSE);
   MA200 = iMA(_Symbol, _Period, 200, 0, MODE_SMA, PRICE_CLOSE);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!Util::isNewBar(BARS))
      return;
   
   Comment(TimeCurrent);
 
   


}
//+------------------------------------------------------------------+
