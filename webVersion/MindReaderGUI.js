//game parameters
var numberOfGameTurns = 100;
var maxTime = 10;
var timePerTurn = 3;

//graphics variables
var canvas = document.getElementById("myCanvas");
var ctx = canvas.getContext("2d");
var GUIscoreWidth = canvas.width*0.2;
var GUIscoreHeight = canvas.height*0.8/(numberOfGameTurns/2);
var GUIuserScoreParam =    {x: canvas.width/2-GUIscoreWidth-GUIscoreWidth/4,  y: canvas.height-20, y_text: canvas.height-5, color: "blue"};
var GUImachineScoreParam = {x: canvas.width/2+GUIscoreWidth/4,                y: canvas.height-20, y_text: canvas.height-5, color: "red"};
var GUItimeParam = {x: canvas.width/2, y: 20, color: "black"};
var GUIendMessage = {x: canvas.width/2, y: canvas.height/2, color: "black", font:"90px Arial"};




//game status variables
var userScore = 0;
var machineScore = 0;
var turnNumber = 0;
var timeLeft = maxTime;
var currentTurnTime = timePerTurn;
var gameStarted = 0;
var waitForRestart = 0;



//start timer
t = setInterval(updateTime, 1000);

//bot instance
var bot  = new Bot(numberOfGameTurns);

//Main screen refresh function
function draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  drawScores();

  requestAnimationFrame(draw);
}
draw();

//Keyboard event listeners
document.addEventListener("keydown", keyDownHandler, false);
function keyDownHandler(e) {
  if(e.which == 39) {  //Right key
      userAction(1);
  }
  else if(e.which == 37) { //Left key
      userAction(-1);
  }
}

//Draw the two bar scores
function drawScores() {
  ctx.font = "16px Arial";

  //Draw the user bar
  ctx.beginPath();
  ctx.rect(GUIuserScoreParam.x, GUIuserScoreParam.y-userScore*GUIscoreHeight, GUIscoreWidth, userScore*GUIscoreHeight);
  ctx.fillStyle = GUIuserScoreParam.color;
  ctx.fill();
  ctx.closePath();

  //Draw the user text
  ctx.fillStyle = GUIuserScoreParam.color;
  ctx.textAlign="center";
  ctx.fillText("User: "+userScore, GUIuserScoreParam.x+GUIscoreWidth/2, GUIuserScoreParam.y_text);

  //Draw the machine bar
  ctx.beginPath();
  ctx.rect(GUImachineScoreParam.x, GUImachineScoreParam.y-machineScore*GUIscoreHeight, GUIscoreWidth, machineScore*GUIscoreHeight);
  ctx.fillStyle = GUImachineScoreParam.color;
  ctx.fill();
  ctx.closePath();

  //Draw the machine text
  ctx.fillStyle = GUImachineScoreParam.color;
  ctx.textAlign="center";
  ctx.fillText("Machine: "+machineScore, GUImachineScoreParam.x+GUIscoreWidth/2, GUImachineScoreParam.y_text);

  //Draw the time text
  ctx.fillStyle = GUItimeParam.color;
  ctx.textAlign="center";
  ctx.fillText("Time left: "+timeLeft, GUItimeParam.x, GUItimeParam.y);

  if (waitForRestart==1) {
    ctx.font = GUIendMessage.font;
    ctx.fillStyle = GUIendMessage.color;
    ctx.textAlign="center";
    ctx.fillText("You Won!", GUIendMessage.x, GUIendMessage.y);
  }
  else if (waitForRestart==2) {
    ctx.font = GUIendMessage.font;
    ctx.fillStyle = GUIendMessage.color;
    ctx.textAlign="center";
    ctx.fillText("You Lost!", GUIendMessage.x, GUIendMessage.y);
  }


}


function updateTime() {
  if (gameStarted==1) {
    timeLeft -= 1;
    currentTurnTime -= 1;

    if (timeLeft==0) {
      machineScore+=1;
      timeLeft = maxTime;
      currentTurnTime=timePerTurn;
      scoreUpdate();
    }
  }
}

//Update the machine status with the user choice
function userAction(key) {
  if (waitForRestart>0) {
    return;
  }
  gameStarted = 1;

  if (currentTurnTime>0) {
    timeLeft+=currentTurnTime
    if (timeLeft>maxTime) {
      timeLeft=maxTime;
    }
  }
  currentTurnTime=timePerTurn;

  if (bot.getBotPrediction() == key) { //bot won
    machineScore+=1;
  }
  else {
    userScore+=1;
  }

  scoreUpdate();

  bot.updateUserMove(key);
}

function scoreUpdate() {
  if (userScore >= numberOfGameTurns/2) { //gave over user won
    gameStarted=0;
    waitForRestart = 1;
  }

  if (machineScore >= numberOfGameTurns/2) { //gave over user won
    gameStarted=0;
    waitForRestart = 2;
  }
}

function restartGame() {
  window.location.reload(false);
}
