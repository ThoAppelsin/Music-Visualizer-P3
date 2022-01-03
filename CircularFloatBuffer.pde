class CircularDoubleBuffer {
  double buffer[];
  private int head;
  final int size;
  double runningAverage = 0;
  double runningVariance = 0;
  
  CircularDoubleBuffer(int size) {
    this.size = size;
    buffer = new double[size];
    head = size - 1;
  }
  
  // Get normalized
  double getNorm(int index) {
    double x = get(index);
    double mu = MathTools.logit(MathTools.cap(runningAverage, Parameters.Normalizing.space, 1 - Parameters.Normalizing.space));
    return (1 + MathTools.erf((MathTools.logit(x) - mu) / 1.4142135623730950488016887242097 / Parameters.Normalizing.stdev)) / 2;
  }
  
  // Get standardized
  double getStd(int index) {
    double x = get(index);
    return (x - runningAverage) / Math.max(Math.sqrt(runningVariance), 0.0001);
  }
  
  // Note that the higher the index the older is the record.
  double get(int index) {
    return buffer[(head - index + size) % size]; 
  }
  
  void add(double value) {
    head = (head + 1) % size;
    buffer[head] = value;
    runningAverage = runningAverage * Parameters.Normalizing.averageFactor + value * (1 - Parameters.Normalizing.averageFactor);
    
    double delta = value - runningAverage;
    runningVariance = runningVariance * Parameters.Standardizing.varianceFactor + delta * delta * (1 - Parameters.Standardizing.varianceFactor);
  }
  
  boolean greaterThan(double[] thresholds) {
    for (int i = 0; i < thresholds.length; i++)
      if (get(i) <= thresholds[i])
        return false;
    return true;
  }
  
  boolean greaterThanStd(double[] thresholds) {
    for (int i = 0; i < thresholds.length; i++)
      if (getStd(i) <= thresholds[i])
        return false;
    return true;
  }
  
  boolean greaterThanNorm(double[] thresholds) {
    for (int i = 0; i < thresholds.length; i++)
      if (getNorm(i) <= thresholds[i])
        return false;
    return true;
  }
  
  boolean devianceGreaterThan(double[] thresholds) {
    for (int i = 0; i < thresholds.length; i++)
      if (get(i) - runningAverage <= thresholds[i])
        return false;
    return true;
  }
  
  boolean derivativeGreaterThan(double[] thresholds) {
    double current = get(0);
    for (int i = 0; i < thresholds.length; i++) {
      double past = get(i + 1);
      if (current - past <= thresholds[i])
        return false;
      current = past;
    }
    return true;
  }
  
  boolean derivativeGreaterThanStd(double[] thresholds) {
    double current = getStd(0);
    for (int i = 0; i < thresholds.length; i++) {
      double past = getStd(i + 1);
      if (current - past <= thresholds[i])
        return false;
      current = past;
    }
    return true;
  }
  
  double average() {
    double sum = 0;
    for (int i = 0; i < size; i++) {
      sum += buffer[i];
    }
    return sum / size;
  }
}
