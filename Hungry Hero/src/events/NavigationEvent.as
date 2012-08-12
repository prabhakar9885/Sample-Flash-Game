package events
{
	import starling.events.Event;
	
	public class NavigationEvent extends Event
	{

		public static const CHANGE_SCREEN:String="changeScreen";
		public var parms:Object;
		
		public function NavigationEvent(type:String, _parms:Object=null, bubbles:Boolean=false)
		{
			super(type, bubbles);
			this.parms=_parms;
		}
	}
}