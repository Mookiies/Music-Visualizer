/**
A FFT visualizer that displays the range by creating line with points scaled by height by the
ammout the value in range is active.
*/
public class RangeLine extends AFFTVisualizer {
  
  public RangeLine(int bands, PApplet pApp) {
    super(bands, pApp);
  }
  
  @Override
  public void render() {
    super.render();
    
    fft.analyze();
    noFill();
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < bands / rangeLimiter; i ++) {
      sum[i] += ((fft.spectrum[i] - sum[i]) * (i + 1)) * (smooth_factor / ((i + 1) / 2));
      //increase the value depending how high it is, since high is activated less
      
      float size = -sum[i]*yBase*scale;
      PVector v = new PVector(i*r_width * rangeLimiter, yBase + size, -1);
      
      if (mode == ColorMode.RAINBOW_SCALED) {
        stroke(((v.y - yBase)/-scale)%255, 255, 255);
      }
      else if (mode == ColorMode.RAINBOW_SIMPLE) {
        float normalizedX = (v.x - 0) / (r_width * rangeLimiter);
        stroke(normalizedX % 255, 255, 255);
      }
      else if (mode == ColorMode.PROGRESSION) {
        stroke((millis() / 100) % 255, 255, 255);
      }
      else {
        stroke(c);
      }
      
      vertex(v.x, v.y, v.z); 
    }
    endShape();
  }
  
  @Override
  public String getDescription() {
    return "Range Line";
  }
  
  
}