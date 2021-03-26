import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//댓글을 볼 수 있는 페이지
class CommentPage extends StatelessWidget {
  final DocumentSnapshot document;

  CommentPage(this.document);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('댓글'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _commentStream(),
          builder: (context, snapshot) {
            //데이터(댓글)가 없다면 로딩
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            //데이터를 map으로 변경 -> ListTile로 변경 -> 타입을 리스트 변경
            return ListView(
              children: snapshot.data.documents.map((doc) {
                return ListTile(
                  leading: Text(doc['writer']),
                  title: Text(doc['comment']),
                );
              }).toList(),
            );
          }),
    );
  }

  //댓글이 목록으로 옴
  Stream<QuerySnapshot> _commentStream() {
    return Firestore.instance
        .collection('post')
        .document(document.documentID)
        //post 컬렉션 안에 문서에서 comment(댓글) 컬렉션을 생성해서
        .collection('comment')
        .snapshots();
  }
}
