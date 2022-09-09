
abstract class DatabaseRecord {

  int get id;
  set id(int id);
  String get name;
  set name(String name);

  DatabaseRecord(String csv);

  bool isEqual(DatabaseRecord r);

}