# Music Visualizer
Customizable Music Visualizer Applet. Has visualizers based on amplitude and range. Customization of colors, scale, visualizer, song, album art.

![sadf](https://user-images.githubusercontent.com/22333355/30186626-5724fc16-93f4-11e7-9a05-1d1c7dea898b.JPG)
![ff](https://user-images.githubusercontent.com/22333355/30186627-584ea628-93f4-11e7-816c-fc98a92e82ce.JPG)
## How to Use:

### Running:
1. Run the processing applet
2. Make selection of visualizer / customization (see selection inforation)
3. Press play
4. Watch visualizer
5. Press back to go back to main GUI screen


### Selection Information
##### Pick visualizer: 
	-at least 1 visualizer must be selected
	-selection reset each time
	-as many visualizers as desired can be combined (see warnings for issues with this)
	-amplitude pulse: pulsing dot based of song amplitude. Recomended scale: (300 - 1000) 
	-amplitude line: draws a scolling line based of amplitude. Recomended scale: (100 - 2000)
	-Range bar: shows range with recangles scaled on activity in range. Recomended scale: (4 - 30)
	-Range line: shows range with a line scaled on activity in range. Recomended scale: (4 - 20)
### Pick song:
	-1 song must be selected
### Optional:
##### Pick color mode:
	-not all visualizer support every color mode
	-progression: changes all color in visualizer over time (supported by all)
	-rainbow scaled: scales color based of degree of activity (supported by all)
	-rainbow simple: creates rainbow based on x coordinate (not supported by amplitude pulse
##### Pick color:
	-input R,G,B separated by spaces. Ex: 255 255 0
	-only affects visualizer set to simple color, or in visualizer not supported by selected mode
##### Pick scale:
	-diffrent for each visualizer. See recomended scale for each visualizer.
	-reset each time


### Adding Songs:
1: add sound file to data folder. For supported formats: ( WAV, AIF/AIFF, MP3 )

2: add album art to data folder. PNG or JPG. This is optional.

3: add file to Songs.txt. All fields can be blank, except for "sound_file" set to the name of file
	-look at bottom entery for example
	
Note: program will not crash if added song is not found. Error message is output to console


### Warnings:
1: playing multiple visualizers will trigger issue with back, where audio will continue to play
2: using more than 1 visualizer can cause diffrent start times an cause audio to be out of sync
	(typically occurs when playing 3 or more)
