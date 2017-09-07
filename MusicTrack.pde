/**
Represents a song, but can also be used to other audio reprentations. Default values
are specified by MuiscTrackBuilder.
*/
public class MusicTrack {
  
  public String artist;
  public String title;
  public String album;
  public PImage albumArt;
  
  SoundFile sound;
  
  /**
  Creates MusicTrack with all fields.
  */
  private MusicTrack(String artist, String title, String album, PImage albumArt, SoundFile sound) {
    this.artist = artist;
    this.title = title;
    this.album = album;
    this.albumArt = albumArt;
    this.sound = sound;
  }
}