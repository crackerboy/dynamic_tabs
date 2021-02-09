import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/classes/tab.dart';
import 'common/grid_item.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({
    this.adaptive = false,
    required this.tabs,
    required this.maxTabs,
  });

  final bool adaptive;
  final List<DynamicTab> tabs;
  final int maxTabs;

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  List<DynamicTab>? _tabs;
  @override
  void initState() {
    _tabs = widget.tabs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adaptive && defaultTargetPlatform == TargetPlatform.iOS) {
      return DefaultTextStyle(
          style: CupertinoTheme.of(context).textTheme.textStyle,
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              transitionBetweenRoutes: false,
              heroTag: 'more-tab',
              trailing: CupertinoButton(
                padding: EdgeInsets.all(0.0),
                child: Text("Save"),
                onPressed: () => _saveTabs(context),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: _buildBody(context, constraints),
                    ),
                    Container(
                      height: 100.0,
                      child: BottomEditableTabBar(
                        adaptive: widget.adaptive,
                        maxTabs: widget.maxTabs,
                        tabs: _tabs,
                        onChanged: (tabs) {
                          setState(() {
                            _tabs = tabs;
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ));
    }
    return DefaultTextStyle(
        style: Theme.of(context).textTheme.display1!,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () => _saveTabs(context),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: _buildBody(context, constraints),
                  ),
                  Container(
                    height: 100.0,
                    child: BottomEditableTabBar(
                      adaptive: widget.adaptive,
                      maxTabs: widget.maxTabs,
                      tabs: _tabs,
                      onChanged: (tabs) {
                        setState(() {
                          _tabs = tabs;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }

  Widget _buildBody(BuildContext context, BoxConstraints constraints) {
    return Center(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 20.0),
              child: Text(
                "Drag the icons to\norganize tabs.",
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(fontSize: 22.0),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: (constraints.maxWidth / 100).round(),
                  children: _tabs!
                      .map(
                        (t) => GridTabItem(
                          active: _tabs!.indexOf(t) >= widget.maxTabs,
                          tab: t,
                          adaptive: widget.adaptive,
                          draggable: true,
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _saveTabs(BuildContext context) {
    Navigator.of(context).pop(_tabs);
  }
}

class BottomEditableTabBar extends StatefulWidget {
  const BottomEditableTabBar({
    required this.maxTabs,
    required this.tabs,
    required this.adaptive,
    required this.onChanged,
  });

  final bool adaptive;
  final int maxTabs;
  final List<DynamicTab>? tabs;
  final ValueChanged<List<DynamicTab>?> onChanged;

  @override
  _BottomEditableTabBarState createState() => _BottomEditableTabBarState();
}

class _BottomEditableTabBarState extends State<BottomEditableTabBar> {
  List<DynamicTab>? _tabs;
  int? _previewIndex;

  @override
  void initState() {
    _tabs = widget.tabs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [];
    List<DynamicTab> _targets = _tabs!.take(widget.maxTabs).toList();
    for (var t in _targets) {
      _children.add(DragTarget<String>(
        builder: (context, possible, rejected) {
          print("Possible: $possible, Rejected: $rejected");
          return GridTabItem(
            tab: t,
            active: _previewIndex == null
                ? true
                : !(_targets.indexOf(t) == _previewIndex),
            adaptive: widget.adaptive,
            // draggable: true,
          );
        },
        onWillAccept: (String? data) {
          setState(() {
            _previewIndex = _targets.indexOf(t);
          });
          return true;
        },
        onLeave: (data) {
          setState(() {
            _previewIndex = null;
          });
        },
        onAccept: (String data) {
          final DynamicTab _baseTab = _targets[_previewIndex!];
          final DynamicTab _newTab = _tabs!.firstWhere((t) => t.tag == data);
          final int _oldIndex = _tabs!.indexOf(_newTab);

          _tabs!.removeAt(_previewIndex!);
          _tabs!.insert(_previewIndex!, _newTab);
          _tabs!.removeAt(_oldIndex);
          _tabs!.insert(_oldIndex, _baseTab);

          widget.onChanged(_tabs);

          setState(() {
            _previewIndex = null;
          });
        },
      ));
    }

    _children.add(GridTabItem(
      tab: DynamicTab(
        child: Container(),
        tab: BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          title: Text("More"),
        ),
        tag: "",
      ),
      draggable: false,
      active: false,
      adaptive: widget.adaptive,
    ));
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _children,
      ),
    );
  }
}
