package hxclap;

import hxclap.CmdLine.ArgType;

/**
 * ...
 * @author Ohmnivore
 */

class E_CmdArgStatus
{
	public static inline var isBAD:Int       = 0x00;  // bad status
	public static inline var isFOUND:Int     = 0x01;  // argument was found in the command line
	public static inline var isVALFOUND:Int  = 0x02;  // the value of the argument was found in the command line
	public static inline var isPARSEOK:Int   = 0x04;   // argument was found and its value is ok
}

class E_CmdArgSyntax
{
	public static inline var isOPT:Int       = 0x01;  // argument is optional
	public static inline var isREQ:Int       = 0x02;  // argument is required
	public static inline var isVALOPT:Int    = 0x04;  // argument value is optional
	public static inline var isVALREQ:Int    = 0x08;  // argument value is required
	public static inline var isHIDDEN:Int    = 0x10;  // argument is not to be printed in usage    
}

class ArgError
{
	public static inline var OPT_CONFLICT_REQUIRED:Int = -1;
	public static inline var INVALID_ARG:Int = -2;
	public static inline var SPACE_DELIMITER:Int = -3;
	public static inline var TOO_FEW_ARGS:Int = -4;
	public static inline var TOO_MANY_ARGS:Int = -5;
}

//Definition of class CmdArg
class CmdArg extends CmdElem
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ)) 
	{
		this.optChar = optChar;
		
		super(keyword, valueName, description, syntaxFlags);
	}
}

//Definition of class CmdArgInt
class CmdArgInt extends CmdArg
{
	public var value:Int;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:Int = 0)
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		value = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		var ptr:String;
		i++;
		
		if (i < argc)
		{
			var arg:String = argv[i];
			
			try
			{
				value = Std.parseInt(arg);
			}
			
			catch (e:Dynamic)
			{
				parseError(ArgError.INVALID_ARG, this, ArgType.ARG_INT, arg);
				return false;
			}
			
			setParseOK();
			return true;
		}
		
		else
		{
			return false;
		}
	}
}

//Definition of class CmdArgFloat
class CmdArgFloat extends CmdArg
{
	public var value:Float;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:Float = 0)
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		value = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		var ptr:String;
		i++;
		
		if (i < argc)
		{
			var arg:String = argv[i];
			
			try
			{
				value = Std.parseFloat(arg);
			}
			
			catch (e:Dynamic)
			{
				parseError(ArgError.INVALID_ARG, this, ArgType.ARG_FLOAT, arg);
				return false;
			}
			
			setParseOK();
			return true;
		}
		
		else
		{
			return false;
		}
	}
}

//Definition of class CmdArgBool
class CmdArgBool extends CmdArg
{
	public var value:Bool;
	
	public function new(optChar:String, keyword:String, description:String, syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ))
	{
		super(optChar, keyword, "", description, syntaxFlags);
		
		value = false;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		value = true;
		setParseOK();
		return true;
	}
}

//Definition of class CmdArgStr
class CmdArgStr extends CmdArg
{
	public var value:String;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:String)
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		value = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var arg:String = argv[i];
			
			if (arg.charAt(0) == "-") return false;
			value = arg;
			setParseOK();
			return true;
		}
		
		else
			return false;
	}
}

//Definition of class CmdArgChar
class CmdArgChar extends CmdArg
{
	public var value:String;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:String)
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		value = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var arg:String = argv[i];
			
			if (arg.length > 1)
			{
				parseError(ArgError.INVALID_ARG, this, ArgType.ARG_CHAR, arg);
				return false;
			}
			
			value = arg.charAt(0);
			setParseOK();
			return true;
		}
		
		else
			return false;
	}
}

