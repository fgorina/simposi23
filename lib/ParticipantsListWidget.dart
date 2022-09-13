import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simposi23/ParticipantView.dart';
import 'Database.dart';
import 'Participant.dart';
import 'Contractacio.dart';
import 'Servei.dart';
import 'screensize_reducers.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'Scanner.dart';
import 'SlideRoutes.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'RespostaWidget.dart';

class ParticipantsListWidget extends StatefulWidget {
  final String title = "Participants";

  bool all = true; // If false only not registered
  int serveiId = 0;

  ParticipantsListWidget(bool this.all, int this.serveiId , {Key? key}) : super(key: key);

  @override
  _ParticipantsListWidgetState createState() => _ParticipantsListWidgetState();
}

class _ParticipantsListWidgetState extends State<ParticipantsListWidget> {
  String searchString = "";
  TextEditingController controller = TextEditingController();

  Database d = Database.shared;

  Servei? elServei;

  void initState(){

     super.initState();
     d.addSubscriptor(this);
    // d.loadDataFromServer(true) ;

     if(widget.serveiId != 0){
      elServei = d.findServei(widget.serveiId);
     } else{
       elServei = null;
     }

  }

  void dispose() {
    d.removeSubscriptors(this);
    super.dispose();
  }

  void modelUpdated(String status, String message, String op){

    final _isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (status != "OK" && _isTopOfNavigationStack){
      Database.displayAlert(context, "Error in List", message);
    }
    if(_isTopOfNavigationStack) {
      String s = controller.text;
      search(s, autoOpen: false);
    }

  }

  bool isNumeric(String s) {
    if(s.isEmpty) {
      return false;
    }
    return int.parse(s) != null;
  }

  void search(String s, {autoOpen = true}) async {

      controller.text = s;
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));

      searchString = s.toLowerCase();
      int? id = int.tryParse(searchString);

      if(s.isNotEmpty && id != null){
        return;
      }

      setState(() {
        d.selectedParticipants = d.searchParticipants(
                (p0) {
                  Participant p1 = p0 as Participant;
                  return p1.name.toLowerCase().contains(searchString)
                      && (!p1.registrat || widget.all);
                });


        if (d.selectedParticipants.length == 1 && elServei == null && autoOpen){
          selectParticipant(d.selectedParticipants[0].id);
       }


    });
  }

  Future consumeixServei(Servei servei, Participant participant, bool scanner) async {

    // Calcular la id de la contractacio :


    int id = participant.id*100 + servei.id;
    String nomServei = servei.name;

    Contractacio? contractacio = d.findContractacio(id);

    Widget resposta;



    resposta = RespostaWidget( participant, servei, "WAITING", "Waiting");
    await Navigator.push(context, SlideLeftRoute(widget:resposta));
    if (scanner){
      scan();
    }else{
      String s = controller.text.toLowerCase();
      search(s, autoOpen: false);
      setState(() {

      });
    }
    return;


  }
  Future seleccionarParticipants(String s) async {
    setState(() {
      controller.text = s;

      searchString = s.toLowerCase();
      int? id = int.tryParse(searchString);

      if(s.isNotEmpty && id != null){
        Participant? participant = d.findParticipant(id);
        if (participant != null){
          d.selectedParticipants = [participant];

        }else {
          d.selectedParticipants = [];
        }
      }else {
        d.selectedParticipants = d.searchParticipants(
                (p0) {
              Participant p1 = p0 as Participant;
              return p1.name.toLowerCase().contains(searchString)
                  && (!p1.registrat || widget.all);
            });

      }

      if (d.selectedParticipants.length == 1){
        if(elServei != null){

        }else {
          selectParticipant(d.selectedParticipants[0].id);
        }
      }


    });
  }

  void validate(String s, {bool scanner = false}) async{


      int? id = int.tryParse(s);
      if (id != null) {
        d.currentParticipant = d.findParticipant(id);
        if(d.currentParticipant != null) {
          d.currentContractacions = d.currentParticipant!.contractacions();
          if(elServei != null) {
            await consumeixServei(elServei!, d.currentParticipant!, scanner);
          }else{
            selectParticipant(id);
          }
        }
      }else{
        await seleccionarParticipants(s);
    }
  }

  void selectParticipant(int id) async{
  /*  try {
      await d.updateParticipant(id);
    }catch(e) {
      print(e.toString());
    }

   */
      d.currentParticipant = d.findParticipant(id);
      d.currentContractacions = d.currentParticipant?.contractacions() ?? [];
      await Navigator.push(context, SlideLeftRoute(widget: ParticipantViewWidget()));
      String s = controller.text;
      search(s, autoOpen: false);

      setState(() {

      });
    }

  void scan() async{
    await scanQR((String s) {
      validate(s, scanner:true);
      print("Rebut "+s);
    });
  }



  void showError(){
    Database.displayAlert(context, "Error de Connexió", d.lastServerError);
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> icons = [];
    int c = min(d.backLogCount(), 10);
    if (c > 0 ){
      icons.add(IconButton(icon: Icon(numberIcons[c-1]), color: Colors.red, onPressed: () async {
        await showBacklog(context);
        setState(() {

        });
      }));
    }

    if(d.lastServerError.isNotEmpty){
      icons.add(IconButton(icon: const Icon(Icons.warning_amber), color: Colors.red, onPressed: showError));
    }

    icons.add( IconButton(icon: const Icon(Icons.qr_code), onPressed: scan));

    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(elServei == null ? "Participants" : elServei!.name),
          actions:  icons,
          //backgroundColor: d.lastServerError.isEmpty ? Colors.grey : Colors.red,

        ),
        body: Consumer<ScreenHeight>(builder: (context, _res, child) {
          return SafeArea(
            minimum: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: Column(
              children: [
                CupertinoSearchTextField(
                  controller: controller,
                  onChanged: search,
                  onSubmitted: validate,
                ),
                Container(
                  height: screenHeight(context) - 200 - _res.keyboardHeight,
                  child: ListView.builder(
                      itemCount: d.selectedParticipants.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(title: Text(d.selectedParticipants[index].name, style: TextStyle(color: d.selectedParticipants[index].registrat ? Colors.black : Colors.red)),

                          onTap:() {
                            if(elServei == null) {
                              selectParticipant(
                                  d.selectedParticipants[index].id);
                            }else{
                              consumeixServei(elServei!, d.selectedParticipants[index], false);
                            }

                           });
                      }),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
