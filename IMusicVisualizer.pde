/**
Interface requiring the basic functionality of a Visualization.
*/
public interface IMusicVisualizer {
  
  /**
  Renders this visualizer, may or may not clear background.
  */
  void render();
  
  /**
  Sets the sound of the visuazer to be a music track so it can display sound information. Triggers the playing of the song.
  Visualizer must be able to play even if mt only contains a soundfile. 
  
  @parat mt the MusicTrack to play and set visualizer to
  */
  void setSound(MusicTrack mt);
  
  /**
  Stops the playing of audio.
  */
  void stop();
  
  /**
  Returns a string with the name of the visualizer and any other vitality important information in parentheses.
  */
  String getDescription();
  
  /**
  Sets the color mode to be used by the visualizer. Is ignored if mode is not supported.
  */
  void setColorMode(ColorMode mode);
  
  /**
  Sets the color to be used by the visualizer. Should only affect visualizers in ColorMode.SIMPLE.
  
  @param c the color to set the visualizer to
  */
  void setColor(color c);
  
  /**
  Sets the Y coordinate of this visualizer.
  
  @param y the y coordinate to set the visualizer to
  */
  void setY(int y);
  
  /**
  Sets the scale by the visualizer. Scale is not normalized.
  
  @param scale the scale factor to set the visualizer to
  */
  void setScale(int scale);
  
  /**
  Sets whether a visualizer should display album art for set track.
  
  @param isAlbumArtVisible true for visible, false for not visible
  */
  void showAlbumbArt(boolean isAlbumArtVisible);
}