//Definition of CmdArgTypeList
class CmdArgTypeList<T> extends CmdArg
{
	public var _list:Array<T>;
	public var _index:Int;
	public var _delimiters:String;
	public var _max:Int;
	public var _min:Int;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ),
		minSize:Int = 1,
		maxSize:Int = 100,
		delim:String = ",-~/.")
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		_delimiters = delim;
		_min = minSize;
		_max = maxSize;
		_list = [];
		
		var buf:String = "";
		buf = valueName;
		if (buf.length == 0)
			buf += " ";
		buf += _delimiters.charAt(0) + " ..." + _delimiters.charAt(0) + " " + valueName + ' (Min: $_min Max: $_max)';
		valueName = buf;
		
		buf = "";
		buf += '$description';
		description = buf;
		
		var i:Int = 0;
		while (i < delim.length)
		{
			if (delim.charAt(i) == ' ')
			{
				parseError(ArgError.SPACE_DELIMITER, this, ArgType.ARG_LIST_STRING, "");
			}
			
			i++;
		}
	}
	
	public function getDelimiters():String
	{
		return _delimiters;
	}
	
	public function getMaxSize():Int
	{
		return _max;
	}
	
	public function getMinSize():Int
	{
		return _min;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		return true;
	}
	
	public function getItem(Index:Int):T
	{
		Index = Index % _list.length;
		while (_index != Index)
		{
			if (_index < Index)
			{
				_index++;
			}
			else
			{
				_index++;
			}
		}
		
		return _list[_index];
	}
	
	public function reset():Void
	{
		_index = 0;
	}
	
	public function size():Int
	{
		return _list.length;
	}
	
	public function insert(Item:T):Void
	{
		if (_list.length < _max)
		{
			_list.push(Item);
		}
	}
	
	public function validate():Bool
	{
		if (_list.length < _min)
		{
			parseError(ArgError.TOO_FEW_ARGS, this, ArgType.ARG_LIST_INT, "");
			return false;
		}
		
		if (_list.length > _max)
		{
			parseError(ArgError.TOO_MANY_ARGS, this, ArgType.ARG_LIST_INT, "");
			return false;
		}
		
		reset();
		setParseOK();
		return true;
	}
}

//Definition of class CmdArgIntList
class CmdArgIntList extends CmdArgTypeList<Int>
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(optChar, keyword, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var tokens:String = argv[i];
			
			var tokens_arr:Array<String> = tokens.split(_delimiters.charAt(0));
			
			for (v in tokens_arr)
			{
				var value:Dynamic = Std.parseInt(v);
				
				if (value != null)
				{
					insert(value);
				}
				else
				{
					parseError(ArgError.INVALID_ARG, this, ArgType.ARG_LIST_INT, v);
					return false;
				}
			}
			
			return validate();
		}
		
		else
			return false;
	}
}

//Definition of class CmdArgFloatList
class CmdArgFloatList extends CmdArgTypeList<Float>
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(optChar, keyword, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var tokens:String = argv[i];
			
			var tokens_arr:Array<String> = tokens.split(_delimiters.charAt(0));
			
			for (v in tokens_arr)
			{
				var value:Dynamic = Std.parseFloat(v);
				
				if (value != null)
				{
					insert(value);
				}
				else
				{
					parseError(ArgError.INVALID_ARG, this, ArgType.ARG_LIST_FLOAT, v);
					return false;
				}
			}
			
			return validate();
		}
		
		else
			return false;
	}
}

//Definition of class CmdArgStrList
class CmdArgStrList extends CmdArgTypeList<String>
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(optChar, keyword, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var tokens:String = argv[i];
			
			var tokens_arr:Array<String> = tokens.split(_delimiters.charAt(0));
			
			for (v in tokens_arr)
			{
				insert(v);
			}
			
			return validate();
		}
		
		else
			return false;
	}
}

//Definition of class CmdArgCharList
class CmdArgCharList extends CmdArgTypeList<String>
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(optChar, keyword, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var tokens:String = argv[i];
			
			var tokens_arr:Array<String> = tokens.split(_delimiters.charAt(0));
			
			for (v in tokens_arr)
			{
				v = StringTools.trim(v);
				
				if (v.length == 1)
				{
					insert(v);
				}
				else
				{
					parseError(ArgError.INVALID_ARG, this, ArgType.ARG_LIST_CHAR, v);
				}
			}
			
			return validate();
		}
		
		else
			return false;
	}
}