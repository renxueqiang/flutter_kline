import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/switch.dart';
import 'package:flutter_demo/ShareData.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFFF4441F),
      ),
      home: MyHomePage(
        title: '首页',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

MethodChannel method = MethodChannel("test");

class _MyHomePageState extends State<MyHomePage> {
  double _padding = 10;
  GlobalKey key = GlobalKey();

  Future<dynamic> handelPushCall(MethodCall methodCall) {
    print(methodCall.toString());
    String backResult = "gobackSuccess";
    if (methodCall.method == "goback") {
      if (Navigator.of(this.context).canPop()) {
        Navigator.of(this.context).pop();
      } else {
        backResult = "我是来自Flutter的值";
      }
    }
    return Future.value(backResult);
  }

  @override
  void initState() {
    super.initState();
    //初始化状态

    method.setMethodCallHandler(handelPushCall);
  }
String str = '初始值';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            FlatButton(
                child: Text('下一页'),
                textColor: Colors.white,
                onPressed: () {
                  print("*****object****");
                })
          ],
        ),
        body: Text(str)

        // getRow()

//        getSwitch(),

//        getGesture()

//        getContainer()

//        rowColumn()

//        getButton()

//        getAlign()

        // getStack()
        // InheritedWidgetTestRoute()

//        flutterAnimate()

//        inkWell()

//        material()
        ,
        floatingActionButton: FloatingActionButton(
          child: Text('切换'),
          onPressed: () {
setState(() {
  str = '和哈哈哈哈哈哈';
});
            method.invokeMethod("testMethod", {"name": "小米", "age": "10"}).then(
                (value) {
              print("*************$value************");
            });
            // getSwitchState();
          },
        ));
    //
  }

  Widget getRow() {
    return

        // Container(
        //     // color: Colors.red,
        //     height: 100,
        //     width: 300,
        //     child: Text(
        //       'text123text123text123text123text123text123text123text123text123text123text123text123',
        //       // softWrap: false,
        //       // overflow: TextOverflow.ellipsis,
        //     ));

        Container(
      // color: Colors.red,
      height: 200,
      width: 300,
      color: Colors.red,
      alignment: Alignment.center,
      child:

          // Text(
          //   'text123text123text123text123text123text123text123text1xt123text123text123text123text123text123text123text12',
          //   style: TextStyle(backgroundColor:Colors.green),
          // )

          Row(
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
              child: Text(
            'text123text123text123text1223text123text123tex3text123text123text123text123text123text123text123text123',
            softWrap: true,
            // overflow: TextOverflow.ellipsis,
            style: TextStyle(),
          ))
        ],
      ),
    );

    // Row(
    //   children: <Widget>[
    //     Text('text123text123text123text123text123text123text123text123text123text123text123text123',
    // softWrap:true,
    // // overflow: TextOverflow.ellipsis,
    // style: TextStyle(

    // ),)
    //   ],
    // )

    // Text('text123text123text123text123text123text123text123text123text123text123text123text123',
    // softWrap:true,
    // // overflow: TextOverflow.ellipsis,
    // style: TextStyle(

    // ),)
  }

  Widget getSwitch() {
    return SwitcherWidget(
      key: key,
    );
  }

  getSwitchState() {
    dynamic obj = key.currentState;
    obj.changeState();
  }

  //***********************手势**************************** */

  Widget getGesture() {
    return GestureDetector(
      child: Container(
        color: Colors.blue,
        child: Row(
          children: <Widget>[
            Text("data",
                style: TextStyle(fontSize: 50, backgroundColor: Colors.red))
          ],
        ),
      ),
      onTap: () {
        print("**********************");
      },
    );
  }

  //***********************容器**************************** */

  Widget getContainer() {
    return Container(
        width: 200,
        height: 200,
        color: Colors.green,
        // alignment: Alignment.topCenter,
        child: Container(
          width: 100,
          height: 100,
          color: Colors.orange,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'text1111',
                style: TextStyle(backgroundColor: Colors.red),
              )
            ],
          ),
        ));
  }
  //***********************行列**************************** */

  Widget rowColumn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          color: Colors.orange,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.blue,
                child: Row(
                  children: <Widget>[Text("1")],
                ),
              ),
//        Row(
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          children: <Widget>[
//
//
//            Container(
//              width: 100,
//              height: 100,
//              color: Colors.red,
//            ),
//            Container(
//              width: 100,
//              height: 100,
//              color: Colors.green,
//            ),
//          ],
//        ),
            ],
          ),
        )
      ],
    );

