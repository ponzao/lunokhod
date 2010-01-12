require("luarocks.require")

local time_then = os.time()
local function dir_walk(func, path)
    local lfs = require("lfs")
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path .. "/" .. file
            local attr = lfs.attributes(f)
            if attr.mode == "directory" then
                print("Processing: " .. f)
                dir_walk(func, f)
            else
                func(f)
            end
        end
    end
end

local t4s = {}
local words = {}
for filename in coroutine.wrap(dir_walk), coroutine.yield, "./20_newsgroups" do
    for line in io.lines(filename) do
        for word in line:gmatch("%w+") do
            local word = word:lower()
            if word == "t4" then t4s[#t4s + 1] = filename end
            words[word] = words[word] and words[word] + 1 or 1
        end
    end
end

local function hash_to_table(hash)
    local result = {}
    for k, v in pairs(hash) do
        result[#result + 1] = { word = k, count = v }
    end
    return result
end

words = hash_to_table(words)

print('Writing "counts-alphabetical-lua".')
table.sort(words, function(a, b) return a.word < b.word end)
io.output(io.open("counts-alphabetical-lua", "w"))
for _, v in ipairs(words) do
    io.write(v.count .. "\t" .. v.word .. "\n")
end
io.close()

print("Writing \"counts-decreasing-lua\".")
table.sort(words, function(a, b) return a.count > b.count end)
io.output(io.open("counts-decreasing-lua", "w"))
for _, v in ipairs(words) do
    io.write(v.count .. "\t" .. v.word .. "\n")
end
io.close()

print("Execution time was: " .. (os.time() - time_then) .. "s.")

print()
print("t4s")
for i, v in ipairs(t4s) do print(v) end
