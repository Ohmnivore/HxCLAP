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
		
		var test_bool:CmdArgBool = new CmdArgBool(
			"b",
			"Boolean",
			"Simple boolean arg"
			);
		//trace(test_bool);
		argarr.push(test_bool);
		
		var testCmd:CmdLine = new CmdLine("Test", argarr);
		
		//testCmd.usage();
		testCmd.parse(2, ["-Boolean"]);
		trace("Done parsing, if no other messages were shown then all went smooth.");
		//--------------------------------------------------------------//
	}
	
}