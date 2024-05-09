package game.states;

import flixel.addons.ui.FlxUIInputText;
import openfl.events.ProgressEvent;
import openfl.net.URLRequest;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import flixel.ui.FlxButton;
import sys.io.File;
import haxe.Http;
import game.Main.*;
import haxegithub.utils.*;
import game.objects.FlxUIDropDownMenuCustom;

class MainState extends MusicBeatState
{
	// Background
	private var backOut:FlxSprite;
	private var BG:FlxSprite;
	private var logo:FlxSprite;

	// Download Bar Stuff
	private var laSexyBar:FlxSprite;
	private var urlRequest:URLRequest;
	private var downloadPercent:FlxText;

	// Download Shit
	private var bit2:Int = 0;
	private var bit:Float = 64;
	private var downloadURL:String;
	private var newVersion:String;
	private var doShit:FlxButton;
	private var bitInput:FlxUIDropDownMenuCustom;
	private final repo = Repository.getReleases('Hackx2', 'FNF-AstroEngine');
	private var fileRef:FileReference;

	override function create()
	{
		BG = new FlxSprite().loadGraphic(Paths.image('bgs/lightNormal'));
		BG.scrollFactor.set(FlxG.mouse.x, FlxG.mouse.y);
		BG.screenCenter();
		add(BG);

		logo = new FlxSprite();
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.animation.addByPrefix('whatthefuck', 'logo bumpin', 24, true);
		logo.animation.play('whatthefuck');
		logo.screenCenter(XY);
		logo.y -= 75;
		logo.antialiasing = true;
		logo.updateHitbox();
		add(logo);

		doShit = new FlxButton(0, 600, "Download", onClick);
		doShit.screenCenter(X);
		doShit.scale.set(2.7, 2.7);
		add(doShit);

		bitInput = new FlxUIDropDownMenuCustom(doShit.x - 500, doShit.y, FlxUIDropDownMenuCustom.makeStrIdLabelArray(["64", "32"], true), function(nerd:String)
		{
			var dude = Std.parseInt(nerd);
			if (dude == 0)
				bit = 64;
			else
				bit = 32;

			tracev2('normal: $bit | normalv2: $nerd');
		});
		add(bitInput);

		laSexyBar = new FlxSprite((FlxG.width - 200) / 2, (FlxG.height - 20) / 2);
		laSexyBar.makeGraphic(200, 20, 0xFF000000);
		laSexyBar.scale.x = 0;

		downloadPercent = new FlxText();
		downloadPercent.setFormat(Paths.font("PhantomMuff.ttf"), 24, FlxColor.BLACK);
		downloadPercent.screenCenter();
		downloadPercent.y += 150;

		// Funi Shit
		backOut = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		backOut.screenCenter();
		backOut.alpha = 1;
		add(backOut);

		FlxG.camera.zoom = 5;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.65, {ease: FlxEase.expoOut});
		FlxTween.tween(backOut, {alpha: 0}, 0.65, {ease: FlxEase.expoOut});
	}

	override function update(elapsed:Float)
		super.update(elapsed);

	private function onClick():Void
	{
		fileRef = new FileReference();
		urlRequest = new URLRequest(downloadURL);
		fileRef.addEventListener(Event.COMPLETE, complete);
		fileRef.addEventListener(ProgressEvent.PROGRESS, progress);
		fileRef.addEventListener(Event.CLOSE, complete);

		fileRef.download(urlRequest, 'AstroEngine${bit}bit.zip');

		tracev2("Downloading >w<");
	}

	private function progress(event:ProgressEvent):Void
	{
		var fuck:Float = event.bytesLoaded / event.bytesTotal;
		var rounded:Float = Math.round((fuck) * 100);
		var lastPer = rounded;

		FlxG.watch.addQuick("Downloaded Percent: ", rounded);

		add(downloadPercent);
		downloadPercent.text = '${rounded}%';
		doShit.visible = false;
		tracev2('Download Progress: $rounded%');
		// laSexyBar.scale.x = fuck;
		//fileRef.removeEventListener(ProgressEvent.PROGRESS, progress);
	}

	private function complete(event:Event):Void
	{
		remove(downloadPercent);
		doShit.visible = true;
		tracev2("Download Completed >w<");

		
		fileRef.removeEventListener(Event.COMPLETE, complete);
		fileRef.removeEventListener(ProgressEvent.PROGRESS, progress);
		fileRef.removeEventListener(Event.CLOSE, complete);
	}

	public function new()
	{
		super();
		switch (bit)
		{
			case 32:
				bit2 = 0;
			case 64:
				bit2 = 1;
			default:
				bit2 = 0;
		}
		downloadURL = repo[0].assets[bit2].browser_download_url;
	}
}
