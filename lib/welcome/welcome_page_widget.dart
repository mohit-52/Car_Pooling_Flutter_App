import 'package:car_pooling/welcome/model_welcome.dart';
import 'package:flutter/material.dart';


class WelcomePageWidget extends StatelessWidget {
  const WelcomePageWidget({
    Key? key,
    required this.model,
  }) : super(key: key);

  final WelcomeModel model;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(30),
      color: model.bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image(
            image: AssetImage(model.image), height: size.height * 0.4,
          ),
          Column(children: [
            Text(
              model.title,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
            Text(
              model.subtitle,
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
          ],
          ),
          Text(
            model.counterText,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 50,),
        ],
      ),
    );
  }
}