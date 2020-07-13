import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jovicionario/loadscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jovicionario',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.purple,
      ),
      home: AnimatedSplashScreen(),//MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {

  AnimationController animationController;
  Animation<double> _animation;
  Tween<double> _tween;

  int _word = 0;
  int _counter = 0;
  int dataLength;
  var _jovirometro;
  Firestore firestore = Firestore.instance;

  final String urlBruno = 'https://twitter.com/brunoantonieto';
  final String urlLucas = 'https://twitter.com/euchamolucas';
  final String picpayBruno = 'https://picpay.me/bruno.antonieto';

  joviValue(){
    double fix = 84;
    double count = _counter.toDouble();
    double res = fix+count;
    return res;
  }

  addDrim(){
    setState(() {
      _counter++;
    });
  }

  _getLength()async{
    firestore.collection('jovi_words').getDocuments().then((data) async {
      dataLength = data.documents.length;
    });
  }

  _getJovirometro(number)async{
    firestore.collection('jovi_words').getDocuments().then((data) async {
      _jovirometro = data.documents[number]['jovirometro'].toDouble();

      _tween.begin = _tween.end;
      animationController.reset();
      _tween.end = _jovirometro;
      animationController.forward();

      return _jovirometro;
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getJovirometro(0); //sim, isso é uma gambiarra.
    _getLength();

    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this
    );
    _tween = Tween(begin:0,end:_jovirometro);
    _animation = _tween.animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut
    ))
        ..addListener((){setState(() {});});
    animationController.forward();
  }

  void _randomize() {
    setState(() {
      _word = Random().nextInt(dataLength);
      _counter = 0;
      _getJovirometro(_word);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jovicionário',
          style: GoogleFonts.merriweather(
          fontSize: 16,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context){
                return infoButton();
              }
            ),
            icon: Icon(Icons.info),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: mainLayout(),
      floatingActionButton: randomizeButton(), //
    );
  }

  infoButton(){
    _launchURL(name) async {
      return await launch(name);
    }
    return AlertDialog(
      title: Text('Informações'),
      content: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text:'Obrigado por instalar o Jovicionário!\n'
                   'Ele é uma tentativa de catalogar todas as Joviwords. '
                   'Pretendo continuar atualizando e corrigindo eventuais bugs.\n'
                   '\n'
                   'Se quiser contribuir, pode me mandar um salve no ',
              style: TextStyle(color:Colors.black),
            ),
            TextSpan(
              text:'PicPay',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()..onTap = (){_launchURL(picpayBruno);}
              ),
            TextSpan(
              text:' ou mandar ideias no Twitter.\n\n',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
                text:'Dev: ',
                style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text:'@brunoantonieto\n',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()..onTap = (){_launchURL(urlBruno);}
            ),
            TextSpan(
              text:'UX Design: ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
                text:'@euchamolucas',
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()..onTap = (){_launchURL(urlLucas);}
            ),
          ]
        )
      ),
        actions: <Widget>[
          FlatButton(
            child: Text('Dale!'),
            onPressed: (){Navigator.of(context).pop();},
          )
      ],
    );
  }

  Widget mainLayout(){
    return StreamBuilder(
        stream: Firestore.instance.collection('jovi_words').snapshots(),
        builder: (context, snapshot) {

          _getHash(name){
            for(var i=0;i<dataLength;i++){
              if(snapshot.data.documents[i]['nome'] == name){
                return i;
              }
            }
          }

          if (!snapshot.hasData) return Center(child: const Text('Carregando...'));

          //var jovirometro = snapshot.data.documents[_word]['jovirometro'];

          if(snapshot.data.documents[_word]['nome'] != 'Drim do drim'){
            return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[

                    //CARD
                    SizedBox(
                      width: double.maxFinite,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    '${snapshot.data.documents[_word]['nome']}',
                                    style: GoogleFonts.merriweather(
                                      fontSize: 46,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.fromLTRB(5,0,0,0),
                                    child: Text('${snapshot.data.documents[_word]['silaba'].replaceAll('-','•')}', style: TextStyle(fontSize: 22)),
                                  ),
                                ),
                                ListTile(title: Text('${snapshot.data.documents[_word]['significado']}',style: TextStyle(color: Colors.grey[800],fontSize: 18),)),
                                ListTile(title: Text('Exemplo', style: TextStyle(color: Colors.grey[800])), subtitle: Text('${snapshot.data.documents[_word]['exemplo']}'),),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    //PALAVRAS RELACIONADAS
                    RelatedStrings(),

                    //JOVIROMETRO
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: Text('Ruim',style: TextStyle(color: Colors.grey[800])),
                                )
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Text('Neutro',style: TextStyle(color: Colors.grey[800]))
                            ),
                            Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 25),
                                  child: Text('Bom',style: TextStyle(color: Colors.grey[800])),
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25,0,25,10),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.1),
                            gradient: LinearGradient(
                                colors: [
                                  Colors.red,
                                  Colors.redAccent,
                                  Colors.white,
                                  Colors.lightGreenAccent,
                                  Colors.green
                                ]
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: AnimatedBuilder(
                            animation: animationController,
                            builder: (_ , __) {
                              return SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white,
                                  trackHeight: 0.1,
                                  thumbColor: Colors.white,
                                  thumbShape: CustomSliderThumbShape(enabledThumbRadius: 10),
                                  overlayColor: Colors.white.withAlpha(1),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: 100,
                                  value: _animation.value,
                                  onChanged: (value){setState((){});},
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text('Jovirômetro',style: TextStyle(fontWeight: FontWeight.bold, color:Colors.grey[800], fontSize: 22),)
                      ),
                    ),

                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.info, size: 10, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.only(top:2),
                                child: Text('Desenvolvido por @brunoantonieto', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              )
                            ],
                          ),
                        )
                    )
                  ],
                )
            );

          } else { // DRIM DO DRIM DO DRIM DO...

            String drim = 'Drim do drim';
            String doDrim = ' do drim';
            String doDrim2 = '-do-drim';
            String muito = ' muito';

            return SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //CARD
                    SizedBox(
                      width: double.maxFinite,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    drim + doDrim*_counter,
                                    style: GoogleFonts.merriweather(
                                      fontSize: 46,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.fromLTRB(5,0,0,0),
                                    child: Text('drim-do-drim'+doDrim2*_counter, style: TextStyle(fontSize: 22)),
                                  ),
                                ),
                                ListTile(title: Text('1 Uma jogada muito${muito*_counter} bem feita',style: TextStyle(color: Colors.grey[800],fontSize: 18),)),
                                ListTile(title: Text('Exemplo', style: TextStyle(color: Colors.grey[800])), subtitle: Text('Essa foi o drim do drim${doDrim*_counter} família'),),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    //PALAVRAS RELACIONADAS
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15,5,0,0),
                        child: Column(
                          children: <Widget>[
                            Wrap(
                              spacing: 5, //gap between Cards
                              runSpacing: 2, //gap between Lines
                              direction: Axis.horizontal,
                              children: <Widget>[
                                Text(
                                    'Palavras relacionadas:',
                                    style: TextStyle(color: Colors.grey[800])
                                ),
                                Divider(color: Colors.white.withAlpha(100), height: 0.1,),
                                //DRIM
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _counter = 0;
                                      _word = _getHash('Drim');
                                    });
                                  },
                                  child: Card(
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text('Drim'),
                                      )
                                  ),
                                ),
                                //DRIM DO DRAWLENS
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _counter = 0;
                                      _word = _getHash('Drim do drawlens');
                                    });
                                  },
                                  child: Card(
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text('Drim do drawlens'),
                                      )
                                  ),
                                ),
                                //DRIM DO DRIM DO DRIM DO...
                                GestureDetector(
                                  onTap: () => addDrim(),
                                  child: Card(
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(drim+' do drim'+doDrim*_counter),
                                    )
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ),

                    //JOVIROMETRO
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,210,0,10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text('Ruim',style: TextStyle(color: Colors.grey[800])),
                              )
                          ),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Text('Neutro',style: TextStyle(color: Colors.grey[800]))
                          ),
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: Text('Bom',style: TextStyle(color: Colors.grey[800])),
                              )
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25,0,25,10),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.1),
                            gradient: LinearGradient(
                                colors: [
                                  Colors.red,
                                  Colors.redAccent,
                                  Colors.white,
                                  Colors.lightGreenAccent,
                                  Colors.green
                                ]
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white,
                              trackHeight: 0.1,
                              thumbColor: Colors.white,
                              thumbShape: CustomSliderThumbShape(enabledThumbRadius: 10),
                              overlayColor: Colors.white.withAlpha(1),
                            ),
                            child: Slider(
                              min: 0,
                              max: 100,
                              value: 100,
                              onChanged: (value){setState((){});},
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text('Jovirômetro',style: TextStyle(fontWeight: FontWeight.bold, color:Colors.grey[800], fontSize: 22),)
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.info, size: 10, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.only(top:2),
                                child: Text('Desenvolvido por @brunoantonieto', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              )
                            ],
                          ),
                        )
                    )
                  ],
                )
              ),
            );
          }
        }
    );
  }

  Widget RelatedStrings(){
    return StreamBuilder(
        stream: Firestore.instance.collection('jovi_words').snapshots(),
        builder: (context, snapshot){

          _getRelated(){
            List relatedWords = List();
            for(var i=0;i<dataLength;i++){
              List wordTag = snapshot.data.documents[_word]['tag'].toList();
              List iterTag = snapshot.data.documents[i]['tag'].toList();

              for(var k=0;k<wordTag.length;k++){

                for(var j=0;j<iterTag.length;j++){

                  if(wordTag[k].contains(iterTag[j])
                      && snapshot.data.documents[i]['nome'] != snapshot.data.documents[_word]['nome']) {
                    relatedWords.add(snapshot.data.documents[i]['nome']);
                  }
                }
              }
            }
            return relatedWords;
          }

          _getHash(name){
            for(var i=0;i<dataLength;i++){
              if(snapshot.data.documents[i]['nome'] == name){
                return i;
              }
            }
          }

          if (!snapshot.hasData) return const Text('Carregando...');
          return Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15,5,0,0),
              child: Column(
                children: <Widget>[
                  Wrap(
                    spacing: 5, //gap between Cards
                    runSpacing: 2, //gap between Lines
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Text(
                          'Palavras relacionadas:',
                          style: TextStyle(color: Colors.grey[800])
                      ),
                      Divider(color: Colors.white.withAlpha(100), height: 0.1,),
                      for(var item in _getRelated()) GestureDetector(
                        onTap: (){
                          setState(() {
                            _word = _getHash(item);
                            _getJovirometro(_word);
                          });
                        },
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(item),
                          )
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          );
        }
    );
  }

  Widget randomizeButton(){
    return FloatingActionButton(
      onPressed: _randomize,
      tooltip: 'Randomizar',
      child: Icon(Icons.shuffle),
    );
  }
}

//JOVIROMETRO'S THUMB SHAPE
class CustomSliderThumbShape extends SliderComponentShape {
  const CustomSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
  });

  final double enabledThumbRadius;

  final double disabledThumbRadius;
  double get _disabledThumbRadius =>  disabledThumbRadius ?? enabledThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        Animation<double> activationAnimation,
        @required Animation<double> enableAnimation,
        bool isDiscrete,
        TextPainter labelPainter,
        RenderBox parentBox,
        @required SliderThemeData sliderTheme,
        TextDirection textDirection,
        double value,
      }) {
    assert(context != null);
    assert(center != null);
    assert(enableAnimation != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );

    canvas.drawCircle(
      center,
      radiusTween.evaluate(enableAnimation),
      Paint()
        ..color = Colors.black
        ..maskFilter = MaskFilter.blur(BlurStyle.solid, 2),
    );

    canvas.drawCircle(
      center,
      radiusTween.evaluate(enableAnimation),
      Paint()
        ..color = Colors.white
    );
  }
}

