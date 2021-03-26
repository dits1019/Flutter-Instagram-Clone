import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'comment_page.dart';

//내가 게시물을 올린 것과 다른 사람 게시물을 표시할 페이지
class FeedWidget extends StatefulWidget {
  final DocumentSnapshot document;

  final FirebaseUser user;

  FeedWidget(this.document, this.user);

  @override
  _FeedWidgetState createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var commentCount = widget.document['commentCount'] ?? 0;
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.document['userPhotoUrl']),
          ),
          title: Text(
            widget.document['email'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.more_vert),
        ),
        Image.network(
          widget.document['photoUrl'],
          height: 300,
          width: double.infinity, //꽉 채우기
          fit: BoxFit.cover,
        ),
        ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //게시물의 likedUsers에 나의 이메일이 있다면 색칠된 하트 표시(좋아요를 누름)
              //다른 게시물엔 필드가 없을 수도 없으니 ?.으로 없을 경우 null
              //그 후 ??로 null일 때는 false로 함
              widget.document['likedUsers']?.contains(widget.user.email) ??
                      false
                  //좋아요를 누른 상태
                  ? GestureDetector(
                      onTap: _unlike,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                    )
                  //좋아요를 누르지 않은 상태
                  : GestureDetector(
                      onTap: _like,
                      child: Icon(Icons.favorite_border),
                    ),
              SizedBox(
                width: 8.0,
              ),
              Icon(Icons.comment),
              SizedBox(
                width: 8.0,
              ),
              Icon(Icons.send),
            ],
          ),
          trailing: Icon(Icons.bookmark_border),
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 16.0,
            ),
            Text(
              //?.으로 likedUsers 필드가 없는 게시물은 좋아요가 null개로 뜨고
              //null을 없애기 위해서 ??를 이용해 null일 경우 0개로 표시
              '좋아요 ${widget.document['likedUsers']?.length ?? 0}개',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
            ),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 16.0,
            ),
            Text(
              widget.document['email'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 8.0,
            ),
            Text(widget.document['contents']),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        //댓글이 0개일 때는 댓글 모두 보기 표시 안 함
        if (commentCount > 0)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentPage(widget.document),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '댓글 $commentCount개 모두 보기',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  //widget.document['lastComment']이 null일 때 default('')이 됨
                  Text(widget.document['lastComment'] ?? ''),
                ],
              ),
            ),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextField(
                  controller: _commentController,
                  //가상 키보드에서 완료 표시를 누를 때
                  onSubmitted: (text) {
                    _writeComment(text);
                    _commentController.text = '';
                  },
                  decoration: InputDecoration(
                    hintText: '댓글 달기',
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  // 좋아요
  // ignore: unused_element
  void _like() {
    //기존 좋아요 리스트를 복사
    final List likedUsers =
        //Cloud Firebase에서 likedUsers에 얻어온 내용으로 업데이트(바로 업데이트가 안 됨)
        List<String>.from(widget.document['likedUsers'] ?? []);

    //복사한 리스트에 나를 추가
    likedUsers.add(widget.user.email);

    //업데이트할 항목을 문서로 준비
    final updateData = {
      'likedUsers': likedUsers,
    };

    //post에 업데이트
    Firestore.instance
        .collection('post')
        .document(widget.document.documentID) //현재 문서에
        .updateData(updateData); //likedUsers 필드만 업데이트
  }

  // 좋아요 취소
  // ignore: unused_element
  void _unlike() {
    //기존 좋아요 리스트를 복사
    final List likedUsers =
        //Cloud Firebase에서 likedUsers에 얻어온 내용으로 업데이트(바로 업데이트가 안 됨)
        List<String>.from(widget.document['likedUsers'] ?? []);

    //복사한 리스트에 나를 빼기
    likedUsers.remove(widget.user.email);

    //업데이트할 항목을 문서로 준비
    final updateData = {
      'likedUsers': likedUsers,
    };

    //post에 업데이트
    Firestore.instance
        .collection('post')
        .document(widget.document.documentID) //현재 문서에
        .updateData(updateData); //likedUsers 필드만 업데이트
  }

  // 댓글 작성
  void _writeComment(String text) {
    //쓸 데이터를 정의
    final data = {
      'writer': widget.user.email,
      'comment': text,
    };

    //댓글 추가
    Firestore.instance
        .collection('post')
        //현재 문서 찾기
        .document(widget.document.documentID)
        .collection('comment')
        .add(data);

    //마지막 댓글과 댓글 개수 갱신
    final updateData = {
      //마지막 댓글
      'lastComment': text,
      //현재 댓글 개수를 가져오고 거기에 +1(없다면 0으로)
      'commentCount': (widget.document['commentCount'] ?? 0) + 1,
    };

    Firestore.instance
        .collection('post')
        .document(widget.document.documentID) //현재 문서에
        .updateData(updateData);
  }
}
