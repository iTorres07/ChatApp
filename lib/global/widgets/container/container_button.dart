import 'package:chat_app_1/global/theme/style.dart';
import 'package:flutter/material.dart';

class ContainerButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? title;
  const ContainerButton({Key? key, this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 44,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          title!,
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
