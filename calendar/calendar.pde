import java.util.*;
import java.io.*;
import java.util.HashMap;
import processing.data.JSONObject;
import java.util.Set;

class CircularButton {
  float x, y, radius;
  color buttonColor, signColor;

  CircularButton(float x, float y, float radius, color buttonColor, color signColor) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.buttonColor = buttonColor;
    this.signColor = signColor;
  }

  void display() {
    fill(buttonColor);
    ellipse(x, y, radius*2, radius*2);

    stroke(signColor);
    strokeWeight(3);
    line(x, y - radius/2, x, y + radius/2);
    line(x - radius/2, y, x + radius/2, y);
  }

  boolean isClicked(float mouseX, float mouseY) {
    float d = dist(mouseX, mouseY, x, y);
    return d < radius;
  }
}

class TextBox {
  int x, y, boxWidth, boxHeight, textLimit = 40;
  float currentValue, keyCounter, previousKeyCounter;
  String textValue = new String("");
  char keyInput, c;
  boolean keyReleased;
  String label;

  TextBox (int x, int y, int boxWidth, int boxHeight, String label) {
    this.x = x;
    this.y = y;
    this.boxWidth = boxWidth;
    this.boxHeight = boxHeight;
    this.label = label;  
  }

  void draw () {
    drawBox ();
    drawText ();
    getUserInput ();
  }

  void drawBox () {
    stroke (205);
    fill (205);
    rect (x, y, boxWidth, boxHeight);
    fill(0);
    text (this.label, x, y - 10);
  }

  void drawText () {
    textAlign (LEFT, CENTER);
    textSize (16);
    fill (255);
    text (textValue + getCursor (), x + 5, y + boxHeight/2);
  }

  void getUserInput () {
    if (hovering()) {
      if (!keyPressed) {
        keyReleased = true;
        keyCounter = 0;
        previousKeyCounter = 0;
      }
      if (keyPressed && c != key) {
        keyCounter = millis ();
        c = key;
        if (c == BACKSPACE) textValue = "";
        else if (c >= ' ') textValue += str (c);
        if (textValue.length () > textLimit) textValue = "";
        previousKeyCounter = keyCounter;
        keyReleased = false;
      }
    }
  }

  String getCursor () {
    return hovering () && (frameCount>>4 & 1) == 0 ? "|" : "";
  }

  boolean hovering () {
    return mouseX >= x && mouseX <= x + boxWidth && mouseY >= y && mouseY <= y + boxHeight;
  }
}

class Meeting {
  String title;
  String agenda;
  String participants;
  String place;

  Meeting(String title, String agenda, String participants, String place) {
    this.title = title;
    this.agenda = agenda;
    this.participants = participants;
    this.place = place;
  }
}

int daysInMonth, currentDay, startDay;
int month, year;
String monthName;
String[] weekDays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
String popupText = "";
boolean showPopup = false;
HashMap<String, Meeting> meetings = new HashMap<String, Meeting>();
JSONObject json = new JSONObject();
TextBox input1;
TextBox input2;
TextBox input3;
TextBox input4;
TextBox input5;
CircularButton button;

void scheduleMeeting(){
  meetings.put(input1.textValue, new Meeting(input2.textValue, input3.textValue, input4.textValue, input5.textValue));
}

void saveHashMap(){
  for (String meet : meetings.keySet()) {
    Meeting obj = meetings.get(meet);
    JSONObject jsonObj = new JSONObject();
    jsonObj.setString("title", obj.title);
    jsonObj.setString("agenda", obj.agenda);
    jsonObj.setString("participants", obj.participants);
    jsonObj.setString("place", obj.place);

    json.setJSONObject(meet, jsonObj);
  }

  saveJSONObject(json, "meetings.json");
}

HashMap<String, Meeting> loadMap(){  
  JSONObject json = loadJSONObject("meetings.json");
  HashMap<String, Meeting> map = new HashMap<String, Meeting>();

  Set<String> meetings = json.keys();
  for (String meeting : meetings) {
    JSONObject jsonObj = json.getJSONObject(meeting);
    String title = jsonObj.getString("title");
    String agenda = jsonObj.getString("agenda");
    String participants = jsonObj.getString("participants");
    String place = jsonObj.getString("place");
    map.put(meeting, new Meeting(title, agenda, participants, place));
  }
  return map;
}

