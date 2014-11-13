package hxclap;

import hxclap.CmdLine.ArgType;
import hxclap.CmdArg.ArgError;
import hxclap.CmdArg.E_CmdArgStatus;
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

class CmdElem
{
	public var isArg:Bool = true;
	
	public var _optChar:String;
	public var _keyword:String;
	public var _valueName:String;
	public var _description:String;
	public var _syntaxFlags:Int;
	public var _status:Int;
	
	//Callback
	public var parseError:Int->CmdElem->Int->String->Void;
	
	public function new(keyWord:String, valueName:String, description:String, syntaxFlags:Int) 
	{
		_keyword = keyWord;
		_valueName = valueName;
		_description = description;
		_syntaxFlags = syntaxFlags;
		_status = E_CmdArgStatus.isBAD;
		
		setUpDefaultCallbacks();
		validate_flags();
	}
	
	public function setUpDefaultCallbacks():Void
	{
		parseError = HandleParseError;
	}
	
	public function HandleParseError(E:Int, Cmd:CmdElem, T:Int, Arg:String=""):Void
	{
		if (E == ArgError.OPT_CONFLICT_REQUIRED)
		{
			trace("Warning: keyword " + Cmd.getKeyword() + " can't be optional AND required");
			trace(" changing the syntax of " + Cmd.getKeyword() + " to be required.");
		}
		
		if (E == ArgError.INVALID_ARG)
		{
			switch(T)
			{
				case ArgType.ARG_INT:
					trace(" invalid integer value '" + Arg + "'");
				case ArgType.ARG_FLOAT:
					trace(" invalid float value '" + Arg + "'");
				case ArgType.ARG_CHAR:
					trace(" value '" + Arg + "' is too long. ignoring");
				
				case ArgType.ARG_LIST_INT:
					trace(" invalid float value '" + Arg + "'");
				case ArgType.ARG_LIST_FLOAT:
					trace(" invalid float value '" + Arg + "'");
				case ArgType.ARG_LIST_CHAR:
					trace(" invalid float value '" + Arg + "'");
			}
		}
		
		if (E == ArgError.SPACE_DELIMITER)
		{
			trace("ERROR: space can't be a delimiter");
		}
		
		if (E == ArgError.TOO_FEW_ARGS)
		{
			trace("Too few arguments to the switch -" + Cmd.getKeyword());
		}
		if (E == ArgError.TOO_MANY_ARGS)
		{
			trace("Too many arguments to the switch -" + Cmd.getKeyword());
		}
	}
	
	// selectors
	public function getOptChar():String
	{
		return _optChar;
	}
	
	public function getKeyword():String
	{
		return _keyword;
	}
	
	public function getValueName():String
	{
		return _valueName;
	}
	
	public function getDescription():String
	{
		return _description;
	}
	
	public function getSyntaxFlags():Int
	{
		return _syntaxFlags;
	}
	
	public function isHidden():Bool
	{
		//return (_syntaxFlags & E_CmdArgSyntax.isHIDDEN);
		if (_syntaxFlags & E_CmdArgSyntax.isHIDDEN > 0)
			return true;
		
		return false;
	}
	
	public function isOpt():Bool
	{
		//return (_syntaxFlags & E_CmdArgSyntax.isOPT);
		if (_syntaxFlags & E_CmdArgSyntax.isOPT > 0)
			return true;
		
		return false;
	}
	
	public function isValOpt():Bool
	{
		//return (_syntaxFlags & E_CmdArgSyntax.isVALOPT);
		if (_syntaxFlags & E_CmdArgSyntax.isVALOPT > 0)
			return true;
		
		return false;
	}
	
	public function isBad():Bool
	{
		//return _status;
		if (_status > 0)
			return true;
		
		return false;
	}
	
	private function setValueName(S:String):Void
	{
		_valueName = S;
	}
	
	private function setDescription(S:String):Void
	{
		_description = S;
	}
	
