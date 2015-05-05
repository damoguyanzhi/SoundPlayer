package com
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class SoundPlayer extends Sprite
	{
		private var soundChannel:SoundChannel;
		private var playBtn:PlayBtn;
		private var pauseBtn:PauseBtn;
		private var seekBar:Sprite;
		private var volumeBar:Sprite;
		private var muteBtn:MovieClip;
		private var bg:Sprite;
		private var posBar:Sprite;
		private var posBtn:Sprite;
		private var volBar:Sprite;
		private var volBtn:Sprite;
		
		private var pos:Number;
		private var vol:Number;
		//是否静音
		private var isMute:Boolean;
		private var saveVol:Number;
		private var info:String;
		
		private var sound:Sound;
		public function SoundPlayer(s:Sound=null,txt:String="")
		{
			super();
			sound=s;
			info=txt;
			init();
		}
		private function init():void
		{
			this.soundChannel=new SoundChannel;
			this.pos=0;
			isMute=false;
			this.vol=1;
			createUI();
		}
		
		/**自动播放/暂停*/
		public function isAutoPlay(isPlay:Boolean):void
		{
			if(isPlay)
			{
				playHandler(null);
			}
			else
			{
				pauseHandler(null);
			}
		}
		
		private function createUI():void
		{
			playBtn=new PlayBtn;
			pauseBtn=new PauseBtn;
			seekBar=(new SoundSeek) as Sprite;
			volumeBar=(new SoundVolume) as Sprite;
			muteBtn=(new SoundMute) as MovieClip;
			bg=(new SoundBg) as Sprite;
			
			this.addChild(bg);
			var btnSprite:Sprite=new Sprite;
			this.addChild(btnSprite);
			btnSprite.x=23.5;
			btnSprite.y=17;
			btnSprite.addChild(playBtn);
			btnSprite.addChild(pauseBtn);
			pauseBtn.visible=false;
			
			
			this.addChild(seekBar);
			seekBar.x=55.65;
			seekBar.y=21.10;
			this.addChild(volumeBar);
			volumeBar.x=243.9;
			volumeBar.y=20.7;
			var muteSprite:Sprite=new Sprite;
			this.addChild(muteSprite);
			muteSprite.x=210;
			muteSprite.y=17.6;
			muteSprite.addChild(muteBtn);
			muteBtn.gotoAndStop(1);
			posBar=seekBar.getChildByName("posBar") as Sprite;
			posBtn=seekBar.getChildByName("posBtn") as Sprite;
			volBar=volumeBar.getChildByName("volBar") as Sprite;
			volBtn=volumeBar.getChildByName("volBtn") as Sprite;
			posBtn.x=0;
			playBtn.addEventListener(MouseEvent.MOUSE_DOWN,playHandler);
			pauseBtn.addEventListener(MouseEvent.MOUSE_DOWN,pauseHandler);
			posBar.addEventListener(MouseEvent.CLICK,setPosHandler);
			posBtn.addEventListener(MouseEvent.MOUSE_DOWN,posDownHandler);
			posBtn.addEventListener(MouseEvent.MOUSE_UP,posUpHandler);
			posBtn.addEventListener(MouseEvent.RELEASE_OUTSIDE,posUpHandler);
			
			volBar.addEventListener(MouseEvent.CLICK,setVolHandler);
			volBtn.addEventListener(MouseEvent.MOUSE_DOWN,volDownHandler);
			volBtn.addEventListener(MouseEvent.MOUSE_UP,volUpHandler);
			volBtn.addEventListener(MouseEvent.RELEASE_OUTSIDE,volUpHandler);
			muteBtn.addEventListener(MouseEvent.CLICK,muteHandler);
			
			if(info!=""){
				var tf:TextFormat=new TextFormat;
				tf.color=0xffffff;
				tf.size=12;
				tf.font="宋体";
				
				var infoTxt:TextField=new TextField;
				infoTxt.autoSize=TextFieldAutoSize.LEFT;
				infoTxt.defaultTextFormat=tf;
				infoTxt.text=info;
				this.addChild(infoTxt);
				infoTxt.x=10;
			}
			
		}
		private function muteHandler(e:MouseEvent):void
		{
			trace("MUTE")
			if(this.isMute){
				this.vol=this.saveVol;
				this.volBtn.x=this.vol/(1/27);
			}else{
				this.saveVol=this.vol;
				this.vol=0;
				this.muteBtn.gotoAndStop(4);
				this.volBtn.x=0;
			}
			this.isMute=!this.isMute;
			this.setVol();
		}
		private function playHandler(e:MouseEvent):void
		{
			if(e)
			{
				e.stopImmediatePropagation();
			}
			
			this.pauseBtn.visible=true;
			this.playBtn.visible=false;
			this.soundChannel=sound.play(this.pos);
			posBtn.addEventListener(Event.ENTER_FRAME,posEnterHandler);
		}
		private function sndComHandler(e:Event):void
		{
			this.pauseBtn.visible=false;
			this.playBtn.visible=true;
			this.pos=0;
			this.soundChannel.stop();
			posBtn.removeEventListener(Event.ENTER_FRAME,posEnterHandler);
		}
		private function pauseHandler(e:MouseEvent):void
		{
			/*if(Variable.mouseType!=""){
				return;
			}*/
			e.stopImmediatePropagation();
			this.pauseBtn.visible=false;
			this.playBtn.visible=true;
			this.pos=this.soundChannel.position;
			this.soundChannel.stop();
			posBtn.removeEventListener(Event.ENTER_FRAME,posEnterHandler);
//			this.soundChannel.removeEventListener(Event.SOUND_COMPLETE,sndComHandler);
		}
		private function setPosHandler(e:MouseEvent):void
		{
			/*if(Variable.mouseType!=""){
				return;
			}*/
			this.pos=sound.length/78*(mouseX-seekBar.x);
			if((mouseX-seekBar.x)>78){
				this.posBtn.x=78;
			}else{
				this.posBtn.x=mouseX-seekBar.x;
			}
			this.setPos();
		}
		private function posEnterHandler(e:Event):void
		{
//			this.pos=sound.length/78*(mouseX);
			this.pos=this.soundChannel.position;
			this.posBtn.x=this.pos/(sound.length/78);
			
		}
		private function posDownHandler(e:MouseEvent):void
		{
			/*if(Variable.mouseType!=""){
				return;
			}*/
			posBtn.removeEventListener(Event.ENTER_FRAME,posEnterHandler);
			this.posBtn.startDrag(false,new Rectangle(0,0,78,0));
		}
		private function posUpHandler(e:MouseEvent):void
		{
			/*if(Variable.mouseType!=""){
				return;
			}*/
			this.posBtn.stopDrag();
			this.pos=sound.length/78*this.posBtn.x;
			this.setPos();
		}
		private function setVolHandler(e:MouseEvent):void
		{
			/*if(Variable.mouseType!=""){
				return;
			}*/
			this.setVol();
		}
		private function volDownHandler(e:MouseEvent):void
		{
			/*if(Variable.mouseType!=""){
				return;
			}*/
			this.volBtn.startDrag(false,new Rectangle(0,0,27,0));
			volBtn.addEventListener(Event.ENTER_FRAME,volEnterHandler);
		}
		private function volEnterHandler(e:Event):void
		{
			
			this.vol=(1/27)*this.volBtn.x;
			this.setVol();
		}
		private function volUpHandler(e:MouseEvent):void
		{
			/*if(Variable.mouseType!=""){
				return;
			}*/
			volBtn.removeEventListener(Event.ENTER_FRAME,volEnterHandler);
			this.vol=(1/27)*this.volBtn.x;
			this.setVol();
			this.volBtn.stopDrag();
		}
		private function setPos():void
		{
			this.soundChannel.stop();
			posBtn.removeEventListener(Event.ENTER_FRAME,posEnterHandler);
//			this.soundChannel.removeEventListener(Event.SOUND_COMPLETE,sndComHandler);
			this.soundChannel=sound.play(this.pos);
			posBtn.addEventListener(Event.ENTER_FRAME,posEnterHandler);
			this.pauseBtn.visible=true;
			this.playBtn.visible=false;
//			this.soundChannel.addEventListener(Event.SOUND_COMPLETE,sndComHandler);
		}
		private function setVol():void
		{
			if(this.vol==0){
				this.muteBtn.gotoAndStop(4);
			}else if(this.vol>0&&this.vol<=0.3){
				this.muteBtn.gotoAndStop(3);
			}else if(this.vol>0.3&&this.vol<=0.6){
				this.muteBtn.gotoAndStop(2);
			}else{
				this.muteBtn.gotoAndStop(1);
			}
			var soundTransform:SoundTransform=this.soundChannel.soundTransform;
			soundTransform.volume=this.vol;
			this.soundChannel.soundTransform=soundTransform;
		}
		public function sndStop():void
		{
			/*if(Variable.mouseType!=""){
				return;
			}*/
			this.soundChannel.stop();
		}
		public function set setSound(s:Sound):void
		{
			sound=s;
			this.pos=0;
			isMute=false;
			this.vol=1;
		}
		/**清空*/
		public function dispose():void
		{
			playBtn.removeEventListener(MouseEvent.MOUSE_DOWN,playHandler);
			pauseBtn.removeEventListener(MouseEvent.MOUSE_DOWN,pauseHandler);
			posBar.removeEventListener(MouseEvent.CLICK,setPosHandler);
			posBtn.removeEventListener(MouseEvent.MOUSE_DOWN,posDownHandler);
			posBtn.removeEventListener(MouseEvent.MOUSE_UP,posUpHandler);
			posBtn.removeEventListener(MouseEvent.RELEASE_OUTSIDE,posUpHandler);
			
			volBar.removeEventListener(MouseEvent.CLICK,setVolHandler);
			volBtn.removeEventListener(MouseEvent.MOUSE_DOWN,volDownHandler);
			volBtn.removeEventListener(MouseEvent.MOUSE_UP,volUpHandler);
			volBtn.removeEventListener(MouseEvent.RELEASE_OUTSIDE,volUpHandler);
			muteBtn.removeEventListener(MouseEvent.CLICK,muteHandler);
			
			if(volBtn.hasEventListener(Event.ENTER_FRAME))
			{
				volBtn.removeEventListener(Event.ENTER_FRAME,volEnterHandler);
			}
			
			if(posBtn.hasEventListener(Event.ENTER_FRAME))
			{
				posBtn.removeEventListener(Event.ENTER_FRAME,posEnterHandler);
			}
			
			this.removeChild(volumeBar);
			this.removeChild(seekBar);
			this.removeChild(bg);
			
			volumeBar=null;
			seekBar=null;
			playBtn=null;
			pauseBtn=null;
			posBar=null;
			posBtn=null;
			volBar=null;
			muteBtn=null;
			bg=null;
			volBtn=null;
			
			sound=null;
			soundChannel.stop();
			soundChannel=null;
		}
	}
}