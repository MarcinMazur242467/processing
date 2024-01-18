// User class
class User {
  constructor(nickname, accountType) {
    this.nickname = nickname;
    this.accountType = accountType;
  }

  canSee(announcement) {
    // Organizers can see all announcements, participants can only see non-private announcements
    return this.accountType === 'organizer' || !announcement.isPrivate;
  }
}

// Announcement class
class Announcement {
  constructor(text, isPrivate) {
    this.text = text;
    this.isPrivate = isPrivate;
  }

  display(y) {
    text(this.text, 10, y);
  }
}

let announcements = [];
let users = [];
let currentUser = null;

function setup() {
  createCanvas(400, 400);
  textSize(32);

  // Create some users
  users.push(new User('Alice', 'organizer'));
  users.push(new User('Bob', 'participant'));

  // Set the current user
  currentUser = users[0];
}

function draw() {
  background(220);
  let y = 32; // reset y position for text

  for (let a of announcements) {
    // If the current user can see the announcement, display it
    if (currentUser.canSee(a)) {
      a.display(y);
      y += 32; // move y position down for next announcement
    }
  }
}

function mousePressed() {
  // Add a new announcement when the mouse is pressed
  let isPrivate = random() < 0.5; // Randomly decide if the announcement is private
  announcements.push(
  new Announcement('New announcement at ' + hour() + ':' + minute(), isPrivate));

  // Switch the current user when the mouse is pressed
  currentUser = currentUser === users[0] ? users[1] : users[0];
}
