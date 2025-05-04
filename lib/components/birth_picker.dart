import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:birth_picker/birth_picker_util.dart';

export 'package:intl/date_symbol_data_local.dart';

class BirthPicker extends StatefulWidget {
  /// Decoration for the widget container (e.g., border, background)
  final BoxDecoration? decoration;

  /// Padding for the entire widget
  final EdgeInsets? padding;

  /// Color of the background when the field is focused
  final Color? focusColor;

  /// Padding when the field is focused
  final EdgeInsets? focusPadding;

  /// Text style for the input fields
  final TextStyle? textStyle;

  /// Locale for date formatting (e.g., "en_US")
  final String? locale;

  /// Whether the first field should get focus automatically on load
  final bool autofocus;

  /// User-customized icon to display next to the input fields
  final Widget? icon;

  /// Color of the icon
  final Color? iconColor;

  /// Size of the icon
  final double iconSize;

  /// Callback function triggered when the date changes
  /// Passes null if the dateTime is invalid.
  final void Function(DateTime? dateTime)? onChanged;

  const BirthPicker({
    super.key,
    this.onChanged,
    this.decoration,
    this.padding,
    this.focusColor,
    this.focusPadding,
    this.textStyle,
    this.locale,
    this.icon,
    this.iconColor,
    this.iconSize = 20,
    this.autofocus = false,
  });

  @override
  State<BirthPicker> createState() => _BirthPickerState();
}

class _BirthPickerState extends State<BirthPicker> {
  late Map<String, String> labels;
  late List<String> dateSeparator;
  late List<String> fieldOrder;

  final Map<String, TextEditingController> controllers = {
    'year': TextEditingController(),
    'month': TextEditingController(),
    'day': TextEditingController(),
  };
  final Map<String, FocusNode> focusNodes = {
    'year': FocusNode(),
    'month': FocusNode(),
    'day': FocusNode(),
  };
  final keyboardEventFocusNode = FocusNode();

  final Map<String, String> fieldTexts = {'year': '', 'month': '', 'day': ''};

  DateTime? currentDate;

  @override
  void initState() {
    super.initState();
    _initializePickerSettings();
    _addFocusListeners();
    _addControllerListeners();
  }

  bool get _isDateEmpty =>
      fieldTexts['day']!.isEmpty &&
      fieldTexts['month']!.isEmpty &&
      fieldTexts['year']!.isEmpty;

  void _initializePickerSettings() {
    final locale =
        widget.locale ??
        WidgetsBinding.instance.platformDispatcher.locale.toString();
    labels = BirthPickerUtil.getLocalizedDateLabels(locale);
    dateSeparator = BirthPickerUtil.getDateSeparator(locale);
    fieldOrder = BirthPickerUtil.getDateOrder(locale);
  }

  void _addFocusListeners() {
    for (var entry in focusNodes.entries) {
      entry.value.addListener(() {
        String fieldType = entry.key;
        String text = fieldTexts[fieldType]!;

        // Automatically checks the format of text when focus is released
        if (!entry.value.hasFocus && text.isNotEmpty) {
          final maxLength = (fieldType == 'year') ? 4 : 2;
          var (correctedValue, _) = BirthPickerUtil.checkDateFormat(
            fieldType,
            text.padLeft(maxLength, "0"),
          );
          fieldTexts[fieldType] = correctedValue;
          controllers[fieldType]!.text = correctedValue;
        }

        setState(() {});
      });
    }
  }

  void _addControllerListeners() {
    for (var controller in controllers.values) {
      controller.addListener(() async {
        // Keep the cursor always at the end of the text
        if (controller.selection ==
            TextSelection.fromPosition(
              TextPosition(offset: controller.text.length - 1),
            )) {
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }

        if (widget.onChanged != null) {
          await Future.delayed(Duration.zero);
          final date = _getDate();

          if (currentDate != date) {
            currentDate = date;
            widget.onChanged!.call(date);
          }
        }
      });
    }
  }

  DateTime? _getDate() {
    int? year = int.tryParse(fieldTexts["year"]!);
    int? month = int.tryParse(fieldTexts['month']!);
    int? day = int.tryParse(fieldTexts['day']!);
    bool isValidDate = false;

    if (year != null && month != null && day != null) {
      isValidDate = BirthPickerUtil.isValidDate(year, month, day);
    }

    return isValidDate ? DateTime(year!, month!, day!) : null;
  }

