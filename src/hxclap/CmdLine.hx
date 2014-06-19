package hxclap;

import hxclap.CmdArg.E_CmdArgSyntax;

import hxclap.CmdArg.CmdArgBool;
import hxclap.CmdArg.CmdArgInt;
import hxclap.CmdArg.CmdArgFloat;
import hxclap.CmdArg.CmdArgStr;
import hxclap.CmdArg.CmdArgChar;

import hxclap.CmdArg.CmdArgIntList;
import hxclap.CmdArg.CmdArgFloatList;
import hxclap.CmdArg.CmdArgStrList;
import hxclap.CmdArg.CmdArgCharList;

/**
 * ...
 * @author Ohmnivore
 */

class CmdLine
{
	public var _cmdList:Array<CmdArg>;
	public var _progName:String;
	public var _maxLength:Int;
	
	//Callbacks
	public var switchNotFound:String->Void;
	public var missingRequiredSwitch:CmdArg->Void;
	
	public var argNotFound:CmdArg->Void;
	public var missingRequiredArg:CmdArg->Void;
	
	public function new(progName:String, cmds:Array<CmdArg>) 
	{
		_progName = progName;
		_maxLength = 0;
		_cmdList = [];
		
		setUpDefaultCallbacks();
		
		for (cmd in cmds)
		{
			_cmdList.push(cmd);
			_maxLength = Std.int(Math.max(_maxLength, cmd._valueName.length));
		}
	}
	
	public function defaultTraceUsage():Void
	{
		var u:UsageInfo = usage();
		
		trace("Usage: " + u.name);
		
		for (cmd in u.args)
		{
			if (cmd.type < 5)
			{
				_traceSimple(cmd);
			}
			else
			{
				_traceList(cmd);
			}
		}
	}
	
	private function _traceSimple(cmd:ArgInfo):Void
	{
		var longName:String = cmd.longName;
		var shortName:String = cmd.shortName;
		var description:String = cmd.description;
		var expects:String = cmd.expects;
		
		if (cmd.isOPT)
		{
			longName = '[$longName]';
		}
		if (cmd.isVALOPT)
		{
			expects = '[$expects]';
		}
		
		trace('-$longName (-$shortName) -> $description -> expects: $expects');
	}
	
	private function _traceList(cmd:ArgInfo):Void
	{
		var longName:String = cmd.longName;
		var shortName:String = cmd.shortName;
		var description:String = cmd.description;
		var expects:String = cmd.expects;
		
		if (cmd.isOPT)
		{
			longName = '[$longName]';
		}
		if (cmd.isVALOPT)
		{
			expects = '[$expects]';
		}
		
		trace('-$longName (-$shortName) -> $description -> expects: $expects');
	}
	
	public function setUpDefaultCallbacks():Void
	{
		switchNotFound = HandleSwitchNotFound;
		missingRequiredSwitch = HandleMissingSwitch;
		
		argNotFound = HandleArgNotFound;
		missingRequiredArg = HandleMissingArg;
	}
	
	public function HandleSwitchNotFound(Switch:String):Void
	{
		trace("Warning: argument '" + Switch + "' looks strange, ignoring");
	}
	
	public function HandleMissingSwitch(Cmd:CmdArg):Void
	{
		trace("Error: the switch -" + Cmd.getKeyword() + " must be supplied");
	}
	
	public function HandleArgNotFound(Cmd:CmdArg):Void
	{
		trace("Error: switch -" + Cmd.getKeyword() + " must take an argument");
	}
	
	public function HandleMissingArg(Cmd:CmdArg):Void
	{
		trace("Error: the switch -" + Cmd.getKeyword() + " must take a value");
	}
	
	//public function HandleParseError(E:Int, Cmd:CmdArg, T:Int):Void
	//{
		//if (E == ArgError.OPT_CONFLICT_REQUIRED)
		//{
			//trace("Warning: keyword " + Cmd.getKeyword() + " can't be optional AND required");
			//trace(" changing the syntax of " + Cmd.getKeyword() + " to be required.");
		//}
		//
		//if (E == ArgError.INVALID_ARG)
		//{
			//
		//}
	//}
	
	public function usage():UsageInfo
	{
		var u:UsageInfo = new UsageInfo(_progName);
		
		for (cmd in _cmdList)
		{
			if (!cmd.isHidden())
			{
				u.args.push(new ArgInfo(cmd));
			}
		}
		
		return u;
	}
	
