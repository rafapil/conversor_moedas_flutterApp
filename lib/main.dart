import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert'; // aqui faz a conversão json maps

const request = "https://api.hgbrasil.com/finance?format=json&key=60df7606";

void main() async {
  //http.Response response = await http.get(request);
  //print(json.decode(response.body)["results"]["currencies"]["BRL"]);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // declarando as moedas
  double euro;
  double dolar;
  double real;

  // declarando os controladores para os edtText
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    // Verifica se o campo esta vazio e apaga todos
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    //print(text);
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    //print(text);
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    //print(text);
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  // Funcao que apaga todos os campos se algum ficar vazio
  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor de Moedas"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados ",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "! Erro ao carregar dados ",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  ),
                );
              } else
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
              euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

              return SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.attach_money,
                      size: 150.0,
                      color: Colors.amber,
                    ),
                    buildTextField(
                        "Reais", "R\$", realController, _realChanged),
                    Divider(),
                    buildTextField(
                        "Dolares", "US\$", dolarController, _dolarChanged),
                    Divider(),
                    buildTextField("Euro", "€", euroController, _euroChanged),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget buildTextField(String label, String prefix,
    TextEditingController controlador, Function funcao) {
  return TextField(
    controller: controlador,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.amber,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    onChanged: funcao,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
  );
}
