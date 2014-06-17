package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import hxclap.CmdArg;
import hxclap.CmdLine;

/**
 * ...
 * @author Ohmnivore
 */

class Main 
{
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		//--------------------------------------------------------------//
		var argarr:Array<CmdArg> = [];
		
		//argarr.push(new CmdArgBool());
		
		//var testCmd:CmdLine = new CmdLine("Test");
		//--------------------------------------------------------------//
	}
	
}