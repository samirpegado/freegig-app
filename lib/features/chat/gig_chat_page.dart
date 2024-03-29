import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freegig_app/features/chat/chat_gigInfo.dart';
import 'package:freegig_app/services/chat/gig_chat_service.dart';
import 'package:intl/intl.dart';

class GigChatPage extends StatefulWidget {
  final String gigSubjectUid;
  const GigChatPage({
    super.key,
    required this.gigSubjectUid,
  });

  @override
  State<GigChatPage> createState() => _GigChatPageState();
}

class _GigChatPageState extends State<GigChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = GigChatService();
  final _firebaseAuth = FirebaseAuth.instance;

  void sendGigMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendGigMessage(
          _messageController.text, widget.gigSubjectUid);
      _messageController.clear();
    }
  }

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    _chatService.lastSeen(widget.gigSubjectUid);
    super.initState();
  }

  @override
  void dispose() {
    _chatService.lastSeen(widget.gigSubjectUid);

    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Chat da GIG'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          //header
          ChatGigInfo(gigSubjectUid: widget.gigSubjectUid),

          /// informacao
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Os futuros participantes que ingressarem nesta GIG terão acesso a todas as mensagens.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
          SizedBox(
            height: 10,
          ),

          ///messages
          Expanded(
            child: _buildMessageList(),
          ),

          /// user input
          _buildMessageInput(),
        ],
      ),
    );
  }

  // build message list

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getGigMessages(widget.gigSubjectUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }

        scrollDown();

        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: ListView(
            controller: _scrollController,
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          ),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //define a posicao da mensagem
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    //define o alinhamento da mensagem
    var columnAlignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    //define a cor do container da mensagem
    var colorContainer = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Colors.blue
        : Color.fromARGB(255, 236, 236, 236);

    //define a cor do container da mensagem
    var colorText = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Colors.white
        : Colors.black;

    // Formata a hora do timestamp
    Timestamp timestamp = data['timestamp'];
    DateTime dateTime = timestamp.toDate();

    String horaFormatada = DateFormat('HH:mm').format(dateTime);
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: columnAlignment,
        children: [
          InkWell(
            onLongPress: () {
              if (data['senderId'] == _firebaseAuth.currentUser!.uid) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          actionsAlignment: MainAxisAlignment.center,
                          title: Text('Apagar'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Fechar',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _chatService.deleteGigMessages(
                                    widget.gigSubjectUid, data['msgUid']);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Apagar mensagem',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorContainer),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['message'],
                  style:
                      TextStyle(color: colorText, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          SizedBox(height: 3),
          Text(
            data['senderPublicName'],
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 3),
          Text(
            horaFormatada + '  ',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // build message input
  FocusNode _messageFocusNode = FocusNode();

  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                focusNode: _messageFocusNode,
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Digite sua mensagem",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                sendGigMessage();
                // Adicione o código para ocultar o teclado
                _messageFocusNode.unfocus();
              },
              icon: Icon(
                Icons.send,
                size: 35,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
