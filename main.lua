require("luarocks.require")
require("pl")

local time_then = os.time()

local function dir_walk(func, fullpath)
    for root, _, files in dir.walk(fullpath) do
        for _, f in ipairs(files) do
            func(path.join(root, f))
        end
    end
end

local words = {}
for filename in coroutine.wrap(dir_walk), coroutine.yield, arg[1] do
    for line in io.lines(filename) do
        for word in line:gmatch("[%w_]+") do
            local word = word:lower()
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

