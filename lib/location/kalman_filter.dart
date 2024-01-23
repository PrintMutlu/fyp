import 'package:fyp_new/location/position.dart';

class KalmanFilter {
  double _lastEstimateX = 0.0, _lastEstimateY = 0.0, _errorEstimate = 1.0, _errorMeasure = 0.085, _q = 0.075;

  KalmanFilter() {
    _lastEstimateX = 0.0;
    _lastEstimateY = 0.0;
    _errorEstimate = 1.0;
    _errorMeasure = 0.085;
    _q = 0.075;
  }
  Position update(Position measurement) {
    double kalmanGain = _errorEstimate / (_errorEstimate + _errorMeasure);
    _lastEstimateX = _lastEstimateX + kalmanGain * (measurement.x - _lastEstimateX);
    _lastEstimateY = _lastEstimateY + kalmanGain * (measurement.y - _lastEstimateY);
    _errorEstimate = (1.0 - kalmanGain) * _errorEstimate +
        (_q * (_lastEstimateX - measurement.x).abs());
    _errorMeasure = (1.0 - kalmanGain) * _errorMeasure +
        (_q * (_lastEstimateY - measurement.y).abs());
    return Position(_lastEstimateX, _lastEstimateY);
  }
}
