import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folding_cell/folding_cell.dart';
import 'package:job_search_assistant/models/job_application_info.dart';
import 'package:job_search_assistant/utils/date_string_formatter.dart';
import 'package:job_search_assistant/utils/info_helper.dart';
import 'package:job_search_assistant/utils/source_view.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoTile extends StatelessWidget {
  final JobApplicationInfo info;
  final Size cellSize;
  final EdgeInsets edgeInsets;
  final Duration animationDuration;
  final double borderRadius;
  final _key = GlobalKey<SimpleFoldingCellState>();

  final onPushEdit;
  final onPushClear;

  AppInfoTile({
    @required this.info,
    @required this.onPushEdit,
    @required this.onPushClear,
    this.cellSize = const Size(100, 100),
    this.edgeInsets = const EdgeInsets.all(10),
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius = 0,
  })  : assert(info != null),
        assert(cellSize != null),
        assert(edgeInsets != null),
        assert(animationDuration != null),
        assert(borderRadius != null && borderRadius >= 0.0);

  @override
  Widget build(BuildContext context) {
    var positionInfoText = Text(
      info.position + ' at ' + info.companyName,
      style: Theme.of(context).textTheme.title,
      textAlign: TextAlign.center,
    );

    var clearIcon = IconButton(
        icon: Icon(Icons.clear),
        alignment: Alignment.centerRight,
        onPressed: onPushClear);

    var applicationDateString =
        DateStringFormatter.getDateAsString(info.whenApplied);
    var currentResult = info.interviewRes ?? JobAppInfoHelper.defaultRes();

    var padding = EdgeInsets.all(8);

    var briefInfoWidget = Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('Applied at $applicationDateString',
                  textAlign: TextAlign.left),
            ),
            Expanded(
              child: Text(
                '$currentResult',
                textAlign: TextAlign.right,
              ),
            )
          ],
        ));

    var boxColor = Theme.of(context).primaryColor;
    Widget front = Container(
      color: boxColor,
      child: Column(
        children: <Widget>[
          Padding(
            padding: padding,
            child: Row(
              children: <Widget>[
                Spacer(flex: 1),
                Expanded(flex: 3, child: positionInfoText),
                Expanded(flex: 1, child: clearIcon),
              ],
            ),
          ),
          briefInfoWidget,
        ],
      ),
    );

    var editIcon = IconButton(
      icon: Icon(Icons.edit),
      alignment: Alignment.centerLeft,
      onPressed: onPushEdit,
    );

    Widget innerTop = Container(
      color: boxColor,
      child: Column(
        children: <Widget>[
          Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(flex: 1, child: editIcon),
                Expanded(flex: 3, child: positionInfoText),
                Expanded(flex: 1, child: clearIcon),
              ],
            ),
          ),
          briefInfoWidget
        ],
      ),
    );

    List<Widget> rowChildren;
    if (info.whenAnswered != null) {
      rowChildren = <Widget>[
        Expanded(
            flex: 1,
            child: Text(
              'Answered on ' +
                  DateStringFormatter.getDateAsString(info.whenAnswered),
              textAlign: TextAlign.left,
            )),
      ];
    } else {
      rowChildren = <Widget>[
        Expanded(
            child: Text(
          'No answer yet',
          textAlign: TextAlign.left,
        ))
      ];
    }

    var source = SourceView.fromString(info.source);
    Widget sourceButton;
    if (source.getName() != null && source.getName().isNotEmpty) {
      sourceButton = Expanded(
          child: RaisedButton(
        child: Text('Go to ' + source.getName()),
        onPressed: () {
          _launchUrl(context, source.getLink());
        },
      ));
    } else {
      sourceButton = Spacer();
    }

    rowChildren.add(sourceButton);

    Widget innerBottom = Container(
      color: boxColor,
      //alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: rowChildren,
            ),
          ),
        ],
      ),
    );

    return InkWell(
      onTap: () {
        _key?.currentState?.toggleFold();
      },
      child: SimpleFoldingCell(
        key: _key,
        frontWidget: front,
        innerTopWidget: innerTop,
        innerBottomWidget: innerBottom,
        cellSize: cellSize,
        padding: edgeInsets,
        animationDuration: animationDuration,
        borderRadius: borderRadius,
      ),
    );
  }

  void _launchUrl(BuildContext context, String link) async {
    try {
      if (await canLaunch(link)) {
        await launch(
          link,
          forceWebView: true,
          enableJavaScript: true,
        );
      } else {
        throw 'Couldn\'t launch $link';
      }
    } catch (exception) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Couldn\' open $link'),
            content: Text('Please check whether the link is correct'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
        barrierDismissible: true,
      );
    }
  }
}
