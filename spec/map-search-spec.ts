import { MapSearch } from "../src/map-search";

let profile = false;

describe("Map search", function () {
	let mapSearch: MapSearch;
	let start: number;

	beforeAll(function () {
		mapSearch = new MapSearch("/path/to/map.sqlite");
	});

	if (profile) {
		beforeEach(() => {
			start = Date.now();
		});

		afterEach(() => {
			const end = Date.now();
			console.log(`Test took ${end - start}ms to execute.`)
		});
	}

	it("should return a successful empty path when start is goal", function (done) {
		mapSearch.pathToRoom("474", "474").then(function (result) {
			expect(result).toBe("0");
			done();
		}).catch(function (reason) {
			fail(reason);
		});
	});

	it("should return a single edge path when start is adjacent to goal", function (done) {
		mapSearch.pathToRoom("474", "501").then(function (result) {
			expect(result).toBe("1 1413");
			done();
		}).catch(function (reason) {
			fail(reason);
		})
	});

	it("should return a correct path from 501 (south gate) to 640 (weapon prac)", function (done) {
		mapSearch.pathToRoom("501", "640").then(function (result) {
			expect(result).toBe("19 1472 1411 1404 1402 1400 1395 1810 1821 1823 1827 1831 1835 1839 1842 1845 1848 1851 1854 1857");
			const end = Date.now();
			done();
		}).catch(function (reason) {
			fail(reason);
		})
	});

	it("should return a correct long path from 501 to 12335", function (done) {
		mapSearch.pathToRoom("501", "12335").then(function (result) {
			expect(result).toBe("106 1472 1411 1404 1402 1400 1394 1382 1379 1038 1035 108032 110074 88845 89206 89204 89202 89200 89198 89196 89194 89192 89190 89188 89182 5413 5074 5072 5069 5067 5079 5190 5318 5315 5312 5308 5291 5296 5298 5301 26244 26241 26239 26237 26235 26233 26231 26229 26227 26225 26223 26220 26218 26216 26214 26212 78481 26208 26205 26203 26201 26199 26197 26194 26192 26184 26174 26172 26163 26158 26146 26144 26132 26122 26120 26110 26108 26096 26094 26081 26079 26076 26062 26057 26044 26042 26030 26028 26018 26013 26004 25994 25992 25989 25987 25985 25966 25968 25970 25972 25974 25977 25980 32155 32158 32167 32169");
			done();
		}).catch(function (reason) {
			fail(reason);
		})
	});
});
