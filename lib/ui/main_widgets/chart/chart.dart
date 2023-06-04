import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../services/api/currency_repository.dart';
import '../../../services/models/candle_ticker_model.dart';
import '../../helper_widgets/symbol_search.dart';

class Chart extends StatefulWidget {
  final double statusBarHeight;

  const Chart({super.key, required this.statusBarHeight});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  final repository = CurrencyRepository();

  List<Candle> candles = [];
  WebSocketChannel? _channel;
  bool themeIsDark = false;
  String currentInterval = "1m";
  final intervals = [
    '1m',
    '3m',
    '5m',
    '15m',
    '30m',
    '1h',
    '2h',
    '4h',
    '6h',
    '8h',
    '12h',
    '1d',
    '3d',
    '1w',
    '1M',
  ];
  List<String> symbols = [];
  String currentSymbol = "";
  List<Indicator> indicators = [
    BollingerBandsIndicator(
      length: 20,
      stdDev: 2,
      upperColor: const Color(0xFF2962FF),
      basisColor: const Color(0xFFFF6D00),
      lowerColor: const Color(0xFF2962FF),
    ),
    WeightedMovingAverageIndicator(
      length: 100,
      color: Colors.green.shade600,
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchSymbols().then((value) {
      symbols = value;
      if (symbols.isNotEmpty) {
        fetchCandles(/*symbols[0]*/ 'BTCUSDT', currentInterval);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_channel != null) _channel!.sink.close();
  }

  Future<List<String>> fetchSymbols() async {
    try {
      // load candles info
      final data = await repository.fetchSymbols();
      return data;
    } catch (e) {
      // handle error
      return [];
    }
  }

  Future<void> fetchCandles(String symbol, String interval) async {
    // close current channel if exists
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    // clear last candle list
    setState(() {
      candles = [];
      currentInterval = interval;
    });

    try {
      // load candles info
      final data =
          await repository.fetchCandles(symbol: symbol, interval: interval);
      // connect to binance stream
      _channel =
          repository.establishConnection(symbol.toLowerCase(), currentInterval);
      // update candles
      setState(() {
        candles = data;
        currentInterval = interval;
        currentSymbol = symbol;
      });
    } catch (e) {
      // handle error
      return;
    }
  }

  void updateCandlesFromSnapshot(AsyncSnapshot<Object?> snapshot) {
    if (candles.isEmpty) return;
    if (snapshot.data != null) {
      final map = jsonDecode(snapshot.data as String) as Map<String, dynamic>;
      if (map.containsKey("k") == true) {
        final candleTicker = CandleTickerModel.fromJson(map);

        // cehck if incoming candle is an update on current last candle, or a new one
        if (candles[0].date == candleTicker.candle.date &&
            candles[0].open == candleTicker.candle.open) {
          // update last candle
          candles[0] = candleTicker.candle;
        }
        // check if incoming new candle is next candle so the difrence
        // between times must be the same as last existing 2 candles
        else if (candleTicker.candle.date.difference(candles[0].date) ==
            candles[0].date.difference(candles[1].date)) {
          // add new candle to list
          candles.insert(0, candleTicker.candle);
        }
      }
    }
  }

  Future<void> loadMoreCandles() async {
    try {
      // load candles info
      final data = await repository.fetchCandles(
          symbol: currentSymbol,
          interval: currentInterval,
          endTime: candles.last.date.millisecondsSinceEpoch);
      candles.removeLast();
      setState(() {
        candles.addAll(data);
      });
    } catch (e) {
      // handle error
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return SizedBox(
      height: isPortrait
          ? size.height * 0.45
          : size.height - widget.statusBarHeight,
      child: StreamBuilder(
        stream: _channel == null ? null : _channel!.stream,
        builder: (context, snapshot) {
          updateCandlesFromSnapshot(snapshot);
          return Candlesticks(
            key: Key(currentSymbol + currentInterval),
            indicators: indicators,
            candles: candles,
            onLoadMoreCandles: loadMoreCandles,
            onRemoveIndicator: (String indicator) {
              setState(() {
                indicators = [...indicators];
                indicators.removeWhere((element) => element.name == indicator);
              });
            },
            actions: [
              ToolBarAction(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Wrap(
                          children: intervals
                              .map((e) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 50,
                                      height: 30,
                                      child: RawMaterialButton(
                                        elevation: 0,
                                        onPressed: () {
                                          fetchCandles(currentSymbol, e);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          e,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  currentInterval,
                ),
              ),
              ToolBarAction(
                width: 100,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SymbolsSearch(
                        symbols: symbols,
                        onSelect: (value) {
                          fetchCandles(value, currentInterval);
                        },
                      );
                    },
                  );
                },
                child: Text(
                  currentSymbol,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
