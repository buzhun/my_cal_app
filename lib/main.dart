import 'package:flutter/material.dart';
import './button.dart';

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
    // 1 + 2 (AC)  = > 0
    List<String> newEntry = ['0'];
    if (!isClearAll) {
      // 1 + 2 (C) => 1 + 0
      newEntry = entry.sublist(0, entry.length - 1);
      newEntry.add('0');
    }

    setState(() {
      _screen = '0';
      last = '0';
      entry = newEntry;
      activeBtn = '';
    });
  }

  void _handleNumberBtnChanged(String val) {
    var newScreen = _screen;
    var newEntry = entry;
    var newLast = '';
    final lastIsNumber = RegExp(r'^[0-9.]+$').hasMatch(last);

    if (last == '0' && entry.length == 1 && val != '.') {
      newScreen = val;
      newLast = val;
      newEntry[entry.length - 1] = val;
    } else if (lastIsNumber) {
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
      case '×':
        result = x * y;
        break;
      case '÷':
        result = x / y;
        break;
    }
    const double infinity = 1.0 / 0.0;

    print('result: $result');
    // 0 的除法
    if(result == infinity){
      return '错误';
    } else if (result.toString().length > 8){
      return result.toStringAsExponential(3);
    } else if (result.toInt() - result == 0) {
      return result.toInt().toString();
    } else {
      return result.toString().length > 8 ? result.toStringAsFixed(5) : result.toString();
    }
  }

  // 计算第一个表达式
  String calExpress(expressList) {
    final operate1 = expressList[1];
    if (expressList.length == 3) {
      // 1 + 2
      return _cal(expressList[0], operate1, expressList[2]);
    } else if (expressList.length == 5) {
      final operate2 = expressList[3];
      if (RegExp(r'^[+-]$').hasMatch(operate1) &&
          RegExp(r'^[×÷]$').hasMatch(operate2)) {
        // 1 + 2 * 3
        return _cal(expressList[0], operate1,
            _cal(expressList[2], operate2, expressList[4]));
      } else {
        // 1 + 2 + 3
        return _cal(_cal(expressList[0], operate1, expressList[2]), operate2,
            expressList[4]);
      }
    }
    else{
      // error
      return '';
    }
  }

  void _handleOperatorBtnChanged(String val) {
//    final lastIsNumber = RegExp(r'^[0-9]+$').hasMatch(last);
    var newActiveBtn = '';
    var newLast = '';
    var newEntry = entry;
    var newScreen = '';

    // 新符号入栈
    void pushStack() {
      newActiveBtn = val;
      newLast = val;
      newEntry.add(val);
      newScreen = last;
    }

    final length = entry.length;
    switch (length) {
//      case 0: 第一位最少也是 0 不会是运算符
      case 1:
        if (val == '=') {
          // 1 (=) 相当于没有
          newActiveBtn = '';
          newLast = last;
          newEntry = entry;
          newScreen = _screen;
        } else {
          // 1 (+) 入栈
          pushStack();
        }
        break;
      case 2:
        // 1+ (=) 自增计算
        if (val == '=') {
          final String result = _cal(entry[0], entry[1], entry[0]);
          newActiveBtn = '';
          newLast = result;
          newEntry = [result];
          newScreen = result;
        } else {
          // 1 + (-) 覆盖上一个运算符
          newActiveBtn = val;
          newLast = val;
          newEntry[entry.length - 1] = newLast;
          newScreen = last;
        }
        break;
      case 3:
        if (RegExp(r'^[+-]$').hasMatch(entry[1]) &&
            RegExp(r'^[×÷]$').hasMatch(val)) {
          // 第一个是+ -，第二个是 × ÷ 入栈
          pushStack();
        } else {
          final String result = calExpress(entry);
          if (result == '错误'){
            newActiveBtn = '';
            newLast = '0';
            newEntry = ['0'];
            newScreen = '错误';
          } else {
            if (val == '=') {
              // 1+2(=) 求值
              newActiveBtn = '';
              newLast = result;
              newEntry = [result];
              newScreen = result;
            } else {
              // 1+2(+) => 3 + 求值并将值和运算符都入栈
              newActiveBtn = val;
              newLast = val;
              entry.replaceRange(0, 3, [result, val]);
              newEntry = entry;
              newScreen = result;
            }
          }
        }
        break;
      case 4:
        // 1 + 2 * (=) => 1 + 2 * 2 => 1 + 4 => 5
        if (val == '=') {
          final String result =
              _cal(entry[0], entry[1], _cal(entry[2], entry[3], entry[2]));
          newActiveBtn = '';
          newLast = result;
          newEntry = [result];
        }
        // 1 + 2 + (-) =>1 + 2 -  覆盖
        newActiveBtn = val;
        newLast = val;
        newEntry[entry.length - 1] = val;
        break;
      case 5:
        final String result1 =  calExpress(entry);
        if (val == '=') {
          // 1+2*3（=）  =>  1+ 6 => 7
          newActiveBtn = '';
          newLast = result1;
          newEntry = [result1];
          newScreen = result1;
        } else if (RegExp(r'^[+-]$').hasMatch(val)) {
          // 1+2*3+
          newActiveBtn = val;
          newLast = val;
          newEntry = [result1, val];
          newScreen = result1;
        } else if (RegExp(r'^[×÷]$').hasMatch(val)) {
          // 1+2*3* // 变成 1 + 6 显示 6
          final String result2 = _cal(entry[2], entry[3], entry[4]);
          newActiveBtn = val;
          newLast = val;
          newEntry = [entry[0], entry[1], result2, val];
          newScreen = result2;
        }
    }
    
    setState(() {
      _screen = newScreen;
      entry = newEntry;
      activeBtn = newActiveBtn;
      last = newLast;
    });
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
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
                          final type = RegExp(r'^[0-9.]+$').hasMatch(name)
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
                  }).toList()))
        ]));
  }
}
