class HashException implements Exception{
  String errMsg() => "Hash exception";
  @override
  String toString() => errMsg();
}