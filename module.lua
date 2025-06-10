-- Declare the classes early as empty tables
Dog = {}     -- Class definition (Encapsulation)
Cat = {}     -- Class definition (Encapsulation)
Other = {}   -- Class definition (Encapsulation)

-- Define Animal first (Base class)
Animal = {}  -- Base class (Encapsulation)
Animal.__index = Animal

-- Lookup table for class types
local Classes = {
    Dog = Dog,
    Cat = Cat,
}

-- Constructor for any animal type (Factory pattern)
function Animal.new(type_, name_, age_, gender_, owner_)
    local Class = Classes[type_]
    -- Inheritance: sets metatable to specific class (Dog, Cat, Other)
    local self = setmetatable({}, Class or Other)  -- Inheritance in action

    -- Encapsulation: storing data inside object
    self.name = name_
    self.age = age_
    self.gender = gender_
    self.owner = owner_
    --
    self.canPlay = true
    self.canFeed = true
    --
    self.id = 0
    self.timer = 0
    self.play = 0

    -- Polymorphism: returns object based on type (Dog.new, Cat.new...)
    if Class then
        return Class.new(self)  -- Polymorphic behavior
    else
        return Other.new(self)
    end
end

-- Shared method across all animals (Encapsulation + Inheritance)
function Animal:GenerateID(pet_objects)
    local new_id

    repeat
        new_id = math.random(100000, 999999)
        local exists = false

        for _, pet in pairs(pet_objects) do
            if pet.id == new_id then
                exists = true
                break
            end
        end
    until not exists

    self.id = new_id

    table.insert(pet_objects, self)
    love.window.showMessageBox(
        "Animal Admitted",
        "The staff has successfully submitted a new animal.\n\n" ..
        "Owner Name: " .. self.owner .. "\n" ..
        "Owner ID: " .. self.id .. "\n\n" ..
        "Please provide this ID to the owner and remind them to keep it safe.",
        "info",
        true
    )

    return self
end

-- Subclass: Dog
Dog.__index = Dog
setmetatable(Dog, Animal)  -- Inheritance: Dog inherits from Animal

function Dog.new(self)
    self.type = "Dog"
    return self
end

-- Subclass: Cat
Cat.__index = Cat
setmetatable(Cat, Animal)  -- Inheritance

function Cat.new(self)
    self.type = "Cat"
    return self
end

-- Subclass: Other
Other.__index = Other
setmetatable(Other, Animal)  -- Inheritance

function Other.new(self)
    self.type = "Other"
    return self
end

return Animal
