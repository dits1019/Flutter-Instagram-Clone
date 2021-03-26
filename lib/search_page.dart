import 'package:chapter10/detail_post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'create_page.dart';

class SearchPage extends StatelessWidget {
  final FirebaseUser user;

  SearchPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(
        'Instagram Clone',
        style: GoogleFonts.pacifico(),
      ),
    );
  }

  Widget _buildBody(context) {
    print('search_page created');
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          //Firestore에서 데이터를 stream으로 얻어올 때 QuerySnapshot을 얻어옴
          stream: Firestore.instance
              .collection('post')
              .snapshots(), //post에 있는 모든 데이터를 가져옴
          //post에 데이터들이 snapshot으로 들어옴
          builder: (context, snapshot) {
            //만약 데이터가 없다면 로딩
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, //가로 길이(열 개수)
                childAspectRatio: 1.0,
                mainAxisSpacing: 1.0, //가로 세로 비율이 1 : 1
                crossAxisSpacing: 1.0, //간격 1
              ),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildListItem(
                    context, snapshot.data.documents[index]); //아이템 하나하나 index
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.create),
        onPressed: () {
          print('눌림');
          Navigator.of(context).push(MaterialPageRoute(
              //CreatePage로 이동하면서 user(user 정보)를 보내줌
              builder: (BuildContext context) => CreatePage(user)));
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Hero(
      tag: document.documentID, //document id를 태그로 함
      child: Material(
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  //DetailPostPage로 이동하면서 document(데이터)와 user(user 정보)를 보내줌
                  builder: (context) => DetailPostPage(document, user),
                ));
          },
          child: Image.network(
            document['photoUrl'], //photoUrl에 접근해서 이미지 Url을 가져옴
            fit: BoxFit.cover, //빈 여백없이
          ),
        ),
      ),
    );
  }
}
