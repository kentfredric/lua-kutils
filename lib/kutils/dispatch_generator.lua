
local sys  = {
	error = error,
	pairs = pairs,
}

-- == USAGE
-- 
-- require "kutils.dispatch_generator"
--
-- local kutils;
--
-- module("example");
--
-- kutils.dispatch_generator.init(_M)
--
-- _add_dispatch( "call_name" , "variant_name_1" , function_1  )
-- _add_dispatch( "call_name" , "variant_name_2" , function_2  )
-- _add_dispatch( "call_name" , "variant_name_3" , function_3  )
--
--  -- Call function_1 
--
-- call_name( "hello world" )   # calls function_1
--
-- -- Set the default for 'call_name' to 'variant_name_2'
-- 
-- _set_default( "call_name", "variant_name_2" )
--
-- -- Call function_2
--
-- call_name("hello world" ) 
--
-- -- Call function_2 regardless.
--
-- _dispatcher("call_name", "variant_name_2" )( "hello world" ) 
--

module("kutils.dispatch_generator")

function init( user_table )

	user_table._config = {}
	user_table._dispatch = {}
	user_table._dispatcher = function( meth, tech )
		local m = user_table._config[ meth ];
		if technique then
			m = technique
		end
		if not m then
			sys.error("No dispatch method chosen for method " .. meth )
		end
		local functions = user_table._dispatch[ meth ];
		if not functions then
			sys.error( "Delegate dispatch table for method " .. meth .. " missing")
		end
		local fun = functions[m]
		if not fun then
			sys.error( "Delegate method " .. m .. " for method " .. meth .. " is missing")
		end
		return fun
	end
	user_table._add_dispatch = function ( call_name, variant_name, fun ) 
		if not user_table._config[ call_name ] then
			user_table._config[ call_name ] = variant_name
		end
		if not user_table[ call_name ] then
			user_table[ call_name ] = function( ... )
				return user_table._dispatcher( call_name )( ... )
			end
		end
		if not user_table._dispatch[ call_name ] then
			user_table._dispatch[ call_name ] = {}
		end
		user_table._dispatch[ call_name ][ variant_name ] = fun
	end
	user_table._set_default = function ( call_name, variant_name )
		if not user_table._config[ call_name ] then
			sys.error( "Cannot change default for " .. call_name .. " as it is not configured");
		end
		if not user_table._dispatch[ call_name ] then
			sys.error( "Cannot change default for " .. call_name .. " as it has no delegates");
		end
		if not user_table._dispatch[ call_name ][ variant_name ] then
			sys.error( "Cannot change default for " .. call_name .. " to " .. variant_name .. " as the specified variant is not in the delegate table")
		end
		user_table._config[ call_name ] = variant_name
	end
	user_table._lexical = function ( opts,  func )

		local orig = {}

		for i, v in sys.pairs( opts ) do
			orig[i] = user_table._config[ i ]
			user_table._config[ i ] = v
		end

		local result = func( orig, opts )

		for i, v in sys.pairs( orig ) do
			user_table._config[ i ] = v
		end

		return result

	end
end
