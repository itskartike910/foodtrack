import 'package:badges/badges.dart' as badges; // Alias for badges package
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationBox extends StatelessWidget {
  const NotificationBox({Key? key, this.number = 0, this.onTap}) : super(key: key);

  final int number;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withOpacity(.3),
          ),
        ),
        child: number > 0 ? _buildNotifiedIcon() : _buildIcon(),
      ),
    );
  }

  Widget _buildNotifiedIcon() {
    return badges.Badge(  // Use the alias here
      padding: EdgeInsets.all(3),
      position: badges.BadgePosition.topEnd(top: -7, end: 2),
      badgeContent: Text(
        number.toString(), // Display the notification count
        style: TextStyle(color: Colors.white),
      ),
      child: _buildIcon(),
    );
  }

  Widget _buildIcon() {
    return Icon(
      FontAwesomeIcons.solidBell,
      size: 20,
    );
  }
}
