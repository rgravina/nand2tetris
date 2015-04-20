import Foundation
import Quick
import Nimble
import Jack

class AssemblerTest: QuickSpec {
  override func spec() {
    describe("the symbol table") {
      pending("should contain a map of predefined symbols") {

      }
      pending("should add a symbol/label to the symbol table") {

      }
      pending("should return the address of an exisitng symbol") {

      }
      pending("should hamdle unknown symbols") {

      }
    }

    describe("an assembly command") {
      it("should get the type correctly") {
        var asm = AssemblyCommand(command: "@2")
        expect(asm.type).to(equal(AssemblyCommandType.Address))
        asm = AssemblyCommand(command: "D=A")
        expect(asm.type).to(equal(AssemblyCommandType.Computation))
        asm = AssemblyCommand(command: "(SOME_LABEL)")
        expect(asm.type).to(equal(AssemblyCommandType.Label))
      }

      it("should parse an address command") {
        var asm = AssemblyCommand(command: "@2")
        expect(asm.type).to(equal(AssemblyCommandType.Address))
        expect(asm.address).to(equal("2"))
      }
    }

    describe("the code mapper") {
    }
  }
}
