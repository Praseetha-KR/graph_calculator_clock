import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:weather_icons/weather_icons.dart';


enum _Element {
  bgMinute,
  bgSecond,
  bgSecondFuture,
  bgCalcHeader,
  bgCalcBody,
  bgLcd,
  bgSolar,
  bgSolarDivider,
  bgHour,
  bgHourCurrent,
  bgHourFuture,
  textDate,
  textLcd,
  textSolar,
  textHour,
  textHourCurrent,
  textHourFuture,
}

final _lightTheme = {
  _Element.bgMinute: Color(0xFF07B494),
  _Element.bgSecond: Color(0xFF15C6A4),
  _Element.bgSecondFuture: Color(0xFFAFEFE3),
  _Element.bgCalcHeader: Color(0xFF151319),
  _Element.bgCalcBody: Color(0xFFBABDC2),
  _Element.bgLcd: Color(0xFF9DAA74),
  _Element.bgSolar: Color(0xFF654C35),
  _Element.bgSolarDivider: Color(0xFF866A5E),
  _Element.bgHour: Color(0xFF878891),
  _Element.bgHourCurrent: Color(0xFF07B494),
  _Element.bgHourFuture: Color(0xFF303232),
  _Element.textDate: Colors.white,
  _Element.textLcd: Colors.black,
  _Element.textSolar: Colors.white38,
  _Element.textHour: Colors.white54,
  _Element.textHourCurrent: Color(0xFFAFEFE3),
  _Element.textHourFuture: Colors.white54,
};

