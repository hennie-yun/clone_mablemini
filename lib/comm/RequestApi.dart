import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketExampleState  {
  WebSocketChannel? channel;

  void connectWebSocket() {
    print('웹소켓연결');
    channel = WebSocketChannel.connect(
        Uri.parse('ws://203.109.30.207:10001/connect'));

    channel!.stream.listen((message) {
      print('Received message: $message');
      final data = jsonDecode(message);
      if (data['Data'] != null) {
        final websocketKey = data['Data']['websocketkey'];
        print('WebSocket Key: $websocketKey');
      } else {
        print('No Data in message');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }


}
