import * as sqlite3 from "sqlite3";
import { IGraphEdge } from 'a-star-for-async-data';

export interface IMapGraphEdge extends IGraphEdge {
	id: string;

	fromX: number;
	fromY: number;
	fromZ: number;

	toX: number;
	toY: number;
	toZ: number;

	targetX: number;
	targetY: number;
	targetZ: number;

	hVal: number;
}

export class MapDatabase {
	private db: sqlite3.Database;
	public dbCount: number;
	private hValCache: { [key: string]: number };

	constructor(dbFilename: string) {
		this.db = new sqlite3.Database(dbFilename, sqlite3.OPEN_READWRITE);

		this.dbCount = 0;

		this.hValCache = {};
	}

	lookupHValForNodeId(nodeId: string) {
		if (typeof this.hValCache[String(nodeId)] === "undefined") {
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
			db.all(`
				SELECT
					[ExitTbl].[ExitID] AS [id], [ExitTbl].[FromID] AS [from], [ExitTbl].[ToID] AS [to], [ExitTbl].[ExitKindID],
					[ExitTbl].[Name] AS [OpenCmd], [ExitTbl].[Param] AS [OpenTgt], [ExitTbl].[Distance],
					[ExitTbl].[DirType] AS [DrawExitDirection], [ExitTbl].[DirToType] AS [DrawToDirection],
					[ExitTbl].[ExitIDTo], 1 AS [cost],
					[FromRoom].[X] [fromX], [FromRoom].[Y] [fromY], [FromRoom].[Z] [fromZ],
					[ToRoom].[X] [toX], [ToRoom].[Y] [toY], [ToRoom].[Z] [toZ],
					[TargetRoom].[X] [targetX], [TargetRoom].[Y] [targetY], [TargetRoom].[Z] [targetZ]
				FROM
					[ExitTbl]
				INNER JOIN [ObjectTbl] [FromRoom] ON [FromRoom].[ObjID] = [ExitTbl].[FromID]
				INNER JOIN [ObjectTbl] [ToRoom] ON [ToRoom].[ObjID] = [ExitTbl].[ToID]
				INNER JOIN [ObjectTbl] [TargetRoom] ON [TargetRoom].[ObjID] = 640
				WHERE
					[FromID] = $nodeId
					`, { $nodeId: nodeId }, function(error, rows: IMapGraphEdge[]) {
					if (error) {
						reject(error);
					} else {
						rows.forEach((row) => {
							// const cost = Math.sqrt(
							// 	Math.pow(row.fromX - row.toX, 2)
							// 	+ Math.pow(row.fromY - row.toY, 2)
							// 	+ Math.pow(row.fromZ - row.toZ, 2)
							// );
							const hVal = Math.sqrt(
								Math.pow(row.targetX - row.toX, 2)
								+ Math.pow(row.targetY - row.toY, 2)
								+ Math.pow(row.targetZ - row.toZ, 2)
							);
							// row.cost = cost;
							row.hVal = hVal;
							self.hValCache[String(row.to)] = hVal;
						});
						resolve(rows);
					}
				});
		});
	}

	private checkAvailability = (success: (_: number) => void, failure: (_: any) => void) => {
		this.db.serialize(() => {
			this.db.all("select count(name) AS tblCount from sqlite_master where type='table'", function(err, tables) {
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
