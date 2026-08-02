local target_count = ya.sync(function()
	local tab = cx.active
	if #tab.selected > 0 then
		return #tab.selected
	end
	return tab.current.hovered and 1 or 0
end)

local function notify(level, content)
	ya.notify({
		title = "Finder tags",
		content = content,
		level = level,
		timeout = 5,
	})
end

local function entry(_, job)
	local action = job.args[1]
	if action ~= "add" and action ~= "remove" then
		return notify("error", "Unknown tag action: " .. tostring(action))
	end

	if target_count() == 0 then
		return notify("warn", "No file or directory is selected")
	end

	ya.emit("plugin", { "mactag", action })
end

return { entry = entry }
