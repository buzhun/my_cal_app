import 'package:flutter/material.dart';
import './button.dart';

//------------------------ OptWidget --------------------------------
final buttonLists = [
  ['C', '+/-', '%', '÷'],
  ['7', '8', '9', '×'],
  ['4', '5', '6', '-'],
  ['1', '2', '3', '+'],
  ['0', '.', '='],
];

class OptWidget extends StatefulWidget {
  OptWidget({
    Key key,
    this.themeIsBlack,
    @required this.isLargeScreen,
  }) : super(key: key);

  final bool isLargeScreen;
  final bool themeIsBlack;

  @override
  _OptWidgetState createState() => _OptWidgetState();
}

class _OptWidgetState extends State<OptWidget> {
  String _screen = '0';
  List<String> _entry = new List.from(['0']);
  String _activeBtn = '';
  bool _lastIsResult = false;

  void _handleClearBtnChanged(bool isClearAll) {
    var tempCopy = _entry.toList();
    if (isClearAll) {
      tempCopy = ['0'];
    } else {
      tempCopy.last = '0';
    }
    setState(() {
      _screen = '0';
      _entry = tempCopy;
      _activeBtn = '';
    });
    print(_entry);
  }

  String clearZero(String val) {
    if (val.length > 1 && val[0] == '0') {
      return val.substring(1);
    }
    return val;
  }

  void _handleNumberBtnChanged(String val) {
    bool lastIsNumber = RegExp(r'^[0-9.]+$').hasMatch(_entry.last);
    List<String> tempEntry = _entry.toList();
    String cur = '';

    if (val == '.' && _entry.last.contains('.')) {
      return;
    }
    if (_lastIsResult) {
      cur = val;
      tempEntry = [val];
    } else if (lastIsNumber) {
      cur = clearZero(_entry.last + val);
      tempEntry.replaceRange(_entry.length - 1, _entry.length, [cur]);
    } else {
      cur = clearZero(val);
      tempEntry.add(cur);
    }

    setState(() {
      _screen = cur;
      _entry = tempEntry;
      _activeBtn = '';
      _lastIsResult = false;
    });
    print('$_lastIsResult,$_entry');
  }

  String _cal(xStr, opt, yStr) {
    print('$xStr, $opt, $yStr');
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

    print('result: $result');
    // 0 的除法
    if (result.isInfinite || result.isNaN) {
      return '错误';
    } else if (result.toString().length > 8) {
      // 保留小数位数 =  10 - int 类型的位数
      return result.toString();
    } else if (result.toInt() - result == 0) {
      return result.toInt().toString();
    } else {
//      return result.toString().length > 8 ? result.toStringAsFixed(5) : result.toString();
      return result.toString();
    }
  }

