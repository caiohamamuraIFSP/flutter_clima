import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:async/async.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Clima Tempo'),
        ),
        body: Center(
          child: CidadeClima(),
        ),
      ),
    );
  }
}

class CidadeClima extends StatefulWidget {
  const CidadeClima({
    super.key,
  });

  @override
  State<CidadeClima> createState() => _CidadeClimaState();
}

class Cidade {
  final String id;
  final String nome;

  Cidade(this.id, this.nome);
}

class _CidadeClimaState extends State<CidadeClima> {
  String tempMin = '';
  String tempMax = '';
  CancelableOperation? cancelavel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete<Cidade>(
          displayStringForOption: (option) => option.nome,
          optionsBuilder: (textEditingValue) async {
            if (textEditingValue.text.length < 3) return [];
            cancelavel?.cancel();
            cancelavel = CancelableOperation.fromFuture(
              Future.delayed(
                Duration(milliseconds: 400),
              ),
            );
            await cancelavel!.value;

            var url = Uri.http('tempo.cptec.inpe.br', '/autocomplete',
                {'term': textEditingValue.text});
            var res = await http.get(url);
            var map = jsonDecode(res.body) as List<dynamic>;
            print(map);

            return map
                .map(
                  (e) => Cidade(
                    e['custom'],
                    Uri.decodeFull(e['value']).replaceAll('+', ' '),
                  ),
                )
                .toList();
            ;
          },
          onSelected: (option) async {
            var url = Uri.http('tempo.cptec.inpe.br', '/${option.id}');
            var res = await http.get(url);
            var doc = html.parse(res.body);
            tempMax = doc.querySelector('.temp-max')!.innerHtml;
            tempMin = doc.querySelector('.temp-min')!.innerHtml;
            setState(() {});
          },
        ),
        Text('Temperatura mínima: ${tempMin}'),
        Text('Temperatura máxima: ${tempMax}'),
      ],
    );
  }
}
