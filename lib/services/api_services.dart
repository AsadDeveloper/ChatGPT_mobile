import 'dart:convert';
import 'dart:io';

import 'dart:developer';

import 'package:chatgpt_mobile/models/chat_model.dart';
import 'package:chatgpt_mobile/models/models_model.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var respone = await http.get(Uri.parse("$BASE_URL/models"),
          headers: {'Authorization': 'Bearer $Api_Key'});

      Map jsonResponse = jsonDecode(respone.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']("message"));
      }
      // print("jsonResponse $jsonResponse");

      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        // print({value["id"]});
      }

      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

//send msg fct

  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      var respone = await http.post(Uri.parse("$BASE_URL/completions"),
          headers: {
            'Authorization': 'Bearer $Api_Key',
            "Content-Type": "application/json"
          },
          body: jsonEncode(
            {
              "model": modelId,
              "prompt": message,
              "max_tokens": 100,
            },
          ));

      Map jsonResponse = jsonDecode(respone.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']("message"));
      }

      List<ChatModel> chatList = [];
      // print("jsonResponse $jsonResponse");

      // List temp = [];
      // for (var value in jsonResponse["data"]) {
      //   temp.add(value);
      //   // print({value["id"]});
      // }

      // return ModelsModel.modelsFromSnapshot(temp);

      if (jsonResponse["choices"].length > 0) {
        chatList = List.generate(
            jsonResponse["choices"].length,
            (index) => ChatModel(
                chatIndex: 1, msg: jsonResponse["choices"][index]["text"]));

        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
      }

      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
