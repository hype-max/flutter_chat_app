import 'package:dio/dio.dart';

class HelloService {
  static final HelloService _instance = HelloService._internal();

  factory HelloService() => _instance;

  HelloService._internal();

  Future<String?> hello() async {
    var dio = Dio();
    var resp = await dio.get("http://localhost:8080/api/hello");
    if (resp.statusCode == 200) {
      return resp.data;
    }
    return null;
  }
}
