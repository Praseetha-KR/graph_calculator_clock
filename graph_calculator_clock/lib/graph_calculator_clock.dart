import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:weather_icons/weather_icons.dart';


enum _Element {
  bgLeftPanel,
  bgRightPanel,
  bgBottomPanel,
  bgSecond,
  bgSecondDone,
  bgHour,
  bgHourDone,
  bgHourActive,
  textTime,
  textDay,
  textTemperature,
  iconWeather,
}

final _lightTheme = {
  _Element.bgLeftPanel: Colors.indigo,
  _Element.bgRightPanel: Colors.indigo[100],
  _Element.bgBottomPanel: Color(0xFFFFFFFF),
  _Element.bgSecond: Colors.indigo[300],
  _Element.bgSecondDone: Colors.deepOrange,
  _Element.bgHour: Colors.green[100],
  _Element.bgHourDone: Colors.green,
  _Element.bgHourActive: Colors.indigo,
  _Element.textTime: Colors.black,
  _Element.textDay: Colors.black,
  _Element.textTemperature: Colors.black,
  _Element.iconWeather: Colors.amber,
};

final _darkTheme = {
  _Element.bgLeftPanel: Colors.black,
  _Element.bgRightPanel: Colors.indigo[100],
  _Element.bgBottomPanel: Color(0xFFFFFFFF),
  _Element.bgSecond: Colors.indigo[200],
  _Element.bgSecondDone: Colors.indigo,
  _Element.bgHour: Colors.green[100],
  _Element.bgHourDone: Colors.green,
  _Element.bgHourActive: Colors.indigo,
  _Element.textTime: Colors.black,
  _Element.textDay: Colors.black,
  _Element.textTemperature: Colors.black,
  _Element.iconWeather: Colors.amber,
};


class GraphCalculatorClock extends StatefulWidget {
  const GraphCalculatorClock(this.model);

  final ClockModel model;

  @override
  _GraphCalculatorClockState createState() => _GraphCalculatorClockState();
}


