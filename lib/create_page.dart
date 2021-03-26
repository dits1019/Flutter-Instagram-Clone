import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//게시물 생성 페이지
class CreatePage extends StatefulWidget {
  final FirebaseUser user;

  CreatePage(this.user);

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final textEditingController = TextEditingController();

  //처음 화면이 뜨면서 _getImage 메소드 호출
  @override
  void initState() {
    super.initState();
    _getImage();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  File _image;

  // 갤러리에서 사진 가져오기
  Future _getImage() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      //이미지 크기 제한
      maxWidth: 640,
      maxHeight: 480,
    );

    setState(() {
      //_getImage에서 선택한 사진이 File _image한테 넘어감
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('새 게시물'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _uploadFile(context);
          },
          child: Text('공유'),
        )
      ],
    );
  }

  Future _uploadFile(BuildContext context) async {
    // 스토리지에 업로드할 파일 경로
    final firebaseStorageRef = FirebaseStorage.instance
        .ref() //기본
        .child('post') //child로 폴더 단위로 들어가기
        .child('${DateTime.now().millisecondsSinceEpoch}.png'); //파일 이름

    // 파일 업로드
    final task = firebaseStorageRef.putFile(
      _image,
      //설정해주지 않으면 image로 인식 하지 않을 수도 있음
      StorageMetadata(contentType: 'image/png'),
    );

    // 완료까지 기다림
    //Futre 타입은 처리가 오래 걸려서 비동기
    final storageTaskSnapshot = await task.onComplete;
    //그 후 StorageTaskSnapshot 객체로 받음

    // 업로드 완료 후 url

    //업로드 한 놈의 레퍼런스를 얻고 다운로드 Url을 얻을 수 있음(올릴려고 하는 이미지 Url)
    final downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

    // 문서 작성 (새로운 문서 작성 시 add 메소드 사용)
    await Firestore.instance.collection('post').add(
        //문서 작성은 중괄호, 문서 내용은 json 형태
        {
          //textEditingController.text로 textField에 텍스트 가져오기
          'contents': textEditingController.text,
          'displayName': widget.user.displayName,
          'email': widget.user.email,
          'photoUrl': downloadUrl,
          'userPhotoUrl': widget.user.photoUrl,
        });

    // 완료 후 앞 화면으로 이동
    Navigator.pop(context);
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                _buildImage(),
                SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '문구 입력...',
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Text('사람 태그하기'),
          ),
          Divider(),
          ListTile(
            leading: Text('위치 추가하기'),
          ),
          Divider(),
          _buildLocation(),
          ListTile(
            leading: Text('위치 추가하기'),
          ),
          ListTile(
            leading: Text('Facebook'),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          ListTile(
            leading: Text('Twitter'),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          ListTile(
            leading: Text('Tumblr'),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          Divider(),
          ListTile(
            leading: Text(
              '고급 설정',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //들어갈 이미지 표시
  Widget _buildImage() {
    return _image == null
        ? Text('No Image')
        : Image.file(
            _image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
  }

  Widget _buildLocation() {
    final locationItems = [
      '꿈두레 도서관',
      '경기도 오산',
      '오산세교',
      '동탄2신도시',
      '동탄',
      '검색',
    ];
    return SizedBox(
      height: 34.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: locationItems.map((location) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Chip(
              label: Text(
                location,
                style: TextStyle(fontSize: 12.0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
