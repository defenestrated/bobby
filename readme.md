# code related to "place for continuous eye contact"

#### written by sam galison
#### updated 2017

---

## two (maybe three) things need to be running simultaneously:
1. (this one i'm not sure about) gaze track streaming application:
  * comes bundled with the [gazetrack processing library](https://github.com/AugustoEst/gazetrack)
  * run _GazeTrackEyeXGazeStream.exe_ (it's in that folder)
2. *eyetracker_sim.pde* in the ... /eyecontact_processing folder
3. *eyecontact_bundle.maxproj* in the ... /eyecontact_max folder

#### this project relies on Open Sound Control to communicate between processing and max
##### more info on OSC [here](http://opensoundcontrol.org/introduction-osc)

---

## osc messages from processing (sent to everything in broadcastaddresses.csv):

### /eyecontact *x* *y* *has_contact*
typetags: *f* (0 - screen width) *f* (0 - screen height) *i* (0 or 1)

### /init/size *width* *height*
typetags: *i* *i*

### /gazestatus *value*
typetag: *i* (0 or 1)
*sent only on change of status*

### /calibration *focus_x* *focus_y* *in_progress* *is_calibrated*
typetags: *f* *f* *i* *i*

---

## osc messages from max (sent to port specified in "broadcast-info" subpatcher)

### /maxinit
[no typetag]
*this is a handshake between processing and max to get everything set up*

### /contactramp *value*
typetag: *f*
*this is the value that slides down on broken contact, up on restored contact. values are 0.-1.*

### /command *command_string*
typetag: *s*
*the only use of this at the moment is to tell processing to start calibration*

### /phase *phase_string*
typetag: *s*
possibilities: *idle, calibration, main, stop*

### setthresh *threshhold_value*
typetag: *i*
*used to set the distance threshhold that defines eye contact*