	public function parse(argc:Int, argv:Array<String>):Void
	{
		var cmd:CmdArg;
		
		var i:Int = 0;
		while (i < argv.length)
		{
			var arg:String = argv[i];
			var found:Bool = false;
			
			var i2:Int = 0;
			while ((i2 < _cmdList.length) && !found)
			{
				cmd = _cmdList[i2];
				
				var cmdWord:String = "";
				var cmdChar:String = "";
				
				cmdWord = "-" + cmd.getKeyword();
				cmdChar = "-" + cmd.getOptChar();
				
				if ((arg == cmdWord) || (arg == cmdChar))
				{
					cmd.setFound();
					
					if (!cmd.getValue(i, argc, argv))
					{
						if (argNotFound != null)
						{
							argNotFound(cmd);
						}
					}
					else
					{
						cmd.setValFound();
						
						if (!Std.is(cmd, CmdArgBool))
							i++;
					}
					
					found = true;
				}
				
				i2++;
			}
			
			if (!found)
			{
				if (switchNotFound != null)
				{
					switchNotFound(arg);
				}
			}
			
			i++;
		}
		
		for (cmd2 in _cmdList)
		{
			if (!cmd2.isOpt()) // i.e required
			{
				if (!cmd2.isFound())
				{
					if (missingRequiredSwitch != null)
					{
						missingRequiredSwitch(cmd2);
					}
				}
			}
			
			if (cmd2.isFound() && !cmd2.isValOpt()) // i.e need value
			{
				if (!cmd2.isValFound())
				{
					if (missingRequiredArg != null)
					{
						missingRequiredArg(cmd2);
					}
				}
			}
		}
	}
}

class UsageInfo
{
	public var name:String;
	public var args:Array<ArgInfo>;
	
	public function new(Name:String)
	{
		name = Name;
		args = [];
	}
}

class ArgInfo
{
	public var longName:String;
	public var shortName:String;
	public var description:String;
	public var expects:String;
	public var min:Int = 0;
	public var max:Int = 100;
	public var type:Int;
	
	public var isOPT:Bool = false;
	public var isREQ:Bool = false;
	public var isVALOPT:Bool = false;
	public var isVALREQ:Bool = false;
	
	public function new(Arg:CmdArg)
	{
		longName = Arg._keyword;
		shortName = Arg._optChar;
		description = Arg._description;
		expects = Arg._valueName;
		
		if ((Arg._syntaxFlags & E_CmdArgSyntax.isOPT) > 0)
		{
			isOPT = true;
		}
		if ((Arg._syntaxFlags & E_CmdArgSyntax.isREQ) > 0)
		{
			isREQ = true;
		}
		if ((Arg._syntaxFlags & E_CmdArgSyntax.isVALOPT) > 0)
		{
			isVALOPT = true;
		}
		if ((Arg._syntaxFlags & E_CmdArgSyntax.isVALREQ) > 0)
		{
			isVALREQ = true;
		}
		
		//Simple
		if (Std.is(Arg, CmdArgBool))
		{
			type = ArgType.ARG_BOOL;
		}
		if (Std.is(Arg, CmdArgInt))
		{
			type = ArgType.ARG_INT;
		}
		if (Std.is(Arg, CmdArgFloat))
		{
			type = ArgType.ARG_FLOAT;
		}
		if (Std.is(Arg, CmdArgStr))
		{
			type = ArgType.ARG_STRING;
		}
		if (Std.is(Arg, CmdArgChar))
		{
			type = ArgType.ARG_CHAR;
		}
		
		//Lists
		if (Std.is(Arg, CmdArgIntList))
		{
			type = ArgType.ARG_LIST_INT;
			initList(Arg);
		}
		if (Std.is(Arg, CmdArgFloatList))
		{
			type = ArgType.ARG_LIST_FLOAT;
			initList(Arg);
		}
		if (Std.is(Arg, CmdArgStrList))
		{
			type = ArgType.ARG_LIST_STRING;
			initList(Arg);
		}
		if (Std.is(Arg, CmdArgCharList))
		{
			type = ArgType.ARG_LIST_CHAR;
			initList(Arg);
		}
	}
	
	private function initList(Arg:CmdArg):Void
	{
		min = Reflect.field(Arg, "_min");
		max = Reflect.field(Arg, "_max");
	}
}

class ArgType
{
	public static inline var ARG_BOOL:Int = 0;
	public static inline var ARG_INT:Int = 1;
	public static inline var ARG_FLOAT:Int = 2;
	public static inline var ARG_STRING:Int = 3;
	public static inline var ARG_CHAR:Int = 4;
	
	public static inline var ARG_LIST_INT:Int = 5;
	public static inline var ARG_LIST_FLOAT:Int = 6;
	public static inline var ARG_LIST_STRING:Int = 7;
	public static inline var ARG_LIST_CHAR:Int = 8;
}