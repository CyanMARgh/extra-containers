#import,dir "..";
#import "Basic"()(MEMORY_DEBUGGER=true);

main :: () {
	defer report_memory_leaks();
	{
		arr := resizeable_array_init(int.[1, 2, 3]); defer array_free(arr);
		print("%\n", arr);
		array_add(*arr, 42);
		print("%\n", arr);			
	}
	{
		arr : SBDA(int, 10);
		array_add(*arr, 15);
		array_add(*arr, 10);
		array_add(*arr, 5);
		print("%\n", arr);
		for arr print("[%] ", it);
		print("\n");

		element := 10;
		ok, id := array_find(arr, element);
		print(ifx ok "arr[%1] = %2\n" else "%2 not found\n", id, element);
		assert(!ok || arr[id] == element);

		element = 12;
		ok, id = array_find(arr, element);
		print(ifx ok "arr[%1] = %2\n" else "%2 not found\n", id, element);
		assert(!ok || arr[id] == element);

		array_add_if_unique(*arr, 20);
		array_add_if_unique(*arr, 10);
		print("%\n", arr);

		array_insert_at(*arr, -5, 2);
		array_insert_at(*arr, -5, 1);
		print("%\n", arr);

		// array_unordered_remove_by_value(*arr, -5);
		// print("%\n", arr);
	}
	{
		arr := resizeable_array_init(int.[10, 2, 1, 2, 3, 4, 5]); defer array_free(arr);
		for arr {
			print("(%)", it);
			if it == 2 remove;
			print("+");
		}
		print("%\n", arr);
	}
	{
		arr : SBDA(int, 10);
		for 1..5 array_add(*arr, it);
		print("\n");
		for arr print("%\n", it);
		array_unordered_remove_by_value(*arr, 3);
		print("\n");
		for arr print("%\n", it);
	}
	{
		a := ivec2.{1, 3};
		b := ivec2.{4, 5};
		print("%\n", a + b);

		box : Generic_Box(s32, 2) = .{3, 3, 1, 1};
		box2 := fit_in_center(box, .{1, 1});

		print("%, %\n", box, box2);		
	}
}
