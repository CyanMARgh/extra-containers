make_array_view :: inline ($type : Type, data := null, count := 0) -> []type {
	arr : []type = ---;
	arr.data, arr.count = data, count;
	return arr;
}
make_array_view :: inline (data : *$type, count := 0) -> []type {
	arr : []type = ---;
	arr.data, arr.count = data, count;
	return arr;
}
resizeable_array_init :: (src : []$type, allocator := context.allocator) -> [..]type {
	arr : [..]type;
	arr.allocator = context.allocator;
	array_reserve(*arr, src.count);
	memcpy(arr.data, src.data, size_of(type) * src.count);
	arr.count = src.count;
	return arr;
}
resizeable_array_init :: ($type : Type, size : int, value := type.{}, allocator := context.allocator) -> [..]type {
	arr : [..]type;
	arr.allocator = context.allocator;
	array_reserve(*arr, src.count);
	for * arr { <<it = value; }
	return arr;
}