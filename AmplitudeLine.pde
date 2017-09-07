public class AmplitudeLine extends AAmplitudeVisualizer {
 
 int x0;
 int spd = 3; //speed
 ArrayList<PVector> points;
 
 AmplitudeLine(PApplet pApp) {
   super(pApp);
   points = new ArrayList<PVector>();
   scale = height / 2; //set appropriate default scale
   x0 = width - 1;
 }
  
 @Override 
 public void render() {
  super.render();
   
  float amplitude = rms.analyze();
  
  points.add(new PVector(x0+spd*frameCount,yBase-scale*amplitude, -1));
  
  noFill();
  strokeWeight(2);
  beginShape();
  for(PVector v : points){
    if (mode == ColorMode.RAINBOW_SCALED) {
      stroke(180*(2.8-(v.y - yBase)/-scale)%255, 255, 255);
    }
    else if (mode == ColorMode.RAINBOW_SIMPLE) {
      stroke(Math.abs(v.x / spd) % 255, 255, 255);
    }
    else if (mode == ColorMode.PROGRESSION) {
      stroke((millis() / 100) % 255, 255, 255);
    }
    else { //default to simple if ColorMode is not supported or not recognized
      stroke(c);
    }
    //TODO find some way to display the whole thing at the end
    vertex(v.x-spd*frameCount,v.y,v.z); 
  }
  endShape();
 }
 
 @Override
 String getDescription() {
   return "Amplitude Line";
 }
 
 @Override
 /**
 The x coordinate for amplitude line the position at which new points are added
 */
 public void setX(int x) {
   this.x0 = x;
 }
 
 /**
 Sets the speed of thei visualizer which changes how fast the line moves across the screen. 
 Higher int means faster, lower means slower.
 */
 public void setSpeed(int speed) {
   if (speed < 0) {
     throw new IllegalArgumentException("Speed cannot be negative");
   }
   this.spd = speed;
 }
 
}