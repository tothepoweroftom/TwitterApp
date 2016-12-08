class ParticleSystem {

  // Flowfield object
  FlowField flowfield;
  // An ArrayList of vehicles
  ArrayList<Particle> particles;

  ParticleSystem() {
    flowfield = new FlowField(20);
    particles = new ArrayList<Particle>();
    // Make a whole bunch of vehicles with random maxspeed and maxforce values
    for (int i = 0; i < 400; i++) {
      //particles.add(new Particle(new PVector(random(width), random(height*0.3, height*0.6)), random(0.2, 0.5), random(0.1, 0.5)));
    }
  }

  void run() {
    flowfield.update();

    // Tell all the vehicles to follow the flow field
    for (Particle p : particles) {
      p.follow(flowfield);
      p.run();
    }
  }
}