with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

package Basic_Tests is
   function Suite return AUnit.Test_Suites.Access_Test_Suite;
private
   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Basic_Usage_Test (Object : in out Fixture);
end Basic_Tests;
