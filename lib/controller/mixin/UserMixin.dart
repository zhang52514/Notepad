import 'package:flutter/material.dart';

import '../../common/domain/ChatUser.dart';

mixin UserMixin on ChangeNotifier {
  ///
  ///所有用户
  final List<ChatUser> _users = [];

  initUser(){
    //模拟后端返回
    // var u1 = ChatUser(
    //   uid: 103,
    //   nickname: 'test-103',
    //   avatarUrl: 'https://img.keaitupian.cn/newupload/11/1668492556474791.jpg',
    // );
    // var u2 = ChatUser(
    //   uid: 102,
    //   nickname: 'text-102',
    //   avatarUrl:
    //   'https://c-ssl.dtstatic.com/uploads/blog/202212/18/20221218144515_64111.thumb.1000_0.jpg',
    // );
    // _users.add(u1);
    // _users.add(u2);
  }

  void addUser(ChatUser user) {
    _users.add(user);
  }


}