final _darkTheme = {
  _Element.bgMinute: Color(0xFF111111),
  _Element.bgSecond: Color(0xFF0f977e),
  _Element.bgSecondFuture: Color(0xFF1C1E1D),
  _Element.bgCalcHeader: Color(0xFF151319),
  _Element.bgCalcBody: Color(0xFF37353B),
  _Element.bgLcd: Color(0xFF9DAA74),
  _Element.bgSolar: Color(0xFF654C35),
  _Element.bgSolarDivider: Color(0xFF866A5E),
  _Element.bgHour: Color(0xFF57595B),
  _Element.bgHourCurrent: Color(0xFF07B494),
  _Element.bgHourFuture: Color(0xFF848492),
  _Element.textDate: Colors.white,
  _Element.textLcd: Colors.black,
  _Element.textSolar: Colors.white38,
  _Element.textHour: Colors.white24,
  _Element.textHourCurrent: Color(0xFFAFEFE3),
  _Element.textHourFuture: Colors.white60,
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

    List<Widget> _createActiveMinuteGridChildren() {
      return new List<Widget>.generate(60, (int index) {
        return Container(
          color: index >= _dateTime.second ? colors[_Element.bgSecondFuture] : colors[_Element.bgSecond]
        );
      });
    }

    List<Widget> _createInactiveMinuteGridChildren(color) {
      return new List<Widget>.generate(60, (int index) {
        return Container(
          color: color,
        );
      });
    }

    final minuteGridCurrent = GridView.count(
      padding: const EdgeInsets.all(0.5),
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 6,
      childAspectRatio: (5 / 4.1),
      children: _createActiveMinuteGridChildren(),
    );

    final minuteGridPast = GridView.count(
      padding: const EdgeInsets.all(0.5),
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 6,
      childAspectRatio: (5 / 4.1),
      children: _createInactiveMinuteGridChildren(colors[_Element.bgSecond]),
    );

    final minuteGridFuture = GridView.count(
      padding: const EdgeInsets.all(0.5),
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 6,
      childAspectRatio: (5 / 4.1),
      children: _createInactiveMinuteGridChildren(colors[_Element.bgSecondFuture]),
    );

    Widget _buildMinuteChild(index) {
      if (index < _dateTime.minute) {
        return minuteGridPast;
      }
      if (index == _dateTime.minute) {
        return minuteGridCurrent;
      }
      return minuteGridFuture;
    }

    List<Widget> _createHourGridChildren() {
      return new List<Widget>.generate(60, (int index) {
        return Container(
          child: _buildMinuteChild(index),
        );
      });
    }

    final _hourGrid = GridView.count(
      padding: const EdgeInsets.all(2),
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 10,
      childAspectRatio: (6 / 8.5),
      children: _createHourGridChildren(),
    );

    Color _getHourTileBg(index) {
      if (index < _dateTime.hour) {
        return colors[_Element.bgHour];
      }
      if (index == _dateTime.hour) {
        return colors[_Element.bgHourCurrent];
      }
      return colors[_Element.bgHourFuture];
    }

    Color _getHourTileFg(index) {
      if (index < _dateTime.hour) {
        return colors[_Element.textHour];
      }
      if (index == _dateTime.hour) {
        return colors[_Element.textHourCurrent];
      }
      return colors[_Element.textHourFuture];
    }

    List<Widget> _createDayGridChildren() {
      return new List<Widget>.generate(24, (int index) {
        return Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _getHourTileBg(index),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: AutoSizeText.rich(
                    TextSpan(
                      text: index.toString(),
                    ),
                    minFontSize: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getHourTileFg(index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    }

    final _dayGrid = GridView.count(
      padding: const EdgeInsets.all(4),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      crossAxisCount: 4,
      childAspectRatio: (6 / 5.78),
      children: _createDayGridChildren(),
    );

    final _calculatorLabel = Row(
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
                fontSize: 200,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: colors[_Element.textDate],
              ),
            ),
          ),
        ),
      ],
    );

    final _calculatorLcdDisplay = Container(
      padding: EdgeInsets.only(left: 3, right: 3, top: 2, bottom: 4),
      decoration: BoxDecoration(
        color: colors[_Element.bgLcd],
        borderRadius: BorderRadius.all(Radius.circular(2))
      ),
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
                  color: colors[_Element.textLcd],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final _calculatorSolarPanel = Row(
      children: [
        Spacer(flex: 24),
        Flexible(
          flex: 56,
          child: Container(
            color: colors[_Element.bgSolar],
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[_Element.bgSolarDivider],
                      borderRadius: BorderRadius.all(Radius.circular(2))
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 18,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors[_Element.bgSolar],
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
                                          color: colors[_Element.textSolar]
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
                          flex: 40,
                          child: Container(
                            padding: EdgeInsets.only(left: 2, right: 2, top: 0.8),
                            color: colors[_Element.bgSolar],
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
                                        fontSize: 200,
                                        color: colors[_Element.textSolar],
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
                          flex: 64,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors[_Element.bgSolar],
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(2),
                                bottomRight: Radius.circular(2),
                              )
                            ),
                            padding: EdgeInsets.only(left: 2, right: 2, top: 1.5),
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
                                        fontSize: 100,
                                        color: colors[_Element.textSolar],
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
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Flexible(
            flex: 80,
            child: Row(
              children: [
                Flexible(
                  flex:60,
                  child: Container(
                    color: colors[_Element.bgMinute],
                    padding: EdgeInsets.all(2),
                    child: _hourGrid,
                  )
                ),

                Flexible(
                  flex: 25,
                  child: Container(
                    color: colors[_Element.bgCalcHeader],
                    child: Column(
                      children: [
                        Flexible(
                          flex: 10,
                          child: Container(
                            padding: EdgeInsets.only(left: 3, right: 3, top: 8, bottom: 2),
                            color: colors[_Element.bgCalcHeader],
                            child: _calculatorLabel,
                          ),
                        ),

                        Flexible(
                          flex: 19,
                          child: Container(
                            padding: EdgeInsets.only(left: 7, right: 7, top: 6, bottom: 5),
                            color: colors[_Element.bgCalcHeader],
                            child: _calculatorLcdDisplay,
                          )
                        ),

                        Flexible(
                          flex: 8,
                          child: Container(
                            padding: EdgeInsets.only(top: 1, bottom: 7),
                            child:  _calculatorSolarPanel,
                          ),
                        ),

                        Flexible(
                          flex: 85,
                          child: Container(
                            padding: EdgeInsets.only(left: 3, right: 3, bottom: 3, top: 2),
                            color: colors[_Element.bgCalcBody],
                            child: _dayGrid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