class _GraphCalculatorClockState extends State<GraphCalculatorClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(GraphCalculatorClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '${widget.model.low} - ${widget.model.highString}';
      _condition = widget.model.weatherString;
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  IconData _getWeatherIcon(condition) {
    final conditionIconMap = {
      'cloudy': WeatherIcons.cloudy,
      'foggy': WeatherIcons.fog,
      'rainy': WeatherIcons.rain,
      'snowy': WeatherIcons.snow,
      'sunny': WeatherIcons.day_sunny,
      'thunderstorm': WeatherIcons.thunderstorm,
      'windy': WeatherIcons.windy,
    };
    return conditionIconMap[condition];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final day = DateFormat('EEE, d MMM').format(_dateTime);

    final fontSize = MediaQuery.of(context).size.width / 20.5;

    List<Widget> _createCurrentSecondsGridChildren() {
      return new List<Widget>.generate(60, (int index) {
        return Container(
          // padding: const EdgeInsets.all(8),
          // child: const Text('0'),
          color: index >= _dateTime.second ? Color(0xFFAFEFE3) : Color(0xFF15C6A4)
        );
      });
    }

    List<Widget> _createPastSecondsGridChildren() {
      return new List<Widget>.generate(60, (int index) {
        return Container(
          // padding: const EdgeInsets.all(8),
          // child: const Text('0'),
          color: Color(0xFF15C6A4)
        );
      });
    }

    List<Widget> _createFutureSecondsGridChildren() {
      return new List<Widget>.generate(60, (int index) {
        return Container(
          // padding: const EdgeInsets.all(8),
          // child: const Text('0'),
          color: Color(0xFFAFEFE3),
        );
      });
    }

    final secondsGridCurrent = GridView.count(
      padding: const EdgeInsets.all(0.5),
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 6,
      childAspectRatio: (5 / 4.1),
      children: _createCurrentSecondsGridChildren(),
    );

    final secondsGridPast = GridView.count(
      padding: const EdgeInsets.all(0.5),
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 6,
      childAspectRatio: (5 / 4.1),
      children: _createPastSecondsGridChildren(),
    );

    final secondsGridFuture = GridView.count(
      padding: const EdgeInsets.all(0.5),
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 6,
      childAspectRatio: (5 / 4.1),
      children: _createFutureSecondsGridChildren(),
    );

    Widget _buildMinuteChild(index) {
      if (index < _dateTime.minute) {
        return secondsGridPast;
      }
      if (index == _dateTime.minute) {
        return secondsGridCurrent;
      }
      return secondsGridFuture;
    }

    List<Widget> _createMinutesGridChildren() {
      return new List<Widget>.generate(60, (int index) {
        return Container(
          // padding: const EdgeInsets.all(8),
          child: _buildMinuteChild(index),
          // color: index >= _dateTime.minute ? Colors.teal[100] : Colors.teal[600],
        );
      });
    }

    final minutesGrid = GridView.count(
      padding: const EdgeInsets.all(2),
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 10,
      childAspectRatio: (6 / 8.5),
      children: _createMinutesGridChildren(),
    );

    Color _getHourTileBg(index) {
      if (index < _dateTime.hour) {
        return Color(0xFF57595B);
      }
      if (index == _dateTime.hour) {
        return Color(0xFF07B494);
      }
      return Color(0xFF848492);
    }

    Color _getHourTileFg(index) {
      if (index < _dateTime.hour) {
        return Colors.white24; //Colors.indigo[300];
      }
      if (index == _dateTime.hour) {
        return Color(0xFFAFEFE3);
      }
      return Colors.white60;
    }

    List<Widget> _createHoursGridChildren() {
      return new List<Widget>.generate(24, (int index) {
        return Container(
          decoration: BoxDecoration(
            color: _getHourTileBg(index),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          // padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              index.toString(),
              style: TextStyle(color: _getHourTileFg(index)),
            )
          ),
          // color: _getHourTileBg(index),
        );
      });
    }

    final hoursGrid = GridView.count(
      padding: const EdgeInsets.all(4),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      crossAxisCount: 4,
      childAspectRatio: (6 / 5.78),
      children: _createHoursGridChildren(),
    );

    // const List<Choice> choices = const <Choice>[];


    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 80,
            child: Row(
              children: <Widget>[
                Flexible(
                  flex:60,
                  child: Container(
                    color: Color(0xFF07B494),
                    padding: EdgeInsets.all(2),
                    child: minutesGrid,
                  )
                ),
                Flexible(
                  flex: 25,
                  child: Container(
                    color: Color(0xFF151319),
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          flex: 10,
                          child: Container(
                            padding: EdgeInsets.only(left: 3, right: 3, top: 8, bottom: 2),
                            color: Color(0xFF151319),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: AutoSizeText.rich(
                                      TextSpan(
                                        text: day.toUpperCase(),
                                      ),
                                      minFontSize: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 200,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        // color: Color(0xFF3d5f6d),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Flexible(
                          flex: 19,
                          child: Container(
                            padding: EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 5),
                            color: Color(0xFF151319),
                            child: Container(
                              padding: EdgeInsets.only(left: 3, right: 3, top: 2, bottom: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF9DAA74), //Color(0xFF527D90), // Color(0xFF684C34),
                                borderRadius: BorderRadius.all(Radius.circular(2))
                              ),
                              // color: Color(0xFF9DAA74),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: AutoSizeText.rich(
                                        TextSpan(
                                          text: '$hour:$minute:$second',
                                        ),
                                        minFontSize: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Digital-7 Mono',
                                          fontSize: 200,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ),

                        Flexible(
                          flex: 8,
                          child: Container(
                            padding: EdgeInsets.only(top: 1, bottom: 7),
                            child: Row(
                              children: <Widget>[
                                Spacer(flex: 24),
                                Flexible(
                                  flex: 56,
                                  child: Container(
                                    color: Color(0xFF654C35),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xFF866A5E),
                                              borderRadius: BorderRadius.all(Radius.circular(2))
                                            ),
                                            // color: Color(0xFF866A5E),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Flexible(
                                                  flex: 18,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF654C35),
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(2),
                                                        bottomLeft: Radius.circular(2),
                                                      )
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 2),
                                                            child: Align(
                                                              alignment: Alignment.center,
                                                              child: LayoutBuilder(builder: (context, constraint) {
                                                                return new BoxedIcon(
                                                                  _getWeatherIcon(_condition),
                                                                  size: constraint.biggest.height / 1.7,
                                                                  color: Colors.white38
                                                                );
                                                              })
                                                            ),
                                                          )
                                                        )
                                                      ]
                                                    )
                                                  ),
                                                ),
                                                Spacer(flex: 1),
                                                Flexible(
                                                  flex: 38,
                                                  child: Container(
                                                    // decoration: BoxDecoration(
                                                    //   color: Color(0xFF654C35),
                                                    //   borderRadius: BorderRadius.only(
                                                    //     topRight: Radius.circular(2),
                                                    //     bottomRight: Radius.circular(2),
                                                    //   )
                                                    // ),
                                                    padding: EdgeInsets.symmetric(horizontal: 3),
                                                    color: Color(0xFF654C35),
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment.center,
                                                            child: AutoSizeText.rich(
                                                              TextSpan(
                                                                text: _temperature,
                                                              ),
                                                              minFontSize: 1,
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontFamily: 'Open Sans',
                                                                fontSize: 100,
                                                                color: Colors.white38,
                                                                height: 1.1,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Spacer(flex: 1),
                                                Flexible(
                                                  flex: 62,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF654C35),
                                                      borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(2),
                                                        bottomRight: Radius.circular(2),
                                                      )
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 2),
                                                    // color: Color(0xFF654C35),
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment.center,
                                                            child: AutoSizeText.rich(
                                                              TextSpan(
                                                                text: _temperatureRange,
                                                              ),
                                                              minFontSize: 1,
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontFamily: 'Open Sans',
                                                                fontSize: 100,
                                                                color: Colors.white38,
                                                                height: 1.1,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(flex: 4),
                              ],
                            )
                          ),
                        ),

                        Flexible(
                          flex: 85,
                          child: Container(
                            padding: EdgeInsets.only(left: 3, right: 3, bottom: 3, top: 2),
                            color: Color(0xFF37353B), //Color(0xFF025472),
                            child: hoursGrid
                          ),
                        )
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
