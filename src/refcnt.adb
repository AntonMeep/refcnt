pragma Ada_2012;

with Ada.Unchecked_Deallocation;

with Atomic.Unsigned_32; use Atomic.Unsigned_32;

package body RefCnt is
   function Clone (This : Reference'Class) return Reference is
     (if This.Payload = null then Null_Reference
      else Create (This.Payload.all.Element.all));

   function Create (Element : Element_Type) return Reference is
      Result : Reference := Null_Reference;
   begin
      Replace (Result, Element);
      return Result;
   end Create;

   procedure Replace (This : in out Reference'Class; Element : Element_Type) is
   begin
      Finalize (This);
      This.Payload :=
        new Payload_Type'
          (Count   => Atomic.Unsigned_32.Init (1),
           Element => new Element_Type'(Element));
   end Replace;

   function Get (This : Reference'Class) return Accessor is
     (Element => This.Payload.all.Element);

   function "="
     (Left : Reference'Class; Right : Element_Type) return Boolean is
     (Left.Payload /= null and then Left.Payload.all.Element /= null
      and then Left.Payload.all.Element.all = Right);

   function "=" (Left, Right : Reference'Class) return Boolean is
     (Left.Payload = Right.Payload);

   function Use_Count (This : Reference'Class) return Interfaces.Unsigned_32 is
   begin
      if This.Payload = null then
         return 0;
      else
         return Load (This.Payload.all.Count);
      end if;
   end Use_Count;

   overriding procedure Adjust (This : in out Reference) is
   begin
      if This.Payload /= null then
         Add (This.Payload.all.Count, 1);
      end if;
   end Adjust;

   overriding procedure Finalize (This : in out Reference) is
      use Interfaces;

      procedure Deallocate is new Ada.Unchecked_Deallocation
        (Payload_Type, Payload_Type_Access);
      procedure Deallocate is new Ada.Unchecked_Deallocation
        (Element_Type, Element_Type_Access);

      New_Count : Unsigned_32 := 0;
   begin
      if This.Payload /= null then
         Sub_Fetch (This.Payload.all.Count, 1, New_Count);
         if New_Count = 0 then
            if This.Payload.all.Element /= null then
               Free (This.Payload.all.Element.all);
               Deallocate (This.Payload.all.Element);
               This.Payload.all.Element := null;
            end if;
            Deallocate (This.Payload);
            This.Payload := null;
         end if;
      end if;
   end Finalize;
end RefCnt;
