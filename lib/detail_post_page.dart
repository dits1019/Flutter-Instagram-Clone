import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// 게시물을 클릭 시 나오는 게시물 상세보기 페이지
class DetailPostPage extends StatelessWidget {
  final DocumentSnapshot document;
  final FirebaseUser user;

  DetailPostPage(this.document, this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('둘러보기'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(document['userPhotoUrl']),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            document['email'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          StreamBuilder<DocumentSnapshot>(
                              stream:
                                  _followingStream(), //팔로우하고 있는 사람 목록 전체를 가져옴
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Text('로딩중');
                                }
                                //데이터가 들어있을 시
                                var data = snapshot.data.data;

                                //팔로우가 뜨게 하는 부분
                                if (data == null ||
                                        //데이터는 있는데 찾고자 하는 계정의 팔로우 정보가 없을 때
                                        data[document['email']] == null ||
                                        data[document['email']] ==
                                            false //정보는 있지만 값이 false
                                    ) {
                                  return GestureDetector(
                                    onTap: _follow,
                                    child: Text(
                                      "팔로우",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }
                                return GestureDetector(
                                  onTap: _unfollow,
                                  child: Text(
                                    "언팔로우",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }),
                        ],
                      ),
                      Text(document['displayName']),
                    ],
                  ),
                )
              ],
            ),
          ),
          Hero(
            tag: document.documentID,
            child: Image.network(
              document['photoUrl'],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(document['contents']),
          ),
        ],
      ),
    );
  }

  /*팔로우 규칙
  팔로우하는 계정과 팔로우 당하는 계정으로 나눠서 분류
  한 계정이 다른 계정을 팔로우하면 그 계정을 true로 아니면 false
  팔로우 당하는 것도 같음*/

  // 팔로우
  void _follow() {
    //true일 때 팔로우
    Firestore.instance
        .collection('following')
        .document(user.email)
        .setData({document['email']: true});

    Firestore.instance
        .collection('follower')
        .document(document['email'])
        .setData({user.email: true});
  }

  // 언팔로우
  void _unfollow() {
    //false일 때는 언팔로우
    Firestore.instance
        .collection('following')
        .document(user.email)
        .setData({document['email']: false});

    Firestore.instance
        .collection('follower')
        .document(document['email'])
        .setData({user.email: false});
  }

  // 팔로잉 상태를 얻는 스트림
  Stream<DocumentSnapshot> _followingStream() {
    return Firestore.instance
        .collection('following')
        .document(user.email)
        //내가 팔로잉하는 사람들을 다 가져옴
        .snapshots();
  }
}
