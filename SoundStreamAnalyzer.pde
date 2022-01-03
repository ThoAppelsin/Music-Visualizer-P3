import processing.sound.*;

class SoundStreamAnalyzer {
  PApplet parent;
  FFT fft;
  float[] spectrum;
  int sampleRate = 48000;
  int nyquist = sampleRate / 2;
  
  int stressedRange = -1;
  private final double   stressPreservingNormStressAverage = 0.2;
  private final double[] stressPreservingStdDifferences = new double[]{.05, .05};
  private final double[] stressPreservingNormEnergy = new double[]{.35, .35};
  
  private final double   stressRelievingNormStressAverage = 0.15;
  private final double[] stressRelievingStdDifferences = new double[]{-1, -1};
  private final double[] stressRelievingNormEnergy = new double[]{.2, .2, .2};
  
  private final double[] stressInitiatingStdDerivativeDifferences3 = new double[]{.7, .7};
  private final double[] stressInitiatingStdDerivativeDifferences2 = new double[]{1};
  private final double stressInitiatingStdDifference2 = .05;
  private final double stressInitiatingStdDifference1 = .9;
  private final double stressInitiatingStdDifference0 = 2.7;
  boolean actionPotential = false;
  
  FrequencyRangeAnalyzer[] fras;
  
  class FrequencyRangeAnalyzer {
    CircularDoubleBuffer energyLog;
    CircularDoubleBuffer energyDifferences;
    
    boolean stressed = false;
    boolean actionPotential = false;
    
    double runningNormStressAverage = 0;
    
    int lowFreq, highFreq;
    
    FrequencyRangeAnalyzer(int lowFreq, int highFreq) {
      energyLog = new CircularDoubleBuffer(16);
      energyDifferences = new CircularDoubleBuffer(energyLog.size);
      
      this.lowFreq = lowFreq;
      this.highFreq = highFreq;
    }
    
    void update() {
      double currentEnergy = getEnergyNormalized(lowFreq, highFreq);
      double energyDiff = currentEnergy - energyLog.get(0);
      energyLog.add(currentEnergy);
      energyDifferences.add(energyDiff);
      
      
      actionPotential = false;
      
      if (stressed) {
        runningNormStressAverage = 0.98 * runningNormStressAverage + 0.02 * energyLog.getNorm(0);
        int stressLevel = (runningNormStressAverage > stressPreservingNormStressAverage ? 1 : 0)
                        + (energyDifferences.greaterThanStd(stressPreservingStdDifferences) ? 1 : 0)
                        + (energyLog.greaterThanNorm(stressPreservingNormEnergy) ? 1 : 0)
                        
                        + (runningNormStressAverage > stressRelievingNormStressAverage ? 0 : -1)
                        + (energyDifferences.greaterThanStd(stressRelievingStdDifferences) ? 0 : -1)
                        + (energyLog.greaterThanNorm(stressRelievingNormEnergy) ? 0 : -1);
        println("stress pres",
                runningNormStressAverage > stressPreservingNormStressAverage ? "x" : ".",
                energyDifferences.greaterThanStd(stressPreservingStdDifferences) ? "x" : ".",
                energyLog.greaterThanNorm(stressPreservingNormEnergy) ? "x" : ".",
                runningNormStressAverage > stressRelievingNormStressAverage ? "x" : ".",
                energyDifferences.greaterThanStd(stressRelievingStdDifferences) ? "x" : ".",
                energyLog.greaterThanNorm(stressRelievingNormEnergy) ? "x" : ".");
        if (stressLevel < 0) {
          stressed = false;
          // println("stress down");
        }
      }
      else if ((energyDifferences.derivativeGreaterThanStd(stressInitiatingStdDerivativeDifferences3) && energyDifferences.getStd(2) > stressInitiatingStdDifference2) ||
               (energyDifferences.derivativeGreaterThanStd(stressInitiatingStdDerivativeDifferences2) && energyDifferences.getStd(1) > stressInitiatingStdDifference1) ||
               (energyDifferences.getStd(0) > stressInitiatingStdDifference0)) {
        stressed = true;
        actionPotential = true;
        runningNormStressAverage = energyLog.getNorm(0);
        println("action potential",
                runningNormStressAverage,
                energyDifferences.derivativeGreaterThanStd(stressInitiatingStdDerivativeDifferences3) ? "x" : ".",
                energyDifferences.getStd(2) > stressInitiatingStdDifference2 ? "x" : ".",
                energyDifferences.derivativeGreaterThanStd(stressInitiatingStdDerivativeDifferences2) ? "x" : ".",
                energyDifferences.getStd(1) > stressInitiatingStdDifference1 ? "x" : ".",
                energyDifferences.getStd(0) > stressInitiatingStdDifference0 ? "x" : ".");
      }
    }
  }
  
  SoundStreamAnalyzer(PApplet parent, AudioIn audioIn) {
    this.parent = parent;
    fft = new FFT(parent, 1024);
    
    // start the Audio Input
    audioIn.start();
  
    // patch the AudioIn
    fft.input(audioIn);
    
    fras = new FrequencyRangeAnalyzer[] {
      new FrequencyRangeAnalyzer(20, 140),
      new FrequencyRangeAnalyzer(140, 400),
      new FrequencyRangeAnalyzer(400, 2600),
      new FrequencyRangeAnalyzer(2600, 5200),
      new FrequencyRangeAnalyzer(5200, 14000)
    };
  }
  
  void update() {
    spectrum = fft.analyze();
    
    for (FrequencyRangeAnalyzer fra : fras) {
      fra.update();
    }
    
    actionPotential = false;
    
    if (stressedRange >= 0) {
      // println(stressedRange);
      if (!fras[stressedRange].stressed) {
        stressedRange = -1;
      }
      else {
        //println(fras[stressedRange].energyLog.runningAverage);
        //println(fras[stressedRange].energyLog.buffer);
        //println(fras[stressedRange].energyDifferences.buffer);
      }
    }
    
    if (stressedRange == -1) {
      for (int i = 0; i < fras.length; i++) {
        if (fras[i].actionPotential) {
          stressedRange = i;
          actionPotential = true;
          break;
        }
      }
    }
  }
  
  double getEnergy(int low, int high) {
    int lowIndex = max(round(spectrum.length * low / nyquist), 1);
    int highIndex = round(spectrum.length * high / nyquist) - 1;
    
    double energy = 0;
    for (int i = lowIndex; i <= highIndex; i++) {
      energy += spectrum[i];
    }
    
    return energy;
  }
  
  double getEnergyNormalized(int low, int high) {
    int lowIndex = max(round(spectrum.length * low / nyquist), 1);
    int highIndex = round(spectrum.length * high / nyquist) - 1;
    
    return getEnergy(low, high) / (highIndex - lowIndex + 1);
  }
}
