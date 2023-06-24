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

   // price when selling
   static double 
   getBidPrice(){
      return SymbolInfoDouble(_Symbol, SYMBOL_BID);    
   }

   //+++++++++++++++++++++++++++++++++++++
   // price when buying
   static double 
   getAskPrice(){
      return SymbolInfoDouble(_Symbol, SYMBOL_ASK);    
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

};