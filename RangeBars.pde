/**
A FFT visualizer that displays the range by creating rectangles scaled by height by the
ammout the value in range is active.
*/
public class RangeBars extends AFFTVisualizer {
  
  color[] lastColor; //smooths the sccaling of color by only changing color based of frameCount
  
  public RangeBars(int bands, PApplet pApp) {
    super(bands, pApp);
    lastColor = new color[bands];
  }
  
  @Override
  void render() {
    super.render();
    fill(0, 0, 255);
    noStroke();
  
    fft.analyze();
    noFill();
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < bands / rangeLimiter; i++) {
      // Smooth the FFT data by smoothing factor
      sum[i] += ((fft.spectrum[i] - sum[i]) * (i + 1)) * (smooth_factor / ((i + 1) / 2));
      //increase the value depending how high it is, since high is activated less
      
      //set fill based off color mode
      if (mode == ColorMode.RAINBOW_SCALED) {
        if (frameCount % 30 == 0) {
          color c = color(((-sum[i]*yBase*scale)/-scale) % 255, 255, 255);
          fill(c);
          lastColor[i] = c;
        }
        else {
          fill(lastColor[i]);
        }
      }
      else if (mode == ColorMode.RAINBOW_SIMPLE) {
        float normalizedX = (i * width) / width;
        fill(normalizedX % 255, 255, 255);
      }
      else if (mode == ColorMode.PROGRESSION) {
        fill((millis() / 100) % 255, 255, 255);
      }
      else {
        fill(c);
      }
    
      // Draw the rects with a scale factor
      rect(i*r_width * rangeLimiter, yBase, r_width * rangeLimiter, -sum[i]*yBase*scale);
    }
  }
    
  @Override
  String getDescription() {
    return "Range bars";
  }
}