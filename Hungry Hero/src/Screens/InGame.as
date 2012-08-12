package Screens
{
	import Objects.GameBackground;
	import Objects.Hero;
	import Objects.Item;
	import Objects.Obstacle;
	
	import avm2.intrinsics.memory.casi32;
	
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.utils.deg2rad;
	
	public class InGame extends Sprite
	{
		
		private var hero:Hero;
		private var bg:GameBackground;
		
		private var timePrevious:Number;
		private var timeCurrent:Number;
		private var elapsed:Number;
		private var startButton:Button;
		
		private var gameState:String;
		private var playerSpeed:Number;
		private var hitObstacle:Number=0;
		private var MIN_SPEED:Number=650;
		
		private var scoreDistance:int;
		private var obstacleGapCount:int;
		
		private var gameArea:Rectangle;
		
		private var obstaclesToAnimate:Vector.<Obstacle>;
		private var itemsToAnimate:Vector.<Item>;
		
		private var touch:Touch;
		private var touchX:Number;
		private var touchY:Number;
		
		private var scoreText:TextField;
		
		public function InGame()
		{
			trace("1. InGame");
			
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			
			trace("2. onAddedToStage");
			this.removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			drawGame();
			
			scoreText = new TextField(300, 100, "Score: 0", "MyFontName", 24, 0xffffff);
			this.addChild(scoreText);
		}
		
		private function drawGame():void
		{
			trace("3. drawGame");

			bg = new GameBackground();
			this.addChild(bg);
			
			hero = new Hero();
			hero.x = stage.stageWidth/2;
			hero.y = stage.stageHeight/2;
			this.addChild(hero);
			
			startButton = new Button(Assets.getAtlas().getTexture("startButton"));
			startButton.x = stage.stageWidth/2 - startButton.width/2;
			startButton.y = stage.stageHeight/2 - startButton.height/2;
			this.addChild(startButton);
			
			gameArea = new Rectangle(0, 100, stage.stageWidth, stage.stageHeight-250); 
		}
		
		public function disposeTemporarily():void
		{
			trace("4. disposeTemporarily");
			this.visible = false;			
		}
		
		public function initialize():void
		{
			trace("5. initialize");
			this.visible = true;
			
			this.addEventListener(Event.ENTER_FRAME, checkElapsed);
			
			hero.x = -stage.stageWidth;
			hero.y = stage.stageHeight*0.5;
			
			gameState= "idle";
			
			playerSpeed = 0;
			hitObstacle = 0;
			bg.speed = 0;
			scoreDistance = 0;
			obstacleGapCount = 0;
			
			obstaclesToAnimate= new Vector.<Obstacle>();
			itemsToAnimate = new Vector.<Item>();
			
			startButton.addEventListener(starling.events.Event.TRIGGERED, onStartButtonClicked);
		}
		
		private function onStartButtonClicked(event:Event):void
		{
			trace("6. onStartButtonClicked");
			startButton.visible = false;
			startButton.removeEventListener(Event.TRIGGERED, onStartButtonClicked);
			
			launchHero();
		}
		
		private function launchHero():void
		{
			trace("7. launchHero");
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			this.addEventListener(Event.ENTER_FRAME, onGameTick);
		}
		
		private function onTouch(event:TouchEvent):void
		{
			touch = event.getTouch(stage);
			touchX = touch.globalX;
			touchY = touch.globalY;
			
		}
		
		private function onGameTick(event:Event):void
		{
			
//			trace("8. onGameTick");
			
			switch(gameState)
			{
				case "idle":
					//Take off
					if(hero.x < stage.stageWidth * 0.5 * 0.5)
					{
						hero.x += ((stage.stageWidth * 0.5 * 0.5 +10)-hero.x) *0.05;
						hero.y = stage.stageHeight * 0.5;
						
						playerSpeed += (MIN_SPEED-playerSpeed) * 0.05;
						bg.speed = playerSpeed * elapsed;
					}
					else
						gameState = "flying";
					break;
				case "flying":
					
					if(hitObstacle<=0)
					{
						hero.y -= (hero.y - touchY)*0.1;
					
						if( -(hero.y - touchY) <150 && -(hero.y - touchY) > -150)
						{
							hero.rotation = deg2rad(-(hero.y -touchY) * 0.2)
						}
						
						if(hero.y > gameArea.bottom - hero.height*0.5)
						{
							hero.y = gameArea.bottom - hero.height*0.5;
							hero.rotation=deg2rad(0);
						}
						if(hero.y < gameArea.top + hero.height*0.5)
						{
							hero.y = gameArea.top + hero.height*0.5;
							hero.rotation=deg2rad(0);
						}
					}
					else
					{
						hitObstacle--;
						cameraShake();
					}
					
					playerSpeed -= (playerSpeed-MIN_SPEED) * 0.01;
					bg.speed = playerSpeed * elapsed;
					
					scoreDistance += playerSpeed*elapsed *0.1;
//					trace("ScoreDis: "+scoreDistance);
					
					scoreText.text = "Score: " + scoreDistance;
					
					initObstacle();
					animateObstacles();
					
					createFoodItems();
					animateItems();
					
					break;
				case "over":
					break;
			}
			
		}
		
		private function animateItems():void
		{
			var itemToTrack:Item;
			
			trace("animateItems: 1");
			
			for( var i:uint=0; i<itemsToAnimate.length; i++)
			{
				itemToTrack = itemsToAnimate[i];
				itemToTrack.x -= playerSpeed * elapsed;
				trace("animateItems: 2");
				
				if(itemToTrack.bounds.intersects(hero.bounds))
				{
					itemToTrack.visible = false;
					itemsToAnimate.splice(i,1);
					this.removeChild(itemToTrack);
				}
				
				if( itemToTrack.x < -50 )
				{
					trace("animateItems: 3");
					itemsToAnimate.splice(i,1);
					this.removeChild(itemToTrack);
				}
			}
		}
		
		private function createFoodItems():void
		{
			trace("CreateFoodItems: 1");
			
			if(Math.random() > 0.95)
			{
				var itemToTrack:Item = new Item(Math.ceil( Math.random() * 5 ));
				itemToTrack.foodItemType = Math.ceil( Math.random() * 5 );
				itemToTrack.x = stage.stageWidth;// + 50;
				itemToTrack.y = int(Math.random()*(gameArea.bottom - gameArea.top)) + gameArea.top;
				this.addChild(itemToTrack);
				
				itemsToAnimate.push(itemToTrack);
				trace("CreateFoodItems: 2");
			}
		}
		
		private function cameraShake():void
		{
			if(hitObstacle>0)
			{
				this.x = Math.random() *hitObstacle;
				this.y = Math.random() *hitObstacle;
			}
			else if(x!=0)
			{
				this.x = 0;
				this.y = 0;
			}
			
		}
		
		private function animateObstacles():void
		{
			var obstacleToTrack:Obstacle;
//			trace("obstaclesToAnimate: "+obstaclesToAnimate.length);
			
			for(var i:uint=0; i<obstaclesToAnimate.length; i++)
			{
				obstacleToTrack = obstaclesToAnimate[i];
				
				if( obstacleToTrack.alreadyHit==false && obstacleToTrack.bounds.intersects(hero.bounds))
				{
					obstacleToTrack.alreadyHit= true;
					obstacleToTrack.rotation = deg2rad(70);
					hitObstacle = 30;
					playerSpeed /= 2;
				}
				
				if(obstacleToTrack.distance > 0)
				{
					obstacleToTrack.distance -= playerSpeed*elapsed;
				}
				else
				{
					if(obstacleToTrack.watchOut)
						obstacleToTrack.watchOut = false;
					obstacleToTrack.x -= (playerSpeed + obstacleToTrack.speed) * elapsed;
				}
			}
			
			if( obstacleToTrack != null && obstacleToTrack.x < -obstacleToTrack.width || gameState=="over")
			{
				obstaclesToAnimate.splice(i,1);
				this.removeChild(obstacleToTrack);
			}
		}
		
		private function initObstacle():void
		{
			if(obstacleGapCount < 1200)
			{
				obstacleGapCount += playerSpeed*elapsed;
			}
			else if( obstacleGapCount != 0)
			{
				obstacleGapCount =0;
				createObstacle(Math.ceil(Math.random()*4), Math.random()*1000 + 1000);
//				trace("Init Obstacles");
			}
//			trace("obstacleGapCount< 1200:  "+obstacleGapCount);
			
		}
		
		private function createObstacle(type:Number, distance:Number):void
		{
			var obstacle:Obstacle = new Obstacle(type,distance,true,300);
			obstacle.x = stage.stageWidth;
			this.addChild(obstacle);
			
			if(type<=3)
			{
				if(Math.random()>0.5)
				{
					obstacle.y = gameArea.top;
					obstacle.position = "top";
				}
				else
				{
					obstacle.y = gameArea.bottom - obstacle.height;
					obstacle.position = "bottom";
				}
			}
			else
			{
				obstacle.y = int(Math.random() *(gameArea.bottom - obstacle.height - gameArea.top)) + gameArea.top;
				obstacle.position = "middle";
			}
			
			obstaclesToAnimate.push(obstacle);
//			trace("Speed: "+obstacle.speed);
		}
		
		private function checkElapsed(event:Event):void
		{
			timePrevious = timeCurrent;
			
			timeCurrent = getTimer();
			
			elapsed = (timeCurrent - timePrevious) * 0.001;
			
//			trace("9. Elapsed: "+elapsed);
		}
	}
}