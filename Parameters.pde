static class Parameters {
  static class Flocking {
    static float cohesionPower = 1, separationPower = 3, alignPower = 4, speedMultiplier = 0.75;
  }
  static class Normalizing {
    static double averageFactor = 0.9;
    static double recentFactor = 0.1;
    static double stdev = 1;
    static double space = 0.05;
  }
  static class Standardizing {
    static double varianceFactor = 0.9;
  }
  
  static PImage img;
}
