var MapSearch = require("../src/map_search");

describe("Map search", function () {
	var mapSearch;

	beforeAll(function () {
		mapSearch = new MapSearch();
	});
/*
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
			expect(result).toBe("1 1413");
			done();
		}).catch(function (reason) {
			fail(reason);
		})
	});
*/
	it("should return a correct path from 501 (south gate) to 640 (weapon prac)", function (done) {
		mapSearch.pathToRoom(501, 640).then(function (result) {
			expect(result).toBe("1 1413");
			done();
		}).catch(function (reason) {
			fail(reason);
		})
	});
/*
	it("should return a correct long path from 501 to 12335", function (done) {
		mapSearch.pathToRoom(501, 12335).then(function (result) {
			expect(result).toBe("1 1413");
			done();
		}).catch(function (reason) {
			fail(reason);
		})
	});
*/
});