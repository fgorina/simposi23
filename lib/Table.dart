
import 'package:simposi23/DatabaseRecord.dart';

class Table<T extends DatabaseRecord>{

  String name;
  Map<int, T> _data ;
  bool _dirty = false;


  Table(this.name, this._data);

  T? find(int id) => _data[id];

  List<T> search(bool Function(T) f) {
    return _data.values.where((element) => f(element)).toList();
  }

  List<T> all(){
    return  _data.values.toList();

  }

  int count(){
    return _data.length;
  }
  void update( T r){
    var old = _data[r.id];

    if (old == null){ // Insert
      _data[r.id] = r;
      _dirty = true;
      return;
    }else {
      if (old.isEqual(r)){
        return;
      }else{
        _data[r.id] = r;
        _dirty = true;
        return;
      }
    }
  }

  void delete(T r){
    _data.removeWhere((key, value) => key == r.id);
    _dirty = true;
  }

  void addAll(List<T> records){
    for(var element in records){
      update(element);
    }
    _dirty = true;
  }

  void clear(){
    _data.clear();
  }

  void clean(){
    _dirty = false;
  }

}