import 'Servei.dart';
import 'Contractacio.dart';
import 'DatabaseRecord.dart';
import 'Database.dart';
import 'Modalitat.dart';
import 'Producte.dart';
import 'Contractacio.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';

List<pw.Widget> pdfStateIcons = [
  pw.Icon(pw.IconData(0xe510), size: 18,),
  pw.Icon(pw.IconData(0xe86c), size: 18, color: PdfColors.green),
  pw.Icon(pw.IconData(0xe86c), size: 18, color: PdfColors.red),
];


class Participant  implements DatabaseRecord{

  int id;
  String name;
  int modalitat;
  String dataModificat;

  String email;
  String idioma;
  String samarreta;

  bool registrat;
  bool pagat;



  Participant(  this.id,  this.name, this.modalitat,  this.dataModificat, this.email, this.idioma, this.samarreta,  this.registrat, this.pagat);

  List<Contractacio> contractacions(){
     var d = Database.shared;

     return d.searchContractacions(( p0) => (p0 as Contractacio).participantId == this.id);
  }

  @override
  bool isEqual(DatabaseRecord r){
    if (this.runtimeType != r.runtimeType){
      return false;
    }
    else{
      var r1 = r as Participant;
      return this.id == r.id
          && this.name == r.name
          && this.registrat == r1.registrat
          && this.pagat == r1.pagat;

    }
  }
  // Crea un participant a partir de un registre de wpdj_pagaia_qr_sympo2023
  static Participant fromCSV(String dades){
    var fields = dades.split(";");    // Camps Separats per ;


    int codi = int.parse(fields[0]);
    String nom = fields[1];
    int modalitat = int.parse(fields[2]);
    String dataModificat = fields[3];
    String email = fields[4];
    String idioma = fields[5];
    String samarreta = fields[6];
    bool enviat = false;
    if (fields.length >= 26) {
      enviat =  fields[25] != "0";
    }else {
      enviat =  fields[8] == 1;
    }

    bool registrat = int.parse(fields[7]) == 1;

    return Participant(codi, nom, modalitat,dataModificat, email, idioma, samarreta, registrat, enviat);
  }

  String toCSV(){
    return  "$id;$name;$modalitat;$dataModificat;$email;$idioma;$samarreta;${registrat?1:0};${pagat?1:0}";
  }

  // Special send routine for mails

Future sendPdf({SmtpServer? server =  null, bool test = true}) async {
    var pdf = await (await toPdf()).save();
    var stream = Stream.value(
      List<int>.from(pdf),
    );

    var attachment = StreamAttachment(stream, "application/pdf", fileName: name + ".pdf");
    attachment.location = Location.attachment;


    String subject = (Database.shared.traduccio(0, 1, idioma) ?? "Benvinguts al Simposi Pagaia 2023").replaceAll("\$nom", name);
    String body = (Database.shared.traduccio(0, 2, idioma) ?? "Benvinguts al Simposi Pagaia 2023").replaceAll("\$nom", name);
    String bodyHtml = (Database.shared.traduccio(0, 3, idioma) ?? "Benvinguts al Simposi Pagaia 2023").replaceAll("\$nom", name);

    SmtpServer theServer = server ?? gmail(Database.shared.smtpUser, Database.shared.smtpPassword);//gmail("fgorina@gmail.com", "dkbuggbtbhwajmiq");
    String destination = test ? "fgorina@mac.com" : email;
    final message = Message()
      ..from = Address(Database.shared.fromEmail, "Symposium Pagaia 2023")
      ..recipients.add(destination)
      ..bccRecipients.add(Database.shared.bccEmail)
      ..subject = subject
      ..text = body
      ..html = bodyHtml
      ..attachments = [attachment];

    try {
      final sendReport = await send(message, theServer);
      Database.shared.enviatParticipant(this.id);
      print("Send message to $name at $email");
    }on MailerException catch (e) {
      print('Message not sent.' + e.message);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }

  }

  // PDF Routines

  Future<pw.Document> toPdf() async {
    final logo = await imageFromAssetBundle('assets/logo.png');

    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.varelaRoundRegular(),
          bold: await PdfGoogleFonts.varelaRoundRegular(),
          icons: await PdfGoogleFonts.materialIcons(),
        ),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pdfContext) {
          return buildPDF(pdfContext, logo);
        }));

    return pdf;
  }

   pw.Widget buildPDF( pw.Context pdfContext, logo) {
    Modalitat? modalitat = Database.shared.findModalitat(this.modalitat);
    String modalitatNameBasic = modalitat?.name ?? this.modalitat.toString();

    String modalitatName = Database.shared.traduccio(2, this.modalitat, this.idioma) ?? modalitatNameBasic;

    return pw.Column(
      children: [
        // Aqui va el títol i el logo

        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(logo, width: 60),
              pw.Column(
                children: [
                  pw.Text("IX Simpòsium Internacional",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text("de  Caiac de Mar",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Text(this.id.toString(),
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ]),

        pw.Divider(),
        pw.Row( mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Spacer(),

            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [pw.Text(this.name,
                    style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text(modalitatName,
                      style:
                      pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Container(height: 10),
                ]),
            pw.Spacer(),
            pw.Text(this.samarreta),
          ],
        ),
        pw.Container(
          width: 100,
          height: 100,
          child: pw.BarcodeWidget(
              data: Database.shared.paticipantCSV(this),
              barcode: pw.Barcode.qrCode()),
        ),

        pw.Divider(),
        pw.ListView.separated(
          itemCount: Database.shared.allProductes().length,
          itemBuilder: (pw.Context pdfContext, int index) {
            return buildPDFTile(
                this, Database.shared.allProductes()[index], pdfContext);
          },
          separatorBuilder: (pw.Context pdfContext, int index) {
            return pw.Divider(color: PdfColors.grey);
          },
        ),

        pw.Spacer(),

        // Aqui hi era elk QR
        pw.Spacer(),
      ],
    );
  }

  static pw.Widget buildPDFTile(
      Participant p, Producte pr, pw.Context pdfContext) {
    DateFormat df = DateFormat("dd/MM");

    var serveis = Database.shared.searchServeisProducte(pr);
    serveis.sort((a, b) => a.id.compareTo(b.id));

    var contractacions =
    Database.shared.searchContractacionsParticipant(p).where((element) {
      var servei = Database.shared.findServei(element.serveiId)!;
      return servei.idProducte == pr.id;
    }).toList();

    contractacions.sort((a, b) => a.id.compareTo(b.id));

    List<pw.Widget> icons = contractacions.map((contractacio) {
      if (contractacions.length == 1) {
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pdfStateIcons[contractacio.estat],
            ]);
      } else {
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(df.format(contractacio.valid(Database.shared).start)),
              pdfStateIcons[contractacio.estat],
            ]);
      }
    }).toList();
    var nameTraduit = Database.shared.traduccio(1, pr.id, p.idioma) ?? pr.name;
    return pw.Column(
      children: [
        pw.Text(nameTraduit), //pw.Text(pr.name),
        pw.Row(
            mainAxisAlignment: icons.length == 1
                ? pw.MainAxisAlignment.center
                : pw.MainAxisAlignment.spaceBetween,
            children: icons),
      ],
    );
  }


}