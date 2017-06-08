var canvas = document.getElementById("canvas");

var ctx = canvas.getContext("2d");

document.body.appendChild(canvas);

var bgReady = false;
var bgImage = new Image();
bgImage.onload = function(){
    bgReady = true;
}
bgImage.src = "Background.png";

var heroReady = false;
var heroImage = new Image();
heroImage.onload = function(){
    heroReady = true;
}
var monsterReady = false;
var monsterImage = new Image();
monsterImage.onload = function(){
    monsterReady = true;
}


heroImage.src = "hero.png";
monsterImage.src = "monster.png";

var render = function(){
    if(bgReady){
        ctx.drawImage(bgImage,0,0);
    }

    if(heroReady){
        ctx.drawImage(heroImage, hero.x ,hero.y);
    }
    if(monsterReady){
        ctx.drawImage(monsterImage, monster.x , monster.y);
    }

    ctx.fillStyle="rgba(0,0,0,0.8)";
    ctx.font = "24px Helvetica";
    ctx.textAlign = "left";
    ctx.textBaseline = "top";
    ctx.fillText("Monster gefangen: "+ monsterCaught, 32, 32);
}

var hero = {
    speed: 1024 // movement
}

var monster = {}
var monsterCaught = 0;


var keysDown = {};

addEventListener("keydown", function(e){
    keysDown[e.keyCode] = true;
}, false);

addEventListener("keyup", function(e){
    delete keysDown[e.keyCode];
});

var update = function(modifier){
    if(38 in keysDown && hero.y >=32){                         // key Up
        hero.y -= hero.speed * modifier;
    }
    if(40 in keysDown && hero.y <=canvas.height-64){                        // key Down
        hero.y += hero.speed * modifier;
    }
    if(37 in keysDown && hero.x >= 32){                        // key Left
        hero.x -= hero.speed * modifier;
    }
    if(39 in keysDown && hero.x <=canvas.width-64){                        // key Right
        hero.x += hero.speed * modifier;
    }

    if(hero.x <= (monster.x + 32) &&
        monster.x <= (hero.x + 32) &&
        hero.y <=(monster.y + 32) &&
        monster.y <= (hero.y +32)
    ){
        monsterCaught ++;
        resetMonster();
    }


}

var resetMonster = function(){
    monster.x = 32 + (Math.random()) * (canvas.width - 96);
    monster.y = 32 + (Math.random()) * (canvas.height - 96);
}
var resetHero = function(){
    hero.x = -16 + canvas.width/2;
    hero.y = -16 + canvas.height/2;
}

var main = function(){
    var now = Date.now();
    var delta = now - then;
    update(delta/1000);         // pixel per Second
    render();

    then = now;
    requestAnimationFrame(main);
}

var w = window;
requestAnimationFrame = w.requestAnimationFrame || w.webkitRequestAnimationFrame;

var then = Date.now();

resetMonster();
resetHero();
main();