void setup() {
  size(450, 600);
  input1 = new TextBox(50, 380, 130, 30, "Date");  
  input2 = new TextBox(190, 380, 180, 30, "Title");
  input3 = new TextBox(50, 430, 320, 30, "Agenda");  
  input4 = new TextBox(50, 480, 320, 30, "Participants");
  input5 = new TextBox(50, 530, 320, 30, "Place");
  button = new CircularButton(400, 530, 20, color(255, 255, 255), color(0, 0, 0));

  textSize(20);
  textAlign(CENTER, CENTER);
  java.util.Calendar calendar = java.util.Calendar.getInstance();
  month = calendar.get(java.util.Calendar.MONTH);
  year = calendar.get(java.util.Calendar.YEAR);
  updateCalendar(month, year);
  meetings = loadMap();
}

void updateCalendar(int month, int year) {
  java.util.Calendar calendar = java.util.Calendar.getInstance();
  calendar.set(java.util.Calendar.MONTH, month);
  calendar.set(java.util.Calendar.YEAR, year);
  daysInMonth = calendar.getActualMaximum(java.util.Calendar.DAY_OF_MONTH);
  currentDay = calendar.get(java.util.Calendar.DAY_OF_MONTH);
  startDay = calendar.get(java.util.Calendar.DAY_OF_WEEK);
  monthName = new java.text.SimpleDateFormat("MMMM").format(calendar.getTime());
}

void draw() {
  background(255);
  int x = 0;
  int y = 50;
  text(monthName, (width / 2)-30, 25);
  for (int i = 0; i < weekDays.length; i++) {
    text(weekDays[i], x * 50 + 50, y);
    x++;
  }
  x = startDay - 1;
  y += 50;
  for (int i = 1; i <= daysInMonth; i++) {
    text(i, x * 50 + 50, y);
    fill(0);
    if (meetings.containsKey(year + "-" + (month+1) + "-" + i)) {
      fill(255, 0, 0, 100);
      ellipse(x * 50 + 57, y, 30, 30);
      fill(0);
    }
    x++;
    if (x > 6) {
      x = 0;
      y += 50;
    }
  }
  input1.draw();
  input2.draw();
  input3.draw();
  input4.draw();
  input5.draw();
  button.display();

  fill(200);
  rect(50, 10, 40, 30);
  rect(width - 90, 10, 40, 30);
  fill(0);
  text("<", 70, 30);
  text(">", width - 70, 30);
  if (showPopup) {
    fill(200);
    rect(0, 0, width, height);
    fill(0);
    textSize(24);
    Meeting meeting = meetings.get(year + "-" + (month+1) + "-" + popupText.split(": ")[1]);
    if (meeting != null) {
      text("Title: "+meeting.title + "\n" + "Agenda: "+ meeting.agenda+ "\n"  + "Place: "+ meeting.place+"\nParticipants: \n", (width / 2)-200, (height / 2)-20);
      float offset = 0;
      for(String pax : meeting.participants.split(",")){
        text(pax,(width / 2)-180, (height / 2)+30+offset);
        offset=offset+20;
      }
    } else {
      text(popupText,(width / 2)-200, (height / 2)-20 );
    }
    fill(255, 0, 0);
    rect(width - 30, 10, 20, 20);
    fill(255);
    text("X", width - 26, 20);
  }
}

void mousePressed() {
  if (mouseX > 50 && mouseX < 90 && mouseY > 10 && mouseY < 40) {
    month--;
    if (month < 0) {
      month = 11;
      year--;
    }
    updateCalendar(month, year);
  }

  if (mouseX > width - 90 && mouseX < width - 50 && mouseY > 10 && mouseY < 40) {
    month++;
    if (month > 11) {
      month = 0;
      year++;
    }
    updateCalendar(month, year);
  }
  int x = (mouseX - 50) / 50;
  int y = (mouseY - 100) / 50;
  if (x >= 0 && x < 7 && y >= 0 && y < 6) {
    int date = y * 7 + x - startDay + 2;
    if (date > 0 && date <= daysInMonth) {
      showPopup = true;
      popupText = "Date: " + date;
    }
  }
  if (mouseX > width - 30 && mouseX < width - 10 && mouseY > 10 && mouseY < 30) {
    showPopup = false;
  }
  if (x >= 0 && x < 7 && y >= 0 && y < 6) {
    int date = y * 7 + x - startDay + 2;
    if (date > 0 && date <= daysInMonth) {
      showPopup = true;
      popupText = "Date: " + date;
    }
  }
}

void mouseClicked() {
  if (button.isClicked(mouseX, mouseY)) {
    scheduleMeeting();
    input1.textValue="";
    input2.textValue="";
    input3.textValue="";
    input4.textValue="";
    input5.textValue="";
  }
}

void exit() {
  saveHashMap();
  super.exit();
}
