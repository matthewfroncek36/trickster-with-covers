package;

import flixel.addons.transition.FlxTransitionableState;
import AlphabetTricky.TrickyAlphaCharacter;
import flixel.system.FlxSound;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{

	public var songs:Array<TrickyButton> = [];
	var selectedIndex = 0;
	var selectedSmth = false;
	public static var diff = 0;
	public static var diffAndScore:FlxText;

	var debug:Bool = false;

	var songFour:TrickyButton;
	
	public static var diffText:AlphabetTricky;

	override function create() {

		trace(diff);
	
		#if debug
		debug = true;
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		songs.push(new TrickyButton(80,120,'menu/freeplay/Improbable Outset Button','menu/freeplay/Improbable Outset Confirm',selectSong, 'Improbable-Outset', -30));
		songs.push(new TrickyButton(80,240,'menu/freeplay/Madness Button','menu/freeplay/Madness Confirm',selectSong, 'Madness', -30));
		songs.push(new TrickyButton(80,360,'menu/freeplay/Hellclown Button','menu/freeplay/Hellclown Confirm',selectSong, 'Hellclown', -30));
		var expurgationSuffix:String = diff == 1 ? "-Emoji" : "";
		if (diff == 1)
			songFour = new TrickyButton(300,420,'menu/freeplay/Expurgation Button-Emoji','menu/freeplay/Expurgation Confirm-Emoji',selectSong, 'expurgation', 0, 10);
		else
			songFour = new TrickyButton(300,420,'menu/freeplay/Expurgation Button','menu/freeplay/Expurgation Confirm',selectSong, 'expurgation', 0, 15);

		songFour.spriteOne = new FlxSprite(songFour.trueX + songFour.tweenX, songFour.trueY + songFour.tweenY).loadGraphic(Paths.image('menu/freeplay/Expurgation Button' + expurgationSuffix,"clown"), true, 800, 200);
        songFour.spriteTwo = new FlxSprite(songFour.trueX + songFour.tweenX, songFour.trueY + songFour.tweenY).loadGraphic(Paths.image('menu/freeplay/Expurgation Confirm' + expurgationSuffix,"clown"), true, 800, 200);
        songFour.spriteTwo.alpha = 0;
		songFour.spriteOne.animation.add("static", [0, 1, 2, 3], 12, true);
		songFour.spriteTwo.animation.add("static", [0, 1, 2, 3], 12, true);
		songFour.spriteOne.animation.play("static");
		songFour.spriteTwo.animation.play("static");

		songFour.spriteOne.screenCenter(X);
		songFour.trueX = songFour.spriteOne.x;
			
		var bg:FlxSprite = new FlxSprite(-10,-10).loadGraphic(Paths.image('menu/freeplay/RedBG','clown'));
		add(bg);
		var hedge:FlxSprite = new FlxSprite(-810,-335).loadGraphic(Paths.image('menu/freeplay/hedge','clown'));
		hedge.setGraphicSize(Std.int(hedge.width * 0.65));
		add(hedge);
		var shade:FlxSprite = new FlxSprite(-205,-100).loadGraphic(Paths.image('menu/freeplay/Shadescreen','clown'));
		shade.setGraphicSize(Std.int(shade.width * 0.65));
		add(shade);
		var bars:FlxSprite = new FlxSprite(-225,-395).loadGraphic(Paths.image('menu/freeplay/theBox','clown'));
		bars.setGraphicSize(Std.int(bars.width * 0.65));
		add(bars);

		if (FlxG.save.data.beatenHard || debug)
			songs.push(songFour);
		else
		{
			var locked:FlxSprite = new FlxSprite(songFour.trueX, songFour.trueY).loadGraphic(Paths.image('menu/freeplay/Expurgation Locked','clown'), true, 900, 200);
			locked.animation.add("static", [0, 1, 2, 3], 12, true);
			locked.animation.play("static");
			locked.screenCenter(X);
			add(locked);
		}

		for (i in songs)
			{
				// just general compensation since pasc made this on 1920x1080 and we're on 1280x720
				i.spriteOne.setGraphicSize(Std.int(i.spriteOne.width * 0.7));
				i.spriteTwo.setGraphicSize(Std.int(i.spriteTwo.width * 0.7));
				add(i);
				add(i.spriteOne);
				add(i.spriteTwo);
			}

		//diffText = new AlphabetTricky(80,500,"Current Difficulty is " + diffGet());
		//add(diffText);

		var score = Highscore.getScore(songs[selectedIndex].pognt,diff);

		diffAndScore = new FlxText(125,600,0,diffGet() + " - " + score);
		diffAndScore.setFormat("tahoma-bold.ttf",42,FlxColor.RED);

		add(diffAndScore);

		var menuShade:FlxSprite = new FlxSprite(-1350,-1190).loadGraphic(Paths.image("menu/freeplay/Menu Shade","clown"));
		menuShade.setGraphicSize(Std.int(menuShade.width * 0.7));
		add(menuShade);

		songs[0].highlight();

		#if mobile
		addVirtualPad(LEFT_FULL, A_B);
		addVirtualPadCamera();
		#end

	}

	function diffGet()
	{
		if (songs[selectedIndex].pognt == 'expurgation')
		{
			switch (diff)
			{
		    	case 0:
			    	return "UNFAIR";
			    case 1:
	     			return "EMOJI";
				case 2:
					return "MARIO";
			}
		}
		switch (diff)
		{
			case 0:
				return "EASY";
			case 1:
				return "MEDIUM";
			case 2:
				return "HARD";
		}
		return "what";
	}

	function selectSong()
	{
		var diffToUse = diff;

		FlxG.sound.music.fadeOut();

		if (MusicMenu.Vocals != null)
			if (MusicMenu.Vocals.playing)
				MusicMenu.Vocals.stop();

		if (songs[selectedIndex].pognt == 'expurgation')
			diffToUse = diff == 1 ? 1 : 2;

		PlayState.storyDifficulty = diffToUse;

		var poop:String = songs[selectedIndex].pognt == 'expurgation' && diffToUse == 1 ? 'expurgation-emoji' : Highscore.formatSong(songs[selectedIndex].pognt.toLowerCase(), diffToUse);

		PlayState.SONG = Song.loadFromJson(poop, songs[selectedIndex].pognt.toLowerCase());
		PlayState.isStoryMode = false;
		PlayState.storyWeek = 7;

		LoadingState.loadAndSwitchState(new PlayState());
	}

	function resyncVocals():Void
		{
			MusicMenu.Vocals.pause();
	
			FlxG.sound.music.play();
			MusicMenu.Vocals.time = FlxG.sound.music.time;
			MusicMenu.Vocals.play();
		}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (MusicMenu.Vocals != null)
		{
			if (MusicMenu.Vocals.playing)
			{
				if (FlxG.sound.music.time > MusicMenu.Vocals.time + 20 || FlxG.sound.music.time < MusicMenu.Vocals.time - 20)
                    resyncVocals();
			}
		}

	
			var score = Highscore.getScore(songs[selectedIndex].pognt,diff);
			if (songs[selectedIndex].pognt == 'expurgation')
				score = Highscore.getScore(songs[selectedIndex].pognt, diff == 1 ? 1 : 2);
			diffAndScore.text = diffGet() + " - " + score; 
			diffAndScore.color = songs[selectedIndex].pognt == 'expurgation' && diff == 1 ? FlxColor.fromRGB(255, 174, 0) : FlxColor.RED;
			songFour.spriteOne.color = diff == 1 ? FlxColor.fromRGB(255, 174, 0) : FlxColor.WHITE;
			songFour.spriteTwo.color = diff == 1 ? FlxColor.fromRGB(255, 174, 0) : FlxColor.WHITE;

			if (controls.BACK && !selectedSmth)
			{
				selectedSmth = true;
				MainMenuState.curDifficulty = diff;
				FlxG.switchState(new MainMenuState());
			}

			if (controls.RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('Hover','clown'));
				diff += 1;
			}
			if (controls.LEFT_P)
			{
				FlxG.sound.play(Paths.sound('Hover','clown'));
				diff -= 1;
			}

			if (diff >= 3)
				diff = 0;
			if (diff < 0)
				diff = 2;

			if (controls.DOWN_P)
				{
					if (selectedIndex + 1 < songs.length)
					{
						songs[selectedIndex].unHighlight();
						songs[selectedIndex + 1].highlight();
						//doTweensReverse();
						selectedIndex++;
						//doTweens();
						trace('selected ' + selectedIndex);
					}
					else
					{
						//doTweensReverse();
						songs[selectedIndex].unHighlight();
						selectedIndex = 0;
						//doTweens();
						songs[selectedIndex].highlight();
						trace('selected ' + selectedIndex);
					}
				}
				if (controls.UP_P)
				{
					if (selectedIndex > 0)
					{
						songs[selectedIndex].unHighlight();
						songs[selectedIndex - 1].highlight();
						//doTweensReverse();
						selectedIndex--;
						//doTweens();
						trace('selected ' + selectedIndex);
					}
					else
					{
						//doTweensReverse();
						songs[selectedIndex].unHighlight();
						songs[songs.length - 1].highlight();
						selectedIndex = songs.length - 1;
						//doTweens();
						trace('selected ' + selectedIndex);
					}
				}
			
	
			if (controls.ACCEPT && !selectedSmth)
			{
				selectedSmth = true;
				songs[selectedIndex].select();
			}
		}
}
