String filename = "test";
String fileext = ".jpg";
String foldername = "./";
float measure;
float bpm = 103;
float floatFrames = 0.0;

SoundStreamAnalyzer ssa;

ArrayList<Patch> flock;

void setup() {
    size(600, 600, P2D);
    //fullScreen(P2D);
    Parameters.img = loadImage("img.png");
    textSize(20);
    colorMode(HSB);
    background(0);
    
    ssa = new SoundStreamAnalyzer(this, new AudioIn(this, 0));
    
    flock = new ArrayList<Patch>();
    for (int i = 0; i < 200; i++) {
        int pixelX = int(random(width));
        int pixelY = int(random(height));
        flock.add(new Patch(new PVector(pixelX, pixelY), ssa));
        // flock.add(new Patch());
    }
    frameRate(30);
    measure = 1 * 60 * 30 / bpm;
}

void mousePressed() {
  background(0);
  randomize(measure/3);
  floatFrames = 0;
}

void randomize(float speedrange) {
    for (Patch p : flock) {
        p.velocity = new PVector(
        randomGaussian()*speedrange*Parameters.Flocking.speedMultiplier*pow(p.countVisibles(flock), 0.8)/7, 
        randomGaussian()*speedrange*Parameters.Flocking.speedMultiplier*pow(p.countVisibles(flock), 0.8)/7
        );
        p.flockingCooldown(10);
    }
}
void keyPressed() {
    if (keyCode == UP) {
      measure *= 2;
    } else if (keyCode == DOWN) {
      measure *= 1f/2;
    } 
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
    for (Patch p : flock) {
        p.draw();
        p.update(flock);
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
      randomize(measure / 8);
    }
    
    //floatFrames += 1;
    //if(floatFrames >= measure){
      
    //  randomize(measure/3);
    //  floatFrames -= measure;
    //} 
    // saveFrame("test#####.jpg");
}