//*******满屏*******
//  Container(
//    color: Colors.red,
//    height: 100,
//    child: Column(
//      children: <Widget>[
//        Container(
//            child: Row(
//              children: <Widget>[
//
//
//              ],
//            ),,
//        )
//      ],
//    ),
//  )

    Row(
      //平均分配 第一个和最后一个在最左边和最右边  剩下的均分居中 MainAxisAlignment.spaceBetween
      //平均分配 在所分配的空间中居中  MainAxisAlignment.spaceAround
      //平均分配 margin + content + margin  MainAxisAlignment.spaceEvenly
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
//      Text("1111"),
//      Text("2222"),
//      Text("3333"),
//      Text("4444"),
//      Text("5555"),
//      Text("6666"),
      ],
    );

    // 第一次出现的 Column Row 会经量占用更大的空间 第一种验证方式
//    Container(
//          color: Colors.red,
//          child: Column(
//            children: <Widget>[
//
//              Text("data"),
//
//              Container(
//                color:  Colors.green,
//                child: Row(
//                children: <Widget>[
//                  Text("data")
//                ],
//              ),
//              )
//            ],
//          )
//        );

    // 第一次出现的 Column Row 会经量占用更大的空间  第二种验证方式
//  Column(
//    mainAxisAlignment: MainAxisAlignment.end,
//    children: <Widget>[
//      Container(
//        color: Colors.red,
//        child:   Row(
//          mainAxisAlignment: MainAxisAlignment.end,
//
//          children: <Widget>[
//            Text("data")
//          ],
//        ),
//      )
//    ],n
//  )
  }

  //***********************相对定位**************************** */

  Widget getButton() {
    Function _onPressed = () {
      print("**********1**********");
    };
    return Column(
      children: <Widget>[
        RaisedButton.icon(
          icon: Icon(Icons.send),
          label: Text("RaisedButton"),
          onPressed: _onPressed,
        ),
        OutlineButton.icon(
          icon: Icon(Icons.add),
          label: Text("OutlineButton"),
          onPressed: _onPressed,
        ),
        FlatButton.icon(
          icon: Icon(Icons.info),
          label: Text("FlatButton"),
          onPressed: _onPressed,
        ),
        IconButton(
          icon: Icon(Icons.info),
          onPressed: () {},
        ),
      ],
    );
  }

  //***********************相对定位**************************** */

  Widget getAlign() {
    return Container(
      // height: 200.0,
      // width: 414.0,
      color: Colors.blue[50],
      child: Align(
        widthFactor: 1.0,
        heightFactor: 2.0,
        alignment: FractionalOffset(0.5, 0.5),
        child: FlutterLogo(
          size: 50,
        ),
      ),
    );
  }

  //***********************固定定位**************************** */

  Widget getStack() {
    // textDirection 控件是左边开始 还是右边开始
    //alignment 没有定位的控件 怎样对齐
    //fit 没有定位的子组件如何去适应Stack的大小
    return Container(
      color: Colors.orange,
      width: 300,
      height: 300,
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 80, left: 119),
            color: Colors.red,
            child: Text("A1111111111B"),
            // child: FlutterLogo(size: 60,),
          ),
          Container(
            margin: EdgeInsets.only(top: 85, left: 119),
            color: Colors.red,
            child: Text("A1111111111B"),
            // child: FlutterLogo(size: 60,),
          ),
          Positioned(
            child: Container(
              color: Colors.yellow,
              child: Text("A2222222222222B"),
            ),
            top: 40,
            left: 150,
          ),
          // Container(
          //   color: Colors.blue,
          //   child:  Text("A3333333333333333333333B"),
          //     //  child: FlutterLogo(size: 40,),
          // ),
          Container(
            color: Colors.green,
            child: Text("A4444444444B"),
            //  child: FlutterLogo(),
          ),

          Positioned(
            child: Container(
              color: Colors.yellow,
              child: Text("A2222222222222B"),
            ),
            top: 40,
            left: 150,
          ),
        ],
        // textDirection: TextDirection.rtl,
        // alignment: AlignmentDirectional.bottomStart,
        // fit: StackFit.expand,
      ),
    );
  }
  //***********************flutter 动画 以及按钮**************************** */

  Widget flutterAnimate() {
    return Column(
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            setState(() {
              _padding = 50;
              // _height = 100;
            });
          },
          child: AnimatedPadding(
            duration: Duration(seconds: 2),
            padding: EdgeInsets.all(_padding),
            child: Text("AnimatedPadding"),
          ),
        ),
        FlatButton(
          onPressed: () {},
          child: Row(
            children: <Widget>[Text("data"), FlutterLogo()],
            mainAxisSize: MainAxisSize.min,
          ),
          color: Colors.red,
        ),
      ],
    );
  }
  //***********************inkWell**************************** */

  Widget inkWell() {
    return ListView.separated(
      itemCount: 30,
      itemBuilder: (BuildContext context, int index) => renderRow(index),
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Colors.red[500],
        );
      },
    );
  }
  //***********************Material控件**************************** */

  Widget material() {
    return Column(
      children: <Widget>[
        new Center(
          child: new Material(
            color: Colors.blueAccent,
            shape: new BeveledRectangleBorder(
              //斜角矩形边框
              side: new BorderSide(
                width: 1.0,
                color: Colors.blueAccent,
                style: BorderStyle.none,
              ),
              borderRadius: new BorderRadius.circular(50.0),
            ),
            child: new Container(
              padding: EdgeInsets.all(20.0),
              child: new Text('斜角矩形边框'),
            ),
          ),
        ),
        new Center(
          child: new Material(
            color: Colors.blueAccent,
            shape: new BeveledRectangleBorder(
              //斜角矩形边框
              side: new BorderSide(
                width: 1.0,
                color: Colors.blueAccent,
                style: BorderStyle.none,
              ),
              borderRadius: new BorderRadius.circular(10.0),
            ),
            child: new Container(
              padding: EdgeInsets.all(20.0),
              child: new Text('斜角矩形边框'),
            ),
          ),
        ),
        new Center(
          child: new Material(
            color: Colors.blueAccent,
            shape: new BorderDirectional(
                start: new BorderSide(
                  color: Colors.yellow,
                  width: 10.0,
                ),
                top: new BorderSide(
                  color: Colors.deepOrange,
                  width: 10.0,
                ),
                end: new BorderSide(
                  color: Colors.black87,
                  width: 10.0,
                ),
                bottom: new BorderSide(
                  color: Colors.purpleAccent,
                  width: 10.0,
                )),
            child: new Container(
              padding: EdgeInsets.all(30.0),
              child: new Text('多彩边框'),
            ),
          ),
        ),
        new Center(
          child: new Material(
            color: Colors.blueAccent,
            shape: new CircleBorder(
                side: new BorderSide(
              color: Colors.yellow,
              width: 10.0,
            )),
            child: new Container(
              padding: EdgeInsets.all(50.0),
              child: new Text('圆形边框'),
            ),
          ),
        ),
        new Center(
          child: new Material(
            color: Colors.blueAccent,
            shape: new RoundedRectangleBorder(
              side: new BorderSide(
                color: Colors.purpleAccent,
                width: 5.0,
              ),
              // borderRadius:new BorderRadius.circular(20.0), //如果[borderRadius]被指定，那么[type]属性不能是 [MaterialType.circle]。
            ),
            child: new Container(
              padding: EdgeInsets.all(30.0),
              child: new Text('圆角矩形'),
            ),
          ),
        ),
        new Center(
          child: new Material(
            color: Colors.purpleAccent,
            elevation: 10.0,
            shadowColor: Colors.yellow,
            shape: new StadiumBorder(
                side: new BorderSide(
              color: Colors.brown,
              width: 5.0,
            )),
            child: new Container(
              padding: EdgeInsets.all(30.0),
              child: new Text('体育场形���'),
            ),
          ),
        )
      ],
    );
  }
  //***********************测试**************************** */

  test() {
    // print("${widget.aaaa} 类型:${widget.aaaa.runtimeType}");
    // print(widget.aaaa);

    // testFuture2();

    // task();
    var aaaaaaa = 44;
    Function callback = () {
      print("object");
    };

    Future<String> login(String userName, String pwd) {
      return Future(() => "123456");
      //用户登录
    }

    Future<String> login111(String userName, String pwd) async {
      return await login("alice", "******");
      //用户登录
    }

    task() async {
      login("userName", "pwd").then((value) {
        print("***11****$value*********");
      });

      String id = await login("alice", "******").then((value) {
        print("***22****$value*********");
      });
      print("***33****$id*********");

      //执行接下来的操作
    }

    void testFuture2() {
      Future f1 = new Future(() => print("1"));
      Future f2 = new Future(() => print("2"));
      Future f3 = new Future(() => print("3"));

      // 都是异步 空实现 顺序进行
      f1.then((_) => print("11"));
      f2.then((_) => print("22"));
      f3.then((_) => print("33"));
    }

    var _align = Alignment.topRight;
    double _height = 0;
    double _left = 0;
    Color _color = Colors.red;
    TextStyle _style = TextStyle(color: Colors.black);
    Color _decorationColor = Colors.blue;

    print("***11***********");
    login111("userName", "pwd").then((value) {
      print("***33****$value*********");
    });

    print("***22***********");
//Text
    Widget wid = Text.rich(TextSpan(text: "11", children: []));

    Widget wid2 = DefaultTextStyle(
        style: TextStyle(),
        child: Row(
          children: <Widget>[Text('text')],
        ));

//BUtton
    FlatButton btn1 = FlatButton(onPressed: () {}, child: Text('text'));
  }

  //***********************cell**************************** */

  Widget smallLabel(String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
      margin: EdgeInsets.only(right: 5),
      child:
          Text(text, style: TextStyle(fontSize: 10, color: Color(0XFF7797B3))),
      decoration: BoxDecoration(color: Color(0xFFE6EFF7)),
    );
  }

  Widget renderRow(int index) {
    var titleRow = Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
                margin: EdgeInsets.only(right: 5),
                child: Text("有效",
                    style: TextStyle(fontSize: 10, color: Colors.white)),
                decoration: BoxDecoration(color: Color(0XFFFb7779)),
              ),
              Text("朝阳门 5号楼3门",
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ))
            ],
          ),
          flex: 1,
        ),
        Image.asset('./images/1.jpg', width: 10.0, height: 10.0),
        SizedBox(
          width: 3,
        ),
        Image.asset('./images/1.jpg', width: 10.0, height: 10.0),
      ],
    );

    var crossRow = Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '2-1-1-1   ',
              style: TextStyle(fontSize: 10),
            ),
            Text(
              '5/7',
              style: TextStyle(fontSize: 10),
            )
          ],
        ),
        Row(
          children: <Widget>[
            DefaultTextStyle(
                style: TextStyle(fontSize: 10, color: Colors.red, height: 1.5),
                child: Row(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
                      child: Text("南北")),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
                      child: Text("多层")),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
                      child: Text("4层-8层"))
                ]))
          ],
        ),
        Row(
          children: <Widget>[
            smallLabel("无抵押"),
            smallLabel("满两年"),
            smallLabel("唯一")
          ],
        )
      ],
    );

    var rightLabel = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text('100.0m²'),
        Text(
          '209万',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red),
        ),
        Text('3.0万/m²')
      ],
    );

    var row = Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
              width: 100.0,
              height: 80.0,
              child: Image.asset(
                "./images/1.jpg",
                fit: BoxFit.fill,
              )),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: <Widget>[
                titleRow,
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: crossRow,
                    ),
                    rightLabel
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );

    var lastLView = Row(
      children: <Widget>[
        Expanded(
            // flex: 1,
            child: Padding(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Image.asset('./images/3.png', width: 15.0, height: 15.0),
        )),
        Expanded(
            // flex: 1,
            child: Padding(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Image.asset('./images/3.png', width: 15.0, height: 15.0),
        )),
        Expanded(
            // flex: 1,
            child: Padding(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Image.asset('./images/3.png', width: 15.0, height: 15.0),
        )),
        Expanded(
            // flex: 1,
            child: Padding(
          padding: EdgeInsets.fromLTRB(0, 5, 10, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset('./images/3.png', width: 15.0, height: 15.0)
            ],
          ),
        ))
      ],
    );

    var view = Column(
      children: <Widget>[row, lastLView],
    );

    return InkWell(
      child: view,
      onTap: () {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('提示'),
                content: Text("*** 😀😀😀😀😀😀😀😀😀***"),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      '确定',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      },
    );
  }
}

class TopScrollView extends StatefulWidget {
  TopScrollView(
      {Key key,
      this.topViewWidth = 200,
      this.topViewheight = 44,
      this.callBackFun,
      @required this.dateArray})
      : super(key: key);
  final double topViewWidth, topViewheight;
  final List<String> dateArray;
  final void Function(int index) callBackFun;

  @override
  _TopScrollViewState createState() => _TopScrollViewState();
}

class _TopScrollViewState extends State<TopScrollView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 40,
      color: Colors.red,
      alignment: Alignment.center,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1,
          mainAxisSpacing: 20,
        ),
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue,
              // borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            child: Text(widget.dateArray[index]),
          );
        },
        // padding: EdgeInsets.symmetric(horizontal:20),
        itemCount: widget.dateArray.length,
      ),
    );
  }
}
