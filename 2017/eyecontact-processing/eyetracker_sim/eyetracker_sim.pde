import gazetrack.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress destination;

GazeTrack gt;

color backgroundColor;

PVector
  current_position,
  avg_center,
  med_center;

int
  cal_start,
  calibration_interval = 2, // how often to grab a new value (in frames)
  calibration_time = 3000; // milliseconds

int contact_thresh = 100;
float current_distance = 0;

OscMessage
  init,
  calibration,
  gazestatus,
  eyecontact;

boolean
  simulate = true, // <---- SET THIS TO FALSE TO ENABLE GAZETRACKING
  show_output = true, // changing this to false disables graphic output, possibly speeding things up a bit
  calibration_greenlight = false,
  cal_in_progress = false,
  iscalibrated = false,
  has_contact = false;

ArrayList<NetAddress> destinations = new ArrayList<NetAddress>();
ArrayList<PVector> centers = new ArrayList<PVector>();
ArrayList<PVector> sample = new ArrayList<PVector>();

Table ipadrs;

void setup() {
  size(1000, 800);
  //fullScreen();
  rectMode(CENTER);
  noStroke();
  fill(#4FA25C);

  current_position = new PVector(width/2, height/2);
  avg_center = new PVector(width/2, height/2);
  med_center = new PVector(width/2, height/2);

  backgroundColor = #000000;
  if (simulate == false) gt = new GazeTrack(this);

  /* start oscP5, listening for incoming messages at port 12346 */
  oscP5 = new OscP5(this,12346);
  println("\n\n");

  Table ipaddrs = loadTable("broadcastaddresses.csv", "header");

  for (TableRow row : ipaddrs.rows()) {
    String addr = row.getString("address");
    int port = row.getInt("port");

    println("adding broadcast address: " + addr + ":" + port);
    destinations.add(new NetAddress(addr, port));
  }

  println("destinations ("+ destinations.size() +"):");

  for(NetAddress n : destinations) {
    println(n.address() + ":" + n.port() + " valid: " + n.isvalid());
  }


  maxinit();


  // plug messages into functions
  // context, fn name, msg pattern
  oscP5.plug(this, "command", "/command");
  oscP5.plug(this, "setthresh", "/setthresh");
  oscP5.plug(this, "maxinit", "/maxinit");


}

void draw() {
  background(backgroundColor);
  noStroke();

  checkCalibration();

  if (simulate == false) {
    current_position.x = gt.getGazeX();
    current_position.y = gt.getGazeY();
  }

  current_distance = med_center.dist(current_position);
  if (current_distance > contact_thresh) has_contact = false;
  else has_contact = true;

  if (show_output) {
    for (PVector point : centers) {
      fill(255,0,255);
      ellipse(point.x, point.y, 5, 5);
    }

    fill(255);
    ellipse(med_center.x, med_center.y, 5, 5);

    noFill();
    stroke(255);
    ellipse(avg_center.x, avg_center.y, 5, 5);

    ellipse(current_position.x, current_position.y, 10, 10);
    ellipse(med_center.x, med_center.y, contact_thresh*2, contact_thresh*2);

    if (!has_contact) stroke(255,0,0);
    line(current_position.x, current_position.y, med_center.x, med_center.y);
  }


  eyecontact = new OscMessage("/eyecontact");
  eyecontact.add(current_position.x);
  eyecontact.add(current_position.y);
  eyecontact.add(has_contact);

  broadcast(eyecontact);
}

public void command(String cmd) {
  println("command received: " + cmd);
  switch (cmd) {
  case "calibrate":
    calibration_greenlight = true;
    break;
  }
}

public void setthresh(int new_thresh) {
  contact_thresh = new_thresh;
  println("new thresh set to: "+new_thresh);
}

public void maxinit() {
  println("sending max init: " + width + " " + height);
  init = new OscMessage("/init/size");
  init.add(width);
  init.add(height);
  broadcast(init);
}

void broadcast(OscMessage message) {

  for (NetAddress n : destinations) {
    oscP5.send(message, n);
  }

}

void gazeStopped() {
  backgroundColor = #cccccc;
  gazestatus = new OscMessage("/gazestatus").add(0);
  broadcast(gazestatus);
}

void gazeStarted() {
  backgroundColor = #ffffff;
  gazestatus = new OscMessage("/gazestatus").add(1);
  broadcast(gazestatus);
}

void mouseMoved() {
  if (simulate == true) {
    current_position.x = mouseX;
    current_position.y = mouseY;
  }
}

void checkCalibration() {


  if (calibration_greenlight) {
    if (!cal_in_progress) {
      println("-----new calibration-----");
      // start new calibration sequence
      iscalibrated = false;

      centers.clear();

      avg_center.set(current_position);

      cal_start = millis();
      cal_in_progress = true;
    }
    calibration_greenlight = false;
  }

  else if (cal_in_progress){
    // calibration already running
    if (millis() - cal_start < calibration_time) {
      if (frameCount % calibration_interval == 0) {
        centers.add(new PVector(current_position.x, current_position.y));

        for (PVector point : centers) {
          avg_center.add(point);
        }
        avg_center.div(centers.size()+1);

        med_center = pvec_median(centers);

        // println("calibration ("+centers.size()+" points): " + avg_center + " ... " + med_center);
      }


    }

    else {
      // timer up
      iscalibrated = true;
      cal_in_progress = false;
    }

    //send it out
    calibration = new OscMessage("/calibration");
    // format: center_x, center_y, iscalibrated
    calibration.add(avg_center.x);
    calibration.add(avg_center.y);
    calibration.add(cal_in_progress);
    calibration.add(iscalibrated);

    broadcast(calibration);
  }

}

void mousePressed() {
  calibration_greenlight = true;
}

void keyPressed() {

  switch (key) {
    case ' ':
      //
      break;
  }

}
