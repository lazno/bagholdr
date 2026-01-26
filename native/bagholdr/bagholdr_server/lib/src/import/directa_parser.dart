/// Directa CSV Parser
///
/// Parses CSV exports from Directa broker.
///
/// Format:
/// - First 10 lines are header metadata
/// - Line 1 contains account name: "ACCOUNT : C6766 Lazzeri Norbert"
/// - Line 10 contains column headers
/// - Data starts at line 11
/// - 12 columns per row
/// - Date format: DD-MM-YYYY

/// Transaction types we import
enum DirectaTransactionType {
  buy,
  sell,
  commission,
}

/// Parsed order from CSV row
class ParsedOrder {
  final String isin;
  final String ticker;
  final String name;
  final DateTime transactionDate;
  final DirectaTransactionType transactionType;
  final double quantity;
  final double amountEur;
  final double currencyAmount;
  final String currency;
  final String orderReference;

  const ParsedOrder({
    required this.isin,
    required this.ticker,
    required this.name,
    required this.transactionDate,
    required this.transactionType,
    required this.quantity,
    required this.amountEur,
    required this.currencyAmount,
    required this.currency,
    required this.orderReference,
  });

  @override
  String toString() =>
      'ParsedOrder(isin: $isin, type: $transactionType, qty: $quantity, amountEur: $amountEur)';
}

/// Parse error with line number
class ParseError {
  final int line;
  final String message;

  const ParseError({required this.line, required this.message});

  @override
  String toString() => 'Line $line: $message';
}

/// Result of parsing Directa CSV
class DirectaParseResult {
  final String accountName;
  final List<ParsedOrder> orders;
  final int skippedRows;
  final List<ParseError> errors;

  const DirectaParseResult({
    required this.accountName,
    required this.orders,
    required this.skippedRows,
    required this.errors,
  });
}

/// Convert DD-MM-YYYY to ISO format YYYY-MM-DD
String? convertItalianDate(String dateStr) {
  final trimmed = dateStr.trim();
  final parts = trimmed.split('-');

  if (parts.length != 3) return null;

  final day = parts[0];
  final month = parts[1];
  final year = parts[2];

  if (day.length != 2 || month.length != 2 || year.length != 4) {
    return null;
  }

  return '$year-$month-$day';
}

/// Extract account name from header line
/// Format: "ACCOUNT : C6766 Lazzeri Norbert"
String? extractAccountName(String headerLine) {
  final match = RegExp(r':\s*(\w+)\s').firstMatch(headerLine);
  return match?.group(1);
}

/// Parse a single CSV line, handling quoted fields
List<String> parseCSVLine(String line) {
  final result = <String>[];
  var current = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];

    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(current.toString().trim());
      current = StringBuffer();
    } else {
      current.write(char);
    }
  }

  result.add(current.toString().trim());
  return result;
}

/// Parse number from string
/// Directa uses period as decimal separator
double parseNumber(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 0;

  final num = double.tryParse(trimmed);
  return num ?? 0;
}

/// Check if this is a transaction type we want to import
bool isImportableTransaction(String type) {
  return type == 'Buy' || type == 'Sell' || type == 'Commissions';
}

/// Map CSV transaction type to our internal type
DirectaTransactionType? mapTransactionType(String type) {
  switch (type) {
    case 'Buy':
      return DirectaTransactionType.buy;
    case 'Sell':
      return DirectaTransactionType.sell;
    case 'Commissions':
      return DirectaTransactionType.commission;
    default:
      return null;
  }
}

/// Parse Directa CSV content
DirectaParseResult parseDirectaCSV(String content) {
  final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();

  if (lines.length < 11) {
    return DirectaParseResult(
      accountName: '',
      orders: [],
      skippedRows: 0,
      errors: [
        const ParseError(line: 0, message: 'File too short - expected at least 11 lines'),
      ],
    );
  }

  // Extract account name from first line
  final accountName = extractAccountName(lines[0]) ?? 'Unknown';

  final orders = <ParsedOrder>[];
  final errors = <ParseError>[];
  var skippedRows = 0;

  // Data starts at line 11 (index 10)
  for (var i = 10; i < lines.length; i++) {
    final line = lines[i];
    final lineNumber = i + 1; // Human-readable line number

    try {
      final parts = parseCSVLine(line);

      if (parts.length < 12) {
        errors.add(ParseError(
          line: lineNumber,
          message: 'Invalid column count: expected 12, got ${parts.length}',
        ));
        continue;
      }

      final transactionDateRaw = parts[0];
      // parts[1] = valueDate - not used
      final transactionTypeRaw = parts[2];
      final ticker = parts[3];
      final isin = parts[4];
      // parts[5] = protocol - not used
      final description = parts[6];
      final quantityRaw = parts[7];
      final amountEurRaw = parts[8];
      final currencyAmountRaw = parts[9];
      final currency = parts[10];
      final orderReference = parts[11];

      // Skip transactions we don't want to import
      if (!isImportableTransaction(transactionTypeRaw)) {
        skippedRows++;
        continue;
      }

      // Parse and validate date
      final isoDate = convertItalianDate(transactionDateRaw);
      if (isoDate == null) {
        errors.add(ParseError(
          line: lineNumber,
          message: 'Invalid date format: $transactionDateRaw',
        ));
        continue;
      }

      // Skip rows without ISIN (shouldn't happen for Buy/Sell/Commission)
      if (isin.trim().isEmpty) {
        errors.add(ParseError(
          line: lineNumber,
          message: 'Missing ISIN',
        ));
        continue;
      }

      final quantity = parseNumber(quantityRaw);
      final amountEur = parseNumber(amountEurRaw);
      final currencyAmount = parseNumber(currencyAmountRaw);

      // Map transaction type and determine quantity sign
      final mappedType = mapTransactionType(transactionTypeRaw)!;
      double finalQuantity;
      if (mappedType == DirectaTransactionType.buy) {
        finalQuantity = quantity.abs();
      } else if (mappedType == DirectaTransactionType.sell) {
        finalQuantity = -quantity.abs();
      } else {
        // Commission: quantity is 0
        finalQuantity = 0;
      }

      orders.add(ParsedOrder(
        isin: isin.trim(),
        ticker: ticker.trim(),
        name: description.trim(),
        transactionDate: DateTime.parse(isoDate),
        transactionType: mappedType,
        quantity: finalQuantity,
        amountEur: amountEur.abs(),
        currencyAmount: currencyAmount.abs(),
        currency: currency.trim().isEmpty ? 'EUR' : currency.trim(),
        orderReference: orderReference.trim(),
      ));
    } catch (e) {
      errors.add(ParseError(
        line: lineNumber,
        message: 'Parse error: $e',
      ));
    }
  }

  return DirectaParseResult(
    accountName: accountName,
    orders: orders,
    skippedRows: skippedRows,
    errors: errors,
  );
}
