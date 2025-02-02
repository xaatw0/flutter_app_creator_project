import 'dart:async';

abstract interface class IAgent<TRequest, TResponse> {
  Future<AResponse<TResponse>> execute(ARequest<TRequest> request);
}

class ARequest<TRequest> {
  const ARequest(this._value);
  final TRequest _value;
  TRequest call() => _value;
}

class AResponse<TResponse> {
  const AResponse(this._value);
  final TResponse _value;
  TResponse call() => _value;
}
