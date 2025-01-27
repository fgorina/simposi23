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
    url = path;
  }
  Future<List<String>> doQuery(Map<String, String> parameters, {String method = 'GET'}) async{

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

    var uri = method == 'GET' || method == 'DELETE' ?  Uri.http(host, url, data) : Uri.http(host, url);
    if(protocol == Protocol.https){
      uri = method == 'GET' || method == 'DELETE' ?  Uri.https(host, url, data) : Uri.https(host, url);
    }

    print(uri.toString());    //Important per poder fer debugging

      var response = method == 'GET' ? await http.get(uri) : ((method == 'POST') ? await http.post(uri, body: data) : await http.delete(uri));
      var headers = response.headers;
      String decoded = "";
      var b = response.bodyBytes;

      try {
        decoded = utf8.decode(response.bodyBytes);
      }
      catch (e){
        print(e.toString());
      }

      var lines = decoded.split("\n");

      var hisHash = lines[0];

      var t = DateTime.now().millisecondsSinceEpoch;
      var t1 = ((double.tryParse(lines[1]) ?? 0.0) * 1000.0).floor();

      var delta = t - t1; // Es en ms.

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
        print("His Hash $hisHash\n My Hash $hash");
        print(rest.sublist(1));
        throw(HashException());
      }

  }


  Future getData(String op, String id, int terminal, Function(List<String>) done) async{

    Map<String, String> query = {"op": op, "id" : id, "terminal" : terminal.toString()};

      var answer = await doQuery(query);
      await done(answer);

  }

  Future deleteData(String op, String id, int terminal, Function(List<String>) done) async{

    Map<String, String> query = {"op": op, "id" : id, "terminal" : terminal.toString()};

    var answer = await doQuery(query, method : "DELETE");
    await done(answer);
    print("Delete $answer");

  }

  Future postData(String op, String id, int terminal, Map<String, String> params, Function(List<String>) done) async {
    Map<String, String> query = {"op": op, "id" : id, "terminal" : terminal.toString()};

    params.forEach((key, value) {
      query[key] = value;
    });

    var answer = await doQuery(query, method: 'POST');
    print(answer);
    await done(answer);
  }
}