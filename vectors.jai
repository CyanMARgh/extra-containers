Generic_Vector :: struct(type : Type, N : int) {
	#assert N > 1;
	#if N < 5 {
		x, y : type;
		#if N > 2 {
			z : type;
			#place x; xy : Generic_Vector(type, 2);
			#place y; yz : Generic_Vector(type, 2);
			#place x; r : type;
			#place y; g : type;
			#place z; b : type;
		}
		#if N > 3 {
			w : type;
			#place z; zw : Generic_Vector(type, 2);
			#place x; xyz : Generic_Vector(type, 3);
			#place y; yzw : Generic_Vector(type, 3);
			#place w; a : type;
		}
		#place x;
	}
	values : [N]type;
}
generic_vector_binary_proc_vv :: (v1 : Generic_Vector($type, $N), v2 : Generic_Vector(type, N), proc : (s1 : type, s2 : type) -> (type)) -> Generic_Vector(type, N) {
	result : Generic_Vector(type, N) = ---;
	for i : 0..N-1 result.values[i] = proc(v1.values[i], v2.values[i]);
	return result;
}
generic_vector_binary_proc_vs :: (v : Generic_Vector($type, $N), s : type, proc : (s1 : type, s2 : type) -> (type)) -> Generic_Vector(type, N) {
	result : Generic_Vector(type, N) = ---;
	for i : 0..N-1 result.values[i] = proc(v.values[i], s);
	return result;
}
generic_vector_binary_proc_sv :: (s : type, v : Generic_Vector($type, $N), proc : (s1 : type, s2 : type) -> (type)) -> Generic_Vector(type, N) {
	result : Generic_Vector(type, N) = ---;
	for i : 0..N-1 result.values[i] = proc(s, v.values[i]);
	return result;
}
generic_vector_unary_proc :: (v : Generic_Vector($type, $N), proc : (s : type) -> (type)) -> Generic_Vector(type, N) {
	result : Generic_Vector(type, N) = ---;
	for i : 0..N-1 result.values[i] = proc(v.values[i]);
	return result;
}

operator- :: #bake_arguments generic_vector_unary_proc(proc = (s) => -s);

operator+ :: #bake_arguments generic_vector_binary_proc_vv(proc = (s1, s2) => s1 + s2);
operator- :: #bake_arguments generic_vector_binary_proc_vv(proc = (s1, s2) => s1 - s2);
operator/ :: #bake_arguments generic_vector_binary_proc_vv(proc = (s1, s2) => s1 / s2);
operator* :: #bake_arguments generic_vector_binary_proc_vv(proc = (s1, s2) => s1 * s2);

operator+ :: #bake_arguments generic_vector_binary_proc_sv(proc = (s1, s2) => s1 + s2);
operator- :: #bake_arguments generic_vector_binary_proc_sv(proc = (s1, s2) => s1 - s2);
operator/ :: #bake_arguments generic_vector_binary_proc_sv(proc = (s1, s2) => s1 / s2);
operator* :: #bake_arguments generic_vector_binary_proc_sv(proc = (s1, s2) => s1 * s2);

operator+ :: #bake_arguments generic_vector_binary_proc_vs(proc = (s1, s2) => s1 + s2);
operator- :: #bake_arguments generic_vector_binary_proc_vs(proc = (s1, s2) => s1 - s2);
operator/ :: #bake_arguments generic_vector_binary_proc_vs(proc = (s1, s2) => s1 / s2);
operator* :: #bake_arguments generic_vector_binary_proc_vs(proc = (s1, s2) => s1 * s2);

operator== :: (v1 : Generic_Vector($type, $N), v2 : Generic_Vector(type, N)) -> bool {
	for i : 0..N-1 {
		if v1.values[i] != v2.values[i] return false;
	}
	return true;
}

