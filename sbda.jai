SBDA :: struct(T : Type, N : s64) {
	buf : [N]T;
	count : s64;
}
operator*[] :: (array : SBDA($T, $N), index : s64) -> *T {
	assert(index >= 0 && index < array.count, "index out of range: %/%", index, array.count);
	return *(array.buf[index]);
}
at :: (array : SBDA($T, $N), index : s64) -> *T {
	assert(index >= 0 && index < array.count, "index out of range: %/%", index, array.count);
	return *(array.buf[index]);
}
array_copy :: (array : SBDA($T, $N)) -> SBDA(T, N) {
	return array;
}
array_view :: (array : SBDA($T, $N), index : s64) -> []T {
	return array_view(array, index, array.count - index);
}
array_view :: (array : SBDA($T, $N), index : s64, count : s64) -> []T {
	assert(index >= 0, "index = %", index);
	assert(count >= 0, "index = %", count);
	if index >= array.count {
		return .[];
	}
	if index + count > array.count {
		count = array.count - index;
	}
	result : []T = ---;
	result.data = array.buf.data + index;
	result.count = count;
	return result;
}
array_free :: (array : SBDA($T, $N)) { }
array_reset :: (array : *SBDA($T, $N)) {
	array.count = 0;
}
array_add :: (array : *SBDA($T, $N), item: T) {
	assert(N > array.count, "SBDA buffer owerflow");
	array.buf[array.count] = item;
	array.count += 1;
}
for_expansion :: (array : SBDA, body : Code, flags : For_Flags) #expand {
	#if flags & .REVERSE {
		for < i : array.count-1..0 {
			#if flags & .POINTER {
				`it := *(array.buf[i]);
			} else {
				`it := array.buf[i];
			}
			`it_index := i;
			#insert(
				remove = #assert(false)
			) body;
		}
	} else {
		for i : 0..array.count-1 {
			#if flags & .POINTER {
				`it := *(array.buf[i]);
			} else {
				`it := array.buf[i];
			}
			`it_index := i;
			#insert(
				remove = #assert(false)
			) body;
		}
	}
}
array_find :: (array : SBDA($T, $N), item : T) -> bool, s64 {
	for array if it == item return true, it_index;
	return false, -1; 
}
array_add_if_unique :: (array: *SBDA($T, $N), item: T) -> bool, s64 {
	found, index := array_find(<<array, item);
	if found return false, index;

	array_add(array, item);
	return true, array.count-1;
}
array_insert_at :: (array: *SBDA($T, $N), item: T, index: int) {
	assert(index >= 0);
	assert(index <= array.count);
	assert(array.count < N);

	array.count += 1;

	i := array.count-1;
	while i > index {
		array.buf[i] = array.buf[i-1];
		i -= 1;
	}

	array.buf[index] = item;
}

array_unordered_remove_by_value :: (using array: *SBDA($T, $N), item: T, $stop_after_first := false) -> s64 {
	removed := 0;
	for i : 0..count-1 {
		if buf[i] == item {
			count -= 1;
			if count {
				buf[i] = buf[count];
			}
			removed += 1;
			#if stop_after_first break;
		}
	}
	return removed;
}

peek :: inline (array : SBDA($T, $N)) -> T {
	return array[array.count-1];
}
peek_pointer :: inline (array : SBDA($T, $N)) -> *T {
	return *(array[array.count-1]);
}
pop :: (array: *SBDA($T, $N)) -> T {
	result := array.buf[array.count-1];
	array.count -= 1;
	return result;
}