  String formatNumber(result) {
    return result.length > 8
        ? double.parse(result).toStringAsExponential(3)
        : result;
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
    } else {
      // error
      return '';
    }
  }

  void changeLast(result) {
    List<String> newEntry = [];
    for (int i = 0; i < _entry.length - 1; i++) {
      newEntry[i] = _entry[i];
    }
    newEntry.add(result);
    setState(() {
      _screen = formatNumber(result);
      _entry = newEntry;
      _activeBtn = '';
    });
  }

  void _handleOperatorBtnChanged(String val) {
//    final lastIsNumber = RegExp(r'^[0-9]+$').hasMatch(last);
    String newActiveBtn = '';
    List<String> newEntry = _entry.toList();
    String newScreen = '';
    String last = _entry.last;
    bool lastIsResult = false;

    // 新符号入栈
    void pushStack() {
      newActiveBtn = val;
      newEntry.add(val);
      newScreen = last;
    }

    if (val == '%') {
      final String result = (double.parse(last) / 100).toString();
      changeLast(result);
      return;
    }

    if (val == '+/-') {
      final String result =
          double.parse(last).isNegative ? last.substring(1) : '-' + last;
      changeLast(result);
      return;
    }

    final length = _entry.length;
    switch (length) {
//      case 0: 第一位最少也是 0 不会是运算符
      case 1:
        if (val == '=') {
          // 1 (=) 相当于没有
          newActiveBtn = '';
          newScreen = _screen;
        } else {
          // 1 (+) 入栈
          pushStack();
        }
        break;
      case 2:
        // 1+ (=) 自增计算
        if (val == '=') {
          final String result = _cal(newEntry[0], newEntry[1], newEntry[0]);
          newActiveBtn = '';
          newEntry = [result];
          newScreen = result;
        } else {
          // 1 + (-) 覆盖上一个运算符
          newActiveBtn = val;
          newEntry.last = val;
          newScreen = last;
        }
        break;
      case 3:
        if (RegExp(r'^[+-]$').hasMatch(newEntry[1]) &&
            RegExp(r'^[×÷]$').hasMatch(val)) {
          // 第一个是+ -，第二个是 × ÷ 入栈
          pushStack();
        } else {
          final String result = calExpress(_entry);
          if (result == '错误') {
            newActiveBtn = '';
            newEntry = ['0'];
            newScreen = '错误';
          } else {
            if (val == '=') {
              // 1+2(=) 求值
              newActiveBtn = '';
              newEntry = [result];
              newScreen = result;
              lastIsResult = true;
            } else {
              // 1+2(+) => 3 + 求值并将值和运算符都入栈
              newActiveBtn = val;
              newEntry.replaceRange(0, 3, [result, val]);
              newScreen = result;
            }
          }
        }
        break;
      case 4:
        // 1 + 2 * (=) => 1 + 2 * 2 => 1 + 4 => 5
        if (val == '=') {
          final String result = _cal(newEntry[0], newEntry[1],
              _cal(newEntry[2], newEntry[3], newEntry[2]));
          newActiveBtn = '';
          newEntry = [result];
          lastIsResult = true;
        }
        // 1 + 2 + (-) =>1 + 2 -  覆盖
        newActiveBtn = val;
        newEntry.last = val;
        break;
      case 5:
        final String result1 = calExpress(newEntry);
        if (val == '=') {
          // 1+2*3（=）  =>  1+ 6 => 7
          newActiveBtn = '';
          newEntry = [result1];
          newScreen = result1;
          lastIsResult = true;
        } else if (RegExp(r'^[+-]$').hasMatch(val)) {
          // 1+2*3+
          newActiveBtn = val;
          newEntry = [result1, val];
          newScreen = result1;
        } else if (RegExp(r'^[×÷]$').hasMatch(val)) {
          // 1+2*3* // 变成 1 + 6 显示 6
          final String result2 = _cal(newEntry[2], newEntry[3], newEntry[4]);
          newActiveBtn = val;
          newEntry = [newEntry[0], newEntry[1], result2, val];
          newScreen = result2;
        }
    }

    setState(() {
      _screen = newScreen;
      _entry = newEntry;
      _activeBtn = newActiveBtn;
      _lastIsResult = lastIsResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    final handleMap = {
      'number': _handleNumberBtnChanged,
      'other': _handleOperatorBtnChanged,
      'operate': _handleOperatorBtnChanged,
    };

    double fontSize = widget.isLargeScreen ? 30.0: 80.0;
    return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.themeIsBlack ? Colors.black: Colors.white,
        ),
        child: SafeArea(
            child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
              Container(
                alignment: Alignment.centerRight,
                height: widget.isLargeScreen ? 80 : 160.0,
                padding:
                    EdgeInsets.only(bottom: widget.isLargeScreen ? 10.0 : 40.0),
                child: Text(
                  '$_screen',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                  ),
                  strutStyle: StrutStyle(
                    fontSize: fontSize,
                    height: 1.5,
                  ),
                ),
              ),
              Expanded(
                  flex: 4,
                  child: Flex(
                      direction: Axis.vertical,
                      children: buttonLists.map((buttonList) {
                        return Expanded(
                            flex: 1,
                            child: Flex(
                                direction: Axis.horizontal,
                                children: buttonList.map((name) {
                                  final type =
                                      RegExp(r'^[0-9.]+$').hasMatch(name)
                                          ? 'number'
                                          : RegExp(r"([C/%])").hasMatch(name)
                                              ? 'other'
                                              : 'operate';

                                  return Expanded(
                                      flex: name == '0' ? 2 : 1,
                                      child: Center(
                                        child: Padding(
                                            //左边添加8像素补白
                                            padding: const EdgeInsets.all(8.0),
                                            child: BaseBtn(
                                              isLargeScreen:
                                                  widget.isLargeScreen,
                                              name: name,
                                              active: _activeBtn == name,
                                              type: type,
                                              onChanged: handleMap[type],
                                              screenIsZero: _screen == '0',
                                              onClear: _handleClearBtnChanged,
                                            )),
                                      ));
                                }).toList()));
                      }).toList()))
            ])));
  }
}
