//+------------------------------------------------------------------+
//|                                                         Util.mqh |
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

const string ARROW = "===========================================> "; 


struct position_t{
   double openPrice;
   double slPrice;
   double tpPrice;
   double lotSize;
   double slPoints;
   double tgrPrice;   

   datetime openTime;



};

struct Util{

   static bool
   isNewBar(int& barsTotal){
      int barsCount = iBars(_Symbol, PERIOD_CURRENT);  
      if(barsCount == barsTotal)
         return false; 
      barsTotal = barsCount;
      return true;
   }
   //+++++++++++++++++++++++++++++++++++++

   static MqlRates
   getPriceInformation(uint lookBack, uint index){
      MqlRates priceInfo[];
      ArraySetAsSeries(priceInfo, true);
      int data = CopyRates(_Symbol, _Period, 0, lookBack, priceInfo);
      return priceInfo[index];
   }
   //+++++++++++++++++++++++++++++++++++++

   static double
   getAtr(ulong lookBack, ulong index){
      int atrHandle = iATR(_Symbol,_Period, 14);
      double atr[];
      ArraySetAsSeries(atr, true);
      CopyBuffer(atrHandle, 0 ,0, (int)lookBack, atr);
      return atr[index];
   }
   
   //+++++++++++++++++++++++++++++++++++++

   static double
   getMACD(ulong lookBack, ulong index, int signalId){
      int handle =  iMACD(_Symbol, PERIOD_CURRENT, 12,26,9, PRICE_CLOSE);
      double buffer[];
      ArraySetAsSeries(buffer, true);
      CopyBuffer(handle, signalId ,0, (int)lookBack, buffer);
      return buffer[index];
   }
   
   //+++++++++++++++++++++++++++++++++++++

   static double
   getMA(ulong lookBack, ulong index, int period){
      int handle =  iMA(_Symbol,_Period, period, 0,MODE_SMA, PRICE_CLOSE);
      double buffer[];
      ArraySetAsSeries(buffer, true);
      CopyBuffer(handle, 0 ,0, (int)lookBack, buffer);
      return buffer[index];
   }
   
   
   
   //+++++++++++++++++++++++++++++++++++++

   // price when selling
   static double 
   getBidPrice(){
      return NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), Digits());    
   }

   //+++++++++++++++++++++++++++++++++++++
   // price when buying
   static double 
   getAskPrice(){
      return NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), Digits());    
   }
   

   //+++++++++++++++++++++++++++++++++++++
   static bool
   isLongPosition(ulong position){
      if(!PositionSelectByTicket(position)){
         Print(__FUNCTION__, "FAILED TO SELECT POSITION");
         return false;
      }
         
      if(!(bool) PositionGetInteger(POSITION_TYPE))
         return true;
      return false;     
      // long -> 0
      // sell -> 1
   }
   //+++++++++++++++++++++++++++++++++++++
   static bool
   isShortPosition(ulong position){
      if(!PositionSelectByTicket(position)){
         Print(__FUNCTION__, "FAILED TO SELECT POSITION");
         return false;
      }
         
      if((bool) PositionGetInteger(POSITION_TYPE))
         return true;
      return false;     
      // long -> 0
      // sell -> 1
   }
   //+++++++++++++++++++++++++++++++++++++
   
   static bool
   isTradingTime(string begin_, string end_){
   
      datetime begin = StringToTime(begin_);
      datetime end = StringToTime(end_);
      datetime time = TimeCurrent();
      
      if(time >= begin && time < end)
         return true;
      return false;
   }
   
   
   //++++++++++++++++++++++++++++++++++++
   
   static bool
   isCurrentTime(string time_){
      if(TimeCurrent() != StringToTime(time_))
         return false;
      return true;
   }
   //++++++++++++++++++++++++++++++++++++
   
   
   
   static double 
   getLotSize(double slPoints, double RISK_){      
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double moneyAtRisk = equity*RISK_/100;
      double posSize = moneyAtRisk/slPoints;              // 10 euro / 5pip(50points) = 10/0,0005 = 20000
      return posSize/(1/Point());                        // LOT // 20000/100000 = 0.2

   }
   //++++++++++++++++++++++++++++++++++++
    
   
   static void
   initLongPosition(double slPoints, double RISK_,double RRR_,  position_t& pos){          
      double openPrice = NormalizeDouble(getAskPrice(), _Digits);
      double slPrice = NormalizeDouble(openPrice - slPoints, _Digits);
      double tpPrice = NormalizeDouble(openPrice + slPoints*RRR_, _Digits); 
      double lotSize = NormalizeDouble(getLotSize(slPoints, RISK_), 2);   
      double tgrPrice = NormalizeDouble(openPrice + slPoints, _Digits); 
 
      position_t _pos{openPrice, slPrice, tpPrice, lotSize, slPoints, tgrPrice};
      pos = _pos;
                   
   }
   //+++++++++++++++++++++++++++++++++++++
   
   static void
   initShortPosition(double slPoints, double RISK_, double RRR_, position_t& pos){          
      double openPrice = NormalizeDouble(getBidPrice(), _Digits);
      double slPrice = NormalizeDouble(openPrice + slPoints, _Digits);
      double tpPrice = NormalizeDouble(openPrice - slPoints*RRR_, _Digits); 
      double lotSize = NormalizeDouble(getLotSize(slPoints, RISK_), 2);  
      double tgrPrice = NormalizeDouble(openPrice - slPoints, _Digits); 
             
      position_t _pos{openPrice, slPrice, tpPrice, lotSize, slPoints, tgrPrice};
      pos = _pos;
             
   }
   

   

};