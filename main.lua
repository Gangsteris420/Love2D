-- required to work
local Slab = require 'Slab'
local ShowMenu = false
local timer = false
local timeElapsed = 0

-- global vars
local InputName
local InputOwnerName 
local InputAge
local Selected = ""
local Selected2 = ""

-- tables
local pet_objects = {}
local options = {}
local heights = {100, 150, 200, 250, 350}

-- error/success output tracking
local inputs = {
	PetName = "Invalid",
	PetType = "Invalid",
	PetAge = "Invalid",
	PetGender = "Invalid",
	OwnerName = "Invalid",
}

-- for validation check
local alphabet_letters = {
    "a", "b", "c", "d", "e", "f", "g",
    "h", "i", "j", "k", "l", "m", "n",
    "o", "p", "q", "r", "s", "t", "u",
    "v", "w", "x", "y", "z"
}

function love.load(args)
	math.randomseed(os.time())
	love.filesystem.remove("Slab.ini")
	Slab.Initialize(args, {"NoDocks"})
	love.window.setMode(288, 96, { resizable = false })
end

-- IM SO LAZY TO PUT EVERYTHING INTO SEPERATE FUNCTIONS OMD, OMG, OML
function love.update(dt)
	Slab.Update(dt)
	local screen_w, screen_h = love.graphics.getDimensions()
	-- Calculate center or some padding
	local slab_x = 3
	local slab_y = 4
	local slab_w = screen_w - 2 * slab_x
	local slab_h = screen_h - 2 * slab_y
  
	if ShowMenu == false then
		Slab.BeginWindow('shelter', { Title = "Welcome to Pet Shelter!", Y = slab_y, X = slab_x, W = slab_w, H = slab_h, AutoSizeWindow = true, AllowResize = false, AutoSizeContent = false, AllowMove = false})
		Slab.Text("What would you like to do?", { Pad = 90 })

		Slab.Text("1.", {Pad = 35})
		Slab.SameLine()
		x, y = Slab.GetCursorPos()
		Slab.SetCursorPos(x + 15, y)
		if Slab.Button("Show All Pets", {W = 150}) then
			local counter = 0
			for _, _ in pairs(pet_objects) do
				counter = counter + 1
			end

			height_ = heights[counter]

			if counter > 5 then
				height_ = 350
			end
			
			if counter > 0 then
				love.window.setMode(1000, height_, { resizable = false })
				ShowPets = true
			elseif counter <= 0 then
				height_ = 50
				love.window.setMode(1000, height_, { resizable = false })
				ShowPets = true
			end

		end

		Slab.Text("2.", {Pad = 35})
		Slab.SameLine()
		x, y = Slab.GetCursorPos()
		Slab.SetCursorPos(x + 15, y)
		if Slab.Button("Admit New Pet", {W = 150}) then
			love.window.setMode(350, 160, { resizable = false })
			AdmitPet = true
		end

		Slab.EndWindow()
	end

	if ShowPets then
		ShowMenu = true
		local counter = 0
		for _, _ in pairs(pet_objects) do
			counter = counter + 1
		end

		local height = heights[counter]

		if counter > 5 then
			height = 350
		end

		local winW, winH = love.graphics.getDimensions()
		local leftW = winW * 0.99
		local rightW = winW - leftW
		local height = winH * 0.95

		Slab.BeginWindow('shelter_pets', {
			Title = "Pet Dashboard",
			X = 0, Y = 0,
			W = leftW, H = height,
			AutoSizeWindow = false,
			AllowResize = false,
			AllowMove = false
		})

		for _, pet in pairs(pet_objects) do

			Slab.Text("Pet Owner ID: " .. pet.id, {Pad = 15})
			Slab.SameLine()
			Slab.Text("Pet Owner Name: " .. pet.owner, {Pad = 15})
			Slab.SameLine()
			Slab.Text("Name of pet: " .. pet.name, {Pad = 15})
			Slab.SameLine()
			Slab.Text("Pet Type: " .. pet.type, {Pad = 15})
			Slab.SameLine()
			Slab.Text("Pet Age (months): " .. pet.age, {Pad = 15})
			Slab.SameLine()
			Slab.Text("Pet Gender: " .. pet.gender, {Pad = 15})
			Slab.SameLine()

			if pet.canFeed == false then 
				pet.timer = pet.timer + dt

				if pet.timer >= 25 then
					pet.canFeed = true
					pet.timer = 0
					--love.window.showMessageBox("Success!", "Pet can be fed again." .. pet.id .. "", "info", true)
				end
			end

			if pet.canPlay == false then
				pet.play = pet.play + dt

				if pet.play >= 30 then
					pet.canPlay = true
					pet.play = 0
				end
			end

			if Slab.Button("Feed the pet", {W = 150}) then
				if pet.canFeed then
					pet.canFeed = false
					love.window.showMessageBox("Success!", "Pet was fed.", "info", true)
				else
					love.window.showMessageBox("Wait", "Pet can't be fed.", "info", true)
				end
			end

			Slab.SameLine()

			if Slab.Button("Let pet to its owner", {W = 150}) then
				ShowPets = false
				ShowLetGo = true
				love.window.setMode(288, 96, { resizable = false })
			end

			Slab.SameLine()
			
			if Slab.Button("Play with pet", {W = 150}) then
				if pet.canPlay then
					local chance = math.random(1, 100)

					if chance > 50 then
						love.window.showMessageBox("Success!", "Pet is very happy because you just pet him!.", "info", true)
					elseif chance < 50 and chance > 20 then
						love.window.showMessageBox("Success!", "Pet is angry, but he let you to pet him.", "info", true)
					elseif chance <= 20 then
						love.window.showMessageBox("Success!", "Pet has bit you!.", "info", true)
						pet.canPlay = false
					end
				else
					love.window.showMessageBox("Wait!", "Pet is tired, wait sometime.", "info", true)
				end
			end
		end

		if Slab.Button("Go Back", {W = 150}) then
			ShowMenu = false
			ShowPets = false
			love.window.setMode(288, 96, { resizable = false })
		end

		Slab.EndWindow()
	end

	if ShowLetGo then
		Slab.BeginWindow('let_go', { Title = "Input the owner ID the owner has given", Y = slab_y, X = slab_x, W = slab_w, H = slab_h, AutoSizeWindow = true, AllowResize = false, AutoSizeContent = false, AllowMove = false})

		Slab.Text("Owner ID: ", {Pad = 35})
		Slab.SameLine()

		x, y = Slab.GetCursorPos()
		Slab.SetCursorPos(x + 15, y)

		if Slab.Input('ID', {Text = tostring(InputID), ReturnOnText = false, NumbersOnly = true}) then
			InputID = Slab.GetInputNumber()
		end

		if Slab.Button("OK", {W = 100}) then
			for i, pet in pairs(pet_objects) do
				if pet.id == InputID then
					table.remove(pet_objects, i)
					love.window.showMessageBox("Success!", "Pet has been let go to its owner", "info", true)

					ShowLetGo = false
					ShowPets = true
					love.window.setMode(1000, height_, { resizable = false })

					break
				end
			end
		end

		if Slab.Button("Go Back", {W = 100}) then
			ShowLetGo = false
			ShowPets = true
			love.window.setMode(1000, height_, { resizable = false })
		end

		Slab.EndWindow()
	end

	if AdmitPet then
		ShowMenu = true

		local winW, winH = love.graphics.getDimensions()

		local marginLeft = 0
		local admitW = 400
		local admitX = marginLeft -- start 20 px from the left edge
		local height = math.floor(winH * 0.95)

		Slab.BeginWindow('shelter_admit', {
			Title = "Admit Pet",
			X = admitX,
			Y = 0,
			W = admitW,
			H = height,
			AutoSizeWindow = false,
			AutoSizeContent = false,
			AllowResize = false,
			AllowMove = false
		})

		Slab.Text("1. Name of pet: ", {Pad = 35})
		Slab.SameLine()

		x, y = Slab.GetCursorPos()
		Slab.SetCursorPos(x + 15, y)

		options = {Text = InputName}
		if Slab.Input('pet_name', options) then
			InputName = Slab.GetInputText()

			if InputName and inputs.PetName == "Invalid" then
				inputs.PetName = InputName
			end
		end

		Slab.Text("2. type of pet: ", {Pad = 35})
		Slab.SameLine()
		x, y = Slab.GetCursorPos()
		Slab.SetCursorPos(x + 25, y)
		local Types = {"Dog", "Cat", "Other"}

		if Slab.BeginComboBox('PetType', {Selected = Selected}) then
			for _, V in ipairs(Types) do
				if Slab.TextSelectable(V) then
					Selected = V
					inputs.PetType = "Valid"
				end
			end

			Slab.EndComboBox()
		end

		Slab.Text("3. Age (months): ", {Pad = 35})
		Slab.SameLine()
		x, y = Slab.GetCursorPos()
		Slab.SetCursorPos(x + 5, y)
		
		-- Set the initial options
		options = {Text = tostring(InputAge), ReturnOnText = false, NumbersOnly = true, MinNumber = 0, MaxNumber = 20, Tooltip = "Double-Click to edit!", SelectOnFocus = false, AllowMove = false}

		-- Update Text value when input is focused
		if Slab.IsInputFocused('pet_age') then

			options.Tooltip = "1 to 20 only"  -- Modify the text when focused

			if timer == false then
				timer = os.time()
			end

			if timer ~= false then
				if os.time() - timer >= 6 then
					options.Tooltip = ""
				end
	
				-- if user is taking too long inputting, remind again
				if os.time() - timer >= 30 then
					timer = false
				end
			end
		else
			timer = false
			options.Tooltip = "Double-Click to edit!"
		end
		
		-- Input field handling
		if Slab.Input('pet_age', options) then
			InputAge = Slab.GetInputNumber()

			if InputAge > 0 then 
				inputs.PetAge = "Valid"
			end
		end

		-- what if player has focused his mouse but is not hovering the actual input field
		if Slab.IsInputFocused('pet_age') and not Slab.IsControlHovered() then
			timer = false
		end

		Slab.Text("4. Gender: ", {Pad = 35})
		Slab.SameLine()
		local Genders = {"Male", "Female"}

		x, y = Slab.GetCursorPos()
		Slab.SetCursorPos(x + 48, y)
		if Slab.BeginComboBox('MyComboBox', {Selected = Selected2}) then
			for I, V in ipairs(Genders) do
				if Slab.TextSelectable(V) then
					Selected2 = V
					inputs.PetGender = "Valid"
				end
			end

			Slab.EndComboBox()
		end

		Slab.Text("5. Owner Name: ", {Pad = 35})
		Slab.SameLine()
		x, y = Slab.GetCursorPos()
		Slab.SetCursorPos(x + 8, y)

		options = {Text = InputOwnerName}
		if Slab.Input('owner_name', options) then
			InputOwnerName = Slab.GetInputText()

			if InputOwnerName and inputs.OwnerName == "Invalid" then
				inputs.OwnerName = InputOwnerName
			end
		end


		if Slab.Button("Go Back", {W = 150}) then
			ShowMenu = false
			AdmitPet = false
			love.window.setMode(288, 96, { resizable = false })
		end
		Slab.SameLine()
		local CanCreate = true

		if Slab.Button("Admit Pet", {W = 150}) then

			if InputName == nil or InputName == "" then
				inputs.PetName = "Invalid"
			end

			if InputOwnerName == nil or InputOwnerName == "" then
				inputs.OwnerName = "Invalid"
			end

			for k,v in pairs(inputs) do
				if v == "Invalid" then
					love.window.showMessageBox("Incorrect input!", k, "info", true)

					if CanCreate then
						CanCreate = false
					end
				end
			end

			if CanCreate then

				counter = 0
				length_of_name = string.len(InputName)
				length_of_owner = string.len(InputOwnerName)

				for char in InputName:gmatch '.' do
					capital_char = string.upper(char)

					for _, v in pairs(alphabet_letters) do
						capital_v = string.upper(v)

						if capital_char == capital_v then
							counter = counter + 1
						end
					end
				end

				if length_of_name > 20 then
					love.window.showMessageBox("Info!", "Your pet name is too long. Allowed length of characters in a name is: 20, Your length: " .. length_of_name .. "", "info", true)
					InputName = string.sub(InputName, 1, 20)
				end

				if length_of_owner > 20 then
					love.window.showMessageBox("Info!", "Your name is too long. Allowed length of characters in a name is: 20, Your length: " .. length_of_owner .. "", "info", true)
					InputOwnerName = string.sub(InputOwnerName, 1, 20)
				end

				if counter == length_of_name and length_of_name <= 20 and length_of_owner <= 20 then
					love.window.showMessageBox("Success!", "Valid Name", "info", true)

					-- AI START --
					local first_char = string.sub(InputName, 1, 1)
					local rest = string.sub(InputName, 2)
					InputName = string.upper(first_char) .. string.lower(rest)
					-- AI END --

					-- AI START --
					local f_char = string.sub(InputOwnerName, 1, 1)
					local r = string.sub(InputOwnerName, 2)
					InputOwnerName = string.upper(f_char) .. string.lower(r)
					-- AI END --

					-- debug -- love.window.showMessageBox("Success!", "" .. InputName .. "", "info", true) -- debug -- 

					local pet_module = require("module")
					local created_pet = pet_module.new(Selected, InputName, InputAge, Selected2, InputOwnerName)
					created_pet:GenerateID(pet_objects)

					--love.window.showMessageBox("test", "" .. #pet_objects .. "", "info", true)

					-- might have to switch on when they being reset because values need to be sent to a module.lua
					Selected = ""
					Selected2 = ""
					InputName = ""
					InputOwnerName = ""
					InputAge = 0
					-- might have to switch on when they being reset because values need to be sent to a module.lua

					for input, _ in pairs(inputs) do
						inputs[input] = "Invalid" 	
					end
				else
					love.window.showMessageBox("Fail!", "Invalid Name", "info", true)
				end

				-- need to create module.lua and then call the module and do OOP shit there
			end
		end

		Slab.EndWindow()
	end
end

function love.draw()
	Slab.Draw()
end