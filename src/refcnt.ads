with Ada.Finalization;

with Atomic.Unsigned_32;
with Interfaces;

generic
   type Element_Type (<>) is private;

   with procedure Free (This : in out Element_Type) is null;
package RefCnt is
   type Reference is tagged private;

   Null_Reference : constant Reference;

   type Accessor (Element : not null access Element_Type)
   is limited null record with
      Implicit_Dereference => Element;

   function Create (Element : Element_Type) return Reference;

   procedure Replace (This : in out Reference'Class; Element : Element_Type);

   function Get (This : Reference'Class) return Accessor;

   function "=" (Left : Reference'Class; Right : Element_Type) return Boolean;

   function "=" (Left, Right : Reference'Class) return Boolean;

   function Use_Count (This : Reference'Class) return Interfaces.Unsigned_32;
private
   type Element_Type_Access is access Element_Type;

   type Payload_Type is limited record
      Count   : aliased Atomic.Unsigned_32.Instance;
      Element : Element_Type_Access := null;
   end record;

   type Payload_Type_Access is access Payload_Type;

   type Reference is new Ada.Finalization.Controlled with record
      Payload : Payload_Type_Access := null;
   end record;

   overriding procedure Adjust (This : in out Reference);
   overriding procedure Finalize (This : in out Reference);

   Null_Reference : constant Reference :=
     (Ada.Finalization.Controlled with Payload => null);
end RefCnt;
