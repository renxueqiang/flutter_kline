
import 'package:flutter/material.dart';
export 'package:flutter_demo/switch.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:jhtoast/jhtoast.dart';
import 'package:flutter_demo/autototast.dart';

class SwitcherWidget extends StatefulWidget {
  SwitcherWidget({Key key}) : super(key: key);

  @override
  _SwitcherWidgetState createState() => _SwitcherWidgetState();
}

class _SwitcherWidgetState extends State<SwitcherWidget> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {

  
    return Scaffold(
      body: Center(
        child: Switch.adaptive(
            value: isActive,
            activeColor: Colors.blueAccent,
            onChanged: (bool currentStatus) {
              isActive = currentStatus;
              setState(() {});
            }),
      ),
    );
  }

  changeState() {
    isActive = !isActive;
    setState(() {});

    getApplicationDocumentsDirectory().then((value){


      print(value);
      print(value.parent);
      print(value.path);

    });
    
 AutoToast.showText(context, msg: "提示文字信字信息!!!",
             closeTime: 10
          );

    
  }
}
