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
import 'package:serverpod/serverpod.dart' as _i1;
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../endpoints/holdings_endpoint.dart' as _i4;
import '../endpoints/portfolio_endpoint.dart' as _i5;
import '../endpoints/valuation_endpoint.dart' as _i6;
import 'package:bagholdr_server/src/generated/return_period.dart' as _i7;
import 'package:bagholdr_server/src/generated/chart_range.dart' as _i8;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i9;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i10;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'holdings': _i4.HoldingsEndpoint()
        ..initialize(
          server,
          'holdings',
          null,
        ),
      'portfolio': _i5.PortfolioEndpoint()
        ..initialize(
          server,
          'portfolio',
          null,
        ),
      'valuation': _i6.ValuationEndpoint()
        ..initialize(
          server,
          'valuation',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['holdings'] = _i1.EndpointConnector(
      name: 'holdings',
      endpoint: endpoints['holdings']!,
      methodConnectors: {
        'getHoldings': _i1.MethodConnector(
          name: 'getHoldings',
          params: {
            'portfolioId': _i1.ParameterDescription(
              name: 'portfolioId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'period': _i1.ParameterDescription(
              name: 'period',
              type: _i1.getType<_i7.ReturnPeriod>(),
              nullable: false,
            ),
            'sleeveId': _i1.ParameterDescription(
              name: 'sleeveId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'search': _i1.ParameterDescription(
              name: 'search',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['holdings'] as _i4.HoldingsEndpoint).getHoldings(
                    session,
                    portfolioId: params['portfolioId'],
                    period: params['period'],
                    sleeveId: params['sleeveId'],
                    search: params['search'],
                    offset: params['offset'],
                    limit: params['limit'],
                  ),
        ),
      },
    );
    connectors['portfolio'] = _i1.EndpointConnector(
      name: 'portfolio',
      endpoint: endpoints['portfolio']!,
      methodConnectors: {
        'getPortfolios': _i1.MethodConnector(
          name: 'getPortfolios',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['portfolio'] as _i5.PortfolioEndpoint)
                  .getPortfolios(session),
        ),
      },
    );
    connectors['valuation'] = _i1.EndpointConnector(
      name: 'valuation',
      endpoint: endpoints['valuation']!,
      methodConnectors: {
        'getPortfolioValuation': _i1.MethodConnector(
          name: 'getPortfolioValuation',
          params: {
            'portfolioId': _i1.ParameterDescription(
              name: 'portfolioId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['valuation'] as _i6.ValuationEndpoint)
                  .getPortfolioValuation(
                    session,
                    params['portfolioId'],
                  ),
        ),
        'getChartData': _i1.MethodConnector(
          name: 'getChartData',
          params: {
            'portfolioId': _i1.ParameterDescription(
              name: 'portfolioId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'range': _i1.ParameterDescription(
              name: 'range',
              type: _i1.getType<_i8.ChartRange>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['valuation'] as _i6.ValuationEndpoint)
                  .getChartData(
                    session,
                    params['portfolioId'],
                    params['range'],
                  ),
        ),
        'getHistoricalReturns': _i1.MethodConnector(
          name: 'getHistoricalReturns',
          params: {
            'portfolioId': _i1.ParameterDescription(
              name: 'portfolioId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['valuation'] as _i6.ValuationEndpoint)
                  .getHistoricalReturns(
                    session,
                    params['portfolioId'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i9.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i10.Endpoints()
      ..initializeEndpoints(server);
  }
}
