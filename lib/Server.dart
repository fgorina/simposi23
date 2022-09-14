import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'Database.dart';
import 'HashException.dart';

/***
 *
 * El format de recepció es :
 *
 * Hash
 * Temps
 * Status
 * Dades...
 *
 */

enum Protocol{
  http,
  https
}
class Server {

  Protocol protocol = Protocol.http;
  String host = "";
  String url = "";


  String secret = "asdjadskfjdaslkfj";
  String alg = "md5";

  Server(this.protocol, this.host, this.url);

  void setAddress(Protocol protocol, String host, String path){
    this.protocol = protocol;
    this.host = host;
    this.url = path;
  }
  Future<List<String>> doQuery(Map<String, String> parameters) async{

    var data  = parameters;
    data["t"] = ((DateTime.now()).millisecondsSinceEpoch).floor().toString();

    var keys = (data.keys).toList();
    keys.sort();

    String body = "";

    for (String k in keys){
      body += data[k] ?? "";
    }
    body += secret;

    String hash =  md5.convert(utf8.encode(body)).toString();
    data["hash"] = hash;

    var uri = Uri.http(host, url, parameters);
    if(protocol == Protocol.https){
      uri = Uri.https(host, url, parameters);
    }

    print(uri.toString());

      var response = await http.get(uri);
      var headers = response.headers;
      headers.forEach((key, value) {
        print("Header |$key| : |$value|");
      });
      var decoded = utf8.decode(response.bodyBytes);

      var lines = decoded.split("\n");
      var hisHash = lines[0];

      if(hisHash == "IR"){
        throw(HashException());
      }

      var rest = lines.sublist(1);

      body = rest.join("\n") + secret;
      hash = md5.convert(utf8.encode(body)).toString();

      if (hisHash == hash){
        return rest.sublist(1);
      } else {
        print("His Hash $hisHash\nMy Hash $hash");
        throw(HashException());
      }

  }


  Future getData(String op, String id, Function(List<String>) done) async{

    Map<String, String> query = {"op": op, "id" : id};

      var answer = await doQuery(query);
      await done(answer);

  }


}