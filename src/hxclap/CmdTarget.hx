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
}

//Definition of class CmdArgStr
class CmdTargStr extends CmdTarget
{
	public var value:String;
	
	public function new(keyWord:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:String)
	{
		super(keyWord, valueName, description, syntaxFlags);
		
		value = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
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

//Definition of CmdArgTypeList
class CmdTargTypeList<T> extends CmdTarget
{
	public var list:Array<T>;
	public var index:Int;
	public var delimiters:String;
	public var max:Int;
	public var min:Int;
	
	public function new(keyWord:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ),
		minSize:Int = 1,
		maxSize:Int = 100,
		delim:String = ",-~/.")
	{
		super(keyWord, valueName, description, syntaxFlags);
		
		delimiters = delim;
		min = minSize;
		max = maxSize;
		list = [];
		
		var buf:String = "";
		buf = valueName;
		if (buf.length == 0)
			buf += " ";
		buf += " ..." + " " + valueName + ' (Min: $min Max: $max)';
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
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		return true;
	}
	
	public function getItem(Index:Int):T
	{
		Index = Index % list.length;
		while (index != Index)
		{
			if (index < Index)
			{
				index++;
			}
			else
			{
				index++;
			}
		}
		
		return list[index];
	}
	
	public function reset():Void
	{
		index = 0;
	}
	
	public function size():Int
	{
		return list.length;
	}
	
	public function insert(Item:T):Void
	{
		if (list.length < max)
		{
			list.push(Item);
		}
	}
	
	public function validate():Bool
	{
		if (list.length < min)
		{
			parseError(ArgError.TOO_FEW_ARGS, this, ArgType.ARG_LIST_INT, "");
			return false;
		}
		
		if (list.length > max)
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
			
			var tokens_arr:Array<String> = tokens.split(delimiters.charAt(0));
			
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