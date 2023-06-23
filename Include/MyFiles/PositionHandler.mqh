//+------------------------------------------------------------------+
//|                                              PositionHandler.mqh |
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


class PositionHandler{

   double rrr;         // risk to reward ratio percentage
   double risk;        // risk percentage
   double trigger;     // percentage of rrr where trailing sl will be adjusted
   
   
   double openPrice;
   double tgr;    // trigger -> somewhere btw openPrice and tp
   double sl;
   double tp;
   
   double slPoints;
   double lotSize;
   
   ulong position;
   
   // used if distance btw sl and price is too small or even negative
   double offset; // pip
   
   double minSlPoints; // min points required to open a position
   double maxSlPoints; // max points
   
   

   
   CTrade trade;
   
   //++++++++++++++++++++++++++++++++++++++++++++
   
   
   double 
   getAskPrice();
   
   double 
   getBidPrice();
   
   
   double 
   getLotSize();
   
   double
   calculateLotSize();
   
   double
   getLastLowestClose(uint candlesCount);
   
   bool
   calculateLongPosition();
   
   
   // ====
   
   double 
   getLastHighestClose(uint candlesCount);
   
   bool
   calculateShortPosition();
   

   
   bool
   isLongPosition();
   
   bool
   isShortPosition();
   
   
public:

   PositionHandler();


   ulong
   getPosition();

   bool
   goLong(double _risk, double _rrr, double _trigger);
   
   bool 
   goShort(double _risk, double _rrr, double _trigger);
   
   
   void
   updatePositions();
   
   
   
   void
   printMeasures();
   
   MqlRates
   getCandlePriceInformation(uint lookBackCandles, uint candleIndex);
   
   double
   getMinSlPoints();
   
    
   double
   getMaxSlPoints();  
   
   
};
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