//                                          affects only on naming
Generic_Box :: struct(type : Type, N : int, left_handed := false) {
	#assert N > 1;
	#if N <= 3 {
		width, height : type;
		#if N == 3 { length : type; }

		#if left_handed { right : type; } else { left : type; }
		top : type;
		#if N == 3 { front : type; }
		#place width;
	}
	size, corner : Generic_Vector(type, N);
}
operator== :: (a : Generic_Box($type, $N, $left_handed), b : Generic_Box(type, N, left_handed)) -> bool {
	return a.size == b.size && a.corner == b.corner;
}
is_empty :: (box : Generic_Box) -> bool {
	return box.size == .{0, 0};
}
is_invalid :: (box : Generic_Box) -> bool {
	return box.width < 0 || box.height < 0;
}
point_inside_zone :: (point : Generic_Vector($type, $N), zone : Generic_Box(type, N)) -> bool {
	for i : 0..N-1 {
		p, l, w := point.values[i], zone.corner.values[i], zone.size.values[i];
		if p < l return false;
		if p >= l + w return false;
	}
	return true;
}
point_inside_zone :: (point : Generic_Vector($type, $N), zone : Generic_Vector(type, N)) -> bool {
	for i : 0..N-1 {
		p, l := point.values[i], zone.values[i];
		if p < 0 return false;
		if p >= l return false;
	}
	return true;
}
zone_inside_zone :: (inner : Generic_Box($type, $N, $left_handed), outer : Generic_Box(type, N, left_handed)) -> bool {
	for i : 0..N-1 {
		c0 := inner.corner.values[i];
		c1 := outer.corner.values[i];

		s0 := inner.size.values[i];
		s1 := outer.size.values[i];

		if c0 < c1 return false;
		if c0 + s0 > c1 + s1 return false;
	}
	return true;
}
zone_inside_zone :: (inner : Generic_Box($type, $N, $left_handed), outer : Generic_Vector(type, N)) -> bool {
	return zone_inside_zone(inner, Generic_Box(type, N, left_handed).{size = outer});
}
zone_inside_zone :: (inner : Generic_Vector($type, $N), outer : Generic_Vector(type, N)) -> bool {
	for i : 0..N-1 {
		if inner.values[i] > outer.values[i] return false;
	}
	return true;
}
cut_border :: (box : Generic_Box($type, $N, $left_handed), gap : type) -> Generic_Box(type, N, left_handed) {
	result : Generic_Box(type, N, left_handed) = ---;
	for i : 0..N-1 {
		result.corner.values[i] = box.corner.values[i] + gap;
		result.size.values[i] = box.size.values[i] - gap * 2;
	}
	return result;
}
fit_in_center :: (zone : Generic_Box($type, $N, $left_handed), box_size : Generic_Vector(type, N)) -> Generic_Box(type, N, left_handed), fit:bool {
	return .{size = box_size, corner = zone.corner + (zone.size - zone.corner) / 2}, zone_inside_zone(box_size, zone.size);
}
intersection :: (box1 : Generic_Box($type, $N, $left_handed), box2 : Generic_Box(type, N, left_handed)) -> Ibox2 {
	result : Generic_Box(type, N, left_handed) = ---;
	for i : 0..N-1 {
		l1, w1 := box1.corner.values[i], box1.size.values[i];
		l2, w2 := box2.corner.values[i], box2.size.values[i];
		result.corner.values[i] = max(l1, l2);
		result.size.values[i] = min(l1 + w1, l2 + w2) - result.corner.values[i];
	}
	return result;
}

intersects :: (box1 : Generic_Box($type, $N, $left_handed), box2 : Generic_Box(type, N, left_handed)) -> bool {
	for i : 0..N-1 {
		l1, w1 := box1.corner.values[i], box1.size.values[i];
		l2, w2 := box2.corner.values[i], box2.size.values[i];
		if max(l1, l2) >= min(l1 + w1, l2 + w2) return false;
	}
	return true;
}

cast_vec :: ($type_out : Type, in : Generic_Vector($type_in, $N)) -> Generic_Vector(type_out, N) {
	result : Generic_Vector(type_out, N) = ---;
	for i : 0..N-1 {
		result.values[i] = xx in.values[i];
	}
	return result;
}

fract :: (x : float) -> float { return x - floor(x); }
fract :: (using v : Vector2) -> Vector2 { return .{fract(x), fract(y)}; }
fract :: (using v : Vector3) -> Vector3 { return .{fract(x), fract(y), fract(z)}; }
fract :: (using v : Vector4) -> Vector4 { return .{fract(x), fract(y), fract(z), fract(w)}; }

floor :: (v : Vector2) -> Vector2 { return .{floor(v.x), floor(v.y)}; }
floor :: (v : Vector3) -> Vector3 { return .{floor(v.x), floor(v.y), floor(v.z)}; }
floor :: (v : Vector4) -> Vector4 { return .{floor(v.x), floor(v.y), floor(v.z), floor(v.w)}; }

