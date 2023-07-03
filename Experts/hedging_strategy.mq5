//+------------------------------------------------------------------+
//|                                             hedging_strategy.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <MyFiles/PositionHandlerV2.mqh>
#include <MyFiles/HedgePositionHandler.mqh>
#include <MyFiles/Util.mqh>
#include <Trade/Trade.mqh>




int MACD; 
int BARS;
int MA200;
int ATR;
const ulong LOOKBACK=10;

CTrade trade;

double RISK=1;
double RRR=2;

HedgePositionHandler ph(RISK, RRR);

ulong buyTicket=0, sellTicket=0;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   MACD = iMACD(_Symbol, _Period, 12,26,9, PRICE_CLOSE);
   MA200 = iMA(_Symbol, _Period, 200, 0, MODE_SMA, PRICE_CLOSE);
   ATR = iATR(_Symbol,_Period, 14);
   
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
   
   Comment(TimeCurrent());
   
   
   double macdMain0 = Util::getMACD(LOOKBACK, 0, MAIN_LINE);
   double macdMain1 = Util::getMACD(LOOKBACK, 1, MAIN_LINE);
   double macdSignal0 = Util::getMACD(LOOKBACK, 0, SIGNAL_LINE);
   double macdSignal1 = Util::getMACD(LOOKBACK, 1, SIGNAL_LINE);
   
   
   bool longCondition = macdMain1 > macdSignal1 && 
                        macdMain0 < macdSignal0 &&
                        PositionsTotal() == 0 &&
                        OrdersTotal() == 0;

                        
   bool shortCondition = macdMain1 < macdSignal1 && 
                        macdMain0 > macdSignal0 &&
                        PositionsTotal() == 0;
                        
                        
   //===================================================================    
   // always open only one buy/sell pair
   // if one sl gets hit adapt the others position sl to breakeven + spread btw. sl of closed position
                
                        
      //todo: on each tick          
      //ph.modifyPosition();




   //===================================================================
   
   if(!Util::isTradingTime("06:00", "18:00"))
      return;

    if(!longCondition)
      return;
      
      ph.openPositionV2();
      
      
      
     
    
      


   
 
   


}
//+------------------------------------------------------------------+