PositionHandler::PositionHandler(){
   
   if(_Period == PERIOD_H1)                   
      offset = 200*_Point;       // 1h -> 20 pip
   else if(_Period == PERIOD_M1)
      offset = 200*_Point;        // 1M -> 5 pip
   else if(_Period == PERIOD_M5)
      offset = 0;//300*_Point;    
      
   else offset = 100*_Point;     // fixme

   minSlPoints = 50*_Point;
   maxSlPoints = 250*_Point;
  
      
   
   
  
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
double
PositionHandler::getMinSlPoints(){
   return minSlPoints;
}
   
   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
double
PositionHandler::getMaxSlPoints(){
   return maxSlPoints;
}  

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// price when selling
double 
PositionHandler::getBidPrice(){
   return NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);     
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// price when buying
double 
PositionHandler::getAskPrice(){
   return NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);     
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool 
PositionHandler::calculateLongPosition(){

   openPrice = getAskPrice();
   sl = NormalizeDouble(getLastLowestClose(10), _Digits);
   

   
   slPoints = NormalizeDouble(openPrice - sl, _Digits); // distance btw buy price and sl 
   
   if(slPoints < minSlPoints || slPoints > maxSlPoints){
      Print(__FUNCTION__, " --------------------------------------------------------------slPoints out of range -> ", slPoints);
      return false;
   }
   
   Print(__FUNCTION__, " --------------------------------------------------------------slPoints in range -> ", slPoints);
   
   
   lotSize = calculateLotSize();
   tp = openPrice + rrr*slPoints;
   tgr = openPrice + trigger*slPoints;
   return true;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bool
PositionHandler::calculateShortPosition(){


   openPrice = getBidPrice();
   sl = NormalizeDouble(getLastHighestClose(10), _Digits);
   

  
   slPoints = NormalizeDouble(sl - openPrice, _Digits); 
   
   if(slPoints < minSlPoints || slPoints > maxSlPoints){
      Print(__FUNCTION__, " --------------------------------------------------------------slPoints out of range -> ", slPoints);
      return false;
   }
      Print(__FUNCTION__, " --------------------------------------------------------------slPoints in range -> ", slPoints);

   //Print("____________________ ", slPoints);
   lotSize = calculateLotSize();
   tp = openPrice - rrr*slPoints;
   tgr = openPrice - trigger*slPoints;
   return true;

}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

double 
PositionHandler::calculateLotSize(){      
   const long STANDARDLOT = (long)1/_Point;
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double moneyAtRisk = equity*risk/100;
   double posSize = moneyAtRisk / slPoints; // 10 euro / 5pip(50points) = 10/0,0005 = 20000
   
   
   
   double lotSize_ =  NormalizeDouble(posSize / STANDARDLOT, 2); // 20000/100000 = 0.2
   return lotSize_;

}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// fixme: in utlity
double 
PositionHandler::getLastLowestClose(uint candlesCount){
   double close[];
   ArraySetAsSeries(close, true);
   CopyClose(_Symbol, _Period, 0, candlesCount, close);
   int indexClose = ArrayMinimum(close, 0, candlesCount);
   return close[indexClose];
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


double 
PositionHandler::getLastHighestClose(uint candlesCount){
   double close[];
   ArraySetAsSeries(close, true);
   CopyClose(_Symbol, _Period, 0, candlesCount, close);
   int indexClose = ArrayMaximum(close, 0, candlesCount);
   return close[indexClose];
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool
PositionHandler::goLong(double  _risk, 
                        double  _rrr, 
                        double  _trigger){

   risk = _risk;
   rrr = _rrr;
   
   // disbale tsl if invalid value
   if(_trigger >= rrr)
      _trigger = 0; 
   
   trigger = _trigger; // if 0 -> no tsl
   
   if(!calculateLongPosition()){
      Print(__FUNCTION__, " Could not compute lot size");
      return false;
   }
  
   if(!trade.Buy(lotSize, _Symbol, openPrice, sl, tp)){
      return false;
   }

   position = trade.ResultOrder();
   return true;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool
PositionHandler::goShort(double _risk, 
                        double _rrr, 
                        double _trigger){

   risk = _risk;
   rrr = _rrr;
   
   // disbale tsl if invalid value
   if(_trigger >= rrr)
      _trigger = 0; 
   
   trigger = _trigger; // if 0 -> no tsl
   
   if(!calculateShortPosition()){
      Print(__FUNCTION__, " Could not compute lot size");
      return false;
   }
   
   // BUG. LOTSIZE IS ZERO
   
   
      
  
   if(!trade.Sell(lotSize, _Symbol, openPrice, sl, tp)){ 
      return false;
   }

   position = trade.ResultOrder();
   return true;
}


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void
PositionHandler::printMeasures(){

   string text = 
      "OPEN PRICE = " + NormalizeDouble(openPrice, _Digits) +  "\n" + 
      "TGR PRICE = " + NormalizeDouble(tgr, _Digits) + "\n" + 
      "SL PRICE = " + NormalizeDouble(sl, _Digits) + "\n" + 
      "TP PRICE = " + NormalizeDouble(tp, _Digits) + "\n" + 
      "SL PIPS = " + NormalizeDouble(slPoints, _Digits) + "\n" +
      "LOT SIZE  = "+  NormalizeDouble(lotSize, 2) + "\n" +
      "POSITION = "+ NormalizeDouble(position, 2) + "\n";
      Comment(text);
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MqlRates
PositionHandler::getCandlePriceInformation(uint lookBackCandles, uint candleIndex){

   MqlRates priceInfo[];
   ArraySetAsSeries(priceInfo, true);
   int data = CopyRates(_Symbol, _Period, 0, lookBackCandles, priceInfo);
   return priceInfo[candleIndex];
}


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// buy only yet
void
PositionHandler::updatePositions(){

   if(PositionsTotal() == 0)
      return;
      
   if(trigger == 0)
      return;
   
   //int position = PositionSelect(_Symbol); // only valid whe always only one psoition is open !
   
   
   
   uint candlesLookBack=2;
   uint previousCandle = 1;
   MqlRates prices = getCandlePriceInformation(candlesLookBack, previousCandle);
   double currentPrice = prices.close;
   
   
   // LONG  
   if(isLongPosition()){
      if(currentPrice >= tgr){
            double shift = slPoints*trigger;
            sl = sl + shift;
            tp = tp + shift;
            tgr = tgr + shift;
            
            // in future us position id here
            if(trade.PositionModify(_Symbol, sl, tp))
               Print("Updated position successfully");

      }
   // SHORT   
   }else if(isShortPosition()){
      if(currentPrice <= tgr){
            double shift = slPoints*trigger;
            sl = sl - shift;
            tp = tp - shift;
            tgr = tgr - shift;
            
            Print("=================================================>", sl, "  < ", tgr );
            
            // in future us position id here
            if(trade.PositionModify(_Symbol, sl, tp))
               Print("Updated position successfully");
            return;  
      } 
   }
   
   

   
      

   
   
   

   

}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ulong
PositionHandler::getPosition(){
   return position;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bool
PositionHandler::isLongPosition(){

   // should be always true as a private member
   if(!PositionSelectByTicket(position))
      return false;
      
   if(!(bool)PositionGetInteger(POSITION_TYPE))
      return true;
   return false;     
   // long -> 0
   // sell -> 1
}




//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool
PositionHandler::isShortPosition(){
   // should be always true as a private member
   if(!PositionSelectByTicket(position))
      return false;
      
   if((bool)PositionGetInteger(POSITION_TYPE))
      return true;
   return false;     
   // long -> 0
   // sell -> 1
}


