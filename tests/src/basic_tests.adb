pragma Ada_2012;

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Interfaces; use Interfaces;
with RefCnt;

package body Basic_Tests is
   package Caller is new AUnit.Test_Caller (Fixture);

   Test_Suite : aliased AUnit.Test_Suites.Test_Suite;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Name : constant String := "[RefCnt - Basic] ";
   begin
      Test_Suite.Add_Test
        (Caller.Create (Name & "basic usage", Basic_Usage_Test'Access));

      return Test_Suite'Access;
   end Suite;

   procedure Basic_Usage_Test (Object : in out Fixture) is
      package Integer_RefCnt is new RefCnt (Integer);
      use Integer_RefCnt;

      A : Reference := Create (42);
   begin
      Assert (A.Use_Count = 1, "one reference on initialization");
      Assert (A.Get = 42, "check value after Create()");
      Assert
        (A = 42, "check value after Create(), using convenient `=` overload");

      declare
         Copy : constant Reference := A;
      begin
         Assert (A = Copy, "they are equal");

         Assert (Copy.Use_Count = 2, "two references after copy");
         Assert (A.Use_Count = 2, "two references after copy");
         Assert (Copy.Get = 42, "check value after copy");
         Assert (A.Get = 42, "check value after copy");

         A.Get := 69;
         Assert (A = Copy, "they are still equal");
         Assert (Copy.Get = 69, "modifying one, modifies the other");
         Assert (A.Get = 69, "modifying one, modifies the other");
      end;

      Assert
        (A.Use_Count = 1, "reference count back to 1 after exiting the scope");
      Assert (A = 69, "value still the same");

      declare
         Copy : constant Reference := A;
      begin
         Assert (Copy.Use_Count = 2, "two references after copy");
         Assert (A.Use_Count = 2, "two references after copy");
         Assert (Copy = 69, "check value after copy");
         Assert (A = 69, "check value after copy");

         A.Replace (420);

         Assert (A /= Copy, "they are not equal now");
         Assert (Copy.Use_Count = 1, "only one reference left");
         Assert (A.Use_Count = 1, "initialized with one reference");
         Assert (Copy = 69, "check value in one");
         Assert (A = 420, "check value in the other");

         A.Get := 1_337;
         Assert (Copy = 69, "they are now independent from one another");
         Assert (A = 1_337, "they are independent now");
      end;
   end Basic_Usage_Test;
end Basic_Tests;
