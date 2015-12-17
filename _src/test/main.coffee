should = require('should')
_ = require('lodash')

NsqNodes = require( "../lib/main" )

test = require( "./data" )
utils = require './utils'

nsqnodes = null
nodeSimulator = null

CNF =
	lookupdHTTPAddresses: []
	lookupdPollInterval: .5
	nodeFilter: null

_testArray = ( inp, pred )->
	inp.length.should.equal( pred.length )

	for _t in pred when _t not in inp
		asrt = new should.Assertion(_t)
		asrt.params =
			operator: "be in `#{ pred.join( '`, `' ) }`"
		asrt.fail()
		
	return
	
_setAddresses = ( servers )->
	for server in servers
		CNF.lookupdHTTPAddresses.push server.address().address + "" + server.address().port
	return

describe "----- nsq-nodes TESTS -----", ->

	before ( done )->
		nodeSimulator = require( "./server" )
		nsqnodes = new NsqNodes( CNF )
		
		if nodeSimulator.running
			_setAddresses( nodeSimulator.servers )
			done()
			return
		
		nodeSimulator.on "running", ( servers )->
			# wait until simulation server is running
			_setAddresses( servers )
			done()
			return
		return

	after ( done )->
		done()
		return

	describe 'Main Tests', ->

		# Implement tests cases here
		it "initial value", ( done )->
			nsqnodes.list ( err, result )->
				throw err if err

				_testArray( utils.nn( result ), test.names() )

				done()
				return
			return
		
		it "add a node", ( done )->
			nsqnodes.list ( err, result )->
				throw err if err
				
				_before = test.names()
				_testArray( utils.nn( result ), _before )
				
				_nodesDiff = []
				
				_check = ( node )->
					_nodesDiff.should.containEql( utils.nn( node ) )
					nsqnodes.removeListener( "add", _check )
					done()
					return
					
				# listen to the add event
				nsqnodes.on( "add", _check )
				
				# step to the next test
				_nodesDiff = _.difference( test.next().names(), _before )
				
				return
			return
		
		it "add two nodes - listen to `add`", ( done )->
			nsqnodes.list ( err, result )->
				throw err if err
				
				
				_before = test.names()
				_testArray( utils.nn( result ), _before )
				
				_nodesDiff = []
				
				count = 2
				_test = ->
					if count <= 0
						done()
						nsqnodes.removeAllListeners()
					return
				
				_check = ( node )->
					_nodesDiff.should.containEql( utils.nn( node ) )
					count--
					_test()
					return
					
				# listen to the add event
				nsqnodes.on( "add", _check )
				
				# step to the next test
				_nodesDiff = _.difference( test.next().names(), _before )
				
				return
			return
		
		it "add two nodes - listen to `change`", ( done )->
			nsqnodes.list ( err, result )->
				throw err if err
				
				
				_before = test.names()
				_after = []

				_check = ( nodes )->
					_testArray( utils.nn( nodes ), _after )
					nsqnodes.removeAllListeners()
					done()
					return
					
				# listen to the add event
				nsqnodes.on( "change", _check )
					
				_after = test.next().names()
				
				return
			return
		
		it "remove a node", ( done )->
			
			
			_nodesDiff = []
			
			_check = ( node )->
				_nodesDiff.should.containEql( utils.nn( node ) )
				nsqnodes.removeAllListeners()
				done()
				return
				
			# listen to the add event
			nsqnodes.on( "remove", _check )
			
			# step to the next test
			_before = test.names()
			_nodesDiff = _.difference( _before, test.next().names() )
				
			return
		
		it "remove two nodes - listen to `remove`", ( done )->

			_before = test.names()
			
			_nodesDiff = []
			
			count = 2
			_test = ->
				count--
				if count <= 0
					done()
					nsqnodes.removeAllListeners()
				return
			
			_check = ( node )->
				_nodesDiff.should.containEql( utils.nn( node ) )
				_test()
				return
				
			# listen to the add event
			nsqnodes.on( "remove", _check )
			
			# step to the next test
			_nodesDiff = _.difference( _before, test.next().names() )

			return
		
		it "remove two nodes - listen to `change`", ( done )->

			_before = test.names()
			_after = []

			_check = ( nodes )->
				_testArray( utils.nn( nodes ), _after )
				nsqnodes.removeAllListeners()
				done()
				return
				
			# listen to the add event
			nsqnodes.on( "change", _check )
				
			_after = test.next().names()
			
			return
		
		it "add and remove nodes", ( done )->

			_before = test.names()
			_after = []
			
			count = 5
			_test = ->
				count--
				if count <= 0
					nsqnodes.list ( err, result )->
						throw err if err
						_testArray( utils.nn( result ), _after )
						done()
						nsqnodes.removeAllListeners()
						return
				return
			
			_checkAdd = ( node )->
				_nodesAdd.should.containEql( utils.nn( node ) )
				_test()
				return
			
			_checkRemove = ( node )->
				_nodesRem.should.containEql( utils.nn( node ) )
				_test()
				return
			
			_checkChange = ( nodes )->
				_testArray( utils.nn( nodes ), _after )
				_test()
				return
				
			# listen to the add event
			nsqnodes.on( "remove", _checkRemove )
			nsqnodes.on( "add", _checkAdd )
			nsqnodes.on( "change", _checkChange )
			
			# step to the next test
			_after = test.next().names()
			_nodesRem = _.difference( _before, _after )
			_nodesAdd = _.difference( _after, _before )

			return
		
		it "add filter", ( done )->
			
			_before = test.names()
			_nodesDiff = []
			
			count = 2
			_test = ->
				count--
				if count <= 0
					nsqnodes.removeAllListeners()
					
					nsqnodes.on "remove", ( node )->
						utils.nn( node ).should.startWith('_')
						nsqnodes.removeAllListeners()
						done()
						return
					
					# add a filter to hide node staring with "_"
					nsqnodes.filter ( node )->
						return utils.nn( node )[0] isnt "_"
						
				return
			
			_check = ( node )->
				_nodesDiff.should.containEql( utils.nn( node ) )
				_test()
				return
				
			# listen to the add event
			nsqnodes.on( "add", _check )
			
			# step to the next test
			_nodesDiff = _.difference( test.next().names(), _before )
			
			return
			
		it "remove filter", ( done )->
			nsqnodes.on "add", ( node )->
				utils.nn( node ).should.startWith('_')
				nsqnodes.removeAllListeners()
				done()
				return
			
			# add a filter to hide node staring with "_"
			nsqnodes.filter( null )
			return
			
		it "regex filter", ( done )->
			regexp = /^_|_$/ig
			
			count = test.len() - 2
			_test = ->
				count--
				if count <= 0
					done()
					nsqnodes.removeAllListeners()
				return
				
			nsqnodes.on "remove", ( node )->
				utils.nn( node ).should.not.match(regexp)
				_test()
				return
			
			# add a filter to hide node staring with "_"
			nsqnodes.filter( regexp )
			return
			
		it "set array filter", ( done )->
			@timeout( 6000 )
			count = test.len()
			_test = ->
				count--
				if count <= 0
					nsqnodes.removeAllListeners()
					
					_before = test.names()
					
					nsqnodes.on "add", ( node )->
						throw new Error( "Should not called!" )
						return
					
					test.next()
					
					_final = ->
						nsqnodes.removeAllListeners()
						done()
						return
					
					setTimeout( _final, 4000 )
				return
				
			nsqnodes.on "add", ( node )->
				_test()
				return
				
			nsqnodes.on "change", ( nodes )->
				_testArray( utils.nn( nodes ), test.names()  )
				_test()
				return
			
			# add a filter to hide node staring with "_"
			_arFilter = test.names()
			nsqnodes.filter( _arFilter )
			return
		
		it "try invalid filter", ( done )->
			( ->
				nsqnodes.filter( 42 )
			).should.throw( Error, { name: "EINVALIDFILTER" })
			done()
			return
		
		it "one lookup server down", ( done )->
			
			#reset filter
			nsqnodes.on "change", ->
				
				nsqnodes.removeAllListeners()
				
				nodeSimulator.stop(0)
				
				setTimeout( ->
					# listen to the add event
					nsqnodes.on "add", ( node )->
						_nodesDiff.should.containEql( utils.nn( node ) )
						nsqnodes.removeAllListeners()
						done()
						return
					
					# step to the next test
					_before = test.names()
					_nodesDiff = _.difference( test.next().names(), _before )
				
				, 1000 )
				return
				
			nsqnodes.filter( null )
			return
			
		it "all lookup servers down ... error event", ( done )->
			
			# listen to the add event
			nsqnodes.on "error", ( err )->
				should.exist( err )
				err.should.have.property( "name" ).and.equal( "EUNAVAILIBLE" )
				done()
				return
			
			nodeSimulator.stop(1)
			return
			
		return
	return



	
