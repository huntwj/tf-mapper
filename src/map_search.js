var MapDb = require("./map_database.js");
var Astar = require("a-star-for-async-data")/*.Debug()*/;

function stringifyPath(searchResult) {
	var pathString = "";
	for (let edgeIdx in searchResult.path) {
		var edge = searchResult.path[edgeIdx];
		pathString += " " + edge.id;
	}
	pathString = searchResult.cost + pathString;
	return pathString;
}

class MapSearch
{
	constructor() {
		var db = this.db = new MapDb();
		this.astar = new Astar({
			exitArcsForNodeId: function(nodeId) {
				return db.lookupExitArcsForNodeId(nodeId);
			},
			getNodeId: function(node) {
				return node.id;
			}
		});
	}

	pathToRoom(startId, endId) {
		var db = this.db;
		var astar = this.astar;
		return new Promise(function(success, error) {
			astar.findPath(startId, endId)
			.then(function (path) {
				var stringifiedPath = stringifyPath(path);
				success(stringifiedPath);
			})
			.catch(function (reason) {
				var msg = "Error calling findPath: " + reason;
				error(msg);
			});
		}.bind(this));
	}
}

module.exports = MapSearch;
