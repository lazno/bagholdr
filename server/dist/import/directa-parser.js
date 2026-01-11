/**
 * Directa CSV Parser
 *
 * Parses CSV exports from Directa broker.
 *
 * Format:
 * - First 10 lines are header metadata
 * - Line 1 contains account name: "ACCOUNT : C6766 Lazzeri Norbert"
 * - Line 10 contains column headers
 * - Data starts at line 11
 * - 12 columns per row
 * - Date format: DD-MM-YYYY
 */
/**
 * Convert DD-MM-YYYY to ISO format YYYY-MM-DD
 */
function convertItalianDate(dateStr) {
    const trimmed = dateStr.trim();
    const parts = trimmed.split('-');
    if (parts.length !== 3)
        return null;
    const [day, month, year] = parts;
    if (day.length !== 2 || month.length !== 2 || year.length !== 4) {
        return null;
    }
    return `${year}-${month}-${day}`;
}
/**
 * Extract account name from header line
 * Format: "ACCOUNT : C6766 Lazzeri Norbert"
 */
function extractAccountName(headerLine) {
    const match = headerLine.match(/:\s*(\w+)\s/);
    return match ? match[1] : null;
}
/**
 * Parse a single CSV line, handling quoted fields
 */
function parseCSVLine(line) {
    const result = [];
    let current = '';
    let inQuotes = false;
    for (let i = 0; i < line.length; i++) {
        const char = line[i];
        if (char === '"') {
            inQuotes = !inQuotes;
        }
        else if (char === ',' && !inQuotes) {
            result.push(current.trim());
            current = '';
        }
        else {
            current += char;
        }
    }
    result.push(current.trim());
    return result;
}
/**
 * Parse number from string, handling European decimal format
 */
function parseNumber(value) {
    const trimmed = value.trim();
    if (!trimmed || trimmed === '')
        return 0;
    // Handle European format (comma as decimal separator)
    // But Directa seems to use period as decimal separator
    const num = parseFloat(trimmed);
    return isNaN(num) ? 0 : num;
}
/**
 * Check if this is a Buy or Sell transaction type
 */
function isBuyOrSell(type) {
    return type === 'Buy' || type === 'Sell';
}
/**
 * Parse Directa CSV content
 */
export function parseDirectaCSV(content) {
    const lines = content.split('\n').filter((line) => line.trim() !== '');
    if (lines.length < 11) {
        return {
            accountName: '',
            orders: [],
            skippedRows: 0,
            errors: [{ line: 0, message: 'File too short - expected at least 11 lines' }]
        };
    }
    // Extract account name from first line
    const accountName = extractAccountName(lines[0]) ?? 'Unknown';
    const orders = [];
    const errors = [];
    let skippedRows = 0;
    // Data starts at line 11 (index 10)
    for (let i = 10; i < lines.length; i++) {
        const line = lines[i];
        const lineNumber = i + 1; // Human-readable line number
        try {
            const parts = parseCSVLine(line);
            if (parts.length < 12) {
                errors.push({
                    line: lineNumber,
                    message: `Invalid column count: expected 12, got ${parts.length}`
                });
                continue;
            }
            const [transactionDateRaw, , // valueDate - not used
            transactionType, ticker, isin, , // protocol - not used
            description, quantityRaw, amountEurRaw, currencyAmountRaw, currency, orderReference] = parts;
            // Skip non-Buy/Sell transactions
            if (!isBuyOrSell(transactionType)) {
                skippedRows++;
                continue;
            }
            // Parse and validate date
            const isoDate = convertItalianDate(transactionDateRaw);
            if (!isoDate) {
                errors.push({
                    line: lineNumber,
                    message: `Invalid date format: ${transactionDateRaw}`
                });
                continue;
            }
            // Skip rows without ISIN (shouldn't happen for Buy/Sell)
            if (!isin || isin.trim() === '') {
                errors.push({
                    line: lineNumber,
                    message: 'Missing ISIN'
                });
                continue;
            }
            const quantity = parseNumber(quantityRaw);
            const amountEur = parseNumber(amountEurRaw);
            const currencyAmount = parseNumber(currencyAmountRaw);
            orders.push({
                isin: isin.trim(),
                ticker: ticker.trim(),
                name: description.trim(),
                transactionDate: new Date(isoDate),
                transactionType,
                quantity: transactionType === 'Buy' ? Math.abs(quantity) : -Math.abs(quantity),
                amountEur: Math.abs(amountEur),
                currencyAmount: Math.abs(currencyAmount),
                currency: currency.trim() || 'EUR',
                orderReference: orderReference.trim()
            });
        }
        catch (err) {
            errors.push({
                line: lineNumber,
                message: `Parse error: ${err instanceof Error ? err.message : 'Unknown error'}`
            });
        }
    }
    return {
        accountName,
        orders,
        skippedRows,
        errors
    };
}
