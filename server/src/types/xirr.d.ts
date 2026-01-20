declare module 'xirr' {
	interface Transaction {
		amount: number;
		when: Date;
	}

	interface Options {
		guess?: number;
		[key: string]: unknown;
	}

	function xirr(transactions: Transaction[], options?: Options): number;

	export = xirr;
}
