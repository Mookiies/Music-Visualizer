/**
Utility class for loading audio. Uses data folder and JSON text file.
*/
public class SongLoader {
  
  PApplet p;
  
  /**
  Creates a songLoader. PApplet required beause to create a SoundFile you need a PApplet.
  */
  public SongLoader(PApplet p) {
    this.p = p;
  }
  
  /**
  Loads tracks specified by JSON at jsonFileName. Loads audio from data folder.
  */
  public HashMap<String, MusicTrack> loadSongs(String jsonFileName) {
    HashMap<String, MusicTrack> songs = new HashMap<String, MusicTrack>();
    JSONObject json = loadJSONObject(jsonFileName);
    JSONArray songArr = json.getJSONArray("songs");
    for (int i = 0; i < songArr.size(); i++) {
      MusicTrack track = createTrack(songArr.getJSONObject(i));
      if (track.title.equals("Title not found")) {
        track.title += i;
      }
      songs.put(track.title, track);
    }
    
    return songs;
  }
  
  /**
  Creates a MusicTrack based on the given JSONObject.
  */
  private MusicTrack createTrack(JSONObject o) {
    String soundFile = o.getString("sound_file");
    SoundFile sound = new SoundFile(p, soundFile); //how do i make this blow up on failure
    MusicTrackBuilder t = new MusicTrackBuilder(sound);
    
    String artist = o.getString("artist");
    if (!artist.equals("")) { t.artist(artist); }
    
    String title = o.getString("title");
    if (!title.equals("")) { t.title(title); }
    
    String album = o.getString("album");
    if (!album.equals("")) { t.album(album); }
    
    String imgFile = o.getString("album_art");
    if (!imgFile.equals("")) {
      try {
        PImage img = loadImage(imgFile);
        img.resize(200,200);
        t.albumArt(img);
      } 
      catch (Exception e) {
        println(e.getMessage());
      }
    }
    
    return t.build();
  }
  
}