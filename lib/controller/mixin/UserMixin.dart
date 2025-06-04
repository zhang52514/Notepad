import 'package:flutter/material.dart';

import '../../common/domain/ChatUser.dart';

mixin UserMixin on ChangeNotifier {
  ///
  ///所有用户
  final List<ChatUser> _users = [];

  initUser(){
    //模拟后端返回
    var u1 = ChatUser(
      uid: 101,
      nickname: 'test-02',
      avatarUrl: 'https://img.keaitupian.cn/newupload/11/1668492556474791.jpg',
    );
    var u2 = ChatUser(
      uid: 102,
      nickname: 'text-03',
      avatarUrl:
      'https://c-ssl.dtstatic.com/uploads/blog/202212/18/20221218144515_64111.thumb.1000_0.jpg',
    );
    _users.add(u1);
    _users.add(u2);
  }

  void addUser(ChatUser user) {
    _users.add(user);
  }

  ///
  /// 获取用户
  ChatUser getUser(int uid) {
    return _users.firstWhere(
          (u) => u.uid == uid,
      orElse: () => ChatUser(uid: uid, nickname: '未知用户', avatarUrl: ''),
    );
  }

}