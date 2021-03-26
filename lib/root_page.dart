import 'package:chapter10/loading_page.dart';
import 'package:chapter10/tab_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('root_page created');
    return _handleCurrentScreen();
  }

  //Firebase 인증 상태를 Stream을 통해서 받음
  Widget _handleCurrentScreen() {
    return StreamBuilder(
      stream: FirebaseAuth.instance
          .onAuthStateChanged, //onAuthStateChanged를 통해서 로그인 상태에 따른 값을 받음
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //연결 상태가 기다리는 중이라면 로딩 페이지를 반환
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingPage();
        } else {
          //연결 되었고 데이터가 있다면
          if (snapshot.hasData) {
            return TabPage(snapshot.data); //인증에 관련된 데이터를 가지고 TabPage로 이동
          }
          //데이터가 없을 시(로그인 X)
          return LoginPage();
        }
      },
    );
  }
}
