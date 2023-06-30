//+------------------------------------------------------------------+
//|                                         HedgePositionHandler.mqh |
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


class HedgePositionHandler{

   double RISK;
   double RRR;
   uint LOOKBACK;

   bool isOpen;   
   ulong buyTicket;
   ulong sellTicket;
   
   position_t bp;
   position_t sp;
   
   CTrade trade;
   
public:
   
   HedgePositionHandler(double RISK_, double RRR_){
   
      RISK = RISK_;
      RRR = RRR_;    
      LOOKBACK=10; // 10 bars  
      
   }
   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   bool
   openPosition(){
   
      if(PositionsTotal() > 0)
         return false;
   
      double slPoints = Util::getAtr(LOOKBACK, 0)*3;  // rule to determine sl
      Util::initLongPosition(slPoints, RISK, RRR, bp);
      Util::initShortPosition(slPoints, RISK, RRR, sp);
      
      
      if(trade.Buy(bp.lotSize, Symbol(), bp.openPrice, bp.slPrice, bp.tpPrice)){
         //bp.orderId = trade.ResultOrder();
         bp.openTime = TimeCurrent();
      }
      
         
    
      if(trade.Sell(sp.lotSize, Symbol(), sp.openPrice, sp.slPrice, sp.tpPrice)){
         //sp.orderId = trade.ResultOrder();
         sp.openTime = TimeCurrent();
      }
      
      
   
   
      return true;  
   }
   
   
   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // return ticket of current open buy or sell position
   
   
   bool
   getPositionTicket(ENUM_POSITION_TYPE TYPE, ulong& ticket){
   
      if(PositionsTotal() > 2){
         Print(ARROW, __FUNCTION__, " MORE THAN 2 POSITIONS FOUND");
         return false;
      }
      
   
      for(int v = PositionsTotal() - 1; v >= 0; v--){
         ulong ticket_ = PositionGetTicket(v);
         if(PositionSelectByTicket(ticket_)){
            ulong type = PositionGetInteger(POSITION_TYPE);
            datetime time = (datetime) PositionGetInteger(POSITION_TIME);
            
            if(type == TYPE && time){
               ticket = ticket_;
               return true;
            }   
         }
   
      }
      
      return true;
      
      
   }
   
   
   
   bool
   modifyPosition(){
   
      if(PositionsTotal() == 0)
         return false;
   
      MqlRates prices = Util::getPriceInformation(LOOKBACK, 0);
      double currentPrice = prices.close;
      double currentSpread = prices.spread;
      
      
      
      // MODIFY BUY POSITION
      if(currentPrice > bp.tgrPrice){
      
         Print(ARROW, "BUY POSITION MUST BE MODIFIED AT ", TimeCurrent());
         
         //double step = Util::getAtr(LOOKBACK, 1)*3;
         
         double step = bp.slPoints; //Util::getAtr(LOOKBACK, 1);
         
         

         
                  
         bp.slPrice = bp.slPrice+step;
         bp.tpPrice = bp.tpPrice+step;
         bp.tgrPrice = bp.tgrPrice+step;
         
      
         ulong ticket;
         if(getPositionTicket(POSITION_TYPE_BUY, ticket)){
            if(trade.PositionModify(ticket, bp.slPrice, bp.tpPrice))
               Print(ARROW, "BUY POSITION MODIFIED AT ", TimeCurrent());
         }
      }
      
      // MODIFY SELL POSITION
      if(currentPrice < sp.tgrPrice){
      
         Print(ARROW, "SELL POSITION MUST BE MODIFIED AT ", TimeCurrent());
         
         
         
         double step =bp.slPoints; //Util::getAtr(LOOKBACK, 1);
        
         //bp.slPrice = bp.slPrice-bp.slPoints;
         //bp.tpPrice = bp.tpPrice-bp.slPoints;
         
                  
         sp.slPrice = sp.slPrice-step;
         sp.tpPrice = sp.tpPrice-step;
         sp.tgrPrice = sp.tgrPrice-step;
         
      
         ulong ticket;
         if(getPositionTicket(POSITION_TYPE_SELL, ticket)){
            if(trade.PositionModify(ticket, sp.slPrice, sp.tpPrice))
            //if(trade.PositionModify(ticket, 0.65100, 0.64830))
               Print(ARROW, "BUY POSITION MODIFIED AT ", TimeCurrent());
         }
      }
   
   
      return true;
   }




};