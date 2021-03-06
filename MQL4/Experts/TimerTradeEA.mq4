//+------------------------------------------------------------------+
//|                                                 TimerTradeEA.mq4 |
//|                                 Copyright 2017, Keisuke Iwabuchi |
//|                                         http://order-button.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Keisuke Iwabuchi"
#property link      "http://order-button.com/"
#property version   "1.00"
#property strict


#include <mql4_modules\Order\Order.mqh>
#include <mql4_modules\Trade\Trade.mqh>


enum TradeType {
   Buy = 0,
   Sell = 1
};


input  TradeType Type        = Buy;     // 取引種別 (Buy or Sell)
input  string    EntryTime   = "9:00";  // エントリー時刻
input  string    ExitTime    = "15:00"; // 決済時刻
input  int       WaitingTime = 60;      // 猶予時間 (sec)
sinput int       MagicNumber = 127;     // マジックナンバー
input  double    Lots        = 0.1;     // 取引数量
sinput int       Slippage    = 10;      // スリッページ (point)
input  double    StopLoss    = 100.0;   // 損切り (pips)
input  double    TakeProfit  = 100.0;   // 利食い (pips)


int OnInit()
{
   Comment(
      "Entry Time : ", EntryTime, "\n",
      "Exit Time : ", ExitTime
   );

   return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason)
{
   if (!IsVisualMode()) {
      Comment("");
   }
}


void OnTick()
{
   OpenPositions pos;
   Order::getOrderCount(pos, MagicNumber);
   
   if (pos.open_pos == 0) {
      OnEntry();
   } else {
      OnExit();
   }
}


void OnEntry()
{
   // EntryTime未設定の場合はエントリーしない 
   if (StringLen(EntryTime) == 0) {
      return;
   }
   
   // 取引時間外の場合は終了
   if (TimeZoneFilter(EntryTime, WaitingTime) == false) {
      return;
   }
   
   
   // 取引パラメーターの設定
   OrderSendRequest request;
   
   if (Type == Buy) {
      request.type = BUY;   
   } else {
      request.type = SELL;
   }
   request.price.type = DYNAMIC_PRICE;
   request.lots = Lots;
   request.slippage = Slippage;
   request.stoploss.type = DYNAMIC_PIPS;
   request.stoploss.value = StopLoss;
   request.takeprofit.type = DYNAMIC_PIPS;
   request.takeprofit.value = TakeProfit;
   request.magic = MagicNumber;
   request.comment = "TimerTradeEA";
   
   
   // 発注
   Trade::Entry(request);
}


void OnExit()
{
   // ExitTime未設定の場合はエントリーしない 
   if (StringLen(ExitTime) == 0) {
      return;
   }
   
   // 時間外の場合は終了
   if (TimeZoneFilter(ExitTime, WaitingTime) == false) {
      return;
   }
   
   
   // ポジション情報の取得
   OrderData data[];
   Order::getOrderByTrades(MagicNumber, data);


   // 決済パラメーターの設定
   OrderCloseRequest request;
   request.ticket = data[0].ticket;
   request.lots = data[0].lots;
   if (data[0].type == BUY) {
      request.price = Bid;
   } else {
      request.price = Ask;
   }
   request.slippage = Slippage;
   
   
   // 決済
   Trade::Exit(request);
}


bool TimeZoneFilter(string start_time, int waiting_time)
{
   datetime s_time = StringToTime(start_time);
   datetime e_time = s_time + waiting_time;

   return(s_time <= TimeCurrent() && TimeCurrent() <= e_time);
}
