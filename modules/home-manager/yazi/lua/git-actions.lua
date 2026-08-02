local cwd = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

local function notify(level, content)
	ya.notify({
		title = "Git",
		content = content,
		level = level,
		timeout = 5,
	})
end

local function output_error(output, err)
	if err then
		return tostring(err)
	end

	local message = output and (output.stderr ~= "" and output.stderr or output.stdout) or "Command failed"
	message = message:gsub("%s+$", "")
	return message ~= "" and message or "Command failed"
end

local function repo_root(current)
	local output, err = Command("git")
		:cwd(current)
		:arg({ "rev-parse", "--show-toplevel" })
		:output()

	if not output or not output.status.success then
		notify("warn", "Not inside a Git repository\n" .. output_error(output, err))
		return nil
	end

	-- Git terminates the path with a newline. Remove only that terminator so a
	-- repository whose name legitimately ends in whitespace remains intact.
	local root = output.stdout:gsub("\r\n$", ""):gsub("\n$", "")
	if root == "" then
		notify("error", "Git returned an empty repository root")
		return nil
	end
	return root
end

local function browse(root)
	local output, err = Command("gh"):cwd(root):arg("browse"):output()
	if not output or not output.status.success then
		notify("error", "Failed to open the repository\n" .. output_error(output, err))
	end
end

local function entry(_, job)
	local current = cwd()
	local root = repo_root(current)
	if not root then
		return
	end

	local action = job.args[1]
	if action == "browse" then
		browse(root)
	elseif action == "root" then
		if current == root then
			notify("info", "Already at the repository root")
		else
			ya.emit("cd", { Url(root) })
		end
	else
		notify("error", "Unknown Git action: " .. tostring(action))
	end
end

return { entry = entry }
