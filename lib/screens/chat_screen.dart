import 'dart:developer';
import 'package:chatgpt_mobile/constants/constants.dart';
import 'package:chatgpt_mobile/models/chat_model.dart';
import 'package:chatgpt_mobile/services/api_services.dart';
import 'package:chatgpt_mobile/services/assets_manager.dart';
import 'package:chatgpt_mobile/services/services.dart';
import 'package:chatgpt_mobile/widgets/chat_widget.dart';
import 'package:chatgpt_mobile/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../providers/models_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final speechToText = SpeechToText();
  String lastWords = '';

  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController listScrollController;
  late FocusNode focusNode;
  @override
  void initState() {
    listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    initSpeechToText();
    super.initState();
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> initTextToSpeech() async {
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      // print(lastWords);
    });
  }

  @override
  void dispose() {
    listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    speechToText.stop();
    super.dispose();
  }

  List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(
      context,
    );
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          actions: [
            IconButton(
                onPressed: () async {
                  await Services.showModalSheet(context: context);
                },
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                ))
          ],
          leading: Padding(
              padding: EdgeInsets.all(8),
              child: Image.asset(AssetsManager.botImage)),
          title: Center(child: const Text('ChatGPT')),
        ),
        body: SafeArea(
            child: Column(children: [
          Flexible(
            child: ListView.builder(
                controller: listScrollController,
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    msg: chatList[index].msg,
                    chatIndex: chatList[index].chatIndex,
                  );
                }),
          ),
          if (_isTyping) ...[
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 18,
            ),
          ],
          SizedBox(
            height: 15,
          ),
          Material(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      style: TextStyle(color: Colors.white),
                      controller: TextEditingController(text: lastWords),

                      // controller: TextEditingController(text: lastWords),
                      onSubmitted: (value) async {
                        await sendMessagefct(modelsProvider: ModelsProvider());
                      },
                      onChanged: (newText) {
                        lastWords = newText;
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: "How can I help you",
                          hintStyle: TextStyle(color: Colors.green)),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        await sendMessagefct(modelsProvider: ModelsProvider());
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          )
        ])),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
            bottom: 55,
          ),
          child: FloatingActionButton(
              elevation: Checkbox.width,
              onPressed: () async {
                if (await speechToText.hasPermission &&
                    speechToText.isNotListening) {
                  await startListening();
                } else if (speechToText.isListening) {
                  // final speech = await openAIService.isArtPromptAPI(lastWords);
                  // if (speech.contains('https')) {
                  //   generatedImageUrl = speech;
                  //   generatedContent = null;
                  //   setState(() {});
                  // } else {
                  // //   generatedImageUrl = null;
                  // //   generatedContent = speech;
                  // //   setState(() {});
                  // //   await systemSpeak(speech);
                  // }
                  await stopListening();
                } else {
                  initSpeechToText();
                }
              },
              child: const Icon(Icons.mic)),
        ));
  }

  void scrolListToEnd() {
    listScrollController.animateTo(
        listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.bounceIn);
  }

  Future<void> sendMessagefct({required ModelsProvider modelsProvider}) async {
    if (lastWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.amber,
          content: TextWidget(label: "Please type a Message")));
      return;
    }
    try {
      String msg = lastWords;
      setState(() {
        _isTyping = true;
        chatList.add(ChatModel(chatIndex: 0, msg: msg));
        // textEditingController.clear();
        focusNode.unfocus();
      });
      chatList.addAll(await ApiService.sendMessage(
          // message: textEditingController.text,
          message: lastWords,
          modelId: modelsProvider.getcurrentModel));

      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.amber,
          content: TextWidget(label: error.toString())));
    } finally {
      setState(() {
        scrolListToEnd();
        _isTyping = false;
        textEditingController.clear();
      });
    }
  }
}
