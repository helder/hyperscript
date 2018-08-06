import tink.unit.*;
import tink.unit.Assert.*;
import tink.testrunner.*;
import deepequal.DeepEqual;

class RunTests {
  static function main() {
    Runner.run(TestBatch.make([
      new TestComponent()
    ])).handle(Runner.exit);
  }
}
