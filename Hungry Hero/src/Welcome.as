package
{
	import com.greensock.TweenLite;
	
	import events.NavigationEvent;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Welcome extends Sprite
	{
		
		private var bg:Image;
		private var title:Image;
		private var hero:Image;
		
		private var playButton:Button;
		private var aboutButton:Button;
		
		public function Welcome()
		{
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			trace("Welcome Screen initalized");
			
			drawScreen();
		}
		
		private function drawScreen():void
		{
			bg = new Image(Assets.getTexture("BgWelcome"));
			this.addChild(bg);
			
			title = new Image(Assets.getAtlas().getTexture("welcome_title"));
			title.x = 440;
			title.y = 20;
			this.addChild(title);
			
			hero = new Image(Assets.getAtlas().getTexture("welcome_hero"));
			hero.x = -hero.width;
			hero.y = 100;
			this.addChild(hero);
			
			playButton = new Button(Assets.getAtlas().getTexture("welcome_playButton"));
			playButton.x = 500;
			playButton.y = 250;
			this.addChild(playButton);
			
			aboutButton = new Button(Assets.getAtlas().getTexture("welcome_aboutButton"));
			aboutButton.x = 410;
			aboutButton.y = 380;
			this.addChild(aboutButton);
			
			this.addEventListener(Event.TRIGGERED, onMainMenuClick);
		}
		
		private function onMainMenuClick(event:Event):void
		{
			 var buttonClicked:Button = event.target as Button;
			
			if(buttonClicked == playButton)
			{
				this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, {id:"play"}, true));
			}
			
		}
		
		public function initialize():void
		{
			this.visible = true;
			
			hero.x = -hero.width;
			hero.y = 100;
			TweenLite.to(hero,2,{x:80});
			 
			this.addEventListener(Event.ENTER_FRAME, heroAnimation);
			  
		}
		
		private function heroAnimation(event:Event):void
		{
			var currentDate:Date = new Date();
			
//			trace("For hero up-and-down: "+ Math.cos(currentDate.getTime() * 0.002) * 25);
			hero.y = 100 + Math.cos(currentDate.getTime() * 0.002) * 25;
			playButton.y = 260 + Math.cos(currentDate.getTime() * 0.002) * 10;
			aboutButton.y = 380 + Math.cos(currentDate.getTime() * 0.002) * 10;
		}
		
		public function disposeTemporarily():void
		{
			this.visible = false;
			
			if(this.hasEventListener(Event.ENTER_FRAME))
				this.removeEventListener(Event.ENTER_FRAME,heroAnimation);
		}
	}
}