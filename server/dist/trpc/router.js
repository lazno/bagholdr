import { router } from './trpc';
import { portfoliosRouter } from './routers/portfolios';
import { assetsRouter } from './routers/assets';
import { holdingsRouter } from './routers/holdings';
import { importRouter } from './routers/import';
import { oracleRouter } from './routers/oracle';
import { sleevesRouter } from './routers/sleeves';
import { valuationRouter } from './routers/valuation';
import { rulesRouter } from './routers/rules';
import { cashRouter } from './routers/cash';
export const appRouter = router({
    portfolios: portfoliosRouter,
    assets: assetsRouter,
    holdings: holdingsRouter,
    import: importRouter,
    oracle: oracleRouter,
    sleeves: sleevesRouter,
    valuation: valuationRouter,
    rules: rulesRouter,
    cash: cashRouter
});
