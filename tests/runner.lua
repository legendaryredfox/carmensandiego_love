-- Set package path so modules resolve from project root.
local script_dir = debug.getinfo(1, "S").source:match("^@(.+/)")
local root = script_dir and script_dir:gsub("/tests/$", "") or "."
package.path = root .. "/?.lua;" .. root .. "/?/init.lua;" .. package.path

local passed, failed, errors = 0, 0, {}

-- Exported helpers — test files call these as globals.
function assert_eq(a, b, msg)
    if a ~= b then
        error((msg or "assert_eq failed") ..
            "\n    expected: " .. tostring(b) ..
            "\n    got:      " .. tostring(a), 2)
    end
end

function assert_near(a, b, tol, msg)
    if math.abs(a - b) > tol then
        error((msg or "assert_near failed") ..
            "\n    expected: " .. tostring(b) .. " ± " .. tostring(tol) ..
            "\n    got:      " .. tostring(a), 2)
    end
end

function assert_true(v, msg)
    if not v then
        error((msg or "assert_true failed") .. "\n    got: " .. tostring(v), 2)
    end
end

function assert_false(v, msg)
    if v then
        error((msg or "assert_false failed") .. "\n    got: " .. tostring(v), 2)
    end
end

function assert_nil(v, msg)
    if v ~= nil then
        error((msg or "assert_nil failed") .. "\n    got: " .. tostring(v), 2)
    end
end

function assert_not_nil(v, msg)
    if v == nil then
        error((msg or "assert_not_nil failed: got nil"), 2)
    end
end

local current_suite = ""

function describe(name, fn)
    current_suite = name
    fn()
    current_suite = ""
end

function it(name, fn)
    local label = current_suite ~= "" and (current_suite .. " > " .. name) or name
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        print("  PASS  " .. label)
    else
        failed = failed + 1
        table.insert(errors, { label = label, err = err })
        print("  FAIL  " .. label)
        print("        " .. tostring(err):gsub("\n", "\n        "))
    end
end

-- Test file list — add new test files here.
local test_files = {
    "tests/locale_test",
    "tests/city_test",
    "tests/suspect_test",
    "tests/mission_test",
    "tests/clue_pool_test",
    "tests/venue_name_test",
    "tests/detective_test",
    "tests/map_test",
    "tests/save_test",
    "tests/settings_test",
    "tests/ui_test",
}

local sep = string.rep("=", 60)
print(sep)
print("Running tests")
print(sep)

for _, path in ipairs(test_files) do
    print("\n--- " .. path)
    local ok, err = pcall(require, path)
    if not ok then
        failed = failed + 1
        local msg = "ERROR loading " .. path .. ": " .. tostring(err)
        table.insert(errors, { label = path, err = msg })
        print("  ERROR " .. msg)
    end
end

print("\n" .. sep)
print(string.format("Results: %d passed, %d failed", passed, failed))

if #errors > 0 then
    print("\nFailed tests:")
    for _, e in ipairs(errors) do
        print("  - " .. e.label)
    end
end

print(sep)
os.exit(failed > 0 and 1 or 0)
