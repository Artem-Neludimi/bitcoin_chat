import 'package:flutter/material.dart';

import 'currency_text_field.dart';

class SymbolsSearch extends StatefulWidget {
  const SymbolsSearch({
    Key? key,
    required this.onSelect,
    required this.symbols,
  }) : super(key: key);

  final Function(String symbol) onSelect;
  final List<String> symbols;

  @override
  State<SymbolsSearch> createState() => _SymbolSearchModalState();
}

class _SymbolSearchModalState extends State<SymbolsSearch> {
  String symbolSearch = "";
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CurrencyTextField(
              onChanged: (value) {
                setState(() {
                  symbolSearch = value;
                });
              },
            ),
          ),
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 130,
              ),
              children: widget.symbols
                  .where((element) => element
                      .toLowerCase()
                      .contains(symbolSearch.toLowerCase()))
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 50,
                        height: 30,
                        child: RawMaterialButton(
                          elevation: 0,
                          onPressed: () {
                            widget.onSelect(e);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            e,
                            style: const TextStyle(),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
