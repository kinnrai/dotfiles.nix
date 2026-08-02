local hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if not h then
		return nil
	end

	return {
		path = tostring(h.url),
		parent = tostring(h.url.parent),
		name = h.name,
		is_dir = h.cha.is_dir,
	}
end)

local function notify(level, content)
	ya.notify({
		title = "Copy content",
		content = content,
		level = level,
		timeout = 5,
	})
end

local function capture(command)
	local output, err = command:output()
	if output and output.status.success then
		return output.stdout
	end

	local message = err and tostring(err) or output and output.stderr or "Command failed"
	if message == "" then
		message = "Command failed"
	end
	return nil, message
end

local function copy(command)
	local content, err = capture(command)
	if not content then
		return false, err
	end

	local ok, clipboard_err = pcall(ya.clipboard, content)
	if not ok then
		return false, tostring(clipboard_err)
	end
	return true
end

local function copy_file(path)
	return copy(Command("cat"):arg(path))
end

local function copy_tree(parent, name, depth)
	return copy(Command("eza"):cwd(parent):arg({
		"--tree",
		"--level=" .. tostring(depth),
		"--all",
		"--color=never",
		"--icons=never",
		"--group-directories-first",
		"--no-quotes",
		"--ignore-glob=.git|.DS_Store",
		"--",
		name,
	}))
end

local function entry()
	local target = hovered()
	if not target then
		return notify("warn", "No file or directory is hovered")
	end

	if not target.is_dir then
		local ok, err = copy_file(target.path)
		if ok then
			return notify("info", "Copied contents of " .. target.name)
		end
		return notify("error", err)
	end

	local value, event = ya.input({
		pos = { "top-center", y = 3, w = 42 },
		title = "Tree depth (1-20):",
		value = "3",
	})
	if event ~= 1 then
		return
	end

	local depth = tonumber(value)
	if not depth or depth % 1 ~= 0 or depth < 1 or depth > 20 then
		return notify("error", "Depth must be an integer from 1 to 20")
	end

	local ok, err = copy_tree(target.parent, target.name, depth)
	if ok then
		return notify("info", string.format("Copied %s tree (depth %d)", target.name, depth))
	end
	notify("error", err)
end

return { entry = entry }
