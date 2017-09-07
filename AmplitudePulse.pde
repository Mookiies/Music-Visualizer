/**
Amplitude visalizer created by a cretangle that expands and becomes more circular
the higher the amplitude.
*/
public class AmplitudePulse extends AAmplitudeVisualizer {
  
  float smoothing = 0.3;
  int x = width / 2;
  
  int amp = 0;
  
  /**
  Create the amplitude visualizer. Sets default scaling and y coordinate;
  */
  public AmplitudePulse(PApplet pApp) {
    super(pApp);
    scale = 500;
    yBase = height / 2; //default y to middle of screen
  }
  
  @Override
  public void render() {
    super.render(); //draws the title
    
    float amplitude = rms.analyze();
    
    amp += (int) (((amplitude * scale) - amp) * smoothing);
    
    if (mode == ColorMode.RAINBOW_SCALED) {
      fill(amp%255, 255, 255);
    }
    else if (mode == ColorMode.PROGRESSION) {
      fill((millis() / 100) % 255, 255, 255);
    }
    else { //default to simple if ColorMode is not supported or not recognized
      fill(c);
    }
    rect(x, yBase, amp, amp, amp);
 }
 
 @Override
 String getDescription() {
   return "Amplitude Pulse";
 }
 
 @Override
 public void setX(int x) {
   this.x = x;
 }
 
}