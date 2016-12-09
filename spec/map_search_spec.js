var MapSearch = require("../src/map_search");

describe("Map search", function () {
	var mapSearch;

	beforeAll(function () {
		mapSearch = new MapSearch();
	});

	it("should return a successful empty path when start is goal", function (done) {
		mapSearch.pathToRoom(474, 474).then(function (result) {
			expect(result).toBe("0");
			done();
		}).catch(function (reason) {
			fail(reason);
		});
	});

	it("should return a single edge path when start is adjacent to goal", function (done) {
		mapSearch.pathToRoom(474, 501).then(function (result) {
			expect(result).toBe("1 1487");
			done();
		}).catch(function (reason) {
			fail(reason);
		})
	});
});