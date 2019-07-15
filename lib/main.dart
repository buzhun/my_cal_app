import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Tutorial',
      home: new Scaffold(
        body: new OptWidget(),
      ),
    ),
  );
}

// OptWidget manages the state.

//------------------------ OptWidget --------------------------------

class OptWidget extends StatefulWidget {
  final buttonLists = [
    ['C', '+/-', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  @override
  _OptWidgetState createState() => _OptWidgetState();
}

class _OptWidgetState extends State<OptWidget> {
  String _screen = '0';
  String last = '0';
  List<String> entry = ['0'];
  String activeBtn = '';

  void _handleClearBtnChanged(bool isClearAll) {
    print('clear');
    setState(() {
      _screen = '0';
      last = '0';
      entry = [last];
//      entry = isClearAll ? [] : entry;
    });
  }

  void _handleNumberBtnChanged(String val) {
    var newScreen = _screen;
    var newEntry = entry;
    var newLast = '';
    final lastIsNumber = RegExp(r'^[0-9]+$').hasMatch(last);

    print('last is $last,lastIsNumber is $lastIsNumber ');

    if (last == '0') {
        newScreen = val;
        newLast = val;
        newEntry[entry.length - 1] = val;
    } else if(lastIsNumber){
        newScreen += val;
        newLast = last + val;
        newEntry[entry.length - 1] = newLast;
    } else {
      // 1 + (3)
      newEntry.add(val);
      newScreen = val;
      newLast = val;
    }


    setState(() {
      _screen = newScreen;
      last = newLast;
      entry = newEntry;
      activeBtn = '';
    });

    print(entry);
  }

  String _cal(xStr, opt, yStr) {

    final double x = double.parse(xStr);
    final double y = double.parse(yStr);

    double result = 0.0;

    switch (opt) {
      case '+':
        result = x + y;
        break;
      case '-':
        result = x - y;
        break;
      case '*':
        result = x * y;
        break;
      case '/':
        result = x / y;
        break;
    }
    return result.toInt() - result == 0 ?  result.toInt().toString(): result.toString();
  }

  void _handleOperatorBtnChanged(String val) {
    final lastIsNumber = RegExp(r'^[0-9]+$').hasMatch(last);
    var newScreen = '';
    var newActiveBtn = '';
    var newLast = '';
    var newEntry = entry;

    // 新符号入栈
    void pushStack() {
      newActiveBtn = val;
      newLast = val;
      newEntry.add(newLast);
    }

    // 计算第一个表达式（前三位）
    String calExpress (){
      return _cal(entry[0], entry[1], entry[2]);
    }

    final length = entry.length;
    switch(length) {
//      case 0: 第一位最少也是 0 不会是运算符

      case 1:
        // 1 (+)
        if (val == '='){

        } else {
          pushStack();
        }
        break;
      case 2:
        // 1+ (=) 自增计算
        if (val == '='){
          newActiveBtn = '';
          final String result =  _cal(entry[0],entry[1],entry[0]);
          newLast = result;
          newEntry = [result];
        } else {
          // 1 + (-) 覆盖上一个运算符
          newActiveBtn = val;
          newLast = val;
          newEntry[entry.length - 1] = newLast;
        }
        break;
      case 3:
        if(RegExp(r'^[+-]$').hasMatch(entry[1]) && RegExp(r'^[×÷]$').hasMatch()){
          // 第一个是+ -，第二个是 × ÷ 入栈
          pushStack();
        } else {
          final String result = calExpress();
          if (val == '='){
            // 1+2(=)
            newActiveBtn = '';
            newLast = result;
            newEntry = [result];
          } else {
            // 1+2(+) 计算结果入栈
            newActiveBtn = val;
            newLast = val;
            entry.replaceRange(0, 3, [result]);
            newEntry = entry;
          }
        }
      break;
      case 4:
        1 + 2 * (=)
    }

    if (val == '=') {
      // 1 + 2 = 3
      if (entry.length == 3) {
        final result =
        newScreen = result;
        newEntry=[result];
        newLast = result;
      }
    } else {
      newActiveBtn = val;
      newLast = val;
      print('last is $last,lastIsNumber is $lastIsNumber ');
      if (!lastIsNumber) {
        newEntry[entry.length - 1] = newLast;
      } else {
        newEntry.add(newLast);
      }
    }

    setState(() {
      _screen = newScreen;
      entry = newEntry;
      activeBtn = newActiveBtn;
      last = newLast;
    });

    print(entry);
  }

  @override
  Widget build(BuildContext context) {
    final handleMap = {
      'number': _handleNumberBtnChanged,
      'other': _handleOperatorBtnChanged,
      'operate': _handleOperatorBtnChanged,
    };

    final colorMap = {
      'number': 'black',
      'other': 'grey',
      'operate': 'orange',
    };

    return Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 750.0,
              height: 100.0,
              padding: EdgeInsets.only(top: 50.0),
              child: Text(
                entry.join(''),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50.0,
                ),
              ),
            ),
            Container(
              width: 750.0,
              height: 200.0,
              padding: EdgeInsets.only(top: 100.0),
              child: Text(
                '$_screen',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 80.0,
                ),
              ),
            ),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.buttonLists.map((buttonList) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: buttonList.map((name) {
                          final type = RegExp(r'^[0-9]+$').hasMatch(name)
                              ? 'number'
                              : RegExp(r"([/%])").hasMatch(name)
                                  ? 'other'
                                  : 'operate';

                          return name == 'C'
                              ? ClearBtn(
                                  isClearAll: _screen == '0',
                                  onChanged: _handleClearBtnChanged,
                                )
                              : BaseBtn(
                                  name: name,
                                  actived: activeBtn == name,
                                  colorType: colorMap[type],
                                  onChanged: handleMap[type],
                                );
                        }).toList());
                  }).toList()),
            )
          ],
        ));
  }
}

