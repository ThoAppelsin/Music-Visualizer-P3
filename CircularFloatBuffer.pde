class CircularDoubleBuffer {
  double buffer[];
  private int head;
  final int size;
  double runningAverage = 0;
  
  CircularDoubleBuffer(int size) {
    this.size = size;
    buffer = new double[size];
    head = size - 1;
  }
  
  // Note that the higher the index the older is the record.
  double get(int index) {
    return buffer[(head - index + size) % size]; 
  }
  
  void add(double value) {
    head = (head + 1) % size;
    buffer[head] = value;
    runningAverage = runningAverage * 0.9 + value * 0.1;
  }
  
  double peek() {
    return buffer[head];
  }
  
  boolean greaterThan(double[] thresholds) {
    for (int i = 0; i < thresholds.length; i++)
      if (get(i) <= thresholds[i])
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
    double current = peek();
    for (int i = 0; i < thresholds.length; i++) {
      double past = get(i + 1);
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