	public function setFound():Void
	{
		_status |= E_CmdArgStatus.isFOUND;
	}
	
	public function isFound():Bool
	{
		if (_status & E_CmdArgStatus.isFOUND > 0)
			return true;
		
		return false;
	}
	
	public function setValFound():Void
	{
		_status |= E_CmdArgStatus.isVALFOUND;
	}
	
	public function isValFound():Bool
	{
		//return (_status & E_CmdArgStatus.isVALFOUND);
		if ((_status & E_CmdArgStatus.isVALFOUND) > 0)
			return true;
		
		return false;
	}
	
	public function setParseOK():Void
	{
		_status |= E_CmdArgStatus.isPARSEOK;
	}
	
	public function isParseOK():Bool
	{
		//return (_status & E_CmdArgStatus.isPARSEOK);
		if (_status & E_CmdArgStatus.isPARSEOK > 0)
			return true;
		
		return false;
	}
	
	//methods
	public function isNull():Bool
	{
		return !isParseOK();
	}
	
	public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		return true;
	}
	
	public function validate_flags():Bool
	{
		if ((_syntaxFlags & E_CmdArgSyntax.isOPT > 0) && (_syntaxFlags & E_CmdArgSyntax.isREQ > 0))
		{
			var type:Int = 0;
			
			if (Std.is(this, CmdArgBool))
			{
				type = ArgType.ARG_BOOL;
			}
			if (Std.is(this, CmdArgInt))
			{
				type = ArgType.ARG_INT;
			}
			if (Std.is(this, CmdArgFloat))
			{
				type = ArgType.ARG_FLOAT;
			}
			if (Std.is(this, CmdArgStr))
			{
				type = ArgType.ARG_STRING;
			}
			if (Std.is(this, CmdArgChar))
			{
				type = ArgType.ARG_CHAR;
			}
			
			if (Std.is(this, CmdArgIntList))
			{
				type = ArgType.ARG_LIST_INT;
			}
			if (Std.is(this, CmdArgFloatList))
			{
				type = ArgType.ARG_LIST_FLOAT;
			}
			if (Std.is(this, CmdArgStrList))
			{
				type = ArgType.ARG_LIST_STRING;
			}
			if (Std.is(this, CmdArgCharList))
			{
				type = ArgType.ARG_LIST_CHAR;
			}
			
			parseError(ArgError.OPT_CONFLICT_REQUIRED, this, type, "");
			
			_syntaxFlags &= ~E_CmdArgSyntax.isOPT;
			return false;
		}
		
		if ((_syntaxFlags & E_CmdArgSyntax.isVALOPT > 0) && (_syntaxFlags & E_CmdArgSyntax.isVALREQ > 0))
		{
		   var type:Int = 0;
			
			if (Std.is(this, CmdArgBool))
			{
				type = ArgType.ARG_BOOL;
			}
			if (Std.is(this, CmdArgInt))
			{
				type = ArgType.ARG_INT;
			}
			if (Std.is(this, CmdArgFloat))
			{
				type = ArgType.ARG_FLOAT;
			}
			if (Std.is(this, CmdArgStr))
			{
				type = ArgType.ARG_STRING;
			}
			if (Std.is(this, CmdArgChar))
			{
				type = ArgType.ARG_CHAR;
			}
			
			if (Std.is(this, CmdArgIntList))
			{
				type = ArgType.ARG_LIST_INT;
			}
			if (Std.is(this, CmdArgFloatList))
			{
				type = ArgType.ARG_LIST_FLOAT;
			}
			if (Std.is(this, CmdArgStrList))
			{
				type = ArgType.ARG_LIST_STRING;
			}
			if (Std.is(this, CmdArgCharList))
			{
				type = ArgType.ARG_LIST_CHAR;
			}
			
			parseError(ArgError.OPT_CONFLICT_REQUIRED, this, type, "");
		   
			_syntaxFlags &= ~E_CmdArgSyntax.isVALREQ;
			return false;
		}
		
		return true;
	}
}