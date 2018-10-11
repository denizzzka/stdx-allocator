///
module stdx.allocator.building_blocks.null_allocator;

/**
$(D NullAllocator) is an emphatically empty implementation of the allocator
interface. Although it has no direct use, it is useful as a "terminator" in
composite allocators.
*/
struct NullAllocator
{
    import stdx.allocator.internal : Ternary;
    /**
    $(D NullAllocator) advertises a relatively large _alignment equal to 64 KB.
    This is because $(D NullAllocator) never actually needs to honor this
    alignment and because composite allocators using $(D NullAllocator)
    shouldn't be unnecessarily constrained.
    */
    enum uint alignment = 64 * 1024;
    // /// Returns $(D n).
    //size_t goodAllocSize(size_t n) shared const
    //{ return .goodAllocSize(this, n); }
    /// Always returns $(D null).
    static void[] allocate(size_t) { return null; }
    /// Always returns $(D null).
    static void[] alignedAllocate(size_t, uint) { return null; }
    /// Always returns $(D null).
    static void[] allocateAll() { return null; }
    /**
    These methods return $(D false).
    Precondition: $(D b is null). This is because there is no other possible
    legitimate input.
    */
    static bool expand(ref void[] b, size_t s)
    { assert(b is null); return s == 0; }
    /// Ditto
    static bool reallocate(ref void[] b, size_t)
    { assert(b is null); return false; }
    /// Ditto
    static bool alignedReallocate(ref void[] b, size_t, uint)
    { assert(b is null); return false; }
    /// Returns $(D Ternary.no).
    static Ternary owns(void[]) { return Ternary.no; }
    /**
    Returns $(D Ternary.no).
    */
    static Ternary resolveInternalPointer(const void*, ref void[])
    { return Ternary.no; }
    /**
    No-op.
    Precondition: $(D b is null)
    */
    static bool deallocate(void[] b) { assert(b is null); return true; }
    /**
    No-op.
    */
    static bool deallocateAll() { return true; }
    /**
    Returns $(D Ternary.yes).
    */
    static Ternary empty() { return Ternary.yes; }
    /**
    static Returns the $(D static) global instance of the $(D NullAllocator).
    */
    enum NullAllocator instance = NullAllocator();
}

@system unittest
{
    assert(NullAllocator.instance.alignedAllocate(100, 0) is null);
    assert(NullAllocator.instance.allocateAll() is null);
    auto b = NullAllocator.instance.allocate(100);
    assert(b is null);
    assert(NullAllocator.instance.expand(b, 0));
    assert(!NullAllocator.instance.expand(b, 42));
    assert(!NullAllocator.instance.reallocate(b, 42));
    assert(!NullAllocator.instance.alignedReallocate(b, 42, 0));
    NullAllocator.instance.deallocate(b);
    NullAllocator.instance.deallocateAll();

    import stdx.allocator.internal : Ternary;
    assert(NullAllocator.instance.empty() == Ternary.yes);
    assert(NullAllocator.instance.owns(null) == Ternary.no);
    void[] p;
    assert(NullAllocator.instance.resolveInternalPointer(null, p) == Ternary.no);
}
