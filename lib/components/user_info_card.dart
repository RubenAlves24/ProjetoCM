import 'package:flutter/material.dart';

class UserInfoCardListTile extends StatelessWidget {
  final String subTitleText;
  final String titleText;
  final IconData icon;
  final Function() onTap;

  const UserInfoCardListTile({
    required this.onTap,
    required this.subTitleText,
    required this.titleText,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onTap,
      child: Card(
        child: ListTile(
          leading: Icon(this.icon),
          title: Text(this.titleText),
          subtitle: Text(this.subTitleText),
        ),
      ),
    );
  }
}