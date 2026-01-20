import 'package:serverpod/serverpod.dart';
import '../generated/portfolio.dart';

/// Endpoint for portfolio operations.
class PortfolioEndpoint extends Endpoint {
  /// Returns all portfolios.
  Future<List<Portfolio>> getPortfolios(Session session) async {
    return await Portfolio.db.find(
      session,
      orderBy: (t) => t.name,
    );
  }
}
