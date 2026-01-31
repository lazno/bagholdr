/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// PortfolioAccount - Junction table linking portfolios to accounts
/// Enables portfolios to aggregate multiple accounts for multi-broker views
abstract class PortfolioAccount implements _i1.SerializableModel {
  PortfolioAccount._({
    this.id,
    required this.portfolioId,
    required this.accountId,
  });

  factory PortfolioAccount({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    required _i1.UuidValue accountId,
  }) = _PortfolioAccountImpl;

  factory PortfolioAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return PortfolioAccount(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      portfolioId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['portfolioId'],
      ),
      accountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Reference to the portfolio (UUID)
  _i1.UuidValue portfolioId;

  /// Reference to the account (UUID)
  _i1.UuidValue accountId;

  /// Returns a shallow copy of this [PortfolioAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PortfolioAccount copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? portfolioId,
    _i1.UuidValue? accountId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PortfolioAccount',
      if (id != null) 'id': id?.toJson(),
      'portfolioId': portfolioId.toJson(),
      'accountId': accountId.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PortfolioAccountImpl extends PortfolioAccount {
  _PortfolioAccountImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    required _i1.UuidValue accountId,
  }) : super._(
         id: id,
         portfolioId: portfolioId,
         accountId: accountId,
       );

  /// Returns a shallow copy of this [PortfolioAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PortfolioAccount copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? portfolioId,
    _i1.UuidValue? accountId,
  }) {
    return PortfolioAccount(
      id: id is _i1.UuidValue? ? id : this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      accountId: accountId ?? this.accountId,
    );
  }
}
