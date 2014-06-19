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
		
		//Simple flags
		var test_bool:CmdArgBool = new CmdArgBool(
			"b",
			"bool",
			"tests CmdArgBool class",
			(E_CmdArgSyntax.isHIDDEN) //Shouldn't show up in usage
			);
		argarr.push(test_bool);
		
		var test_int:CmdArgInt = new CmdArgInt(
			"i",
			"int",
			"Int",
			"tests CmdArgInt class"
			);
		argarr.push(test_int);
		
		var test_float:CmdArgFloat = new CmdArgFloat(
			"f",
			"float",
			"Float",
			"tests CmdArgFloat class"
			);
		argarr.push(test_float);
		
		var test_string:CmdArgStr = new CmdArgStr(
			"s",
			"string",
			"String",
			"tests CmdArgStr class",
			(E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ),
			"default"
			);
		argarr.push(test_string);
		
		var test_char:CmdArgChar = new CmdArgChar(
			"c",
			"char",
			"Character",
			"tests CmdArgChar class",
			(E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ),
			"d"
			);
		argarr.push(test_char);
		
		//List flags
		var test_list_int:CmdArgIntList = new CmdArgIntList(
			"I",
			"list-int",
			"Int",
			"tests CmdArgIntList class"
			);
		argarr.push(test_list_int);
		
		var test_list_float:CmdArgFloatList = new CmdArgFloatList(
			"F",
			"list-float",
			"Float",
			"tests CmdArgFloatList class"
			);
		argarr.push(test_list_float);
		
		var test_list_string:CmdArgStrList = new CmdArgStrList(
			"S",
			"list-string",
			"String",
			"tests CmdArgStrList class"
			);
		argarr.push(test_list_string);
		
		var test_list_char:CmdArgCharList = new CmdArgCharList(
			"C",
			"list-char",
			"Character",
			"tests CmdArgCharList class"
			);
		argarr.push(test_list_char);
		
		var testCmd:CmdLine = new CmdLine("Test", argarr);
		
		var parseArr:Array<String> = [
			"-bool",
			"-int", "1234",
			"-float", "3.1416",
			"-string", "Mmmmmmy generation...",
			"-char", "C",
			"-list-int", "2, 3, 4 , 5 , 6 , 7",
			"-list-float", "11.34, 3.01245",
			"-S", "Come, on, baby, light, my, fire", //same as -list-string
			"-C", "H, E, L, L, O"  //same as -list-char
			];
		testCmd.parse(parseArr.length, parseArr);
		trace("");
		trace("***Done parsing, if no other previous messages were shown then all went smooth.");
		trace("");
		trace("***Now, parse results are shown for following args: " + parseArr);
		
		trace(test_bool, test_bool._v);
		trace(test_int, test_int._v);
		trace(test_float, test_float._v);
		trace(test_string, test_string._v);
		trace(test_char, test_char._v);
		trace(test_list_int, test_list_int._list);
		trace(test_list_float, test_list_float._list);
		trace(test_list_string, test_list_string._list);
		trace(test_list_char, test_list_char._list);
		
		trace("");
		trace("***Now tracing usage: ");
		testCmd.defaultTraceUsage();
		//--------------------------------------------------------------//
	}
	
}