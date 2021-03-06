//+------------------------------------------------------------------+
//|                                                 SymbolSearch.mqh |
//|                                 Copyright 2017, Keisuke Iwabuchi |
//|                                        https://order-button.com/ |
//+------------------------------------------------------------------+


#ifndef _LOAD_MODULE_SYMBOL_SEARCH
#define _LOAD_MODULE_SYMBOL_SEARCH


/** 取引銘柄名取得処理 */
class SymbolSearch
{
   public:
      static string getSymbolInMarket(const string currency1, 
                                      const string currency2 = "");
      static string getSymbolInAll(const string currency1, 
                                   const string currency2 = "");
   
   private:
      static string getSymbol(      bool   selected, 
                              const string currency1, 
                              const string currency2 = "");
};


/**
 * currency1を含む銘柄名を気配値表示から取得する
 * currency2が指定されている場合は1と2両方を含む銘柄名を取得する
 * 気配値表示に存在せず全銘柄一覧には存在する場合は、
 * 気配値表示に追加してから銘柄名を返す
 *
 * @param const string currency1 銘柄名
 * @param const string currency2 銘柄名
 *
 * @return string 該当する銘柄名。存在しない場合は空の文字列。
 */
static string SymbolSearch::getSymbolInMarket(const string currency1, 
                                              const string currency2 = "")
{
   string symbol, add;
   
   /** 気配値表示から該当の銘柄を取得 */
   symbol = SymbolSearch::getSymbol(true, currency1, currency2);
   if(StringLen(symbol) > 0) return(symbol);

   /** 銘柄一覧から銘柄を取得 */
   add = SymbolSearch::getSymbol(false, currency1, currency2);
   
   /** 銘柄が一覧に存在していれば気配値表示に追加 */
   if(StringLen(add) > 0) {
      SymbolSelect(add, true);
      
      /**
       * 銘柄を追加してもMarketInfoで値が取得できるまでラグがある
       * 回避策として1秒Sleepさせる
       */
      Sleep(1000);
   }

   return(add);
}


/**
 * currency1を含む銘柄名を全銘柄一覧から取得する
 * currency2が指定されている場合は1と2両方を含む銘柄名を取得する
 *
 * @param const string currency1 銘柄名
 * @param const string currency2 銘柄名
 *
 * @return string 該当する銘柄名。存在しない場合は空の文字列。
 */
static string SymbolSearch::getSymbolInAll(const string currency1, 
                                           const string currency2 = "")
{
   return(SymbolSearch::getSymbol(false, currency1, currency2));
}


/**
 * currency1を含む銘柄名を取得する
 * currency2が指定されている場合は1と2両方を含む銘柄名を取得する
 *
 * @param bool selected true:気配値一覧, false:全銘柄一覧
 * @param const string currency1 銘柄名
 * @param const string currency2 銘柄名
 *
 * @return string 該当する銘柄名。存在しない場合は空の文字列。
 */
static string SymbolSearch::getSymbol(      bool   selected,
                                      const string currency1, 
                                      const string currency2 = "")
{
   string symbol = "";
   
   for(int i = 0; i < SymbolsTotal(selected); i++) {
      symbol = SymbolName(i, selected);
      if(StringFind(symbol, currency1) == -1) continue;
      if(StringLen(currency2) > 0) {
         if(StringFind(symbol, currency2) == -1) continue;
      }
      
      return(symbol);
   }
   
   return("");
}


#endif
