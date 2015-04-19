import Foundation
import Quick
import Nimble
import Jack

class JackTests: QuickSpec {
  override func spec() {
    describe("a VM command") {
      it("should parse a valid push command") {
        let vmc = VirtualMachineCommand(command: "push constant 1")
        expect(vmc.description).to(equal("push constant 1"))
        expect(vmc.type).to(equal(VirtualMachineCommandType.Push))
        expect(vmc.arg1).to(equal("constant"))
        expect(vmc.arg2).to(equal("1"))
      }
    }
  }
}
