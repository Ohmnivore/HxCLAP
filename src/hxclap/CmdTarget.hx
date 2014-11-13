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

//Definition of class CmdArg
class CmdTarget extends CmdElem
{
	public function new(keyWord:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ)) 
	{
		super(keyWord, valueName, description, syntaxFlags);
		
		isArg = false;
	}
	
	override public function getOptChar():String 
	{
		return getKeyword();
	}
}

//Definition of class CmdArgStr
class CmdTargStr extends CmdTarget
{
	public var _v:String;
	
	public function new(keyWord:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:String)
	{
		super(keyWord, valueName, description, syntaxFlags);
		
		_v = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		if (i < argc)
		{
			var arg:String = argv[i];
			
			if (arg.charAt(0) == "-") return false;
			_v = arg;
			setParseOK();
			return true;
		}
		
		else
			return false;
	}
}

//Definition of CmdArgTypeList
class CmdTargTypeList<T> extends CmdTarget
{
	public var _list:Array<T>;
	public var _index:Int;
	public var _delimiters:String;
	public var _max:Int;
	public var _min:Int;
	
	public function new(keyWord:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ),
		minSize:Int = 1,
		maxSize:Int = 100,
		delim:String = ",-~/.")
	{
		super(keyWord, valueName, description, syntaxFlags);
		
		_delimiters = delim;
		_min = minSize;
		_max = maxSize;
		_list = [];
		
		var buf:String = "";
		buf = getValueName();
		if (buf.length == 0)
			buf += " ";
		buf += " ..." + " " + getValueName() + ' (Min: $_min Max: $_max)';
		setValueName(buf);
		
		buf = "";
		buf += '$description';
		setDescription(buf);
		
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

//Definition of class CmdArgStrList
class CmdTargStrList extends CmdTargTypeList<String>
{
	public function new(keyWord:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(keyWord, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		//i++;
		
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