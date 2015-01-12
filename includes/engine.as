import flash.events.MouseEvent;
import flash.ui.Mouse;

import classes.StatBarSmall;
import classes.StatBarBig;
	
//Table of Contents
//0. PARSER
//1: TEXT FUNCTIONS
//2. DISPLAY STUFF
//3. UTILITY FUNCTIONS
//4. MOVEMENTS


public function doParse(script:String, markdown=false):String 
{
	return parser.recursiveParser(script, markdown);
}


/*
MOST of this should be broken up into simple shim-functions that call the real, relevant function in userInterface:GUI
I'm breaking it out into a separate class, and just manipulating those class variables for the moment
once that's working, I can start piecemeal moving things to functions in GUI.

*/

//1: TEXT FUNCTIONS
public function output(words:String, markdown:Boolean = false, parse:Boolean = true):void 
{
	if (parse) this.userInterface.outputBuffer += doParse(words, markdown);
	else this.userInterface.outputBuffer += words;
	this.userInterface.output();
}

public function clearOutput():void 
{
	if (this.userInterface.imgString != null && this.userInterface.imgString.length > 0) this.userInterface.imgString = "";
	this.userInterface.clearOutput();
}

public function output2(words:String, markdown:Boolean = false):void
{
	this.userInterface.outputBuffer2 += doParse(words, markdown);
	this.userInterface.output2();
}

public function clearOutput2():void
{
	this.userInterface.clearOutput2();
}

public function outputCodex(words:String, markdown:Boolean = false):void
{
	this.userInterface.outputCodexBuffer += doParse(words, markdown);
}

public function clearOutputCodex():void
{
	this.userInterface.clearOutputCodex();
}

// HTML tag formatting wrappers, because lazy as fuck
public function header(words:String):String
{
	return String("<span class='header'>" + words + "</span>\n");
}

public function blockHeader(words:String):String
{
	return String("<span class='blockHeader'>" + words + "</span>\n");
}

public function num2Text(number:Number):String {
	var returnVar:String = null;
	var numWords = new Array("zero","one","two","three","four","five","six","seven","eight","nine","ten");
	if (number > 10 || int(number) != number) {
		returnVar = "" + number;
	} 
	else {
		returnVar = numWords[number];
	}
	return(returnVar);
}
public function num2Text2(number:int):String {
	var returnVar:String = null;
	var numWords = new Array("zero","first","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth");
	if (number > 10) {
		returnVar = "" + number + "th";
	} 
	else {
		returnVar = numWords[number];
	}
	return(returnVar);
}

public function author(arg:String):void 
{
	userInterface.author(arg);
}


public function upperCase(str:String):String {
	var firstChar:String = str.substr(0,1);
	var restOfString:String = str.substr(1,str.length);
	return firstChar.toUpperCase()+restOfString.toLowerCase();
}

public function plural(str:String):String {
	//var lastChar: String = str.substr(str.length - 1, str.length);
	//var nextToLastChar: String = str.substr(str.length - 2, str.length - 1);
	var lastChar: String = str.substr(str.length - 1);
	var nextToLastChar: String = str.substr(str.length - 2, 1); //Someone here confused .substr with .substring!
	//Various weird pluralize shits
	if (lastChar == "s") str += "es";
	else if (nextToLastChar == "s" && lastChar == "h") str += "es";
	else if (lastChar == "x") str += "es";
	//Ends in y and consonant before, ex: pussy -> pussies
	else if (lastChar == "y" && nextToLastChar != "e" && nextToLastChar != "a" && nextToLastChar != "u" && nextToLastChar != "o" && nextToLastChar != "i") 
	{
		var temp:String = str.substr(0, str.length-1);
		str = temp + "ies";
	}
	//Normal pluralizes
	else str += "s";
	return str;
}
public function possessive(str:String):String {
	var lastChar:String = str.substr(str.length-1,str.length);
	if(lastChar == "s") str += "'";
	else str += "'s";
	return str;
}

