//float measure;
//float bpm = 103;
float floatFrames = 0.0;

SoundStreamAnalyzer ssa;

ArrayList<Patch> patches;

void setup() {
  size(960, 600, P2D);
  //fullScreen(P2D);
  //Parameters.img = loadImage("img.png");
  textSize(20);
  colorMode(HSB);
  background(0);
  
  ssa = new SoundStreamAnalyzer(this, new AudioIn(this, 0));
  
  patches = new ArrayList<Patch>();
  for (int i = 0; i < 400; i++) {
    int pixelX = int(random(width));
    int pixelY = int(random(height));
    patches.add(new Patch(new PVector(pixelX, pixelY), ssa));
    // patches.add(new Patch());
  }
  frameRate(30);
  //measure = 1 * 60 * 30 / bpm;
}

void mousePressed() {
  background(0);
  randomize(4);
  floatFrames = 0;
}

void randomize(float speedrange) {
  for (Patch p : patches) {
    p.velocity = new PVector(
      randomGaussian()*speedrange*Parameters.Flocking.speedMultiplier*pow(p.countVisibles(patches), 0.8)/7, 
      randomGaussian()*speedrange*Parameters.Flocking.speedMultiplier*pow(p.countVisibles(patches), 0.8)/7
    );
    p.flockingCooldown(10);
  }
}

void subflockize(float speedrange) {
  ArrayList<Patch> all = new ArrayList<Patch>(patches);
  while (!all.isEmpty()) {
    ArrayList<Patch> flock = all.get(0).getFlock(patches);
    int size = flock.size();
    int root = ceil(sqrt(size)); // this should always be >= 1
    float vx = 0, vy = 0;
    int i = 0; // flock index
    
    // makes root-many sub-flocks with member counts as close as they can be
    for (int j = 1; j <= root; j++) {
      vx = randomGaussian() * speedrange * Parameters.Flocking.speedMultiplier * pow(size, 0.8) / 7; // these lines...
      vy = randomGaussian() * speedrange * Parameters.Flocking.speedMultiplier * pow(size, 0.8) / 7; // execute at least once
      
      while (i < round(1.0 * size * j / root)) { // beautiful magic
        flock.get(i).velocity = new PVector(vx, vy);
        flock.get(i).flockingCooldown(10);
        i++;
      }
    }
    
    for (Patch p : flock) {
      all.remove(p);
    }
  }
}

void keyPressed() {
  //if (keyCode == UP) {
  //  measure *= 2;
  //} else if (keyCode == DOWN) {
  //  measure *= 1f/2;
  //} 
  if (key == 'q') {
    Parameters.Flocking.cohesionPower += 0.1;
  } else if (key == 'a') {
    Parameters.Flocking.cohesionPower -= 0.1;
  } 
  if (key == 'w') {
    Parameters.Flocking.alignPower += 0.1;
  } else if (key == 's') {
    Parameters.Flocking.alignPower -= 0.1;
  } 
  if (key == 'e') {
    Parameters.Flocking.separationPower += 0.1;
  } else if (key == 'd') {
    Parameters.Flocking.separationPower -= 0.1;
  } 
  if (key == 'r') {
    Parameters.Flocking.speedMultiplier += 0.1;
  } else if (key == 'f') {
    Parameters.Flocking.speedMultiplier -= 0.1;
  } 
  
  if (key == ' ') mousePressed();
}

void draw() {
  ssa.update();

  //fill(0, 200);
  //rect(0,0,250,150);
  //fill(255);
  //text("Cohesion: " + Parameters.Flocking.cohesionPower, 10, 25);
  //text("Alignment: " + Parameters.Flocking.alignPower, 10, 50);
  //text("Separation: " + Parameters.Flocking.separationPower, 10, 75);
  //text("Speed Multiplier: " + Parameters.Flocking.speedMultiplier, 10, 100);
  //text("StressedFreqRange: " + ssa.stressedRange, 10, 125);
  for (Patch p : patches) {
    p.draw();
    p.update(patches);
  }
  
  noStroke();
  blendMode(MULTIPLY);
  fill(250);
  rect(0,0,width,height);
  blendMode(SUBTRACT);
  fill(1);
  rect(0,0,width,height);
  blendMode(BLEND);
  
  if (ssa.actionPotential) {
    subflockize(2.2);
  }
  
  //floatFrames += 1;
  //if(floatFrames >= measure){
    
  //  randomize(measure/3);
  //  floatFrames -= measure;
  //} 
  // saveFrame("test#####.jpg");
}
