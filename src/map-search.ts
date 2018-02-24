import { Astar, IGraphPath, IGraphEdge, GraphNode } from "a-star-for-async-data";
import { MapDatabase, IMapGraphEdge } from "./map-database";

function stringifyPath(searchResult: IGraphPath<IMapGraphEdge>) {
	let pathString = "";
	for (let edgeIdx in searchResult.path) {
		let edge = searchResult.path[edgeIdx];
		pathString += " " + edge.id;
	}
	pathString = searchResult.cost + pathString;
	return pathString;
}

export class MapSearch {
	private db: MapDatabase;
	private astar: Astar<IMapGraphEdge>;

	constructor(dbFilename: string) {
		this.db = new MapDatabase(dbFilename);
		this.astar = new Astar<IMapGraphEdge>({
			exitArcsForNodeId: (nodeId: GraphNode) => this.db.lookupExitArcsForNodeId(nodeId),
			h: (target: GraphNode, nodeId: GraphNode) => this.db.lookupHValForNodeId(nodeId)
		});
	}

	pathToRoom(startId: GraphNode, endId: GraphNode) {
		var db = this.db;
		var astar = this.astar;

		var start = new Date();
		return new Promise<string>((success, error) => {
			astar.findPath(startId, endId)
				.then((path: IGraphPath<IMapGraphEdge>) => {
					var stringifiedPath = stringifyPath(path);
					var end = new Date();
					// console.log("hVal cache:");
					// console.log(db.hValCache);
					console.log("Path calculated in " + (end.getTime() - start.getTime()) + "ms with " + db.dbCount + " calls to the database using " + db.dbTime + "ms of that time.");

					success(stringifiedPath);
				})
				.catch(function(reason: any) {
					var msg = "Error calling findPath: " + reason;
					error(msg);
				});
		});
	}
}
