//------------------------- BaseBtn ----------------------------------
import 'package:flutter/material.dart';

// 不同按钮类型对应的颜色
final fontColorMap = {
  'number': Colors.white,
  'other': Colors.black,
  'operate': Colors.white,
};

final bgColorMap = {
  'number': Colors.grey[800],
  'other': Colors.grey[300],
  'operate': Colors.orange,
};

final lightColorMap = {
  'number': Colors.grey[500],
  'other': Colors.grey[100],
  'operate': Colors.orange[100],
};

class BaseBtn extends StatefulWidget {
  BaseBtn({
    Key key,
    @required this.name,
    this.active: false,
    @required this.type,
    @required this.onChanged,
    @required this.screenIsZero,
    @required  this.isLargeScreen,
    this.onClear,
  }) : super(key: key);

  final String name;
  final String type;

  // 是否为当前活跃的按钮
  final bool active;
  final bool screenIsZero;
  final bool isLargeScreen;

  // 点击回调
  final onChanged;
  final onClear;

  @override
  _BaseBtnState createState() => new _BaseBtnState();
}

class _BaseBtnState extends State<BaseBtn> {
  bool _highlight = false;
  String displayName = ''; // 按钮显示文字

  @override
  void initState() {
    super.initState();
    // 初始化状态
    if (widget.name == 'C') {
      displayName = widget.screenIsZero ? 'AC' : 'C';
    } else {
      displayName = widget.name;
    }
  }

  @override
  void didUpdateWidget(BaseBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 监听 screenIsZero 的变化，动态更新 C 按钮的显示文案
    if (oldWidget.screenIsZero != widget.screenIsZero && widget.name == 'C') {
      setState(() => displayName = widget.screenIsZero ? 'AC' : 'C');
    }
  }

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
    if (widget.name == 'C') {
      widget.onClear(widget.screenIsZero);
    } else {
      widget.onChanged(widget.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      displayName,
      style: TextStyle(
        fontSize: widget.isLargeScreen ? 20.0 : 40.0,
        color: widget.active ? Colors.orange : fontColorMap[widget.type],
      ),
    );

    final Widget centerText = Center(
      child: text,
    );

    final Widget zeroText = Container(
      padding: EdgeInsets.fromLTRB(22.0, 12.0, 0, 0),
      child: text,
    );

    return GestureDetector(

      onTapDown: _handleTapDown,
      // Handle the tap events in the order that
      onTapUp: _handleTapUp,
      // they occur: down, up, tap, cancel
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
          color: widget.active
              ? Colors.white
              : _highlight
                  ? lightColorMap[widget.type]
                  : bgColorMap[widget.type],
        ),
      ),
    );
  }
}
