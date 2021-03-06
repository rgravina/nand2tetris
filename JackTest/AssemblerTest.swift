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
        expect(asm.type).to(equal(AssemblyCommandType.address))
        asm = AssemblyCommand(command: "D=A")
        expect(asm.type).to(equal(AssemblyCommandType.computation))
        asm = AssemblyCommand(command: "(SOME_LABEL)")
        expect(asm.type).to(equal(AssemblyCommandType.label))
      }

      it("should parse an address command") {
        var asm = AssemblyCommand(command: "@2")
        expect(asm.type).to(equal(AssemblyCommandType.address))
        expect(asm.address).to(equal("2"))
      }

      it("should parse a computation command") {
        // dest=comp;jump, comp;jump, dest=comp
        var asm = AssemblyCommand(command: "AM=M-1;JNE")
        expect(asm.type).to(equal(AssemblyCommandType.computation))
        expect(asm.dest).to(equal("AM"))
        expect(asm.comp).to(equal("M-1"))
        expect(asm.jump).to(equal("JNE"))
        asm = AssemblyCommand(command: "D=M")
        expect(asm.type).to(equal(AssemblyCommandType.computation))
        expect(asm.dest).to(equal("D"))
        expect(asm.comp).to(equal("M"))
        expect(asm.jump).to(beNil())
        asm = AssemblyCommand(command: "D;JNE")
        expect(asm.type).to(equal(AssemblyCommandType.computation))
        expect(asm.dest).to(beNil())
        expect(asm.comp).to(equal("D"))
        expect(asm.jump).to(equal("JNE"))
      }
    }

    describe("the code mapper") {
      it("should convert simple integer addresses to binary form instrunctions") {
        var asm = AssemblyCommand(command: "@2")
        expect(asm.machineCode).to(equal("0000000000000010"))
        asm = AssemblyCommand(command: "@3")
        expect(asm.machineCode).to(equal("0000000000000011"))
      }
    }

    describe("the symbol table") {
      it("should get a predefined symbol address") {
        var st = AssemblerSymbolTable()
        expect(st.get("R10")).to(equal(10))
      }
      it("should return nil if getting a symbol which doesn't exist") {
        var st = AssemblerSymbolTable()
        expect(st.get("HELLO")).to(beNil())
      }
      it("should add new symbols while incrementing the address it stores them at") {
        var st = AssemblerSymbolTable()
        expect(st.add("a")).to(equal(16))
        expect(st.add("b")).to(equal(17))
      }
    }
}
}
