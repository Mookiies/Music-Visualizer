 /**
Main for the project. Handles the GUI and all elements set-up by the GUI. Loads in songs
from JSON on running.

Malcolm Scruggs
Trivia Project
*/
/*
Adding songs. 
Songs are loaded through a JSON file. See Songs.txt for formatting on adding a song.

Things to know:
1: the only part that must be set is the name of sound file to play, which must be in data folder
2: songs cannot have duplicate titles (its okay for multiple songs to have no title, "")
*/
/*
Known issues: 
-sound plays mono
-visualizer FFT and amplitude stop outputing values on long songs (sometimes)
- using more than three visualizer does not sync sound
*/

import processing.sound.*;
import java.util.*;
import controlP5.*;

private ControlP5 cp5; //use the ControlP5 library to create and control GUI elements

private HashMap<String, MusicTrack> songs; //mapped by name, to track
private static final String songJsonFileName = "Songs.txt";

private HashMap<String, ColorMode> colorModes; //use string as key because Control event will give a string name back, so that key can be used to access map

private boolean isPlaying = false;

//visualal constans
public static final int DEFAULT_PADDING = 25;
public static final int HEADER_TEXT_SIZE = 30;
public static final int NORMAL_TEXT_SIZE = 20;

public static final color TEXT_COLOR = #FAFAFA;
public static final color BACKGROUND_COLOR = #1a1b1c;
public static final color GUI_ELEMENT_BCKG_COLOR = #303F9F;
public static final color GUI_ELEMENT_ACTIVE_COLOR = #03A9F4;
public static final color GUI_ELEMENT_FOREGRND_COLOR = #3F51B5;

public static final int BUTTON_WIDTH = 200;
public static final int BUTTON_HEIGHT = 20;
public static final int BUTTON_SPACING = 10;


//I wanted to make GUI its own class but it wouldn't work becuase of the ControlP5 library so I had to do it in this 
//each component has a contsant string for the name, so it can be consistently refered to as a key, and for dispatching to correct function.
//gui components
private HashMap<String, Controller> mainScreenComponents;
private Button playButton;
private static final String PLAY_NAME = "play";

private Button rangeBarsButton;
private static final String RANGE_BAR_NAME = "rngBar";

private Button rangeLineButton;
private static final String RANGE_LINE_NAME = "rngLine";

private Button amplitudeLineButton;
private static final String AMPLITUDE_LINE_NAME = "ampLine";

private Button amplitudePulseButton;
private static final String AMPLITUDE_PULSE_NAME = "ampPulse";

private DropdownList songList;
private static final String DROPDOW_NAME = "songList";

private DropdownList modeList;
private static final String MODE_NAME = "modeList";

private Textfield colorPicker;
private static final String COLOR_NAME = "colorPicker";

private Textfield scalePicker;
private static final String SCALE_NAME = "scalePicker";

private Toggle albumArtToggle;
private static final String ALBUM_ART_TOGGLE = "albumToggle";

//visualization screen components
private HashMap<String, Controller> visScreenComponents;
Button backButton;
private static final String BACK_NAME = "back";

//String and delay variables for the update message appearing after a selection
String updateAction;
int updateActionFrameCount = 0;
private final int UPDATE_ACTION_WAIT = 150;

//components set-up by GUI
ArrayList<IMusicVisualizer> visualizers;
RangeBars rngB;
RangeLine rngL;
AmplitudeLine ampLn;
AmplitudePulse ampP;
MusicTrack selectedTrack; //must be set
ColorMode selectedMode = null; //only set color mode if user selects it, otheriwse use visualizer default
color selectedColor = TEXT_COLOR; //default color to TEXT_COLOR
int selectedScale = Integer.MIN_VALUE; //only set scale if not at default of MIN_VALUE
boolean isAlbumVisible = true; //default album art to true

//the number of bands to use for FFT. This number must be a power of 2. Higher numbers
//will likely cause the program to crash. 256 seems to be most stable number
private final static int NUM_BANDS = 256; 