mix :: (x : float, y : float, m : float) -> float { return x + (y - x) * m; } 
mix :: (x : Vector2, y : Vector2, m : float) -> Vector2 { return .{mix(x.x, y.x, m), mix(x.y, y.y, m)}; } 
mix :: (x : Vector3, y : Vector3, m : float) -> Vector3 { return .{mix(x.x, y.x, m), mix(x.y, y.y, m), mix(x.z, y.z, m)}; } 
mix :: (x : Vector4, y : Vector4, m : float) -> Vector4 { return .{mix(x.x, y.x, m), mix(x.y, y.y, m), mix(x.z, y.z, m), mix(x.w, y.w, m)}; } 

mix :: (x : Vector2, y : Vector2, m : Vector2) -> Vector2 { return .{mix(x.x, y.x, m.x), mix(x.y, y.y, m.y)}; } 
mix :: (x : Vector3, y : Vector3, m : Vector3) -> Vector3 { return .{mix(x.x, y.x, m.x), mix(x.y, y.y, m.y), mix(x.z, y.z, m.z)}; } 
mix :: (x : Vector4, y : Vector4, m : Vector4) -> Vector4 { return .{mix(x.x, y.x, m.x), mix(x.y, y.y, m.y), mix(x.z, y.z, m.z), mix(x.w, y.w, m.z)}; } 

clamp :: (a : Vector2, mi : float, ma : float) -> Vector2 { return .{clamp(a.x, mi, ma), clamp(a.y, mi, ma)}; }
clamp :: (a : Vector3, mi : float, ma : float) -> Vector3 { return .{clamp(a.x, mi, ma), clamp(a.y, mi, ma), clamp(a.z, mi, ma)}; }
clamp :: (a : Vector4, mi : float, ma : float) -> Vector4 { return .{clamp(a.x, mi, ma), clamp(a.y, mi, ma), clamp(a.z, mi, ma), clamp(a.w, mi, ma)}; }


sin :: (v : Vector2) -> Vector2 { return .{sin(v.x), sin(v.y)}; }
sin :: (v : Vector3) -> Vector3 { return .{sin(v.x), sin(v.y), sin(v.z)}; }
sin :: (v : Vector4) -> Vector4 { return .{sin(v.x), sin(v.y), sin(v.z), sin(v.w)}; }

hash22 :: (_p : Vector2, seed := Vector2.{}) -> Vector2 {
	p := multiply(Matrix2.{127.1, 311.7, 269.5, 183.3}, _p);
	p = Vector2.{-1., -1.} + 2. * fract(sin(p) * 43758.545);
	return sin(p * 6.283 + seed * Vector2.{124.1, 8123.1});
}

perlin_level :: (p : Vector2) -> float {
	pi := floor(p);
	pf := p - pi;
	w := pf * pf * (Vector2.{3., 3.} - Vector2.{2., 2.} * pf);

	f00 := dot(hash22(pi + Vector2.{0., 0.}), pf - Vector2.{0., 0.});
	f01 := dot(hash22(pi + Vector2.{0., 1.}), pf - Vector2.{0., 1.});
	f10 := dot(hash22(pi + Vector2.{1., 0.}), pf - Vector2.{1., 0.});
	f11 := dot(hash22(pi + Vector2.{1., 1.}), pf - Vector2.{1., 1.});

	return mix(mix(f00, f10, w.x), mix(f01, f11, w.x), w.y);   
}
perlin :: (_p : Vector2) -> float {
	p := _p;
	M1 :: 4;
	a, r, s := 1., 0., 0.;
	for i : 0..M1 - 1 {
		r += a * perlin_level(p);
		s += a;
		p *= 2.;
		a *= .5;
	}
	return r / s;
}

hsv2rgb :: (c : Vector3) -> Vector3 {
	K := Vector4.{1, 2. / 3, 1. / 3, 3};
	p := abs(fract(Vector3.{c.x, c.x, c.x} + K.xyz) * 6.0 - Vector3.{K.w, K.w, K.w});
	return c.z * mix(Vector3.{K.x, K.x, K.x}, clamp(p - Vector3.{K.x, K.x, K.x}, 0, 1), c.y);
}


ivec2 :: Generic_Vector(s32, 2);
ivec3 :: Generic_Vector(s32, 3);
u8vec3 :: Generic_Vector(u8, 3);
Ibox2 :: Generic_Box(s32, 2, false);
