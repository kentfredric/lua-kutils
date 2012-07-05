
-- Usage:
--
-- require 'kutils.pp'
--
-- io.write( kutils.pp( thing ) )
--
--

require "kutils.dispatch_generator"
local sys = {
	os = os,
	type = type,
	pairs = pairs,
	table = table,
	io = io,
	string = string,
	debug = debug,
	setmetatable = setmetatable,
}
local kutils = kutils;

module("kutils.pp")

kutils.dispatch_generator.init(_M)

_add_dispatch("pp_nil", "simple" , function(arg)
	return "nil"
end)

_add_dispatch("pp_string","simple", function(arg)
	return "string<\"" .. arg .. "\">"
end)
_add_dispatch("pp_number","simple", function(arg)
	return "number<" .. arg .. ">"
end)

_add_dispatch("pp_boolean","simple", function(arg)
	return "boolean<" .. arg .. ">"
end)

_add_dispatch("pp_table","simple",function(arg)
	return "table<?>"
end)


_add_dispatch("pp_table", "names", function(arg)
	local dmap = {}
	for i, v in sys.pairs( arg ) do
		sys.table.insert( dmap, i .. " = ?")
	end
	return pp_h_join("table<[" , dmap, "]>")
end)


local deep = 0;

_add_dispatch("pp_table", "recursive_0", function(arg)
	local dmap = {}
	for i, v in sys.pairs( arg ) do
		sys.table.insert( dmap,
			i .. " = " .. pp_table_leaf( i, v )
		)
	end
	return pp_v_join("table<{", dmap, "}>")
end)

_set_default("pp_table", "recursive_0")

_add_dispatch("pp_table_leaf", "simple", function(key,value)
	if key == "_M" then
		return "table<_M>"
	end
	local ret;
	 _lexical({ pp_table = "simple", pp_function = "simple" }, function( orig, new )
		ret = pp( value );
	end)
	
	return pp_indent( ret )
end)

_add_dispatch("pp_table_leaf", "recursive_0", function(key, value)
	if key == "_M" then
		return "table<_M>"
	end
	return pp_indent(  pp( value )   ) 
end)
_add_dispatch("pp_function", "simple", function( arg )
	return "function<?>"
end)
_add_dispatch("pp_function", "recursive_0", function( arg )
	local body = sys.debug.getinfo( arg )
	local dmap = {}
	for i, v in sys.pairs( body ) do
		sys.table.insert( dmap, i .. " = " .. pp_function_leaf( i, v ))
	end
	return pp_v_join("function<", dmap, ">" )
end)
_add_dispatch("pp_function_leaf", "simple", function(key,value)
	if key == "func" then
		return "function<func>"
	end
	return pp_indent(_lexical({ pp_table = "simple", pp_function = "simple" }, function( orig, new )
		return pp( value );
	end))
end)

_add_dispatch("pp_thread", "simple", function(arg)
	return "thread<?>"
end)

_add_dispatch("pp_userdata", "simple", function(arg)
	return "userdata<?>"
end)

_add_dispatch("pp_indent", "basic" , function( data )
	return sys.string.gsub( data, "\n", "\n\t" )
end)

_add_dispatch("pp_v_join", "basic" , function( fore, tabl, aft )
	return fore .. "\n\t" .. sys.table.concat( tabl, "\n\t" ) .. "\n" .. aft
end)

_add_dispatch("pp_h_join", "basic" , function( fore, tabl, aft )
	return fore .. " " .. sys.table.concat( tabl, ", " ) .. " " .. aft
end)

function pp ( arg )
	local t = sys.type( arg )
	return _dispatcher( "pp_" .. t )(arg);
end

sys.setmetatable( _M, {
	__call = function(self, ...)
		return pp(...)
	end
})
