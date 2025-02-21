import 'dart:async';
import 'package:flutter/material.dart';
import 'package:openai_dart/openai_dart.dart';
import '../utils/mvc.dart';
import '../dao/model/message.dart';
import '../service/user_service.dart';

class AiChatController extends MvcContextController {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Message> messages = [];
  bool isLoading = false;
  String selectedModel = 'deepseek-r1:1.5b'; // Default model
  late OpenAIClient _client;

  @override
  void initState(BuildContext context) {
    super.initState(context);
    setupScrollListener();
    _initOpenAIClient();
  }

  void _initOpenAIClient() {
    _client = OpenAIClient(
      apiKey: "ollama",
      baseUrl: "http://localhost:11434/v1",
    );
  }

  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // Load more messages if needed
      }
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final currentUser = UserService().currentUser;
    if (currentUser == null) return;

    // Create and add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      content: text,
      senderId: currentUser.id!,
      receiverId: -1,
      // AI receiver ID
      sendTime: DateTime.now().millisecondsSinceEpoch,
      contentType: MessageContentType.TEXT,
    );
    messages.insert(0, userMessage);
    textController.clear();
    refreshView();

    // Show typing indicator
    isLoading = true;
    refreshView();

    try {
      // Send request to AI
      final stream = _client.createChatCompletionStream(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(selectedModel),
          messages: [
            ChatCompletionMessage.system(
              content: 'You are a helpful assistant.',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(text),
            ),
          ],
        ),
      );

      String responseContent = '';
      await for (final res in stream) {
        responseContent += res.choices.first.delta.content ?? '';
        // Create AI response message
        final aiMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch,
          content: responseContent,
          senderId: -1,
          // AI sender ID
          receiverId: currentUser.id,
          sendTime: DateTime.now().millisecondsSinceEpoch,
          contentType: MessageContentType.TEXT,
        );

        // Update or add AI message
        if (messages.length > 1 && messages[0].senderId == -1) {
          messages[0] = aiMessage;
        } else {
          messages.insert(0, aiMessage);
        }
        refreshView();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get AI response: $e')),
      );
    } finally {
      isLoading = false;
      refreshView();
    }
  }

  void setModel(String model) {
    selectedModel = model;
    refreshView();
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
