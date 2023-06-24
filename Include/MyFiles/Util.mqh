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

class Util{

   static MqlRates
   getCandlePriceInformation(uint lookBackCandles, uint candleIndex){
      MqlRates priceInfo[];
      ArraySetAsSeries(priceInfo, true);
      int data = CopyRates(_Symbol, _Period, 0, lookBackCandles, priceInfo);
      return priceInfo[candleIndex];
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


};