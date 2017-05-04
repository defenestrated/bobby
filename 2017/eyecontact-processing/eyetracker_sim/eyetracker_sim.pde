import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress destination;

color backgroundColor;

PVector avg_center;

int
  cal_start,
  calibration_interval = 2, // how often to grab a new value (in frames)
  calibration_time = 3000; // milliseconds

float
  offX = 0,
  offY = 0,
  finalx = 0,
  finaly = 0;

OscMessage calibration, gazestatus;

boolean
  calibration_greenlight = false,
  cal_in_progress = false,
  iscalibrated = false;

ArrayList<NetAddress> destinations = new ArrayList<NetAddress>();
ArrayList<PVector> centers = new ArrayList<PVector>();
Table ipadrs;

void setup() {
  size(1200, 800);
  //fullScreen();
  rectMode(CENTER);
  noStroke();
  fill(#4FA25C);

  avg_center = new PVector(width/2, height/2);

  backgroundColor = #000000;


  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);

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
}

void draw() {
  background(backgroundColor);
  calibrate();

  for (PVector point : centers) {
    fill(255,0,255);
    ellipse(point.x, point.y, 10,10);
  }

  fill(255);
  ellipse(avg_center.x, avg_center.y, 10, 10);
  // eyex = new OscMessage("/eyeX");
  // eyey = new OscMessage("/eyeY");

  // eyex.add(finalx);
  // eyey.add(finaly);

  // oscP5.send(eyex, destination);
  // oscP5.send(eyey, destination);

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
  OscMessage eyepos = new OscMessage("/eyeposition");

  eyepos.add(mouseX);
  eyepos.add(mouseY);

  broadcast(eyepos);
}

void calibrate() {

  PVector curpos = new PVector(mouseX, mouseY);

  if (calibration_greenlight) {
    if (!cal_in_progress) {
      println("-----new calibration-----");
      // start new calibration sequence
      iscalibrated = false;

      centers.clear();

      avg_center.set(curpos);

      cal_start = millis();
      cal_in_progress = true;
    }
    calibration_greenlight = false;
  }

  else if (cal_in_progress){
    // calibration already running
    if (millis() - cal_start < calibration_time) {
      if (frameCount % calibration_interval == 0) {
        centers.add(new PVector(curpos.x, curpos.y));

        for (PVector point : centers) {
          avg_center.add(point);
        }
        avg_center.div(centers.size()+1);

        println("calibration ("+centers.size()+" points): " + avg_center);
      }


    }

    else {
      cal_in_progress = false;
    }
  }
  calibration = new OscMessage("/calibration");

  // format: center_x, center_y, iscalibrated
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
