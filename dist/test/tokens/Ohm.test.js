"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var chai_1 = __importDefault(require("chai"));
var chai_as_promised_1 = __importDefault(require("chai-as-promised"));
var hardhat_1 = require("hardhat");
chai_1.default.use(chai_as_promised_1.default);
var expect = chai_1.default.expect;
var types_1 = require("../../types");
describe("OlympusTest", function () {
    var deployer;
    var vault;
    var bob;
    var alice;
    var ohm;
    beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
        var _a;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0: return [4 /*yield*/, hardhat_1.ethers.getSigners()];
                case 1:
                    _a = _b.sent(), deployer = _a[0], vault = _a[1], bob = _a[2], alice = _a[3];
                    return [4 /*yield*/, (new types_1.KlimaToken__factory(deployer)).deploy(deployer.address)];
                case 2:
                    ohm = _b.sent();
                    return [2 /*return*/];
            }
        });
    }); });
    it("correctly constructs an ERC20", function () { return __awaiter(void 0, void 0, void 0, function () {
        var _a, _b, _c;
        return __generator(this, function (_d) {
            switch (_d.label) {
                case 0:
                    _a = expect;
                    return [4 /*yield*/, ohm.name()];
                case 1:
                    _a.apply(void 0, [_d.sent()]).to.equal("Olympus");
                    _b = expect;
                    return [4 /*yield*/, ohm.symbol()];
                case 2:
                    _b.apply(void 0, [_d.sent()]).to.equal("OHM");
                    _c = expect;
                    return [4 /*yield*/, ohm.decimals()];
                case 3:
                    _c.apply(void 0, [_d.sent()]).to.equal(9);
                    return [2 /*return*/];
            }
        });
    }); });
    describe("mint", function () {
        it("must be done by vault", function () { return __awaiter(void 0, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, expect(ohm.connect(deployer).mint(bob.address, 100)).
                            to.be.rejectedWith("UNAUTHORIZED")];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        }); });
        it("increases total supply", function () { return __awaiter(void 0, void 0, void 0, function () {
            var supplyBefore, _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, ohm.totalSupply()];
                    case 1:
                        supplyBefore = _c.sent();
                        return [4 /*yield*/, ohm.connect(vault).mint(bob.address, 100)];
                    case 2:
                        _c.sent();
                        _b = (_a = expect(supplyBefore.add(100)).to).equal;
                        return [4 /*yield*/, ohm.totalSupply()];
                    case 3:
                        _b.apply(_a, [_c.sent()]);
                        return [2 /*return*/];
                }
            });
        }); });
    });
    describe("burn", function () {
        beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, ohm.connect(vault).mint(bob.address, 100)];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        }); });
        it("reduces the total supply", function () { return __awaiter(void 0, void 0, void 0, function () {
            var supplyBefore, _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, ohm.totalSupply()];
                    case 1:
                        supplyBefore = _c.sent();
                        return [4 /*yield*/, ohm.connect(bob).burn(10)];
                    case 2:
                        _c.sent();
                        _b = (_a = expect(supplyBefore.sub(10)).to).equal;
                        return [4 /*yield*/, ohm.totalSupply()];
                    case 3:
                        _b.apply(_a, [_c.sent()]);
                        return [2 /*return*/];
                }
            });
        }); });
        it("cannot exceed total supply", function () { return __awaiter(void 0, void 0, void 0, function () {
            var supply;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, ohm.totalSupply()];
                    case 1:
                        supply = _a.sent();
                        return [4 /*yield*/, expect(ohm.connect(bob).burn(supply.add(1))).
                                to.be.rejectedWith("ERC20: burn amount exceeds balance")];
                    case 2:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        }); });
        it("cannot exceed bob's balance", function () { return __awaiter(void 0, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, ohm.connect(vault).mint(alice.address, 15)];
                    case 1:
                        _a.sent();
                        return [4 /*yield*/, expect(ohm.connect(alice).burn(16)).
                                to.be.rejectedWith("ERC20: burn amount exceeds balance")];
                    case 2:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        }); });
    });
});
