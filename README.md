nsq-nodes
============

[![Build Status](https://secure.travis-ci.org/mpneuried/nsq-nodes.png?branch=master)](http://travis-ci.org/mpneuried/nsq-nodes)
[![Build Status](https://david-dm.org/mpneuried/nsq-nodes.png)](https://david-dm.org/mpneuried/nsq-nodes)
[![NPM version](https://badge.fury.io/js/nsq-nodes.png)](http://badge.fury.io/js/nsq-nodes)

Nsq helper to poll a nsqlookupd service for all it's nodes and mirror it locally.

[![NPM](https://nodei.co/npm/nsq-nodes.png?downloads=true&stars=true)](https://nodei.co/npm/nsq-nodes/)

**INFO: all examples are written in coffee-script**

## Install

```
  npm install nsq-nodes
```

## Initialize

```js
new NsqNodes( config );
```

**Example:**

```js
var NsqNodes = require( "nsq-nodes" )

var nodes = new NsqNodes({
    // Listen to two local nsq lookupservers
    "lookupdHTTPAddresses": [ "127.0.0.1:4161", "127.0.0.1:4163" ]
});

// get the current list of nodes
nodes.list( function( err, nodes ){
    if( err ){
        // handle the error
    }
    console.log( nodes ) // -> an array of nodes. E.g.: ( )`users`, `logins`, ... )


    // listen for new nodes
    nodes.on( "add", function( node ){
        // called until a new node arrived
    });

    // listen for removed nodes
    nodes.on( "remove", function( node ){
        // called until a node was removed
    });

    // listen for node list changes
    nodes.on( "change", function( nodeList ){
        // beside the `add` and `remove` events a single "change" event will be emitted
    });

    // listen for errors
    nodes.on( "error", function( err ){
        // E.g. called if a invalid filter was used or no lookup server is available
    });

});
```

**Config** 

- **lookupdHTTPAddresses** : *( `String|String[]` required )* A single or multiple nsqlookupd hosts. *This is also a configuration of ['nsqjs'](https://github.com/dudleycarr/nsqjs)*
- **lookupdPollInterval** : *( `Number` optional: default = `60` )* Time in seconds to poll the nsqlookupd servers to sync the available nodes. *This is also a configuration of ['nsqjs'](https://github.com/dudleycarr/nsqjs)*
- **active** : *( `Boolean` optional: default = `true` )* Configuration to (de)activate the nsq nodes on startup


## Methods

### `.activate()`

Activate the module

**Return**

*( Boolean )*: `true` if it is now activated. `false` if it was already active

### `.deactivate()`

Deactivate the module

**Return**

*( Boolean )*: `true` if it is now deactivated. `false` if it was already inactive

### `.active()`

Test if the module is currently active

**Return**

*( Boolean )*: Is active?

### `.list( cb )`

Get a list of the current nodes

* `cb` : *( `Function` optional )*: Callback to get the list of nodes

**Return**

*( Self )*: The instance itself for chaining.

**Example:**

```js
nodes.list( function( err, nodes ){
    if( err ){
        // handle the error
    }
    console.log( nodes ) // -> an array of nodes. E.g.: ( )`users`, `logins`, ... )
});
```

## Events

### `add`

A new node was added

**Arguments** 

- **node** : *( `String` )* The new node

**Example:**

```js
nodes.on( "add", function( node ){
    // called until a new node arrived
});
```

### `remove`

A existing node was removed

**Arguments** 

- **node** : *( `String` )* The removed node

**Example:**

```js
nodes.on( "remove", function( node ){
    // called until a node was removed
});
```

### `change`

The list of nodes changed

**Arguments** 

- **nodes** : *( `String[]` )* A list of current nodes

**Example:**

```js
nodes.on( "change", function( nodeList ){
    // beside the `add` and `remove` events a single "change" event will be emitted
});
```

### `error`

An error occurred. E.g. called if a invalid filter was used or no lookup server is available

**Arguments** 

- **err** : *( `Error` )* The error object. 

**Example:**

```js
nodes.on( "error", function( err ){
    // handle the error
});
```

### `ready`

Emitted once the list of nodes where received the first time.
This is just an internal helper. The Method `list` will also wait for the first response. The events `add`, `remove` and `change` are active after this first response.
**Example:**

```js
nodes.on( "ready", function( err ){
    // handle the error
});
```

## Release History
|Version|Date|Description|
|:--:|:--:|:--|
|0.0.1|2015-11-27|Initial commit|

[![NPM](https://nodei.co/npm-dl/nsq-nodes.png?months=6)](https://nodei.co/npm/nsq-nodes/)

> Initially Generated with [generator-mpnodemodule](https://github.com/mpneuried/generator-mpnodemodule)
## Other projects

|Name|Description|
|:--|:--|
|[**nsq-logger**](https://github.com/mpneuried/nsq-logger)|Nsq service to read messages from all topics listed within a list of nsqlookupd services.|
|[**nsq-topics**](https://github.com/mpneuried/nsq-topics)|Nsq helper to poll a nsqlookupd service for all it's topics and mirror it locally.|
|[**nsq-watch**](https://github.com/mpneuried/nsq-watch)|Watch one or many topics for unprocessed messages.|
|[**node-cache**](https://github.com/tcs-de/nodecache)|Simple and fast NodeJS internal caching. Node internal in memory cache like memcached.|
|[**rsmq**](https://github.com/smrchy/rsmq)|A really simple message queue based on redis|
|[**redis-heartbeat**](https://github.com/mpneuried/redis-heartbeat)|Pulse a heartbeat to redis. This can be used to detach or attach servers to nginx or similar problems.|
|[**systemhealth**](https://github.com/mpneuried/systemhealth)|Node module to run simple custom checks for your machine or it's connections. It will use [redis-heartbeat](https://github.com/mpneuried/redis-heartbeat) to send the current state to redis.|
|[**rsmq-cli**](https://github.com/mpneuried/rsmq-cli)|a terminal client for rsmq|
|[**rest-rsmq**](https://github.com/smrchy/rest-rsmq)|REST interface for.|
|[**redis-sessions**](https://github.com/smrchy/redis-sessions)|An advanced session store for NodeJS and Redis|
|[**connect-redis-sessions**](https://github.com/mpneuried/connect-redis-sessions)|A connect or express middleware to simply use the [redis sessions](https://github.com/smrchy/redis-sessions). With [redis sessions](https://github.com/smrchy/redis-sessions) you can handle multiple sessions per user_id.|
|[**redis-notifications**](https://github.com/mpneuried/redis-notifications)|A redis based notification engine. It implements the rsmq-worker to safely create notifications and recurring reports.|
|[**hyperrequest**](https://github.com/mpneuried/hyperrequest)|A wrapper around [hyperquest](https://github.com/substack/hyperquest) to handle the results|
|[**task-queue-worker**](https://github.com/smrchy/task-queue-worker)|A powerful tool for background processing of tasks that are run by making standard http requests
|[**soyer**](https://github.com/mpneuried/soyer)|Soyer is small lib for server side use of Google Closure Templates with node.js.|
|[**grunt-soy-compile**](https://github.com/mpneuried/grunt-soy-compile)|Compile Goggle Closure Templates ( SOY ) templates including the handling of XLIFF language files.|
|[**backlunr**](https://github.com/mpneuried/backlunr)|A solution to bring Backbone Collections together with the browser fulltext search engine Lunr.js|
|[**domel**](https://github.com/mpneuried/domel)|A simple dom helper if you want to get rid of jQuery|
|[**obj-schema**](https://github.com/mpneuried/obj-schema)|Simple module to validate an object by a predefined schema|

## The MIT License (MIT)

Copyright © 2015 M. Peter, http://www.tcs.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
