import processing.sound.*;

class SoundStreamAnalyzer {
  PApplet parent;
  FFT fft;
  float[] spectrum;
  int sampleRate = 48000;
  int nyquist = sampleRate / 2;
  
  int stressedRange = -1;
  private final double stressPreservingEnergyAverage = 0.02;
  private final double stressRelievingEnergyAverage = 0.00001;
  private final double[] stressRelievingEnergyDeviances = new double[]{-.003, -.003, -.003};
  private final double[] stressRelievingDifferences = new double[]{-.0002, -.0002};
  private final double[] stressPreservingEnergyDeviances = new double[]{.0005, .0005, .0005};
  private final double[] stressPreservingDifferences = new double[]{.0003, .0003};
  private final double[] stressInitiatingDerivativeDifferences3 = new double[]{.0007, .0007};
  private final double[] stressInitiatingDerivativeDifferences2 = new double[]{.001};
  private final double stressInitiatingDifference2 = .0001;
  private final double stressInitiatingDifference1 = .001;
  private final double stressInitiatingDifference0 = .002;
  boolean actionPotential = false;
  
  FrequencyRangeAnalyzer[] fras;
  
  class FrequencyRangeAnalyzer {
    CircularDoubleBuffer energyLog;
    CircularDoubleBuffer energyDifferences;
    
    float multiplier = 1;
    
    boolean stressed = false;
    boolean actionPotential = false;
    
    double runningStressAverage = 0;
    
    int lowFreq, highFreq;
    
    FrequencyRangeAnalyzer(int lowFreq, int highFreq) {
      energyLog = new CircularDoubleBuffer(16);
      energyDifferences = new CircularDoubleBuffer(energyLog.size);
      
      this.lowFreq = lowFreq;
      this.highFreq = highFreq;
    }
    
    FrequencyRangeAnalyzer(int lowFreq, int highFreq, float multiplier) {
      this(lowFreq, highFreq);
      this.multiplier = multiplier;
    }
    
    void update() {
      double currentEnergy = getEnergyNormalized(lowFreq, highFreq) * multiplier;
      double energyDiff = currentEnergy - energyLog.peek();
      energyLog.add(currentEnergy);
      energyDifferences.add(energyDiff);
      
      
      actionPotential = false;
      
      if (stressed) {
        runningStressAverage = 0.98 * runningStressAverage + 0.02 * currentEnergy;
        int stressLevel = runningStressAverage > stressPreservingEnergyAverage ? 1 : 0
                        + (energyDifferences.greaterThan(stressPreservingDifferences) ? 1 : 0)
                        + (energyLog.devianceGreaterThan(stressPreservingEnergyDeviances) ? 1 : 0)
                        + (energyDifferences.greaterThan(stressRelievingDifferences) ? 0 : -1)
                        + (energyLog.devianceGreaterThan(stressRelievingEnergyDeviances) ? 0 : -1)
                        + (energyLog.runningAverage < stressRelievingEnergyAverage ? 0 : -1);
        if (stressLevel < 0) {
          stressed = false;
          //println("stress down");
        }
      }
      else if ((energyDifferences.derivativeGreaterThan(stressInitiatingDerivativeDifferences3) && energyDifferences.get(2) > stressInitiatingDifference2) ||
               (energyDifferences.derivativeGreaterThan(stressInitiatingDerivativeDifferences2) && energyDifferences.get(1) > stressInitiatingDifference1) ||
               (energyDifferences.peek() > stressInitiatingDifference0)) {
        stressed = true;
        actionPotential = true;
        runningStressAverage = currentEnergy;
        //println("AP!");
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
      new FrequencyRangeAnalyzer(140, 400, 3.5),
      new FrequencyRangeAnalyzer(400, 2600, 8),
      new FrequencyRangeAnalyzer(2600, 5200, 10),
      new FrequencyRangeAnalyzer(5200, 14000, 10)
    };
  }
  
  void update() {
    spectrum = fft.analyze();
    
    for (FrequencyRangeAnalyzer fra : fras) {
      fra.update();
    }
    
    actionPotential = false;
    
    if (stressedRange >= 0) {
      println(stressedRange);
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
