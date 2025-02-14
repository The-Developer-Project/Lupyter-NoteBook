local toolbar = plugin:CreateToolbar("Lupyter Notebook")  -- Create a toolbar for the plugin
local button = toolbar:CreateButton("Open Notebook", "Open the custom notebook", "rbxassetid://87052362812494")  -- Button to open notebook
local h = nil;

local function createNotebookUI()
	-- Check if the DockWidgetPluginGui already exists
	if h then
		-- If it exists, just make it visible and bring it to the front
		h.Enabled = true
		--existingDockWidget.Parent = plugin
		return  -- Exit the function to prevent creating a new one
	end

	-- Create the DockWidgetPluginGui
	local dockWidget = plugin:CreateDockWidgetPluginGui("Notebook", DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float, -- Initial docking state (floating)
		true,  -- Initially visible
		true,  -- Allow the user to resize
		400,   -- Width of the plugin window
		600    -- Height of the plugin window
		))

	-- Set the title for the docked window
	dockWidget.Title = "Lupyter Notebook"
	dockWidget.Name = "Notebook"
	h = dockWidget

	-- Frame containing the TextBox and TextLabel
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.Parent = dockWidget

	-- ScrollingFrame for output
	local outputFrame = Instance.new("ScrollingFrame")
	outputFrame.Size = UDim2.new(1, 0, 0.8, 0)
	outputFrame.Position = UDim2.new(0, 0, 0, 0)
	outputFrame.CanvasSize = UDim2.new(0, 0, 10, 0)  -- Allow for vertical scrolling
	outputFrame.ScrollBarThickness = 8
	outputFrame.Parent = frame

	-- ScrollingFrame for input (TextBox)
	local inputFrame = Instance.new("Frame")
	inputFrame.Size = UDim2.new(1, 0, 0.2, 0)
	inputFrame.Position = UDim2.new(0, 0, 0.8, 0)
	inputFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	inputFrame.Parent = frame

	-- Create TextBox for user input
	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, -10, 1, -10)
	textBox.Position = UDim2.new(0, 5, 0, 5)
	textBox.ClearTextOnFocus = false
	textBox.PlaceholderText = "Enter your code here..."
	textBox.Text = ""
	textBox.PlaceholderColor3 = Color3.fromHex("#646464")
	textBox.TextSize = 15
	textBox.Parent = inputFrame

	-- Create the submit button
	local submitButton = Instance.new("TextButton")
	submitButton.Size = UDim2.new(0, 100, 0, 40)
	submitButton.Position = UDim2.new(0.5, -50, 0, 5)  -- Adjusted position of the button to avoid overlap
	submitButton.Text = "Execute"
	submitButton.Parent = inputFrame

	-- Make sure the ScrollingFrame has a UIListLayout
	local listLayout = outputFrame:FindFirstChildOfClass("UIListLayout")
	if not listLayout then
		listLayout = Instance.new("UIListLayout")
		listLayout.Parent = outputFrame
	end
	
	local env = {
		output = {},  -- Table to capture print outputs
		game = game,
		script = script,
		workspace = workspace,

		-- Standard Libraries
		math = math,
		string = string,
		table = table,
		coroutine = coroutine,
		os = os,  -- Limited in Roblox
		utf8 = utf8,
		bit32 = bit32,
		time = time,
		warn = warn,
		wait = wait,

		-- Utility Functions
		ipairs = ipairs,
		pairs = pairs,
		next = next,
		select = select,
		tonumber = tonumber,
		tostring = tostring,
		assert = assert,
		error = error,
		pcall = pcall,
		xpcall = xpcall,
		rawequal = rawequal,
		rawget = rawget,
		rawset = rawset,
		setmetatable = setmetatable,
		getmetatable = getmetatable,
		loadstring = loadstring,
		setfenv = setfenv,
		getfenv = getfenv,

		-- Roblox-Specific Functions
		require = require,
		tick = tick,
		task = task,
		settings = settings,
		spawn = spawn,
		shared = shared,
		SharedTable = SharedTable,
		SecurityCapabilities = SecurityCapabilities,
		Secret = Secret,

		-- Roblox Data Types
		Axes = Axes,
		BrickColor = BrickColor,
		CFrame = CFrame,
		Color3 = Color3,
		ColorSequence = ColorSequence,
		ColorSequenceKeypoint = ColorSequenceKeypoint,
		DateTime = DateTime,
		DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo,
		Enum = Enum,
		Faces = Faces,
		Instance = Instance,
		NumberRange = NumberRange,
		NumberSequence = NumberSequence,
		NumberSequenceKeypoint = NumberSequenceKeypoint,
		PathWaypoint = PathWaypoint,
		PhysicalProperties = PhysicalProperties,
		Random = Random,
		Ray = Ray,
		Rect = Rect,
		Region3 = Region3,
		Region3int16 = Region3int16,
		TweenInfo = TweenInfo,
		UDim = UDim,
		UDim2 = UDim2,
		Vector2 = Vector2,
		Vector2int16 = Vector2int16,
		Vector3 = Vector3,
		Vector3int16 = Vector3int16,
	}
	
	env.print = function(...)
		-- Capture printed output and store it in the output table
		local outputText = table.concat({...}, " ")
		table.insert(env.output, outputText)
	end
	
	env.clear = function()
		for i, v in pairs(outputFrame:GetDescendants()) do
			if v:IsA("TextLabel") then
				v:Destroy()
			end
		end
	end
	
	

	-- Function to run user input code safely and display output
	local function executeCode(code)
		local result = ""
		local success, errorMessage = pcall(function()
			-- Execute the user code safely using loadstring
			local func, err = loadstring(code)
			if func then
				setfenv(func, env)
				env.output = {}
				
				func()
				result = table.concat(env.output, "\n")-- Run the user code
			else
				result = "Error: " .. err  -- If the code has an error, show the error message
			end
		end)

		if not success then
			result = "Execution Error: " .. errorMessage  -- In case of any other errors
		end

		-- Add the result to the output frame
		local newOutput = Instance.new("TextLabel")
		newOutput.Size = UDim2.new(1, 0, 0, 30)  -- Set the size for each new label
		newOutput.Text = code.." > "..tostring(result)
		newOutput.Parent = outputFrame
		newOutput.TextWrapped = true  -- Allow the text to wrap
		newOutput.BackgroundTransparency = 1  -- Transparent background
		newOutput.TextColor3 = Color3.fromRGB(0, 0, 0)  -- Black text
		newOutput.TextSize = 20

		-- Set text alignment to top-left
		newOutput.TextXAlignment = Enum.TextXAlignment.Left
		newOutput.TextYAlignment = Enum.TextYAlignment.Top

		-- Ensure the ScrollingFrame scrolls to the bottom after new output is added
		-- outputFrame.CanvasPosition = Vector2.new(0, newOutput.Position.Y.Offset)
	end
	
	local function submit()
		local userCode = textBox.Text:gsub("^local%s+", "")
		textBox.Text = ""  -- Clear input after submitting

		-- Execute the user code and display the result
		executeCode(userCode)
	end
	-- Handle the submission of code
	submitButton.MouseButton1Click:Connect(submit)
	
	textBox.FocusLost:Connect(function(e)
		if e then
			submit()
		end
	end)
end

-- When the plugin button is clicked, create the notebook UI
button.Click:Connect(createNotebookUI)  -- Correct event here (.Click)
