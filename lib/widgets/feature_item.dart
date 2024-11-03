import 'package:flutter/material.dart';
import 'package:foodtrack/theme/color.dart';
import 'package:foodtrack/widgets/custom_image.dart';

import 'favorite_box.dart';

class FeaturedItem extends StatelessWidget {
  const FeaturedItem({Key? key, required this.data, this.onTap})
      : super(key: key);
  final data;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomImage(
              data["image"],
              width: 60,
              height: 60,
              radius: 10,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildItemInfo(),
            ),
            _buildItemPrice(),
          ],
        ),
      ),
    );
  }

  _buildItemPrice() {
    return Column(
      children: <Widget>[
        Text(
          data["price"],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: primary),
        ),
        const SizedBox(
          height: 10,
        ),
        FavoriteBox(
          iconSize: 13,
          isFavorited: data["is_favorited"],
        )
      ],
    );
  }

  _buildItemInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data["name"],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          data["sources"],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(
          height: 4,
        ),
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              size: 14,
              color: primary,
            ),
            const SizedBox(
              width: 2,
            ),
            Text(
              data["rate"] + " (" + data["rate_number"] + ")",
              style: const TextStyle(fontSize: 12, color: primary),
            ),
          ],
        )
      ],
    );
  }
}
