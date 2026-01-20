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
export type DirectaTransactionType = 'Buy' | 'Sell' | 'Commissions' | 'Wire transfer payment' | 'Cap.gain tax' | 'Portfolio stamp duty*' | 'Etf withholding tax' | 'Bond accrd int wd' | 'Bond accrd int wd tax' | 'Bonds coupon pmt' | 'Bonds coupon tax' | 'Bond accrd int pmt' | 'Bond accrd int pmt tax' | 'Disagio debt w/t' | 'Disagio credit w/t';
export interface DirectaRow {
    transactionDate: string;
    valueDate: string;
    transactionType: string;
    ticker: string;
    isin: string;
    protocol: string;
    description: string;
    quantity: number;
    amountEur: number;
    currencyAmount: number;
    currency: string;
    orderReference: string;
}
export interface ParsedOrder {
    isin: string;
    ticker: string;
    name: string;
    transactionDate: Date;
    transactionType: 'Buy' | 'Sell' | 'Commission';
    quantity: number;
    amountEur: number;
    currencyAmount: number;
    currency: string;
    orderReference: string;
}
export interface DirectaParseResult {
    accountName: string;
    orders: ParsedOrder[];
    skippedRows: number;
    errors: Array<{
        line: number;
        message: string;
    }>;
}
/**
 * Parse Directa CSV content
 */
export declare function parseDirectaCSV(content: string): DirectaParseResult;
