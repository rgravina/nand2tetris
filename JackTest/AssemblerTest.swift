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

      it("should parse a computation command") {
        // dest=comp;jump, comp;jump, dest=comp
        var asm = AssemblyCommand(command: "dest=comp;jump")
        expect(asm.type).to(equal(AssemblyCommandType.Computation))
        expect(asm.dest).to(equal("dest"))
        expect(asm.comp).to(equal("comp"))
        expect(asm.jump).to(equal("jump"))
        asm = AssemblyCommand(command: "dest=comp")
        expect(asm.type).to(equal(AssemblyCommandType.Computation))
        expect(asm.dest).to(equal("dest"))
        expect(asm.comp).to(equal("comp"))
        expect(asm.jump).to(beNil())
        asm = AssemblyCommand(command: "comp;jump")
        expect(asm.type).to(equal(AssemblyCommandType.Computation))
        expect(asm.dest).to(beNil())
        expect(asm.comp).to(equal("comp"))
        expect(asm.jump).to(equal("jump"))
      }
    }

    describe("the code mapper") {
    }
  }
}
