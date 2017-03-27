import gazetrack.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress destination;

GazeTrack gt;
color backgroundColor;

int startX, startY;
float
  offX = 0,
  offY = 0,
  finalx = 0,
  finaly = 0;

OscMessage eyex, eyey, gazestatus;

NetAddress[] destinations = new NetAddress[2];;


void setup()
{
  size(1200, 800);
  //fullScreen();
  rectMode(CENTER);
  noStroke();
  fill(#4FA25C);

  gt = new GazeTrack(this);
  backgroundColor = #ffffff;


  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);

  destinations[0] = new NetAddress("127.0.0.1",12345); //local
  destinations[1] = new NetAddress("10.2.78.42",12345); // remote
}

void draw()
{
  background(backgroundColor);

  finalx = gt.getGazeX()-offX;
  finaly = gt.getGazeY()-offY;

  fill(0);
  if (startX > 0) rect(startX, startY, 10,10);

  noFill();
  stroke(0);
  if (offY != 0) ellipse(finalx, finaly, 40, 40);

  stroke(0, 127);
  rect(gt.getGazeX(), gt.getGazeY(), 20, 20);

  eyex = new OscMessage("/eyeX");
  eyey = new OscMessage("/eyeY");

  eyex.add(finalx);
  eyey.add(finaly);

  oscP5.send(eyex, destination);
  oscP5.send(eyey, destination);

}

void broadcast(message) {

}

void gazeStopped()
{
  backgroundColor = #cccccc;
  gazestatus = new OscMessage("/gazestatus").add(0);
  oscP5.send(gazestatus, destination);
}

void gazeStarted()
{
  backgroundColor = #ffffff;
  gazestatus = new OscMessage("/gazestatus").add(1);
  oscP5.send(gazestatus, destination);
}

void mousePressed() {



  startX = mouseX;
  startY = mouseY;


}

void keyPressed() {

  switch (key) {
    case ' ':
    offX = gt.getGazeX() - startX;
    offY = gt.getGazeY() - startY;
    println(offX, offY);
    break;
  }

}
