import processing.sound.*;

/**
Class to handle necessicties that every FFT based visualizer has. Has a scaling factor, array for spectrum,
smoothing factor, smoothing array, range limiting factor, FFT, along with other necessities specified by IMusicVisualizer.
*/
public abstract class AFFTVisualizer implements IMusicVisualizer {
  /*
  bind the required fields
  protected constructor
  */
  protected FFT fft;
  protected MusicTrack track;
  
  float[] spectrum;
  
  protected final int bands; // must be power of 2
  
  // Declare a scaling factor
  protected int scale;
  
  // Create a smoothing vector
  protected float[] sum;
  
  // Create a smoothing factor (lower number is smoother) 0 - 1.0
  protected float smooth_factor = 0.02;
  
  //lowers the range of values selected, higher values means less diverse range
  protected int rangeLimiter;
  
  protected float r_width;
  protected int yBase;
  
  protected color c = #FAFAFA;
  protected ColorMode mode = ColorMode.SIMPLE;
  
  protected boolean isAlbumArtVisible;
  
  /**
  Creates FFT visualizer using bands and PApplet. If PApplet is null or
  bands is not a power of two, program will crash.
  */
  AFFTVisualizer(int bands, PApplet pApp) {
    this.bands = bands;
    fft = new FFT(pApp, bands);
    
    spectrum = new float[bands];
    sum = new float[bands];
    yBase = height;
    rangeLimiter = 4;
    scale = 5;
    r_width = width/(float(bands));
    this.isAlbumArtVisible = true;
  }
  
  @Override
  void setSound(MusicTrack track) {
    this.track = track;
    track.sound.play();
    fft.input(track.sound);
  }
  
  @Override
  /**
  If overridding render and not calling super.render() new method should check track for non-nullness,
  and handle display of track information.
  */
  public void render() {
    if (track == null) {
      throw new IllegalStateException("Cannot play without track");
    }
    
    //TODO album art
    textSize(HEADER_TEXT_SIZE);
    fill(TEXT_COLOR);
    textAlign(CENTER);
    rectMode(CENTER);
    imageMode(CENTER);
    text(track.title, width / 2, DEFAULT_PADDING * 2);
    textSize(NORMAL_TEXT_SIZE);
    text(track.artist, width / 2, DEFAULT_PADDING * 2 + HEADER_TEXT_SIZE);
    if (isAlbumArtVisible && track.albumArt != null) {
      image(track.albumArt, width / 2, DEFAULT_PADDING * 3 + HEADER_TEXT_SIZE + track.albumArt.height / 2);
    }
  }
  
  @Override
  public void stop() {
    if (track == null) {
      return;
    }
    else {
      track.sound.stop();
    }
  }
  
  @Override
  void setScale(int scale) {
    if (scale < 0) {
      throw new IllegalArgumentException("Scale cannot be negative");
    }
    this.scale = scale;
  }
  
  void setSmooth(float smooth) {
    if (smooth < 0) {
      throw new IllegalArgumentException("smooth cannot be negative");
    }
    this.smooth_factor = smooth;
  }
  
  @Override
  public void setColorMode(ColorMode mode) {
    if (mode == null) {
      throw new IllegalArgumentException("mode cannot be null");
    }
    this.mode = mode;
  }
  
  /**
  Changes the ammount of range to limit on this visualizer. Higher values means 
  less bands shown selected from the lower range of FFT output.
  
  WARNING: changing the range limit will adjust the final X coordinate.
  
  @param rangeLimiter the range limiting factor to set this visualier to
  */
  public void setRangeLimiter(int rangeLimiter) {
    this.rangeLimiter = rangeLimiter;
    this.r_width = r_width/(float(bands) / rangeLimiter);
  }
  
  @Override
  public void setY(int y) {
    this.yBase = y;
  }
  
  @Override
  public void showAlbumbArt(boolean isAlbumArtVisible) {
    this.isAlbumArtVisible = isAlbumArtVisible;
  }
  
  @Override
  public void setColor(color c) {
    this.c = c;
  }
  
}