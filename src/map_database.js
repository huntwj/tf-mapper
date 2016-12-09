var sqlite3 = require("sqlite3").verbose();

class MapDatabase
{
	constructor()
	{
        this.db = new sqlite3.Database("map.sqlite", sqlite3.OPEN_READWRITE);
	}

	getNode(nodeId) {
		return new Promise(function (result, reason) {
			result({
				id: nodeId
			});
		});
	}

	lookupExitArcsForNodeId(nodeId) {
		let allEdges = [
			{ id: 1487, from: 474, to: 501, cost: 1 }
		];
		return new Promise(function (result, reason) {
			let edges = allEdges.filter(function (edge) {
				return String(edge.from) == nodeId;
			});
			result(edges);
		});
	}

	checkAvailability(success, failure)
	{
        this.db.serialize(function() {
	        this.db.all("select count(name) AS tblCount from sqlite_master where type='table'", function (err, tables) {
	        	if (err) {
	        		failure(err);
	        	} else {
	        		if (tables.length !== 1) {
	        			failure("invalid tables length");
	        		} else if (tables[0].tblCount > 0) {
	        			success(tables[0].tblCount);
	        		} else {
	        			failure("no tables?");
	        		}
	        	}
	        });
	    }.bind(this));

	}
}

module.exports = MapDatabase;
