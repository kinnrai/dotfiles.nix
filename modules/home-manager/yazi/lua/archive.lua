local target_count = ya.sync(function()
	local tab = cx.active
	if #tab.selected > 0 then
		return #tab.selected
	end
	return tab.current.hovered and 1 or 0
end)

local function entry()
	if target_count() == 0 then
		return ya.notify({
			title = "Archive",
			content = "No file or directory is selected",
			level = "warn",
			timeout = 5,
		})
	end

	ya.emit("plugin", { "ouch" })
end

return { entry = entry }
