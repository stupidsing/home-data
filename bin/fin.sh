HOME=/home/friends/ywsing
FIN=${HOME}/fin
PATH=/usr/bin:${PATH}
D=$(date +%Y%m%d)
DT=$(date +%Y%m%d-%H%M%S)

(
  FIND=${FIN}/${D}
  mkdir ${FIND}
  for SYMBOL in AAPL GOOG MSFT; do
    wget -q -O - --user-agent="Mozilla/5.0 (Linux; Android 6.0.1; MotoG3 Build/MPI24.107-55) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.81 Mobile Safari/537.36" http://finance.yahoo.com/webservice/v1/symbols/${SYMBOL}/quote?format=json > ${FIND}/${SYMBOL}-${DT}.html
  done

  for CUR in USDEUR USDJPY; do
    wget -q -O - "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22USDEUR%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=" > ${FIND}/${CUR}-${DT}.html
  done

  wget -q -O - https://www.hkex.com.hk/eng/ddp/ddp_index.asp > ${FIND}/HKEX-FuturesOptions-${DT}.html

  for STOCK in 5 6; do
    wget -q -O - https://www.hkex.com.hk/eng/invest/stock_data/cache/pricetable_page_e_${STOCK}_1.htm > ${FIND}/HKEX-pricetables-${STOCK}-${DT}.html
	wget -q -O - https://www.hkex.com.hk/eng/invest/stock_data/cache/turnovertable_page_e_${STOCK}_1.htm > ${FIND}/HKEX-turnovers-${STOCK}-${DT}.html
  done
) > ${HOME}/public_html/fin.out
