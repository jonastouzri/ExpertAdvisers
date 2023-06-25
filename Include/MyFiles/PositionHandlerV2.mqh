//+------------------------------------------------------------------+
//|                                            PositionHandlerV2.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include <MyFiles/Util.mqh>

class PositionHandlerV2{

   double LOT;                      // 100.000

   
   double risk;                     // risk percentage of equity
   double riskRewardRatio;          // risk to reward ratio percentage
   double triggerRatio;                  // percentage of rrr where trailing sl will be adjusted
   
   
   double openPrice;                // trigger -> somewhere btw openPrice and tp
   double slPrice;                 
   double triggerPrice;          
   double tpPrice;
   
   double slPoints;
   double lotSize;
   
   ulong position;
   CTrade trade;
   
   
   
public:
   //+++++++++++++++++++++++++++++++++++++
   
   PositionHandlerV2(double _risk, double _riskRewardRatio){
   
      risk = _risk;
      riskRewardRatio = _riskRewardRatio;
      triggerRatio = _riskRewardRatio/2; // 0.25%
      
      LOT  = (long) 1/Point();   // fixme cast?
   }
   
   

   //+++++++++++++++++++++++++++++++++++++
   double 
   getLotSize(){      
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double moneyAtRisk = equity*risk/100;
      double posSize = moneyAtRisk / slPoints;              // 10 euro / 5pip(50points) = 10/0,0005 = 20000
      return posSize/LOT;                                   // 20000/100000 = 0.2

   }
   
   
   //+++++++++++++++++++++++++++++++++++++
   //+++++++++++++++++++++++++++++++++++++
   void
   initLongPosition(){          
      openPrice = NormalizeDouble(Util::getAskPrice(), _Digits);
      slPrice = NormalizeDouble(openPrice - 2*Util::getAtr(2, 1), _Digits);
      slPoints = NormalizeDouble(openPrice-slPrice, _Digits);
      tpPrice = NormalizeDouble(openPrice + slPoints*riskRewardRatio, _Digits); 
      triggerPrice = NormalizeDouble(openPrice + slPoints*triggerRatio, _Digits); 
      lotSize = NormalizeDouble(getLotSize(), 2);                
   }
   //+++++++++++++++++++++++++++++++++++++
   
   void
   initShortPosition(){          
      openPrice = NormalizeDouble(Util::getBidPrice(), _Digits);
      slPrice = NormalizeDouble(openPrice + 2*Util::getAtr(2, 1), _Digits);
      slPoints = NormalizeDouble(slPrice-openPrice, _Digits);
      tpPrice = NormalizeDouble(openPrice - slPoints*riskRewardRatio, _Digits); 
      triggerPrice = NormalizeDouble(openPrice - slPoints*triggerRatio, _Digits); 
      lotSize = NormalizeDouble(getLotSize(), 2);         
      
      Print("openPrice = ", openPrice, ", ", "slPrice = ", slPrice, ", ", "tpPrice = ", tpPrice, " ");
      
             
   }
   
   //+++++++++++++++++++++++++++++++++++++
   bool
   openLongPosition(){
      initLongPosition();
      
  
      if(!trade.Buy(lotSize, _Symbol, openPrice, slPrice, tpPrice)){
         Print("LONG POSITION FAILED = ", TimeCurrent());
         return false;
      }

      position = trade.ResultOrder();
      return true;
   
   }
   //+++++++++++++++++++++++++++++++++++++
   bool
   openShortPosition(){
   
      initShortPosition();
      if(!trade.Sell(lotSize, _Symbol, openPrice, slPrice, tpPrice)){
         Print("SHORT POSITION FAILED = ", TimeCurrent());
         return false;
      }

      position = trade.ResultOrder();
      return true;
      
   }
   
   //+++++++++++++++++++++++++++++++++++++
   void
   updateLongPosition(){
   
      if(PositionsTotal() == 0)
         return;
         
      if(!Util::isLongPosition(position))
         return;
         
      MqlRates prices = Util::getPriceInformation(2, 1);   
      double currentPrice = NormalizeDouble(prices.close, _Digits);
      
      if(currentPrice < triggerPrice)
         return;
         
         
      double shift = slPoints*triggerRatio;
      slPrice = slPrice + shift;
      tpPrice = tpPrice + shift;
      triggerPrice = triggerPrice + shift;         
         
         
      // fixme use position id version
      if(!trade.PositionModify(_Symbol, slPrice, tpPrice))
         Print("FAILED TO UPDATE LONG POSITION = ", TimeCurrent());         
         
         

         
      
   }
   //+++++++++++++++++++++++++++++++++++++
   void
   updateShortPosition(){
   
      if(PositionsTotal() == 0)
         return;
         
      if(!Util::isShortPosition(position))
         return;
         
      MqlRates prices = Util::getPriceInformation(2, 1);   
      double currentPrice = NormalizeDouble(prices.close, _Digits);
      
      if(currentPrice > triggerPrice)
         return;
         
         
      double shift = slPoints*triggerRatio;
      slPrice = slPrice - shift;
      tpPrice = tpPrice - shift;
      triggerPrice = triggerPrice - shift;         
         
      // fixme use position id version
      if(!trade.PositionModify(_Symbol, slPrice, tpPrice))
         Print("FAILED TO UPDATE SHORT POSITION = ", TimeCurrent());
      Print("sl = ", slPrice, "  tp = ", tpPrice, " tgr = ", triggerPrice);     

   }
   //+++++++++++++++++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++
   void
   trailingLong_V1(double& sl, double& tgr, double& tp){
   
      double step = slPoints*0.25;//triggerRatio;

   
      triggerPrice = NormalizeDouble(openPrice + step, _Digits); 
      MqlRates prices = Util::getPriceInformation(2, 1);   
      double currentPrice = NormalizeDouble(prices.close, _Digits);
      
      if(currentPrice > triggerPrice)
         return;
   
 
      slPrice = slPrice + step*4;   // go to breakeven
      tpPrice = tpPrice + step;
      triggerPrice = triggerPrice + step;         
 
   }
   //+++++++++++++++++++++++++++++++++++++


};
