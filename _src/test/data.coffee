utils = require( "./utils" )

genNode = (namepre = "")->
	_name = utils.randomString( 5, 0 )
	_port = utils.randRange( 4150, 4199 )

	data = 
		"remote_address": "127.0.0.1:54900"
		"hostname": ( namepre + "MachineName.#{_name}" )
		"broadcast_address": "MachineName.#{_name}"
		"tcp_port": _port
		"http_port": _port+1
		"version": "0.3.6"
		"tombstones": []
		"topics": []
	return data
	
nodes = []
for idx in [ 0..3 ]
	nodes.push genNode()

_data = [
	utils.clone( ( nodes ) ),
	utils.clone( ( nodes.push( genNode() ); nodes ) ),
	utils.clone( ( nodes.push( genNode() ); nodes.push( genNode() ); nodes ) ),
	utils.clone( ( nodes.push( genNode() ); nodes.push( genNode() ); nodes ) ),
	utils.clone( ( nodes.splice(0,1); nodes ) ),
	utils.clone( ( nodes.splice(0,2); nodes ) ),
	utils.clone( ( nodes.splice(0,2); nodes ) ),
	utils.clone( ( nodes.push( genNode() ); nodes.push( genNode() ); nodes.splice(0,2); nodes ) ),
	utils.clone( ( nodes.push( genNode("_") ); nodes.push( genNode("_")); nodes ) ),
	utils.clone( ( nodes.push( genNode() ); nodes.push( genNode() ); nodes ) ),
	utils.clone( ( nodes.push( genNode() ); nodes ) ),
	utils.clone( ( nodes.push( genNode() ); nodes ) )
]
_len = _data.length

idx = 0
_current = ->
	if idx >= _len
		return _data[ _len - 1 ]
	return _data[ idx ]
	
fn = ->
	_resp =
		"producers": _current()
	return _resp
	
	
fn.next = ->
	idx++
	return @

fn.len = ->
	return _current().length
	

fn.list = ->
	return _current()

fn.names = ->
	return utils.nn( _current() )
	
module.exports = fn