  void _handleKeyEvent(KeyEvent event) {
    // Get the currently focused field.
    final focusedField =
        focusNodes.entries
            .firstWhere(
              (entry) => entry.value.hasFocus,
              orElse: () => MapEntry('', FocusNode()),
            )
            .key;

    if (focusedField.isEmpty) return;

    final currentIndex = fieldOrder.indexOf(focusedField);

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && currentIndex > 0) {
      _requestFocus(fieldOrder[currentIndex - 1]);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        currentIndex < fieldOrder.length - 1) {
      _requestFocus(fieldOrder[currentIndex + 1]);
    }
  }

  Widget _buildField(BuildContext context, String fieldType) {
    final controller = controllers[fieldType]!;
    final focusNode = focusNodes[fieldType]!;
    final label = labels[fieldType]!;
    final maxLength = (fieldType == 'year') ? 4 : 2;
    final defaultTextStyle = widget.textStyle ?? TextStyle(fontSize: 16);
    final text = fieldTexts[fieldType]!;
    final order = fieldOrder.indexOf(fieldType);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _requestFocus(fieldType),
      child: Stack(
        children: [
          Center(
            child: Row(
              children: [
                Container(
                  padding:
                      widget.focusPadding ??
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        focusNode.hasFocus
                            ? widget.focusColor ??
                                (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xff2176FF).withValues(
                                      alpha: 0.2,
                                    ) // Reduced transparency
                                    : const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ).withValues(alpha: 0.2))
                            : null,
                  ),
                  child: Text(
                    text.isEmpty ? label : text.padLeft(maxLength, '0'),
                    style: defaultTextStyle,
                  ),
                ),
                Text(dateSeparator[order], style: defaultTextStyle),
              ],
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: Center(
              child: SizedBox(
                width: 0,
                height: 0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  enableInteractiveSelection: false,
                  enableSuggestions: false,
                  autofocus: widget.autofocus && fieldType == fieldOrder.first,
                  decoration: const InputDecoration(
                    isDense: true,
                    counterText: '',
                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                  ),
                  onChanged: (value) {
                    if (text.length > value.length) {
                      fieldTexts[fieldType] = "";
                      controller.clear();
                    } else {
                      if (value.length > maxLength) {
                        value = value.substring(maxLength, value.length);
                      }

                      if (BirthPickerUtil.isInteger(value)) {
                        var (
                          correctedValue,
                          moveNext,
                        ) = BirthPickerUtil.checkDateFormat(fieldType, value);

                        fieldTexts[fieldType] = correctedValue;

                        if (moveNext) {
                          _moveFocusToNextField(fieldType);
                        }
                        controller.text = correctedValue;
                      } else {
                        controller.text = text;
                      }
                    }
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => keyboardEventFocusNode.unfocus(),
      child: GestureDetector(
        onTap: () => _requestFocus(fieldOrder.first),
        child: KeyboardListener(
          focusNode: keyboardEventFocusNode,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              _handleKeyEvent(event);
            }
          },
          child: Container(
            decoration: widget.decoration,
            padding:
                widget.padding ??
                const EdgeInsets.only(top: 2, bottom: 2, left: 18, right: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child:
                      _isDateEmpty
                          ? Text(
                            'Data de Nascimento',
                            style:
                                widget.textStyle?.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ) ??
                                TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: 16,
                                ),
                          )
                          : Row(
                            children:
                                fieldOrder
                                    .map((field) => _buildField(context, field))
                                    .toList(),
                          ),
                ),
                IconButton(
                  onPressed: () async {
                    keyboardEventFocusNode.unfocus();
                    await Future.delayed(Duration.zero);
                    if (context.mounted) {
                      DateTime? selectedDate = await _showPlatformDatePicker(
                        context,
                      );
                      if (selectedDate != null) {
                        _setSelectedDate(selectedDate);
                      }
                    }
                  },
                  iconSize: widget.iconSize,
                  color: widget.iconColor,
                  icon: widget.icon ?? Icon(Icons.calendar_today_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _showPlatformDatePicker(BuildContext context) async {
    DateTime initialDate = _getDate() ?? DateTime.now();
    DateTime firstDate = DateTime(1, 1, 1);
    DateTime lastDate = DateTime(9999, 12, 31);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _showDialog(
        CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: initialDate,
          minimumDate: firstDate,
          maximumDate: lastDate,
          onDateTimeChanged: (DateTime date) {
            _setSelectedDate(date);
          },
        ),
      );
    } else {
      return await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    }
    return null;
  }

  Future<void> _showDialog(Widget child) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(top: false, child: child),
          ),
    );
  }

  void _setSelectedDate(DateTime selectedDate) {
    controllers['year']!.text = selectedDate.year.toString().padLeft(4, '0');
    controllers['month']!.text = selectedDate.month.toString().padLeft(2, '0');
    controllers['day']!.text = selectedDate.day.toString().padLeft(2, '0');
    fieldTexts['year'] = controllers['year']!.text;
    fieldTexts['month'] = controllers['month']!.text;
    fieldTexts['day'] = controllers['day']!.text;
    setState(() {});
  }

  void _moveFocusToNextField(String currentField) {
    final currentIndex = fieldOrder.indexOf(currentField);
    if (currentIndex < fieldOrder.length - 1) {
      _requestFocus(fieldOrder[currentIndex + 1]);
    } else {
      focusNodes[currentField]!.unfocus();
    }
  }

  void _requestFocus(String fieldType) {
    focusNodes[fieldType]!.requestFocus();
  }

  @override
  void dispose() {
    keyboardEventFocusNode.dispose();
    for (var controller in controllers.values) {
      controller.dispose();
    }
    for (var focusNode in focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
