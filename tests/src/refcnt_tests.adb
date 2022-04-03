with AUnit.Reporter.Text;
with AUnit.Run;
with AUnit.Test_Suites;

with Basic_Tests;

procedure RefCnt_Tests is
   function Suite return AUnit.Test_Suites.Access_Test_Suite;

   procedure Runner is new AUnit.Run.Test_Runner (Suite);

   Reporter : AUnit.Reporter.Text.Text_Reporter;

   Test_Suite : aliased AUnit.Test_Suites.Test_Suite;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   begin
      Test_Suite.Add_Test (Basic_Tests.Suite);

      return Test_Suite'Unchecked_Access;
   end Suite;
begin
   Reporter.Set_Use_ANSI_Colors (True);
   Runner (Reporter);
end RefCnt_Tests;
