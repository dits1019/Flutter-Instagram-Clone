import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

//로그인 페이지(시작 화면)
class LoginPage extends StatelessWidget {
  //구글 로그인을 하기 위한 객체(구글 로그인)
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  //파이어베이스 인증 정보를 가지는 객체(구글 로그인)
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Instagram Clone',
              style: GoogleFonts.pacifico(
                fontSize: 40.0,
              ),
            ),
            Container(
              margin: EdgeInsets.all(50.0),
            ),
            SignInButton(
              Buttons.Google,
              onPressed: () {
                _handleSignIn();
              },
            ),
          ],
        ),
      ),
    );
  }

  //구글 로그인을 수행하고 FirebaseUser를 변환
  Future<FirebaseUser> _handleSignIn() async {
    //_googleSignIn을 통해서 signIn()이 발생
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    //비동기로 인해 대기하다가 GoogleSignInAccount라는 객체를 얻어옴

    //googleUser로 GoogleSignInAuthentication 객체를 얻어옴
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    //구글 로그인으로 인증된 정보를 기반으로 FirebaseUser 객체를 구성
    FirebaseUser user = (await _auth.signInWithCredential(
            GoogleAuthProvider.getCredential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken)))
        .user;
    //로그인 정보를 출력하는 로그
    print("signed in " + user.displayName);
    return user;
  }
}
