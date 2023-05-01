extends Node2D

@onready var UI = get_node("UI");
@onready var levelgrid = [
	UI.get_node("x0y0"),
	UI.get_node("x1y0"),
	UI.get_node("x2y0"),
	UI.get_node("x0y1"),
	UI.get_node("x1y1"),
	UI.get_node("x2y1"),
	UI.get_node("x0y2"),
	UI.get_node("x1y2"),
	UI.get_node("x2y2")
]
@onready var cursor = UI.get_node("cursor");
@onready var playerimage = UI.get_node("playerimage");
@onready var movingarrow = UI.get_node("movingarrow");
@onready var Header = UI.get_node("Header");
@onready var FadeLayer = UI.get_node("FadeLayer");
var movingdirection:String = "none";
var movevector:Vector2;

var state:String = "select";
var timer:float = 0.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	World.reset();
	settolevelgrid();
	movecursor(World.playerposition);
	movingdirection = "none";

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pressleft:bool = Input.is_action_pressed("left");
	var pressright:bool = Input.is_action_pressed("right");
	var pressup:bool = Input.is_action_pressed("up");
	var pressdown:bool = Input.is_action_pressed("down");
	var pressedjump:bool = Input.is_action_just_pressed("confirm");
	
	match state:
		"startlevel_wait":
			if timer > 0:
				timer -= delta;
				if timer <= 0:
					timer = 0;
					FadeLayer.visible = true;
					startlevel();
					state = "startlevel";
		"moveplayer":
			playerimage.position += movevector;
			timer -= 1;
			
			if timer < 0:
				state = "startlevel_wait";
				timer = 0.5;
		"selected":
			if Timers.timer_1_4_frame % 2 == 0:
				cursor.visible = true;
			else:
				cursor.visible = false;
			
			if timer > 0:
				timer -= delta;
				if timer <= 0:
					state = "moveplayer";
					match movingdirection:
						"up":
							movevector = Vector2i(0, -2);
						"down":
							movevector = Vector2i(0, 2);
						"left":
							movevector = Vector2i(-2, 0);
						"right":
							movevector = Vector2i(2, 0);
					timer = 11;
					
					World.levelgrid[World.playerposition] = "clear";
					levelgrid[World.playerposition].play("clear");
					playerimage.position = getindexposition(World.playerposition);
					playerimage.visible = true;
					cursor.visible = true;
					movingdirection = "none";
		"select":
			var attempt:bool = true;
			if pressup:
				if World.playerposition - 3 > 0:
					movecursor(World.playerposition - 3);
					movingdirection = "up";
				else:
					attempt = false;
			if pressdown:
				if World.playerposition + 3 < 9:
					movecursor(World.playerposition + 3);
					movingdirection = "down";
				else:
					attempt = false;
			if pressleft:
				if World.playerposition - 1 > 0:
					if (World.playerposition - 1) % 3 != 2:
						movecursor(World.playerposition - 1);
						movingdirection = "left";
					else:
						attempt = false;
				else:
					attempt = false;
			if pressright:
				if World.playerposition + 1 > 0:
					if (World.playerposition + 1) % 3:
						movecursor(World.playerposition + 1);
						movingdirection = "right";
					else:
						attempt = false;
				else:
					attempt = false;
			
			if !attempt:
				movecursor(World.playerposition);
				movingdirection = "none";
				
			if pressedjump:
				if World.cursorposition != World.playerposition:
					Header.text = S.uppercase(World.levelgrid[World.cursorposition]);
					state = "selected";
					timer = 2.0;
	
	updatemovingdirection();
	
func updatemovingdirection():
	match movingdirection:
		"none":
			movingarrow.visible = false;
		"up":
			movingarrow.position = cursor.position + Vector2(0, 16);
			movingarrow.play(movingdirection);
			movingarrow.visible = true;
		"down":
			movingarrow.position = cursor.position + Vector2(7, 20);
			movingarrow.play(movingdirection);
			movingarrow.visible = true;
		"left":
			movingarrow.position = cursor.position + Vector2(7, 20);
			movingarrow.play(movingdirection);
			movingarrow.visible = true;
		"right":
			movingarrow.position = cursor.position + Vector2(-12, 0);
			movingarrow.play(movingdirection);
			movingarrow.visible = true;
			

func settolevelgrid():
	var i:int = 0;
	while i < 9:
		if World.fog[i]:
			levelgrid[i].play("question");
		else:
			levelgrid[i].play(World.levelgrid[i]);
		i += 1;
	
	levelgrid[World.playerposition].play("player");

func getindexposition(index) -> Vector2:
	#whatever, I'm lazy
	#
	#56, 80, 104
	#26, 50, 74
	var returnvector:Vector2;
	match index:
		0:
			returnvector = Vector2(56, 26);
		1:
			returnvector = Vector2(80, 26);
		2:
			returnvector = Vector2(104, 26);
		3:
			returnvector = Vector2(56, 50);
		4:
			returnvector = Vector2(80, 50);
		5:
			returnvector = Vector2(104, 50);
		6:
			returnvector = Vector2(56, 74);
		7:
			returnvector = Vector2(80, 74);
		8:
			returnvector = Vector2(104, 74);
			
	return returnvector;

func movecursor(index):
	World.cursorposition = index;
	if index == -1:
		cursor.visible = false;
		return;
		
	cursor.visible = true;
	cursor.position = getindexposition(index);

func startlevel():
	print("starting a new " + str(World.levelgrid[World.cursorposition]) + " stage")