void setup() {
  size(1600, 800, P3D); 
  colorMode(HSB, 255);
  frameRate(60);
  cp5 = new ControlP5(this);
  updateAction = "";
  
  SongLoader songLoader = new SongLoader(this);
  songs = songLoader.loadSongs(songJsonFileName);
  
  //add all colorModes to the selection 
  colorModes = new HashMap<String, ColorMode>();
  for (ColorMode c : ColorMode.values()) {
    colorModes.put(c.toString(), c);
  }
  
  //set-up the gui components
  initalizeMainScreen();
  initializeVisScreen();
  setScreenVisible(false, visScreenComponents); 
  setScreenVisible(true, mainScreenComponents);
  
  visualizers = new ArrayList<IMusicVisualizer>();
}

void draw() {
  background(BACKGROUND_COLOR);
  
  if (isPlaying) {
    for (IMusicVisualizer vis : visualizers) {
      vis.render();
    }
  }
  else {
    displayMainSceenExtras();
  }
}

/**
Creates all the non-controlP5 elements of the GUI for the main screen. Draws the selection area, the title of Applet, the
update message, and warning message based of selections.
*/
private void displayMainSceenExtras() {
  int col1X = 100;
  int col2X = 300;
  
  //draw rectacle behind all selection text
  rectMode(CORNER);
  fill(GUI_ELEMENT_BCKG_COLOR);
  stroke(GUI_ELEMENT_FOREGRND_COLOR);   
  strokeWeight(3);
  rect(col1X - DEFAULT_PADDING, 465, 800, 175, 5, 5, 5, 5);
  
  //selections test
  textAlign(LEFT);
  rectMode(LEFT);
  fill(TEXT_COLOR);
  textSize(HEADER_TEXT_SIZE);
  text("Selections:", col1X, 500);
  
  //song selection
  textSize(NORMAL_TEXT_SIZE);
  text("Song: ", col1X, 500 + DEFAULT_PADDING);
  if (selectedTrack != null) {
    text(selectedTrack.title, col2X, 500 + DEFAULT_PADDING);
  }
  else {
    text("None. Track must be selected", col2X, 500 + DEFAULT_PADDING);
  }
  
  //visualizer selection
  text("Visualizers: ", col1X, 500 + DEFAULT_PADDING * 2);
  if (visualizers.size() > 0) {
    String result = "";
    for (IMusicVisualizer vis : visualizers) {
      result += vis.getDescription() + ", ";
    }
    text(result, col2X, 500 + DEFAULT_PADDING * 2);
  }
  else {
    text("None. Visualizer must be selected", col2X, 500 + DEFAULT_PADDING * 2);
  }
  //display warning due to inability to pasue sound
  if (visualizers.size() > 1) {
    fill(#ff0000);
    text("WARNING: Sound will not stop without closing program", 100, 80);
    fill(TEXT_COLOR);
  }
  
  //color  mode selection
  text("Color mode: ", col1X, 500 + DEFAULT_PADDING * 3);
  if (selectedMode != null) {
    text(selectedMode.toString(), col2X, 500 + DEFAULT_PADDING * 3);
  }
  else {
    text("default", col2X, 500 + DEFAULT_PADDING * 3);
  }
  
  //custom color selection
  text("Color: ", col1X, 500 + DEFAULT_PADDING * 4);
  rectMode(CORNER);
  fill(selectedColor);
  noStroke();
  rect(col2X, 500 + DEFAULT_PADDING * 4 - 15, 100, 15);
  textAlign(LEFT); //reset back to defaults
  rectMode(LEFT);
  fill(TEXT_COLOR);
  
  //scale selection
  text("Scale: ", col1X, 500 + DEFAULT_PADDING * 5);
  if (selectedScale != Integer.MIN_VALUE) {
    text(selectedScale +"   Note: Scale behaves diffrently for each visualizer", col2X, 500 + DEFAULT_PADDING * 5);
  }
  else {
    text("default", col2X, 500 + DEFAULT_PADDING * 5);
  }
  
  //display title message
  fill(GUI_ELEMENT_BCKG_COLOR);
  textSize(HEADER_TEXT_SIZE);
  text("Music Visualization Applet", width - 400, height - 10);
  
  updateActionMessage();
}

/**
Draws the action message that is updated based on responses from selections or actions taken by the user. Draws the
box on for the delay that it is visible for, otherwise resets updateAction to and empty string.
*/
private void updateActionMessage() { 
  if (updateAction.equals("")) {
    return;
  }
  updateActionFrameCount++;
  if (updateActionFrameCount > UPDATE_ACTION_WAIT) {
    updateActionFrameCount = 0;
    updateAction = "";
    return;
  }
  textAlign(CENTER);
  rectMode(CENTER);
  fill(GUI_ELEMENT_BCKG_COLOR);
  stroke(GUI_ELEMENT_FOREGRND_COLOR);   
  strokeWeight(3);
  rect(width / 2, height / 2 + 10 - 100, 600, 85, 5, 5, 5, 5);
  fill(TEXT_COLOR);
  textSize(NORMAL_TEXT_SIZE);
  text(updateAction, width / 2, height / 2 - 100);
}


/**
Creats all controlP5 components of the main screen. Each created component is added mainScreenComponents
with the key being the constant string designated to it.
*/
private void initalizeMainScreen() {
  /*
  Process for adding a component:
  1: set up by adding it to cp5 with it's name
  2: set value, size, poition, and activation 
  3: set lable to desired text to show on screen
  4: show it
  5: add it to mainScreenComponents with its name as key, and itself as value
  
  7: create a handle method
  8: set controlEvent to displatch handle method 
  */
  mainScreenComponents = new HashMap<String, Controller>();
  playButton = cp5.addButton(PLAY_NAME)
     .setValue(0)
     .setPosition(100,100)
     .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
     .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
     .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
     .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
     .activateBy(ControlP5.PRESSED);
   mainScreenComponents.put(PLAY_NAME, playButton);
 
  rangeBarsButton = cp5.addButton(RANGE_BAR_NAME)
      .setValue(0)
      .setPosition(400, 100)
      .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .activateBy(ControlP5.PRESSED)
      .setLabel("Add Range Bar");
  mainScreenComponents.put(RANGE_BAR_NAME, rangeBarsButton);
  
  rangeLineButton = cp5.addButton(RANGE_LINE_NAME)
      .setValue(0)
      .setPosition(400, 130)
      .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .activateBy(ControlP5.PRESSED)
      .setLabel("Add Range Line");
  mainScreenComponents.put(RANGE_LINE_NAME, rangeLineButton);
  
  amplitudeLineButton = cp5.addButton(AMPLITUDE_LINE_NAME) 
      .setValue(0)
      .setPosition(400, 160)
      .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .activateBy(ControlP5.PRESSED)
      .setLabel("Add Amplitude Line");
 mainScreenComponents.put(AMPLITUDE_LINE_NAME, amplitudeLineButton);
 
 amplitudePulseButton = cp5.addButton(AMPLITUDE_PULSE_NAME)     
      .setValue(0)
      .setPosition(400, 190)
      .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .activateBy(ControlP5.PRESSED)
      .setLabel("Add Amplitude Pulse");
 mainScreenComponents.put(AMPLITUDE_PULSE_NAME, amplitudePulseButton);
      
  songList = cp5.addDropdownList(DROPDOW_NAME)
      .setPosition(700, 100)
      .setSize(200, 120)
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .setLabel("Song selection");
  setUpSongList();
  mainScreenComponents.put(DROPDOW_NAME, songList);
  
  modeList = cp5.addDropdownList(MODE_NAME)
      .setPosition(1000, 100)
      .setSize(200, 120)
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .setLabel("Color mode selection");
  setUpModeList();
  mainScreenComponents.put(MODE_NAME, modeList);
  
 colorPicker = cp5.addTextfield(COLOR_NAME)
      .setPosition(1300, 100)
      .setText("Color input")
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .setAutoClear(true);
 mainScreenComponents.put(COLOR_NAME, colorPicker);
 
 scalePicker = cp5.addTextfield(SCALE_NAME)
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .setPosition(1300, 150)
      .setText("Scale input")
      .setAutoClear(true);
 mainScreenComponents.put(SCALE_NAME, scalePicker);
       
 albumArtToggle = cp5.addToggle(ALBUM_ART_TOGGLE)
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .setPosition(1300, 200)
      .setSize(60, 20)
      .setValue(isAlbumVisible)
      .setLabel("Album Art Visible")
      .setMode(ControlP5.SWITCH);
 mainScreenComponents.put(ALBUM_ART_TOGGLE, albumArtToggle);

}

/**
Further customizes the songList controlP5 dropdown component. Adds all loaded songs to the list
in alphabetical order.
*/
private void setUpSongList() {
  songList.setItemHeight(20);
  songList.setBarHeight(15);
  int itemIdx = 0;
  Collection<String> titles = songs.keySet();
  List<String> sortedTitles = new ArrayList<String>(titles); //just so it can be sorted
  Collections.sort(sortedTitles);
  for (String s : sortedTitles) {
    songList.addItem(s, itemIdx);
    itemIdx++;
  }
}

/**
Further customizes the modeList controlP5 dropdown component. Adds all colormodes to the list 
in order designated by colorMode.keySet().
*/
private void setUpModeList() {
  modeList.setItemHeight(20);
  modeList.setBarHeight(15);
  int itemIdx = 0;
  for (String s : colorModes.keySet()) {
    modeList.addItem(s, itemIdx);
    itemIdx++;
    
  }
}

/**
Creats all controlP5 components of the visualizer screen. Each created component is added visScreenComponents
with the key being the constant string designated to it.
*/
private void initializeVisScreen() {
  visScreenComponents = new HashMap<String, Controller>();
  backButton = cp5.addButton(BACK_NAME)     
      .setValue(0)
      .setPosition(50, 50)
      .setSize(75, BUTTON_HEIGHT)
      .setColorBackground(GUI_ELEMENT_BCKG_COLOR)
      .setColorActive(GUI_ELEMENT_ACTIVE_COLOR)
      .setColorForeground(GUI_ELEMENT_FOREGRND_COLOR)
      .activateBy(ControlP5.PRESSED)
      .hide();
  visScreenComponents.put(BACK_NAME, backButton);
}

/**
Sets the visibility of all the Controller controlP5 components in the given map to the given
boolean value. False to hide the screen, true to show it.
*/
private void setScreenVisible(boolean isVisible, HashMap<String, Controller> screenComponents) {
  for (String s : screenComponents.keySet()) {
    Controller c = screenComponents.get(s);
    if (isVisible) {
      c.show();
    }
    else {
      c.hide();
    }
  }
}

/**
Updates all the selected visualzers to use values selected through the GUI.
Handles to logic of not setting visualizer for default values for colorMode and 
selected scale.
*/
private void finishVisualzerSetup() {
  if (selectedTrack == null) {
    throw new IllegalStateException("Cannot play without a track");
  }
  for (IMusicVisualizer vis : visualizers) {
    vis.setSound(selectedTrack);
    vis.setColor(selectedColor);
    vis.showAlbumbArt(isAlbumVisible);
    if (selectedMode != null) {
      vis.setColorMode(selectedMode);
    }
    if (selectedScale != Integer.MIN_VALUE) {
      vis.setScale(selectedScale);
    }
  }
}

/**
Resets the selection of the main screen for use after the sceen is returned to. Resets updateAction,
selected visalizers and scale. Color, colormode, album art visiblity, and song are not reset.
*/
private void resetValues() {
  for (IMusicVisualizer vis : visualizers) {
    vis.stop();
  }
  updateAction = "";
  updateActionFrameCount = 0;
  isPlaying = false;
  visualizers.clear();
  rngB = null;
  rngL = null;
  ampLn = null;
  ampP = null;
  selectedScale = Integer.MIN_VALUE;
}

/**
Responds to action on the controlP5 play button.
Initalizes visualizations if all necessary values are set, or displays a updateAction message
for what action needs to be taken. Responsible for hiding and setting screen visibilty during
transition.

All controlP5 methods are intentionally not called by their name (ex: play()) so that 
controlEvent(ControlEvent) is the sole function responsible for delegation of activation.
If the function was just called play() it would bypass controlEvent.
*/
public void handlePlay() {
    //println("play value: " + value);
    if (playButton != null && playButton.isPressed()) {
      if (visualizers.size() == 0) {
        updateAction = "Cannot play without a visualizer";
        return;
      }
      if (selectedTrack == null) {
        //TODO fix this
        updateAction = "Cannot play without a song";
        return;
      }
      
      isPlaying = true;
      setScreenVisible(false, mainScreenComponents);
      setScreenVisible(true, visScreenComponents);
      finishVisualzerSetup();
   }
}

/**
Responds to action on the controlP5 add rangebar button.
Adds a range bar to selected visualizations if not already selected,
or removes it has been.  
*/
public void handleRngBar() {
  if (rangeBarsButton != null && rangeBarsButton.isPressed()) {
    if (visualizers.contains(rngB)) {
      updateAction = "Range bar visualizer removed";
      visualizers.remove(rngB);
    }
    else {
      updateAction = "Range bar visualizer added \n Recomended scale: (4 - 30)";
      rngB = new RangeBars(NUM_BANDS, this);
      visualizers.add(rngB);
    }
  }
}

/**
Responds to action on the controlP5 add RangeLine button.
Adds a RangeLine to selected visualizations if not already selected,
or removes it has been.  
*/
public void handleRngLine() {
  if (rangeLineButton != null && rangeLineButton.isPressed()) {
    if (visualizers.contains(rngL)) {
      updateAction = ("Range line removed");
      visualizers.remove(rngL);
    }
    else {
      updateAction = ("Range line visualizer added \n Recomended scale: (4 - 20)");
      rngL = new RangeLine(NUM_BANDS, this);
      visualizers.add(rngL);
    }
  }
}

/**
Responds to action on the controlP5 add amplitudeline button.
Adds a AmplitudeLine to selected visualizations if not already selected,
or removes it has been.  
*/
public void handleAmpLine() {
  if (amplitudeLineButton != null && amplitudeLineButton.isPressed()) {
    if (visualizers.contains(ampLn)) {
      updateAction = ("Amplitude Line visualizer removed");
      visualizers.remove(ampLn);
    }
    else {
      updateAction = ("Amplitude line visualizer added \n Recomended scale: (100 - 2000)");
      ampLn = new AmplitudeLine(this);
      visualizers.add(ampLn);
    }
  }
}

/**
Responds to action on the controlP5 add amplitude pule button.
Adds a AmplitudePulse to selected visualizations if not already selected,
or removes it has been.  
*/
public void handleAmpPulse() {
  if (amplitudePulseButton != null && amplitudePulseButton.isPressed()) {
    if (visualizers.contains(ampP)) {
      updateAction = ("Amplitude pulse visualizer removed");
      visualizers.remove(ampP);
    }
    else {
      updateAction = ("Amplitude pulse visualizer added \n Recomended scale: (300 - 1000)");
      ampP = new AmplitudePulse(this);
      visualizers.add(ampP);
    }
  }
}

/**
Responds to action of the controlP5 songlist dropdown list.
Sets the selected song to the the name of the song corresponding to a MusicTrack
in songs.
*/
public void handleSongList(ControlEvent theEvent) {
  int idxItemSelected = (int) theEvent.getController().getValue();
  Map<String, Object> itemSelected = songList.getItem(idxItemSelected);
  String itemSelectedName = itemSelected.get("name").toString(); //we know its a string based on how addItem works
  selectedTrack = songs.get(itemSelectedName);
  
  updateAction = (selectedTrack.title + " selected");
}

/**
Responds to action of the controlP5 modeList dropdown list.
Sets the selected mode to the the name of the mode corresponding to a ColorMode
in colorModes.
*/
public void handleModeList(ControlEvent theEvent) {
   int idxItemSelected = (int) theEvent.getController().getValue();
   Map<String, Object> itemSelected = modeList.getItem(idxItemSelected);
   String itemSelectedName = itemSelected.get("name").toString(); //we know its a string based on how addItem works
   selectedMode = colorModes.get(itemSelectedName);
   
   updateAction = (selectedMode.toString() + " selected");
}

/**
Responds to action of the controlP5 colorPicker textBox.
Takes the input text and parse's it to see if it fits format R B G, where 
R G B are ints. Sets the selected color to result.
*/
public void handleColorPicker() {
  String text = colorPicker.getText();
  Scanner scanner = new Scanner(text);
  try {
      int r = Integer.parseInt(scanner.next());
      int g = Integer.parseInt(scanner.next());
      int b = Integer.parseInt(scanner.next());
      scanner.close();
      selectedColor = color(r, g, b);
      updateAction = "Color set to Red: " + r + ", Green: " + g + ", Blue: " + b;
  }
  catch (NumberFormatException e) {
    updateAction = "Color input must be in format: 255 255 255 \n Input: " + text;
  }
}

/**
Responds to action of the controlP5 scalePicker textBox.
Takes the input text and parse's it to see if it fits format i, where
i is an non-negative int. If valid input sets selectedScale to input.
*/
public void handleScalePicker() {
  String text = scalePicker.getText();
  try {
    int scaleInput = Integer.parseInt(text);
    if (scaleInput < 0) {
      updateAction = "Scale input cannot be negative. \n Input: " + scaleInput;
      return;
    }
    updateAction = "Scale set to " + scaleInput;
    selectedScale = scaleInput;
  }
  catch (NumberFormatException e) {
    updateAction = "Scale input must be in format: 5 \n Input: " + text;
  }
}

/**
Responds to action on the controlP5 back button.
Resets the value of the GUI and sets screen visiblity back to only mainScreen.
*/
public void handleBack() {
  if (backButton != null && backButton.isPressed()) {
    resetValues();
    setScreenVisible(true, mainScreenComponents);
    setScreenVisible(false, visScreenComponents);
    updateAction = "Visualizers and scale have been reset \n Other selections remain";
  }
}

/**
Responds teo action on the controlP5 albumArtToggle toggle.
Sets the value of isAlbumArtVisible to the state of the toggle.
*/
public void handleAlbumToggle() {
  if (albumArtToggle != null) {
    isAlbumVisible = albumArtToggle.getState();
    updateAction = "Album art visibility set to: " + isAlbumVisible;
  }
}

/**
Handles the dispatch of all actions of a controlP5 element. Any time an actions is completed on a
controlP5 element this method is called, and theEvent contains information about the event such 
as the name, values, and state changes.

This method dispatches the incoming ControlEvent to the function corresponding to the controlP5 event
affected by the event.

@param theEvent the control event to use to disptach to correct handler
*/
void controlEvent(ControlEvent theEvent) {
  //The packing of events is diffrent depending on if the event is a group, so must check
  //if is a group to properly pull out name of triggered component.
  String nameOfTriggeredElemend = "Unrecognized ControlEvent type";
  if (theEvent.isGroup()) { // check if the Event was triggered from a ControlGroup
    String eventString = theEvent.getGroup().getName();
    eventString.substring(0, eventString.indexOf(" "));
    nameOfTriggeredElemend = eventString;
  } 
  else if (theEvent.isController()) {
    nameOfTriggeredElemend = theEvent.getController().getName();
  }
  
  switch (nameOfTriggeredElemend) {
    case DROPDOW_NAME :
       handleSongList(theEvent);
       break;
    case MODE_NAME :
      handleModeList(theEvent);
      break;
    case PLAY_NAME :
      handlePlay();
      break;
    case RANGE_BAR_NAME :
      handleRngBar();
      break;
    case RANGE_LINE_NAME :
      handleRngLine();
      break;
    case AMPLITUDE_LINE_NAME :
      handleAmpLine();
      break;
    case AMPLITUDE_PULSE_NAME :
      handleAmpPulse();
      break;
    case BACK_NAME :
      handleBack();
      break;
    case COLOR_NAME :
      handleColorPicker();
      break;
    case SCALE_NAME :
      handleScalePicker();
      break;
    case ALBUM_ART_TOGGLE :
       handleAlbumToggle();
       break;
    default : 
       println("no case to handle: " + nameOfTriggeredElemend);
  }
}