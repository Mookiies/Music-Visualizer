/**
Builder for a MusicTrack. Default values are for strings are "X not found" where x is
the value the string represents, or null for other values.
*/
public class MusicTrackBuilder {
  String artist = "Artist not found";
  String title = "Title not found";
  String album = "Album not found";
  PImage albumArt = null;
  
  SoundFile sound;
  
  public MusicTrackBuilder(SoundFile sound) {
    this.sound = sound;
  }
  
  public MusicTrackBuilder artist(String artist) { this.artist = artist; return this; }
  
  public MusicTrackBuilder title(String title) { this.title = title; return this; }
  
  public MusicTrackBuilder album(String album) { this.album = album; return this; }
  
  public MusicTrackBuilder albumArt(PImage albumArt) { this.albumArt = albumArt; return this; }
  
  public MusicTrack build() { 
    return new MusicTrack(artist, title, album, albumArt, sound);
  }
}