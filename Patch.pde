class Patch {
    PVector position, velocity, acceleration;
    float perceptionRange;
    float mass;
    float cohesionPower = 1, separationPower = 1, alignPower = 4;
    float speedMultiplier = 0.8;

    int flockingCD = 0;
    float cH = random(360);
    float cS = 255;
    float cB = 255;
    
    SoundStreamAnalyzer ssa;
    
    Patch() {
        this.position = new PVector(random(width), random(height));
        this.velocity = new PVector(random(-2,3)*speedMultiplier, random(-2, 3)*speedMultiplier);
        this.acceleration = new PVector();
        this.perceptionRange = 6400.0;
        this.mass = 50;
    }
    Patch(PVector position, PVector velocity, PVector acceleration, float perceptionRange, float mass) {
        this.position = position;
        this.velocity = velocity;
        this.acceleration = acceleration;
        this.perceptionRange = perceptionRange;
        this.mass = mass;
    }
    Patch(PVector position, SoundStreamAnalyzer ssa) {
        this();
        this.position = position;
        this.ssa = ssa;
    }

    boolean isVisible(Patch p) {
        boolean isMe = this == p;
        //float w2 = width/2;
        //float h2 = height/2;
        //float translationX = w2 - this.position.x;
        //float translationY = h2 - this.position.y;
        //float xdif = w2 - (p.position.x + translationX + width) % width;
        //float ydif = h2 - (p.position.y + translationY + height) % height;
        float xdif = this.position.x - p.position.x;
        float ydif = this.position.y - p.position.y;
        boolean isInRange = this.perceptionRange >= (xdif*xdif + ydif*ydif);
        return !isMe && isInRange;
    }
    
    Patch setPowers(float cohesionPower, float separationPower, float alignPower) {
        this.cohesionPower = cohesionPower;
        this.separationPower = separationPower;
        this.alignPower = alignPower;
        return this;
    }
    
    ArrayList<Patch> getVisibles(ArrayList<Patch> patches) {
      ArrayList<Patch> visibles = new ArrayList<Patch>();
      for (Patch patch : patches)
        if (isVisible(patch))
          visibles.add(patch);
      
      return visibles;
    }
    
    ArrayList<Patch> getFlock(ArrayList<Patch> patches) {
      ArrayList<Patch> flock = getVisibles(patches);
      flock.add(this);
      return flock;
    }
    
    int countVisibles(ArrayList<Patch> patches) {
      return getVisibles(patches).size();
    }
    
    void flockingCooldown(int frames) {
      flockingCD = frames;
    }
    
    PVector separation(ArrayList<Patch> patches) {
        PVector steering = new PVector();
        //int totalPerceptiblePatches = 0;
        for (Patch patch : patches) {
            if (isVisible(patch)) {
                PVector reverseDirection = PVector.sub(this.position, patch.position);
                reverseDirection.div(reverseDirection.mag());
                steering.add(reverseDirection);    
                //totalPerceptiblePatches++;
            }
        }
        //steering.div(totalPerceptiblePatches);
        steering.div(this.mass);
   
        return steering;
    }
    
    PVector cohesion(ArrayList<Patch> patches) {
        PVector avg = this.position.copy();
        int totalPerceptiblePatches = 1;
        for (Patch patch : patches) {
            if (isVisible(patch)) {
                avg.add(patch.position);    
                totalPerceptiblePatches++;
                // might need to exclude this patch in this calculation
            }
        }
        avg.div(totalPerceptiblePatches);
        PVector steering = new PVector();
        steering = PVector.sub(avg, this.position);
        steering.div(this.mass);
        return steering;
    }
    
    PVector align(ArrayList<Patch> patches) {
        PVector avg = this.velocity.copy();
        int totalPerceptiblePatches = 1;
        for (Patch patch : patches) {
            if (isVisible(patch)) {
                avg.add(patch.velocity);    
                totalPerceptiblePatches++;
                // might need to exclude this patch in this calculation
            }
        }
        avg.div(totalPerceptiblePatches);
        PVector steering = new PVector();
        steering = PVector.sub(avg, this.velocity);
        steering.div(this.mass);
        return steering;
    }
    
    void update(ArrayList<Patch> patches) {
        //println(frameCount, "pos",this.position.toString());
        //println(frameCount, "vel", this.velocity.toString());
        this.position.add(this.velocity);
        //float oldVelocityMagnitude = this.velocity.mag();
        if (flockingCD <= 0)
          this.velocity.add(this.acceleration);
        else
          flockingCD--;
        //this.velocity.setMag(oldVelocityMagnitude);
        this.position.x = (this.position.x + width) % width;
        this.position.y = (this.position.y + height) % height;
        
        
        this.acceleration = PVector.mult(align(patches), Parameters.Flocking.alignPower);
        this.acceleration.add(PVector.mult(cohesion(patches), Parameters.Flocking.cohesionPower));
        this.acceleration.add(PVector.mult(separation(patches), Parameters.Flocking.separationPower));
    }
    
    int sigmoid(float x, float steepness, float inflection) {
      return int(255f / (1 + exp(-steepness * (x - inflection))));
    }
    
    void draw() {
      //stroke(0);
      //c = color(255);
      //fill(c);
      //ellipse(position.x, position.y, 40, 40);
      //blendMode(DIFFERENCE);
      //image(Parameters.Flocking.img, this.position.x, this.position.y);
      //blend(Parameters.Flocking.img, 0, 0, Parameters.Flocking.img.width, Parameters.Flocking.img.height, 
      //int(this.position.x), int(this.position.y),  Parameters.Flocking.img.width, Parameters.Flocking.img.height, DIFFERENCE);
      
      cB = ssa.actionPotential ? 255 : (0.95 * cB + 0.05 * (ssa.stressedRange == -1 ? 100 : 255));
      strokeWeight(3);
      stroke(color(cH, cS, cB, sigmoid(this.velocity.mag(), 0.15, 15)));
      line(this.position.x, this.position.y, this.position.x + this.velocity.x * 5, this.position.y + this.velocity.y * 5);
    }
}
