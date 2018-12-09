import 'package:comunicacion_publica/Widgets/NewHeader.dart';
import 'package:comunicacion_publica/Widgets/NewItem.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:comunicacion_publica/Model/Noticia.dart';
import 'package:comunicacion_publica/Strings.dart';

var page = 1;
var loadStatus = false;

Future<List<Noticia>> getLastNews(int page) async {
  loadStatus = true;
  String query = "posts?_embed&page=";
  String urlFinal = url + query + page.toString();

  var response = await http.get(urlFinal);

  if (response.statusCode == 200) {
    loadStatus = false;
    return Noticia.fromJsonList(json.decode(response.body));
  } else {
    //todo falla de carga
  }
}

void main() => runApp(new Home());

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appName),
        ),
        body: FutureBuilder<List<Noticia>>(
          future: getLastNews(1),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return BodyMain(
                listaDeNoticias: snapshot.data,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class BodyMain extends StatefulWidget {
  final List<Noticia> listaDeNoticias;

  const BodyMain({Key key, this.listaDeNoticias}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BodyMainState();
}

class BodyMainState extends State<BodyMain> {
  List<Noticia> listaDeNoticias;
  final ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    listaDeNoticias = widget.listaDeNoticias;
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: onNotification,
      child: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(child: NewHeader(noticia: listaDeNoticias[0])),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 0.7,
            ),
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              if (index == listaDeNoticias.length) {
                return NewItem(newS: listaDeNoticias[index]);
              } else {
                return NewItem(newS: listaDeNoticias[index + 1]);
              }
            }, childCount: listaDeNoticias.length - 1),
          )
        ],
      ),
    );
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (scrollController.position.maxScrollExtent > scrollController.offset &&
          scrollController.position.maxScrollExtent - scrollController.offset <=
              50) {
        if (loadStatus == false) {
          print('pidiendo');
          loadStatus = true;
          page += 1;
          getLastNews(page).then((list) {
            loadStatus = false;
            print('pedido');
            setState(() => listaDeNoticias.addAll(list));
          });
        }
      }
    }
    return true;
  }
}
