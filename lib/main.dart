import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _clearAll();
      } else if (value == '⌫') {
        _backspace();
      } else if (value == '+' || value == '-' || value == '×' || value == '÷') {
        _setOperator(value);
      } else if (value == '=') {
        _calculateResult();
      } else if (value == '.') {
        _appendDecimal();
      } else {
        _appendDigit(value);
      }
    });
  }

  void _clearAll() {
    _display = '0';
    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = false;
  }

  void _backspace() {
    if (_shouldResetDisplay || _display == 'Error') {
      _clearAll();
      return;
    }
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
  }

  void _appendDigit(String digit) {
    if (_display == 'Error' || _shouldResetDisplay) {
      _display = digit;
      _shouldResetDisplay = false;
      return;
    }
    if (_display == '0') {
      _display = digit;
    } else {
      _display += digit;
    }
  }

  void _appendDecimal() {
    if (_display == 'Error' || _shouldResetDisplay) {
      _display = '0.';
      _shouldResetDisplay = false;
      return;
    }
    if (!_display.contains('.')) {
      _display += '.';
    }
  }

  void _setOperator(String nextOperator) {
    if (_display == 'Error') return;

    final currentValue = double.tryParse(_display);
    if (currentValue == null) return;

    if (_firstOperand == null) {
      _firstOperand = currentValue;
    } else if (!_shouldResetDisplay && _operator != null) {
      _calculateResult(keepOperator: true);
      if (_display == 'Error') return;
      _firstOperand = double.tryParse(_display);
    }

    _operator = nextOperator;
    _shouldResetDisplay = true;
  }

  void _calculateResult({bool keepOperator = false}) {
    if (_firstOperand == null || _operator == null || _display == 'Error') {
      return;
    }

    final secondOperand = double.tryParse(_display);
    if (secondOperand == null) return;

    double result;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case '×':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
        if (secondOperand == 0) {
          _display = 'Error';
          _firstOperand = null;
          _operator = null;
          _shouldResetDisplay = true;
          return;
        }
        result = _firstOperand! / secondOperand;
        break;
      default:
        return;
    }

    _display = _formatNumber(result);
    if (!keepOperator) {
      _firstOperand = null;
      _operator = null;
    }
    _shouldResetDisplay = true;
  }

  String _formatNumber(double value) {
    if (value.isInfinite || value.isNaN) return 'Error';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    // Trim trailing zeros for cleaner decimal display
    return value.toStringAsFixed(8).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Widget _buildCalcButton(
    String label, {
    Color? backgroundColor,
    Color? textColor,
    int flex = 1,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.surfaceContainerHigh;
    final fg = textColor ?? scheme.onSurface;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: FilledButton(
          onPressed: () => _onButtonPressed(label),
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expressionHint = _firstOperand != null && _operator != null
        ? '${_formatNumber(_firstOperand!)} $_operator'
        : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Calculator'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (expressionHint.isNotEmpty)
                      Text(
                        expressionHint,
                        style: TextStyle(
                          fontSize: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildCalcButton(
                        'C',
                        backgroundColor: scheme.errorContainer,
                        textColor: scheme.onErrorContainer,
                      ),
                      _buildCalcButton(
                        '⌫',
                        backgroundColor: scheme.secondaryContainer,
                        textColor: scheme.onSecondaryContainer,
                      ),
                      _buildCalcButton(
                        '÷',
                        backgroundColor: scheme.primaryContainer,
                        textColor: scheme.onPrimaryContainer,
                      ),
                      _buildCalcButton(
                        '×',
                        backgroundColor: scheme.primaryContainer,
                        textColor: scheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalcButton('7'),
                      _buildCalcButton('8'),
                      _buildCalcButton('9'),
                      _buildCalcButton(
                        '-',
                        backgroundColor: scheme.primaryContainer,
                        textColor: scheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalcButton('4'),
                      _buildCalcButton('5'),
                      _buildCalcButton('6'),
                      _buildCalcButton(
                        '+',
                        backgroundColor: scheme.primaryContainer,
                        textColor: scheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalcButton('1'),
                      _buildCalcButton('2'),
                      _buildCalcButton('3'),
                      _buildCalcButton(
                        '=',
                        backgroundColor: scheme.primary,
                        textColor: scheme.onPrimary,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalcButton('0', flex: 2),
                      _buildCalcButton('.'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
