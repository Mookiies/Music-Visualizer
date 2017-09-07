import processing.sound.*;

/**
Class to handle necessicties that every Amplitude based visualizer has. Has a scaling factor, Amplitude,
along with other necessities specified by IMusicVisualizer.
*/
public abstract class AAmplitudeVisualizer implements IMusicVisualizer {
  /*
  bind the required fields to default values
  */
  protected Amplitude rms;
  protected MusicTrack track;
  protected color c = #FAFAFA;
  protected ColorMode mode = ColorMode.SIMPLE; //default to simple
  protected int yBase;
  protected int scale = 5;
  protected boolean isAlbumArtVisible;
  
  /**
  Creates the visualizer. Creates the Amplitude with given pApp.
  */
  AAmplitudeVisualizer(PApplet pApp) {
    // Create and patch the rms tracker
    rms = new Amplitude(pApp);
    isAlbumArtVisible = true;
    yBase = height;
  }
  
  @Override
  public void setSound(MusicTrack track) {
    this.track = track;
    track.sound.play();
    rms.input(track.sound);
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
    
    //display track information
    noStroke();
    fill(TEXT_COLOR);
    textSize(HEADER_TEXT_SIZE);
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
      println("stopping"); //this simply doesn't stop if from playing.... (only when multiple...)
      track.sound.stop();
    }
  }
  
  @Override
  public void setColorMode(ColorMode mode) {
    this.mode = mode;
  }
  
  @Override
  void setScale(int scale) {
    if (scale < 0) {
      throw new IllegalArgumentException("Scale cannot be negative");
    }
    this.scale = scale;
  }
  
  @Override
  public void setColor(color c) {
    this.c = c;
  }
  
  @Override
  public void setY(int y) {
    this.yBase = y;
  }
  
  @Override
  public void showAlbumbArt(boolean isAlbumArtVisible) {
    this.isAlbumArtVisible = isAlbumArtVisible;
  }
  
  /**
  Sets the X coordinate for the visualizer.
  
  @param x the x corrdinate to set the visualizer to
  */
  abstract void setX(int x);
}