public function leftBarClear():void {
	this.userInterface.leftBarClear();
}
public function hidePCStats():void {
	this.userInterface.hidePCStats()
}
public function showPCStats():void {
	this.userInterface.showPCStats()
}
public function showNPCStats():void {
	this.userInterface.showNPCStats()
}
public function hideNPCStats():void {
	this.userInterface.hideNPCStats()
}
public function showMinimap():void {
	this.userInterface.showMinimap();
}
public function hideMinimap():void {
	this.userInterface.hideMinimap();
}
public function deglow():void 
{
	this.userInterface.deglow()
}	
public function updatePCStats():void {
	if (pc.short != "uncreated" && pc.short.length > 0)
		this.userInterface.setGuiPlayerNameText(pc.short);
	else
		this.userInterface.setGuiPlayerNameText("");

	userInterface.playerShields.updateBar(pc.shields(),pc.shieldsMax());

	userInterface.playerHP.updateBar(pc.HP(),pc.HPMax());
	userInterface.playerLust.updateBar(pc.lust(),pc.lustMax());
	userInterface.playerEnergy.updateBar(pc.energy(),pc.energyMax());
	
	this.userInterface.playerPhysique.updateBar(pc.physique(),pc.physiqueMax());	
	this.userInterface.playerReflexes.updateBar(pc.reflexes(),pc.reflexesMax());
	this.userInterface.playerAim.updateBar(pc.aim(),pc.aimMax());
	this.userInterface.playerIntelligence.updateBar(pc.intelligence(),pc.intelligenceMax());
	this.userInterface.playerWillpower.updateBar(pc.willpower(),pc.willpowerMax());
	this.userInterface.playerLibido.updateBar(pc.libido(), pc.libidoMax());
	userInterface.playerXP.updateBar(pc.XP(), pc.XPMax());
	
	this.userInterface.playerStatusEffects = this.chars["PC"].statusEffects;
	this.userInterface.playerLevel.value = String(pc.level);
	this.userInterface.playerCredits.value = String(pc.credits);
	
	this.userInterface.time = timeText();
	this.userInterface.days = String(days);
	this.userInterface.showSceneTag();
	
	if ((pc as PlayerCharacter).levelUpAvailable())
	{
		if (gameOverEvent == true || inSceneBlockSaving == true)
		{
			userInterface.levelUpButton.Deactivate();
		}
		else
		{
			userInterface.levelUpButton.Activate();
		}
	}
	else
	{
		userInterface.levelUpButton.Deactivate();
	}
	
	updateNPCStats();
}
public function timeText():String 
{
	var buffer:String = ""
	
	if (hours < 10)
	{
		buffer += "0";
	}
	
	buffer += hours + ":";
	
	if (minutes < 10) 
	{
		buffer += "0";
	}
	
	buffer += minutes;
	return buffer;
}

public function updateNPCStats():void {
	if(foes.length >= 1) {
		userInterface.monsterShield.updateBar(foes[0].shields(),  foes[0].shieldsMax());
		userInterface.monsterHP.updateBar(foes[0].HP(),       foes[0].HPMax());
		userInterface.monsterLust.updateBar(foes[0].lust(),     foes[0].lustMax());
		userInterface.monsterEnergy.updateBar(foes[0].energy(),   foes[0].energyMax());
		
		this.userInterface.monsterLevel.value = String(foes[0].level);
		this.userInterface.monsterRace.value = StringUtil.toTitleCase(foes[0].originalRace);
		if(foes[0].hasCock()) {
			if(foes[0].hasVagina())	
				this.userInterface.monsterSex.value = "Herm";
			else this.userInterface.monsterSex.value = "Male";
		}
		else if(foes[0].hasVagina()) this.userInterface.monsterSex.value = "Female";
		else this.userInterface.monsterSex.value = "???";
		
		this.userInterface.monsterStatusEffects = foes[0].statusEffects;
	}
}
public function updateStatBar(arg:MovieClip, value = undefined, max = undefined):void {
	//if(title != "" && title is String) arg.masks.labels.text = title;
	if(max != undefined) 
		arg.setMax(max);
	if(value != undefined && arg.visible == true) 
	{
		if(arg.getGoal() != value) 
		{
			arg.setGoal(value);
			//trace("SETTING GOAL");
		}
	}
}

public function setLocation(title:String, planet:String = "Error Planet", system:String = "Error System"):void 
{
	userInterface.setLocation(title, planet, system);
}

//3. UTILITY FUNCTIONS
public function rand(max:Number):Number
{
	return int(Math.random()*max);
}

public function clearList():void {
	list = new Array();
}
var list:Array = new Array();
public function addToList(arg):void {
	list[list.length] = arg;
}
public function formatList():String {
	var stuff:String = "";
	if(list.length == 1) return list[0];
	for(var x:int = 0; x < list.length; x++) {
		stuff += list[x];
		if(list.length == 2 && x == 0) {
			stuff += " and ";
		}
		else if(x < list.length-2) {
			stuff += ", ";
		}
		else if(x < list.length-1) {
			stuff += ", and ";
		}
	}
	list = new Array();
	return stuff;	
}

//4. MOVEMENTS