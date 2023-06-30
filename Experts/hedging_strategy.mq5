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
#include <Trade/Trade.mqh>




int MACD; 
int BARS;
int MA200;
int ATR;
const ulong LOOKBACK=10;

CTrade trade;

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
                        PositionsTotal() == 0;

                        
   bool shortCondition = macdMain1 < macdSignal1 && 
                        macdMain0 > macdSignal0 &&
                        PositionsTotal() == 0;
                        
                        
   //===================================================================    
   // always open only one buy/sell pair
   // if one sl gets hit adapt the others position sl to breakeven + spread btw. sl of closed position
                
                        
   if(buyTicket != 0){           
      ulong ticket = PositionGetTicket(PositionsTotal()-1);
      
      
      
      if(PositionSelectByTicket(ticket)){
         ulong  type =PositionGetInteger(POSITION_TYPE);
         ulong  magic =PositionGetInteger(POSITION_MAGIC);
         Print("=============================> TYPE BUY ", type, "  ", magic);
      }
      
          
      Print("=============================> POSITIONS TOTAL ", PositionsTotal());
      if(!trade.PositionModify(ticket, 0.64780,0.65300)){
         Print("=============================> UPDATED BUY ", TimeCurrent(), "   ", trade.ResultOrder(), "   ", buyTicket);
      }
   }



   //===================================================================

    if(!longCondition)
      return;
      
      
   double atr = Util::getAtr(LOOKBACK, 0)*3;

    
   double rrr =1.5;
   double lotSize = 0.1;
   double slPoints = atr;//Point()*100; // 10 pip
   double openPrice = Util::getAskPrice();
   double slPriceBuy = openPrice - slPoints;
   double tpPriceBuy = openPrice + rrr*slPoints;
   double slPriceSell = openPrice + slPoints;
   double tpPriceSell = openPrice - rrr*slPoints;
   
   if(trade.Buy(lotSize, Symbol(), Util::getAskPrice(),slPriceBuy, tpPriceBuy)){
      buyTicket = trade.ResultOrder();
      Print("=============================> OPENED BUY ", TimeCurrent(), "   ", trade.ResultOrder());
      
      
      
   }
   /*     
   if(trade.Sell(lotSize, Symbol(), Util::getBidPrice(),slPriceSell, tpPriceSell)){
      Print("=============================> OPENED SELL ", TimeCurrent(), "   ", trade.ResultOrder());
      sellTicket = trade.ResultOrder();
      
   }
   */
     
   
    

   
 
   


}
//+------------------------------------------------------------------+