//------------------------- ClearBtn ----------------------------------

class ClearBtn extends StatefulWidget {
  ClearBtn({Key key, this.isClearAll: false, @required this.onChanged})
      : super(key: key);

  final bool isClearAll;
  final onChanged;
  _ClearBtnState createState() => _ClearBtnState();
}

class _ClearBtnState extends State<ClearBtn> {
  void _handleChange(String name) {
    widget.onChanged(widget.isClearAll);
  }

  Widget build(BuildContext context) {
    final String name = widget.isClearAll ? 'AC' : 'C';
    return BaseBtn(
      name: name,
      onChanged: _handleChange,
      colorType: 'grey',
    );
  }
}

//------------------------- BaseBtn ----------------------------------

//------------------------- BaseBtn ----------------------------------

class BaseBtn extends StatefulWidget {
  BaseBtn(
      {Key key,
      this.name: '',
      this.actived: false,
      this.colorType: 'black',
      @required this.onChanged})
      : super(key: key);

  final String name;
  final String colorType;
  final onChanged;
  final bool actived;

  @override
  _BaseBtnState createState() => _BaseBtnState();
}

class _BaseBtnState extends State<BaseBtn> {
  bool _highlight = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _highlight = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _highlight = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _highlight = false;
    });
  }

  void _handleTap() {
    widget.onChanged(widget.name);
  }

  Widget build(BuildContext context) {
    final fontColorMap = {
      'black': Colors.white,
      'grey': Colors.black,
      'orange': Colors.white,
    };

    final bgColorMap = {
      'black': Colors.grey[800],
      'grey': Colors.grey[300],
      'orange': Colors.orange,
    };

    final lightColorMap = {
      'black': Colors.grey[500],
      'grey': Colors.grey[100],
      'orange': Colors.orange[100],
    };

    final text = Text(
      widget.name,
      style: TextStyle(
          fontSize: 40.0,
          color:
              widget.actived ? Colors.orange : fontColorMap[widget.colorType]),
    );

    final centerText = Center(
      child: text,
    );

    final zeroText = Container(
      padding: EdgeInsets.fromLTRB(22.0, 12.0, 0, 0),
      child: text,
    );

    return GestureDetector(
      onTapDown: _handleTapDown, // Handle the tap events in the order that
      onTapUp: _handleTapUp, // they occur: down, up, tap, cancel
      onTap: _handleTap,
      onTapCancel: _handleTapCancel,
      child: Container(
        child: widget.name == '0' ? zeroText : centerText,
        width: widget.name == '0' ? 140.0 : 70.0,
        height: 70.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            const Radius.circular(70.0),
          ),
          color: widget.actived
              ? Colors.white
              : _highlight
                  ? lightColorMap[widget.colorType]
                  : bgColorMap[widget.colorType],
        ),
      ),
    );
  }
}
