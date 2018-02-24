import * as sqlite3 from "sqlite3";
import { IGraphEdge } from 'a-star-for-async-data';

export interface IMapGraphEdge extends IGraphEdge {
	id: string;
}

export class MapDatabase
{
	private db: sqlite3.Database;
	public dbCount: number;
	public dbTime: number;
  private hValCache: { [key: string]: number };

	constructor(dbFilename: string)
	{
        this.db = new sqlite3.Database(dbFilename, sqlite3.OPEN_READWRITE);

        this.dbCount = 0;
        this.dbTime = 0;

        this.hValCache = {};
	}

	lookupHValForNodeId(nodeId: string) {
		if (typeof this.hValCache[String(nodeId)] === "undefined") {
			// console.log("hVal cache miss for " + nodeId);
			return Promise.resolve(1);
		} else {
			return Promise.resolve(this.hValCache[String(nodeId)]);
		}
	}

	public lookupExitArcsForNodeId = (nodeId: string) => {
		let db = this.db;
		let self = this;
		return new Promise<IMapGraphEdge[]>((resolve, reject) => {
	        this.dbCount++;
	        var queryStart = new Date();
			db.all(`
				SELECT
					[ExitTbl].[ExitID] AS [id], [ExitTbl].[FromID] AS [from], [ExitTbl].[ToID] AS [to], [ExitTbl].[ExitKindID],
					[ExitTbl].[Name] AS [OpenCmd], [ExitTbl].[Param] AS [OpenTgt], [ExitTbl].[Distance],
					[ExitTbl].[DirType] AS [DrawExitDirection], [ExitTbl].[DirToType] AS [DrawToDirection],
					[ExitTbl].[ExitIDTo], 1 AS [cost],
					[FromRoom].[X] [x1], [FromRoom].[Y] [y1], [FromRoom].[Z] [z1],
					[ToRoom].[X] [x2], [ToRoom].[Y] [y2], [ToRoom].[Z] [z2],
					[TargetRoom].[X] [x3], [TargetRoom].[Y] [y3], [TargetRoom].[Z] [z3]
				FROM
					[ExitTbl]
				INNER JOIN [ObjectTbl] [FromRoom] ON [FromRoom].[ObjID] = [ExitTbl].[FromID]
				INNER JOIN [ObjectTbl] [ToRoom] ON [ToRoom].[ObjID] = [ExitTbl].[ToID]
				INNER JOIN [ObjectTbl] [TargetRoom] ON [TargetRoom].[ObjID] = 640
				WHERE
					[FromID] = $nodeId
					`, { $nodeId: nodeId }, function (error, rows) {
				var queryEnd = new Date();
				self.dbTime += (queryEnd.getTime() - queryStart.getTime());
				if (error) {
					reject(error);
				} else {
					for (let id in rows) {
						let row = rows[id];
						let cost = Math.sqrt(
							Math.pow(row.x1 - row.x2, 2)
							+ Math.pow(row.y1 - row.y2, 2)
							+ Math.pow(row.z1 - row.z2, 2)
						);
						let hVal = Math.sqrt(
							Math.pow(row.x3 - row.x2, 2)
							+ Math.pow(row.y3 - row.y2, 2)
							+ Math.pow(row.z3 - row.z2, 2)
						);
						row.cost = cost;
						row.hVal = hVal;
						self.hValCache[String(row.to)] = hVal;
						// console.log(row);
						// console.log("Cost");
						// console.log(cost);
						// console.log("hVal");
						// console.log(hVal);
					}
					resolve(rows);
				}
			});
		});
	}

	private checkAvailability = (success: (_: number) => void, failure: (_: any) => void) =>
	{
        this.db.serialize(() => {
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
	    });
	}
}
