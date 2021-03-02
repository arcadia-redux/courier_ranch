function math.random_point_inside_circle(origin, radius, min_length)
	local dist = math.random((min_length or 0), radius)
	local angle = math.random(0, math.pi * 2)

	local x_offset = dist * math.cos(angle)
	local y_offset = dist * math.sin(angle)

	return origin + Vector(x_offset, y_offset, 0)
end
