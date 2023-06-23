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

int macdHandle;
int devHandle;
int barsTotal;
ulong activePosition;

double slNow, tpNow;
double halfWay;
double priceNow;


PositionHandler phr;







//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   macdHandle = iMACD(_Symbol, PERIOD_CURRENT, 12,26,9, PRICE_CLOSE);
   devHandle = iStdDev(_Symbol,_Period,20,0,MODE_SMA, PRICE_CLOSE);
   
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


  
   
   
   
   
   
   
   
   
   
   
   
     
   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   int barsCount = iBars(_Symbol, PERIOD_CURRENT);  
   if(barsCount == barsTotal)
      return; 
   barsTotal = barsCount;


   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // fill buffers
   
   // copies the last two values, starting with last completed bar [1]
   double macd[];
   CopyBuffer(macdHandle, MAIN_LINE, 1,2, macd); // stores only 2 items

   double signal[];
   CopyBuffer(macdHandle, SIGNAL_LINE, 1,2, signal);
   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // 

     //test(); 

   

   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // 

   

   //drawPositionOpenCloseLines();
   

   phr.updateLongPosition();
   
   
   //Print("POSIIONS", PositionsTotal());
   
   if(PositionsTotal() > 0){
      if(PositionSelectByTicket(phr.getPosition())){
         Print("Found position = ",phr.getPosition());
         PositionGetInteger(POSITION_TYPE);
         Print("PositionType = ", PositionGetInteger(POSITION_TYPE));

      }
         
         
         
         
         //PositionGetInteger()
   
   }
   



   
   
   
   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // return if open positions
   //if(PositionsTotal() > 0)
   //   return;
      
   double risk = 1;   // %
   double  rrr = 2;   // %
   double  tgr = 1;   // %      
   
   bool longCondition = macd[1] > signal[1] && 
                        macd[0] < signal[0] && 
                        macd[1] < 0 && PositionsTotal() == 0;
                        
   bool shortCondition = macd[1] < signal[1] && 
                        macd[0] > signal[0] && 
                        macd[1] > 0 && PositionsTotal() == 0;               
      
      
   if(!isTradingTime())
      return;   
   
      
   // buy condition
   if(longCondition){
      
      if(!phr.goLong(risk, rrr, tgr))
         Print("Error going long");
      phr.printMeasures();
      
      
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
// price when selling
double getBidPrice(){
   return NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);     
}

//+------------------------------------------------------------------+
// price when buying
double getAskPrice(){
   return NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);     
}
//+------------------------------------------------------------------+

double getBuyStopLoss(uint pips){
   return getAskPrice() - pips*10*_Point;
}
//+------------------------------------------------------------------+
double getBuyTakeProfit(uint pips){
   return getAskPrice() + pips*10*_Point;
}

//+------------------------------------------------------------------+

double getLastLowestClose(uint candlesCount){
   double close[];
   ArraySetAsSeries(close, true);
   CopyClose(_Symbol, _Period, 0, candlesCount, close);
   int indexClose = ArrayMinimum(close, 0, candlesCount);
   return close[indexClose];
}
//+------------------------------------------------------------------+

double calculateLotSize(double slPoints, uint riskPercentage){      
   const long STANDARDLOT = 1/_Point;
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double moneyAtRisk = equity*riskPercentage/100;
   double posSize = moneyAtRisk / slPoints; // 10 euro / 5pip(50points) = 10/0,0005 = 20000
   double lotSize =  NormalizeDouble(posSize / STANDARDLOT, 2); // 20000/100000 = 0.2

   /*
   Print("Lot size = ", NormalizeDouble(lotSize, 2),
         " Sl points / pip= ", NormalizeDouble(slPoints/0.0001, 2),
         " Money at risk = ", NormalizeDouble(moneyAtRisk, 2)
   );
   */
   
   return lotSize;

}
//+------------------------------------------------------------------+

bool 
calculateBuyPosition(double askPrice, uint risk, uint rrr, double& lotSize, double& sl, double& tp){

   sl = getLastLowestClose(10);
   double slPoints = askPrice - sl;
   lotSize = calculateLotSize(slPoints, risk);
   tp = askPrice + rrr*slPoints;
   
   // fixme -> bad approach
   halfWay = askPrice + rrr/2*slPoints;
   
   return true;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

MqlRates
getCandlePriceInformation(uint lookBackCandles, uint candleIndex){

   MqlRates priceInfo[];
   ArraySetAsSeries(priceInfo, true);
   int data = CopyRates(_Symbol, _Period, 0, lookBackCandles, priceInfo);
   return priceInfo[candleIndex];
}


//+------------------------------------------------------------------+
void
updatePosition(){

   if(PositionsTotal() == 0)
      return;
   
   int position = PositionSelect(_Symbol); // only valid whe always only one psoition is open !

   
   
   uint candlesLookBack=2;
   uint previousCandle = 1;
   MqlRates prices = getCandlePriceInformation(candlesLookBack, previousCandle);
   double currentClosePrice = prices.close;
   
   
   Comment("CURRENT PRICE = ", prices.close,"\n",
            "HALF WAY = ", halfWay, "\n"
            ); 
   
   if(currentClosePrice >= halfWay){
  
         double slNew = halfWay; //1.06490;
         double tpNew = tpNow;
         //Print("Updated position successfully");
         if(trade.PositionModify(_Symbol, slNew, tpNew))
            Print("Updated position successfully");
         Print("Updated position successfully");   
   }
}
//+------------------------------------------------------------------+
bool
isTradingTime(){

   datetime begin = StringToTime("07:00");
   datetime end = StringToTime("18:00");
   datetime time = TimeCurrent();
   
   if(time >= begin && time < end)
      return true;
   return false;
}