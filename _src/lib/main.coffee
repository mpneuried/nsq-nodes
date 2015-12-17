# # NsqNodes Module
# ### extends [Basic](basic.coffee.html)
#
# Fetch all availibable tocis from the lookup servers and keep them in sync

# **npm modules**
async = require( "async" )
_ = require( "lodash" )

# **internal modules**
request = require( "hyperrequest" )

NODES = {}

class NsqNodes extends require( "mpbasic" )()


	# ## defaults
	defaults: =>
		@extend super,
			# **lookupdHTTPAddresses** *String|String[]* A single or multiple nsqlookupd hosts.
			lookupdHTTPAddresses: [ "127.0.0.1:4161", "127.0.0.1:4163" ]
			# **lookupdHTTPAddresses** *Number* Time in seconds to poll the nsqlookupd servers to sync the availible nodes
			lookupdPollInterval: 60
			# **nodeFilter** *Null|String|Array|RegExp|Function* A filter to reduce the returned nodes
			nodeFilter: null
			# **active** *Boolean* Configuration to (de)activate the nsq nodes
			active: true

	constructor: ->
		@ready = false
		
		super
		
		@list = @_waitUntil( @_list, "ready" )
		
		@_start()
		return
	
	_start: =>
		if not @config.active
			@warning "nsq nodes disabled"
			return
			
		@filter( @config.nodeFilter )
		@fetchNodes()
		@_interval = setInterval( @fetchNodes, @config.lookupdPollInterval * 1000 )
		return
	
	active: =>
		return @config.active
			
	activate: =>
		if @config.active
			return false
		@config.active = true
		clearInterval( @_interval )
		@start()
		return true
	
	deactivate: =>
		if not @config.active
			return false
		@config.active = false
		clearInterval( @_interval )
		return true
	
	_list: ( cb )->
		process.nextTick ->
			cb( null, _.values( NODES ) )
			return
		return @

	fetchNodes: =>
		if not @config.active
			@warning "nsq nodes disabled"
			return
		
		if _.isString( @config.lookupdHTTPAddresses )
			aFns = [ @_fetch( @config.lookupdHTTPAddresses ) ]
		else
			aFns = for host in @config.lookupdHTTPAddresses
				@_fetch( host )
		
		async.parallel aFns, ( err, results )=>
			if err
				@error "multi fetch", err
				return
				
			aNodes = _.compact( results )
			if not aNodes.length
				_err = @_handleError( true, "EUNAVAILIBLE" )
				
				if @listeners( "error" )?.length
					@emit "error", _err
				else
					throw _err
				return
			
			_nodes = {}
			_nodesnames = []
			for _nds in aNodes when _nds?
				for _nd in _nds when _nd.node not in _nodesnames and @_checkNode( _nd )
					_nodesnames.push( _nd.node )
					_nodes[ _nd.node ] = _nd.data

			@debug "nodes found", _nodes
			if not @ready
				# initial
				NODES = _nodes
				@ready = true
				@emit "ready", NODES
				return

			@debug "nodes", _nodes

			@_setNodeList( _nodes )

			return
		return
		
	_setNodeList: ( _nodes )=>
		_removedNodes = _.difference( Object.keys( NODES ), Object.keys( _nodes ) )
		_newNodes = _.difference( Object.keys( _nodes ), Object.keys( NODES ) )
		
		if not _removedNodes.length and not _newNodes.length
			@debug "no node change"
			return

		_oldNodes = NODES
		NODES = _nodes

		@emit( "change", _.values( NODES ) )
		for _nd in _newNodes
			@emit( "add", NODES[ _nd ] )
		for _nd in _removedNodes
			@emit( "remove", _oldNodes[ _nd ] )
		return

	_checkNode: ( testNode )=>
		if not @nodeFilter?
			return true
		return @nodeFilter( testNode.data, testNode.node )

	filter: ( filter )=>
		if not filter?
			# delete teh current filter
			@nodeFilter = null
		
		else if _.isString( filter )
			# if the string filter starts with "regexp:" interpret it as a regular expression
			if filter[0..6] is "regexp:"
				regexp = new RegExp(filter[7..])
				@nodeFilter = ( node, name )->
					return regexp.test( name )

			@nodeFilter = ( node, name )->
				return name is filter

		else if _.isArray( filter )
			@nodeFilter = ( node, name )->
				return name in filter

		else if _.isFunction( filter )
			@nodeFilter = ( node, name )->
				return filter( node, name )

		else if _.isRegExp( filter )
			@nodeFilter = ( node, name )->
				return filter.test( name )
		
		else
			_err = @_handleError( true, "EINVALIDFILTER" )
			@emit "error", _err
			throw _err
			return
		
		# run filter on current list
		_nodes = {}
		for _nn, _nd of NODES when @_checkNode( { node: _nn, data: _nd } )
			_nodes[ _nn ] = _nd
		
		@_setNodeList( _nodes )

		return @

	_prepareUrl: ( host )->
		return "http://" + host + "/nodes"

	_fetch: ( host )=>
		return ( cb )=>
			request { url: @_prepareUrl( host ) }, ( err, result )=>
				if err
					@warning "fetch nodes", err
					cb( null, null )
					return

				if _.isString( result.body )
					_body = JSON.parse( result.body )
				else
					_body = result.body

				if _body.status_code is 200
					cb( null, @_processReturn( _body.data ) )
				return
			return

	_processReturn: ( raw )=>
		if not raw?.producers?.length
			return []

		nodes = []
		for prod in raw.producers
			nodes.push( node: @genName( prod ), data: prod )
		return nodes

	genName: ( prod )=>
		if _.isArray( prod )
			_names = for _pr in prod
				@genName( _pr )
			return _names
		return prod.hostname + "_" + prod.http_port

	ERRORS: =>
		@extend super,
			"EUNAVAILIBLE": [ 404, "No nsq-lookup servers availible" ]
			"EINVALIDFILTER": [ 500, "Only `null` valiables of type `String`, `Array`, `Function` or `RegExp` are allowed as filter" ]

module.exports = NsqNodes
