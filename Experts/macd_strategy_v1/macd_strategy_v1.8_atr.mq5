//+------------------------------------------------------------------+
//|                                             macd_strategy_v1.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <MyFiles/Util.mqh>
#include <MyFiles/PositionHandler.mqh>

CTrade trade;


int barsTotal;
int macdHandle;
int devHandle;
int momHandle;
int ma200Handle;
int ma200Handle2;
int atrHandle;







PositionHandler phr;







//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   macdHandle = iMACD(_Symbol, PERIOD_CURRENT, 12,26,9, PRICE_CLOSE);
   //devHandle = iStdDev(_Symbol,_Period,20,0,MODE_SMA, PRICE_CLOSE);
   //momHandle = iMomentum(_Symbol,PERIOD_CURRENT, 14, PRICE_CLOSE);
   ma200Handle = iMA(_Symbol,_Period,200, 0,MODE_SMA, PRICE_CLOSE);
   //ma200Handle2 = iMA(_Symbol,_Period,200, 0,MODE_SMMA, PRICE_CLOSE);
   
   atrHandle = iATR(_Symbol,_Period, 14);
   
   ObjectSetInteger(0,ma200Handle2,OBJPROP_COLOR,clrAliceBlue);
   
   barsTotal = iBars(_Symbol, PERIOD_CURRENT);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //updatePosition();


  // todos:
  // add spread filter to stay out of trade if spreadis too high
  // minimum steigung von ma200
  // test different candles lookback -> smaller than 10
  // use an atr volatility min value to enter trades -> 0,0004
  // find out how to determine a trend
  
  // use atr to device wether to enter a trade or not
  // use atr to determine risk to take -> low atr -> lower risk = 0.5 %
  // use atr to determin stop loss -> buy: openprice[0]- atr[0]
  
   
   
   
   
   

   
   
   
   
   
     
   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   int barsCount = iBars(_Symbol, PERIOD_CURRENT);  
   if(barsCount == barsTotal)
      return; 
   barsTotal = barsCount;


   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // fill MACD buffer
   
   // copies the last two values, starting with last completed bar [1]
   double macd[];
   CopyBuffer(macdHandle, MAIN_LINE, 1,2, macd); // stores only 2 items

   double signal[];
   CopyBuffer(macdHandle, SIGNAL_LINE, 1,2, signal);
   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // fill mA bufefr
   
   MqlRates price[];
   ArraySetAsSeries(price, true); // required??
   int data = CopyRates(_Symbol,_Period, 0, 2, price);
      
   
   
   double ma[];
   ArraySetAsSeries(ma, true);
   CopyBuffer(ma200Handle, 0, 0, 2, ma);
   
   double atr[];
   ArraySetAsSeries(atr, true);
   CopyBuffer(atrHandle, 0 ,0, 2, atr);



   

   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // 

   phr.updatePositions();
   phr.printMeasures();

   //drawPositionOpenCloseLines();
   


   



   
   
   
   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // return if open positions
   //if(PositionsTotal() > 0)
   //   return;
      
   double risk = 1;   // %
   double  rrr = 2;   // %
   double  tgr = 1;   // %     
   
   const double MINATR = 50*_Point;
   
   bool longCondition = macd[1] > signal[1] && 
                        macd[0] < signal[0] && 
                        //macd[1] < 0 && 
                        PositionsTotal() == 0 &&
                        price[1].close > ma[1];
                        // && atr[1] >= MINATR; //phr.getMinSlPoints();  // volatility 
                        
   bool shortCondition = macd[1] < signal[1] && 
                        macd[0] > signal[0] && 
                        //macd[1] > 0 && 
                        PositionsTotal() == 0 &&
                        price[1].close < ma[1];
                        //&& atr[1] >= MINATR; //phr.getMinSlPoints();  // volatility    
      
      
   if(!isTradingTime())
      return;   
   
      
   // buy condition
   if(longCondition){
      
      if(!phr.goLong(risk, rrr, tgr))
         Print("Error going long");
      phr.printMeasures();
      
   // sell condition
   }else if(shortCondition){
  
      if(!phr.goShort(risk, rrr, tgr))
         Print("Error going short");
      phr.printMeasures();

      
      
   }
      
   


}
//+------------------------------------------------------------------+

void drawOpenPositionLine(datetime date){

   string name = "OPEN at " + TimeToString(date);
   ObjectCreate(_Symbol, name, OBJ_VLINE,0, date ,0); // fixme
   ObjectSetInteger(0, name, OBJPROP_WIDTH,3);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlue);

}

//+------------------------------------------------------------------+

void drawClosePositionLine(datetime date){

   string name = "CLOSE at " + TimeToString(date);
   ObjectCreate(_Symbol, name, OBJ_VLINE,0,  date ,0);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,3);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);

}
//+------------------------------------------------------------------+
void drawPositionOpenCloseLines(){
   datetime from=0;
   datetime to=TimeCurrent();
   HistorySelect(from,to); // important
   for(uint i=0; i<(uint)HistoryOrdersTotal(); i++){
      if(i % 2){
         ulong ticket = HistoryOrderGetTicket(i);  // only close of position
         datetime done = (datetime)HistoryOrderGetInteger(ticket, ORDER_TIME_DONE);
         //Print("Closed position = ", ticket, " at ", done);
         drawClosePositionLine(done);
      }else{
         ulong ticket = HistoryOrderGetTicket(i);  // only close of position
         datetime done = (datetime)HistoryOrderGetInteger(ticket, ORDER_TIME_DONE);
         //Print("Closed position = ", ticket, " at ", done);
         drawOpenPositionLine(done);
      }  
   }
}


//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
bool
isTradingTime(){

   datetime begin = StringToTime("08:00");
   datetime end = StringToTime("18:00");
   datetime time = TimeCurrent();
   
   if(time >= begin && time < end)
      return true;
   return false;
}