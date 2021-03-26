import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountPage extends StatelessWidget {
  final FirebaseUser user;

  AccountPage(this.user);

  //로그인 했을 때도 필요했음
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          _buildProfile(),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                SizedBox(
                  width: 80.0,
                  height: 80.0,
                  child: GestureDetector(
                    onTap: () => print('이미지 클릭'),
                    child: CircleAvatar(
                      //user에 프로필 이미지 URL
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                  ),
                ),
                Container(
                  width: 80.0,
                  height: 80.0,
                  alignment: Alignment.bottomRight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 28.0,
                        height: 28.0,
                        child: FloatingActionButton(
                          onPressed: null,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 25.0,
                        height: 25.0,
                        child: FloatingActionButton(
                          backgroundColor: Colors.blue,
                          onPressed: null,
                          child: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Text(
              user.displayName, //user에 닉네임
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: _postStream(),
              builder: (context, snapshot) {
                //데이터(게시물)가 없을 수도 있음
                var post = 0;
                //데이터(게시물)가 있을 시
                if (snapshot.hasData) {
                  post = snapshot.data.documents.length;
                }

                return Text(
                  '$post\n게시물',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                );
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<DocumentSnapshot>(
              stream: _followerStream(),
              builder: (context, snapshot) {
                var follower = 0;

                //데이터(팔로워)가 있을 때
                if (snapshot.hasData) {
                  var filterdMap;
                  //데이터(팔로워)가 없을 때
                  if (snapshot.data.data == null) {
                    filterdMap = []; //빈 데이터라는 뜻
                  } else {
                    //팔로우하다가 언팔로우 할 때
                    filterdMap = snapshot.data.data
                      //dart언어에서 ..을 하면 원래 있던 객체로 리턴해줌(리턴타입이 맞지 않아서 사용)
                      //false인 계정을 제거하겠다는 뜻
                      ..removeWhere((key, value) => value == false);
                  }
                  follower = filterdMap.length;
                }
                return Text(
                  '$follower\n팔로워',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                );
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<DocumentSnapshot>(
              stream: _followingStream(),
              builder: (context, snapshot) {
                var following = 0;

                //데이터(팔로워)가 있을 때
                if (snapshot.hasData) {
                  var filterdMap;
                  //데이터(팔로워)가 없을 때
                  if (snapshot.data.data == null) {
                    filterdMap = []; //빈 데이터라는 뜻
                  } else {
                    //팔로우하다가 언팔로우 할 때
                    filterdMap = snapshot.data.data
                      //dart언어에서 ..을 하면 원래 있던 객체로 리턴해줌(리턴타입이 맞지 않아서 사용)
                      //false인 계정을 제거하겠다는 뜻
                      ..removeWhere((key, value) => value == false);
                  }
                  following = filterdMap.length;
                }
                return Text(
                  '$following\n팔로잉',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                );
              }),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.exit_to_app),
          color: Colors.black,
          onPressed: () {
            // 로그아웃
            FirebaseAuth.instance.signOut();
            //GoogleSignIn도 같이 로그아웃을 해줘야 함
            _googleSignIn.signOut();
          },
        )
      ],
      backgroundColor: Colors.white,
      title: Text(
        'Instagram Clone',
        style: GoogleFonts.pacifico(),
      ),
    );
  }

  // 내 게시물 가져오기
  Stream<QuerySnapshot> _postStream() {
    return Firestore.instance
        .collection('post')
        //이메일 정보가 내 현재 이메일과 같은 모든 정보를 모두 가져옴
        .where('email', isEqualTo: user.email)
        .snapshots();
  }

  // 팔로잉 가져오기

  //DocumentSnapshot은 하나의 문서 정보만 가져오기 <=> QuerySnapshot
  Stream<DocumentSnapshot> _followingStream() {
    return Firestore.instance
        .collection('following')
        //나의 아이디만 가진 정보만 가져오기
        .document(user.email)
        .snapshots();
  }

  // 팔로워 가져오기
  Stream<DocumentSnapshot> _followerStream() {
    return Firestore.instance
        .collection('follower')
        //나의 아이디만 가진 정보만 가져오기
        .document(user.email)
        .snapshots();
  }
}
