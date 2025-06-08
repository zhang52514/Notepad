import 'package:flutter/material.dart';
import 'package:notepad/common/module/AvatarWidget.dart';
import 'package:provider/provider.dart';

import '../../controller/ChatController.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, ChatController value, child) {
        return ListView.builder(
          itemCount: value.users.length,
          itemBuilder: (context, index) {
            var user = value.users.values.elementAt(index);
            return ListTile(
              title: Text(user.nickname),
              subtitle: Text(user.status),
              leading: AvatarWidget(url: user.avatarUrl),
              onTap: () {
              },
              trailing: Text(user.status),
            );
          },
        );
      },
    );
  }
}
