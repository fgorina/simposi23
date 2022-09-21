import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'HashException.dart';

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

    print(uri.toString());    //Important per poder fer debugging

      var response = await http.get(uri);
      var headers = response.headers;
      var decoded = utf8.decode(response.bodyBytes);

      var lines = decoded.split("\n");
      var hisHash = lines[0];

      var t = DateTime.now().millisecondsSinceEpoch;
      var t1 = ((double.tryParse(lines[1]) ?? 0.0) * 1000.0).floor();

      var delta = t - t1; // Es en ms.

      print("Delta $delta");


    // ToDo Limit value of delta. If > some value (ex. 2s) generate a HashException

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


  Future getData(String op, String id, int terminal, Function(List<String>) done) async{

    Map<String, String> query = {"op": op, "id" : id, "terminal" : terminal.toString()};

      var answer = await doQuery(query);
      await done(answer);

  }


}