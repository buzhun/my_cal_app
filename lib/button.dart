//------------------------- BaseBtn ----------------------------------
import 'package:flutter/material.dart';

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
